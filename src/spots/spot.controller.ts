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

@Controller('spot')
export class SpotController {
  constructor(private readonly spotService: SpotService) {}

  @Get()
  findAll() {
    return this.spotService.findAll();
  }
  @Get("/esperando")
  async esperando(): Promise<Spot[]>{
    return this.spotService.esperando();
  }

  @Get("/aceptados")
  async aceptados(): Promise<Spot[]>{
    return this.spotService.aceptados();
  }

  @Get(':id')
  async find(@Param('id') id: string): Promise<Spot> {
    return this.spotService.find(id);
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

  @Get('/:id/especies')
  async findAllEspecies(@Param('id') id: string): Promise<EspecieConNombreComun[]> {
    return this.spotService.findAllEspecies(id);
  }

  @Get('/:id/tipoPesca')
  async findAllTipoPesca(@Param('id') id: string): Promise<SpotTipoPesca[]> {
    return this.spotService.findAllTipoPesca(id);
  }

  @Get(':id/carnadas')
  async getCarnadasByEspecies(@Param('id') idSpot: string): Promise<Record<string, Carnada[]>> {
    return this.spotService.findCarnadasByEspecies(idSpot);
  }

  @Patch(":id/aprobar")
  // @Roles("moderador")
  async aprobar(@Param("id") id: string): Promise<Spot> {
    return this.spotService.aprobar(id);
  }
  @Patch(":id/rechazar")
  // @Roles("moderador")
  async rechazar(@Param("id") id: string): Promise<Spot> {
    return this.spotService.rechazar(id);
  }

}
