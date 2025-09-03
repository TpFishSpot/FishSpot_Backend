import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { CarnadaController } from './carnada.controller';
import { CarnadaService } from './carnada.service';
import { CarnadaRepository } from './carnada.repository';
import { Carnada } from 'src/models/Carnada';
import { Especie } from 'src/models/Especie';
import { Spot } from 'src/models/Spot';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';

@Module({
  imports: [SequelizeModule.forFeature([Carnada, SpotCarnadaEspecie, Especie, Spot])],
  controllers: [CarnadaController],
  providers: [CarnadaService, CarnadaRepository],
  exports: [CarnadaService, CarnadaRepository],
})
export class CarnadaModule {}
