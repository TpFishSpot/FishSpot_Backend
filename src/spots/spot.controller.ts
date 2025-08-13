import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  Get,
  Param,
  BadRequestException,
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

@Controller('spot')
export class SpotController {
  constructor(private readonly spotService: SpotService) {}

  @Get()
  findAll() {
    return this.spotService.findAll();
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
  async crearSpot(@UploadedFile() imagen: Express.Multer.File, @Body() rawBody: any) {

    if (typeof rawBody.ubicacion === 'string') {
      try {
        rawBody.ubicacion = JSON.parse(rawBody.ubicacion);
      } catch {
        throw new BadRequestException('ubicacion debe ser un JSON válido');
      }
    }

    const spotDto = plainToInstance(SpotDto, rawBody);

 
    const errors = await validate(spotDto);
    if (errors.length > 0) {
      throw new BadRequestException(errors);
    }

    const imagenPath = imagen ? `uploads/${imagen.filename}` : undefined;

    return this.spotService.agregarSpot(spotDto, imagenPath);
  }
  
  @Get('/:id/especies')
  async findAllEspecies(@Param('id') id: string): Promise<EspecieConNombreComun[]> {
    return await this.spotService.findAllEspecies(id);
  }
}
