import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Spot } from '../models/Spot';
import { SpotController } from './spot.controller';
import { SpotRepository } from './spot.repository';
import { SpotService } from './spot.service';
import { SpotEspecie } from 'src/models/SpotEspecie';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { SpotTipoPesca } from 'src/models/SpotTipoPesca';
import { TipoPesca } from 'src/models/TipoPesca';

@Module({
  imports: [
    SequelizeModule.forFeature([
      Spot,
      SpotEspecie,
      Especie,
      NombreEspecie,
      SpotTipoPesca, 
      TipoPesca
    ]),
  ],
  providers: [SpotService, SpotRepository],
  controllers: [SpotController],
})
export class SpotModule {}
