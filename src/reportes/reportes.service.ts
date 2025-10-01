import { BadRequestException, Injectable } from '@nestjs/common';
import { CreateReporteDto } from 'src/dto/CreateReporteDto';
import { ReporteRepository } from './reportes.repository';
import { Reporte } from 'src/models/Reporte';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ReportesService {
    constructor(
        private readonly reporteRepository: ReporteRepository,
    ) {}
    
    async crearReporte(dto: CreateReporteDto , usuarioId: string){
        const existente = await this.reporteRepository.buscarPorUsuarioYSpot(usuarioId, dto.idSpot);
        if (existente) {
            throw new BadRequestException('Ya has reportado este spot');
        }
        const nuevoReporte: Reporte = {
            id: uuidv4(),
            idSpot: dto.idSpot,
            idUsuario: usuarioId,
            descripcion: dto.descripcion?.trim() || undefined,
            fechaCreacion: new Date(),
        } as Reporte;
        return await this.reporteRepository.crearReporte(nuevoReporte);
    }
    
    async listarReportes() :Promise<Reporte[]> {
      return await this.reporteRepository.listarReportes();
    }
}

