import { Module } from '@nestjs/common';
import { ReportesService } from './reportes.service';
import { ReportesController } from './reportes.controller';
import { SequelizeModule } from '@nestjs/sequelize';
import { Spot } from 'src/models/Spot';
import { Reporte } from 'src/models/Reporte';
import { CreateReporteDto } from 'src/dto/CreateReporteDto';
import { AuthModule } from 'src/auth/auth.module';
import { ReporteRepository } from './reportes.repository';

@Module({
  imports: [
      SequelizeModule.forFeature([
        Spot,
        Reporte,
      ]),
      AuthModule,
    ],
  controllers: [ReportesController],
  providers: [
    ReportesService,
    ReporteRepository,
  ],
})
export class ReportesModule {}
