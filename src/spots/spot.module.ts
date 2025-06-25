import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Spot } from '../models/Spot';
import { SpotService } from './spot.service';
import { SpotController } from './spot.controller';

@Module({
  imports: [SequelizeModule.forFeature([Spot])],
  providers: [SpotService],
  controllers: [SpotController],
})
export class SpotModule {}