import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { ReportesService } from './reportes.service';
import { UserRole } from 'src/auth/enums/roles.enum';
import { Roles } from 'src/auth/decorator';
import { RequestWithUser } from 'src/auth/interfaces/auth.interface';
import { CreateReporteDto } from 'src/dto/CreateReporteDto';
import { Reporte } from 'src/models/Reporte';

@Controller('reportes')
export class ReportesController {
  constructor(private readonly reporteService: ReportesService) {}

  
  @Post()
  @Roles(UserRole.USER)
  async crearReporte(@Body() dto: CreateReporteDto, @Req() req: RequestWithUser) {
    const usuarioId = req.user.uid;
    return this.reporteService.crearReporte(dto, usuarioId);
  }

  
  @Get()
  @Roles(UserRole.MODERATOR)
  async listarReportes(): Promise<Reporte[]> {
    return this.reporteService.listarReportes();
  }
}
