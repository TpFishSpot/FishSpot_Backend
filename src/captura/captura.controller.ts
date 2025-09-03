import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  Get,
  Param,
  BadRequestException,
  Put,
  Delete,
  Query,
  Req,
  ForbiddenException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { v4 as uuidv4 } from 'uuid';
import { CapturaService } from './captura.service';
import { CapturaDto } from 'src/dto/CapturaDto';
import { Captura } from 'src/models/Captura';
import { extname } from 'path';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { Roles, Public } from 'src/auth/decorator';
import { RequestWithUser } from 'src/auth/interfaces/auth.interface';
import { UserRole } from 'src/auth/enums/roles.enum';

const imageUploadConfig = {
  storage: diskStorage({
    destination: './uploads',
    filename: (req, file, cb) => {
      const uniqueSuffix = uuidv4();
      cb(null, `${uniqueSuffix}${extname(file.originalname)}`);
    },
  }),
  fileFilter: (req, file, cb) => {
    if (file.mimetype.match(/\/(jpg|jpeg|png|gif)$/)) {
      cb(null, true);
    } else {
      cb(new BadRequestException('Solo se permiten archivos de imagen'), false);
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 },
};

@Controller('capturas')
export class CapturaController {
  constructor(private readonly capturaService: CapturaService) {}

  @Get()
  @Public()
  async findAll(
    @Query('usuario') usuario?: string, 
    @Query('especie') especie?: string
  ): Promise<Captura[]> {
    if (usuario) return this.capturaService.findByUsuario(usuario);
    if (especie) return this.capturaService.findByEspecie(especie);
    return this.capturaService.findAll();
  }

  @Get('mis-capturas')
  @Roles(UserRole.USER, UserRole.MODERATOR)
  async getMyCapturas(@Req() req: RequestWithUser): Promise<Captura[]> {
    return this.capturaService.findByUsuario(req.user.uid);
  }

  @Get('mis-estadisticas')
  @Roles(UserRole.USER, UserRole.MODERATOR)
  async getMyStatistics(@Req() req: RequestWithUser): Promise<any> {
    const userId = req.user.uid;
    const capturas = await this.capturaService.findByUsuario(userId);
    
    return {
      totalCapturas: capturas.length,
      especiesCapturadas: [...new Set(capturas.map(c => c.especieId))].length,
      capturasPorMes: this.groupCapturesByMonth(capturas),
    };
  }

  @Get(':id')
  @Public()
  async findOne(@Param('id') id: string): Promise<Captura> {
    return this.capturaService.findOne(id);
  }

  @Post()
  @Roles(UserRole.USER, UserRole.MODERATOR)
  @UseInterceptors(FileInterceptor('foto', imageUploadConfig))
  async create(
    @Body() rawBody: any,
    @Req() req: RequestWithUser,
    @UploadedFile() foto?: Express.Multer.File,
  ): Promise<Captura> {
    try {
      if (rawBody.peso) rawBody.peso = parseFloat(rawBody.peso);
      if (rawBody.longitud) rawBody.longitud = parseFloat(rawBody.longitud);

      const capturaDto = plainToInstance(CapturaDto, rawBody);
      const errors = await validate(capturaDto);

      if (errors.length > 0) {
        throw new BadRequestException('Datos de captura inválidos');
      }

      const imagenPath = foto ? `uploads/${foto.filename}` : undefined;
      return this.capturaService.create(capturaDto, req.user.uid, imagenPath);
    } catch (error) {
      throw new BadRequestException('Error creando captura: ' + error.message);
    }
  }

  @Put(':id')
  @Roles(UserRole.USER, UserRole.MODERATOR)
  @UseInterceptors(FileInterceptor('foto', imageUploadConfig))
  async update(
    @Param('id') id: string,
    @Body() rawBody: any,
    @Req() req: RequestWithUser,
    @UploadedFile() foto?: Express.Multer.File,
  ): Promise<Captura> {
    try {
      const existingCaptura = await this.capturaService.findOne(id);
      if (existingCaptura.idUsuario !== req.user.uid) {
        throw new ForbiddenException('No tienes permisos para editar esta captura');
      }

      if (rawBody.peso) rawBody.peso = parseFloat(rawBody.peso);
      if (rawBody.longitud) rawBody.longitud = parseFloat(rawBody.longitud);

      const capturaDto = plainToInstance(CapturaDto, rawBody);
      const errors = await validate(capturaDto);

      if (errors.length > 0) {
        throw new BadRequestException('Datos de captura inválidos');
      }

      const imagenPath = foto ? `uploads/${foto.filename}` : undefined;
      return this.capturaService.update(id, capturaDto, imagenPath);
    } catch (error) {
      if (error instanceof ForbiddenException) throw error;
      throw new BadRequestException('Error actualizando captura: ' + error.message);
    }
  }

  @Delete(':id')
  @Roles(UserRole.USER, UserRole.MODERATOR)
  async delete(@Param('id') id: string, @Req() req: RequestWithUser): Promise<void> {
    const existingCaptura = await this.capturaService.findOne(id);
    if (existingCaptura.idUsuario !== req.user.uid) {
      throw new ForbiddenException('No tienes permisos para eliminar esta captura');
    }

    return this.capturaService.delete(id);
  }

  private groupCapturesByMonth(capturas: Captura[]): Record<string, number> {
    return capturas.reduce((acc, captura) => {
      const fecha = new Date(captura.fecha);
      const mesAño = `${fecha.getFullYear()}-${(fecha.getMonth() + 1).toString().padStart(2, '0')}`;
      acc[mesAño] = (acc[mesAño] || 0) + 1;
      return acc;
    }, {});
  }
}
