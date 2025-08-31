import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  Get,
  Param,
  BadRequestException,
  Patch,
  Req,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { v4 as uuidv4 } from 'uuid';
import { SpotService } from './spot.service';
import { SpotDto } from 'src/dto/SpotDto';
import { Spot } from 'src/models/Spot';
import { extname } from 'path';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { SpotTipoPesca } from 'src/models/SpotTipoPesca';
import { Carnada } from 'src/models/Carnada';
import { Roles, Public } from 'src/auth/decorator';
import { RequestWithUser } from 'src/auth/interfaces/auth.interface';
import { UserRole } from 'src/auth/enums/roles.enum';

@Controller('spot')
export class SpotController {
  constructor(private readonly spotService: SpotService) {}

  @Get()
  @Public()
  findAll(): Promise<Spot[]> {
    return this.spotService.findAll();
  }

  @Get('esperando')
  @Roles(UserRole.MODERATOR)
  esperando(): Promise<Spot[]> {
    return this.spotService.esperando();
  }

  @Get(':id')
  @Public()
  find(@Param('id') id: string): Promise<Spot> {
    return this.spotService.find(id);
  }

  @Get('/:id/especies')
  @Public()
  findAllEspecies(@Param('id') id: string): Promise<EspecieConNombreComun[]> {
    return this.spotService.findAllEspecies(id);
  }

  @Get('/:id/tipoPesca')
  @Public()
  findAllTipoPesca(@Param('id') id: string): Promise<SpotTipoPesca[]> {
    return this.spotService.findAllTipoPesca(id);
  }

  @Get(':id/carnadas')
  @Public()
  getCarnadasByEspecies(@Param('id') idSpot: string): Promise<Record<string, Carnada[]>> {
    return this.spotService.findCarnadasByEspecies(idSpot);
  }

  @Post()
  @UseInterceptors(
    FileInterceptor('imagen', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const uniqueName = uuidv4() + extname(file.originalname);
          cb(null, uniqueName);
        },
      }),
    }),
  )
  async crearSpot(
    @UploadedFile() imagen: Express.Multer.File,
    @Body() rawBody: any,
    @Req() request: RequestWithUser,
  ) {
    if (typeof rawBody.ubicacion === 'string') {
      try {
        rawBody.ubicacion = JSON.parse(rawBody.ubicacion);
      } catch {
        throw new BadRequestException('ubicacion debe ser un JSON válido');
      }
    }
    if (typeof rawBody.especies === 'string') rawBody.especies = JSON.parse(rawBody.especies);
    if (typeof rawBody.tiposPesca === 'string') rawBody.tiposPesca = JSON.parse(rawBody.tiposPesca);
    if (typeof rawBody.carnadas === 'string') rawBody.carnadas = JSON.parse(rawBody.carnadas);

    rawBody.idUsuario = request.user.uid;
    rawBody.idUsuarioActualizo = request.user.uid;

    const spotDto = plainToInstance(SpotDto, rawBody);
    const errors = await validate(spotDto);
    if (errors.length > 0) throw new BadRequestException(errors);

    const imagenPath = imagen ? `uploads/${imagen.filename}` : undefined;

    return this.spotService.agregarSpot(
      spotDto,
      imagenPath,
      rawBody.especies || [],
      rawBody.tiposPesca || [],
      rawBody.carnadas || [],
    );
  }

  @Patch(':id/aprobar')
  @Roles(UserRole.MODERATOR)
  aprobar(@Param('id') id: string): Promise<Spot> {
    return this.spotService.aprobar(id);
  }

  @Patch(':id/rechazar')
  @Roles(UserRole.MODERATOR)
  rechazar(@Param('id') id: string): Promise<Spot> {
    return this.spotService.rechazar(id);
  }
}
