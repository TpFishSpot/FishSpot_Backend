import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Spot } from '../models/Spot';
import { SpotController } from './spot.controller';
import { SpotRepository } from './spot.repository';
import { SpotService } from './spot.service';

@Module({
  imports: [SequelizeModule.forFeature([Spot])],
  providers: [SpotService, SpotRepository],
  controllers: [SpotController],
})
export class SpotModule {}
