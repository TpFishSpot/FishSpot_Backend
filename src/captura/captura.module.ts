import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Captura } from '../models/Captura';
import { CapturaController } from './captura.controller';
import { CapturaRepository } from './captura.repository';
import { CapturaService } from './captura.service';
import { Usuario } from 'src/models/Usuario';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { Spot } from 'src/models/Spot';
import { AuthModule } from 'src/auth/auth.module';

@Module({
  imports: [
    SequelizeModule.forFeature([
      Captura,
      Usuario,
      Especie,
      NombreEspecie,
      Spot,
    ]),
    AuthModule,
  ],
  controllers: [CapturaController],
  providers: [CapturaService, CapturaRepository],
  exports: [CapturaService, CapturaRepository],
})
export class CapturaModule {}
