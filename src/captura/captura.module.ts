import { forwardRef, Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Captura } from '../models/Captura';
import { CapturaController } from './captura.controller';
import { CapturaRepository } from './captura.repository';
import { CapturaService } from './captura.service';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { Spot } from 'src/models/Spot';
import { SpotEspecie } from 'src/models/SpotEspecie';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    SequelizeModule.forFeature([
      Captura,
      Especie,
      NombreEspecie,
      Spot,
      SpotEspecie,
    ]),
    forwardRef(() => AuthModule),
  ],
  controllers: [CapturaController],
  providers: [CapturaService, CapturaRepository],
  exports: [CapturaService, CapturaRepository],
})
export class CapturaModule {}
