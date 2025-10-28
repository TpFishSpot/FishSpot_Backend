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

  @Get('spot/:spotId/destacadas')
  @Public()
  async getCapturasDestacadas(@Param('spotId') spotId: string): Promise<Captura[]> {
    return this.capturaService.findCapturasDestacadasBySpot(spotId);
  }

  @Get('estadisticas/globales')
  @Public()
  async getEstadisticasGlobales(): Promise<any> {
    return this.capturaService.obtenerEstadisticasGlobales();
  }

  @Get('heatmap')
  @Public()
  async getHeatmap(
    @Query('especie') especieId?: string,
    @Query('mes') mes?: string,
  ): Promise<any> {
    const mesNumero = mes ? parseInt(mes) : undefined;
    return this.capturaService.obtenerHeatmap(especieId, mesNumero);
  }

  @Get('spot/:spotId/estadisticas')
  @Public()
  async getEstadisticasSpot(@Param('spotId') spotId: string): Promise<any> {
    const allCapturas = await this.capturaService.findAll();
    const capturas = allCapturas.filter(c => c.spotId === spotId);

    if (capturas.length === 0) {
      return {
        spotId,
        estadisticas: {
          totalCapturas: 0,
          especiesUnicas: 0,
          especiesDetalle: [],
          capturasPorMes: {},
          carnadasMasUsadas: [],
          tiposPescaMasUsados: [],
          mejoresHorarios: {
            madrugada: 0,
            mañana: 0,
            tarde: 0,
            noche: 0,
          },
          climasRegistrados: {},
        }
      };
    }

    const tiposPescaMap = capturas.reduce((acc, captura) => {
      const tipo = captura.tipoPesca;
      acc[tipo] = (acc[tipo] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const tiposPescaMasUsados = Object.entries(tiposPescaMap)
      .map(([nombre, cantidad]) => ({ nombre, cantidad }))
      .sort((a, b) => b.cantidad - a.cantidad);

    const carnadasMap = capturas.reduce((acc, captura) => {
      if (captura.carnada) {
        acc[captura.carnada] = (acc[captura.carnada] || 0) + 1;
      }
      return acc;
    }, {} as Record<string, number>);

    const carnadasMasUsadas = Object.entries(carnadasMap)
      .map(([nombre, cantidad]) => ({ nombre, cantidad }))
      .sort((a, b) => b.cantidad - a.cantidad)
      .slice(0, 5);

    const getHorario = (hora: string | undefined) => {
      if (!hora) return 'mañana';
      const h = parseInt(hora.split(':')[0]);
      if (h >= 0 && h < 6) return 'madrugada';
      if (h >= 6 && h < 12) return 'mañana';
      if (h >= 12 && h < 18) return 'tarde';
      return 'noche';
    };

    const mejoresHorarios = capturas.reduce((acc, captura) => {
      const horario = getHorario(captura.horaCaptura);
      acc[horario]++;
      return acc;
    }, { madrugada: 0, mañana: 0, tarde: 0, noche: 0 });

    const climasRegistrados = capturas.reduce((acc, captura) => {
      if (captura.clima) {
        acc[captura.clima] = (acc[captura.clima] || 0) + 1;
      }
      return acc;
    }, {} as Record<string, number>);

    const especiesIds = [...new Set(capturas.map(c => c.especieId))];
    const especiesInfoMap = await this.capturaService.obtenerDetalleEspecies(especiesIds);

    const especiesStatsMap = new Map<string, any>();
    capturas.forEach(captura => {
      if (!especiesStatsMap.has(captura.especieId)) {
        const especieInfo = especiesInfoMap.get(captura.especieId);
        especiesStatsMap.set(captura.especieId, {
          especieId: captura.especieId,
          nombreCientifico: especieInfo?.nombreCientifico || captura.especieId,
          nombresComunes: especieInfo?.nombresComunes?.length > 0 
            ? especieInfo.nombresComunes 
            : [captura.especieId],
          totalCapturas: 0,
          pesos: [],
          tamanios: [],
          capturas: [],
        });
      }
      const especie = especiesStatsMap.get(captura.especieId);
      especie!.totalCapturas++;
      if (captura.peso) especie!.pesos.push(captura.peso);
      if (captura.tamanio) especie!.tamanios.push(captura.tamanio);
      especie!.capturas.push(captura);
    });

    const especiesDetalle = Array.from(especiesStatsMap.values())
      .map(especie => {
        let mejorCaptura: Captura | null = null;
        
        const capturasConFotoYPeso = especie.capturas.filter((c: Captura) => c.foto && c.peso);
        if (capturasConFotoYPeso.length > 0) {
          mejorCaptura = capturasConFotoYPeso.reduce((max: Captura, c: Captura) => 
            c.peso! > max.peso! ? c : max
          );
        } else {
          const capturasConFoto = especie.capturas.filter((c: Captura) => c.foto);
          if (capturasConFoto.length > 0) {
            mejorCaptura = capturasConFoto[0];
          } else if (especie.pesos.length > 0) {
            const pesoMaximo = Math.max(...especie.pesos);
            mejorCaptura = especie.capturas.find((c: Captura) => c.peso === pesoMaximo) || null;
          } else {
            mejorCaptura = especie.capturas[0] || null;
          }
        }

        return {
          especieId: especie.especieId,
          nombreCientifico: especie.nombreCientifico,
          nombresComunes: especie.nombresComunes,
          imagen: mejorCaptura?.foto || null,
          totalCapturas: especie.totalCapturas,
          pesoPromedio: especie.pesos.length > 0 
            ? (especie.pesos.reduce((a: number, b: number) => a + b, 0) / especie.pesos.length).toFixed(2)
            : null,
          pesoMaximo: especie.pesos.length > 0 
            ? Math.max(...especie.pesos).toFixed(2)
            : null,
          tamanioPromedio: especie.tamanios.length > 0 
            ? (especie.tamanios.reduce((a: number, b: number) => a + b, 0) / especie.tamanios.length).toFixed(2)
            : null,
          tamanioMaximo: especie.tamanios.length > 0 
            ? Math.max(...especie.tamanios).toFixed(2)
            : null,
        };
      })
      .sort((a, b) => b.totalCapturas - a.totalCapturas);

    return {
      spotId,
      estadisticas: {
        totalCapturas: capturas.length,
        especiesUnicas: especiesStatsMap.size,
        especiesDetalle,
        capturasPorMes: this.groupCapturesByMonth(capturas),
        carnadasMasUsadas,
        tiposPescaMasUsados,
        mejoresHorarios,
        climasRegistrados,
      }
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
      if (rawBody.tamanio) rawBody.tamanio = parseFloat(rawBody.tamanio);
      if (rawBody.latitud) rawBody.latitud = parseFloat(rawBody.latitud);
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
