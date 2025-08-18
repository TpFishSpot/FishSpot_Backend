import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { CarnadaController } from './carnada.controller';
import { CarnadaService } from './carnada.service';
import { CarnadaRepository } from './carnada.repository';
import { Carnada } from 'src/models/Carnada';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';
import { Especie } from 'src/models/Especie';
import { Spot } from 'src/models/Spot';


// no esta cargado en app.module.ts
@Module({
  imports: [SequelizeModule.forFeature([Carnada, SpotCarnadaEspecie, Especie, Spot])],
  controllers: [CarnadaController],
  providers: [CarnadaService, CarnadaRepository],
  exports: [CarnadaService],
})
export class CarnadaModule {}
