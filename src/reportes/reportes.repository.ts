import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, Transaction } from 'sequelize';
import { CreateReporteDto } from 'src/dto/CreateReporteDto';
import { Reporte } from 'src/models/Reporte';

@Injectable()
export class ReporteRepository {
    constructor(
        @InjectModel(Reporte)
        private readonly reporteModel: typeof Reporte,
    ) {}
    
    async crearReporte(reporte: Reporte, options?: { transaction?: Transaction }) {
    return this.reporteModel.create(reporte, options);
    }
    
    async listarReportes(): Promise<Reporte[]> {
        return this.reporteModel.findAll({
            attributes: ['id', 'idSpot', 'idUsuario', 'descripcion', 'fechaCreacion'],
        });
    }

    async buscarPorUsuarioYSpot(idUsuario: string, idSpot: string): Promise<Reporte | null> {
        return await this.reporteModel.findOne({
            where: { idUsuario, idSpot },
        });
    }

}  