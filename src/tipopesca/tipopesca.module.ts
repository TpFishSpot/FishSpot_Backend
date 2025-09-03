import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { TipoPesca } from '../models/TipoPesca';
import { TipoPescaController } from './tipopesca.controller';
import { TipoPescaRepository } from './tipopesca.repository';
import { TipoPescaService } from './tipopesca.service';

@Module({
  imports: [
    SequelizeModule.forFeature([TipoPesca]),
  ],
  controllers: [TipoPescaController],
  providers: [TipoPescaService, TipoPescaRepository],
  exports: [TipoPescaService, TipoPescaRepository],
})
export class TipoPescaModule {}
