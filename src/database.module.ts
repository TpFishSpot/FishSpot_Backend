import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Usuario } from './models/Usuario';
import { Spot } from './models/Spot';
import { Especie } from './models/Especie';
import { Carnada } from './models/Carnada';
import { SpotEspecie } from './models/SpotEspecie';
import { Rol } from './models/Rol';
import { UsuarioRol } from './models/UsuarioRol';
import { NombreEspecie } from './models/NombreEspecie';
import { SpotCarnadaEspecie } from './models/SpotCarnadaEspecie';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    SequelizeModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        return {
          dialect: 'postgres',
          host: configService.get('DATABASE_HOST') || 'localhost',
          port: parseInt(configService.get('DATABASE_PORT') || '5432', 10),
          username: configService.get('DATABASE_USER'),
          password: configService.get('DATABASE_PASSWORD'),
          database: configService.get('DATABASE_NAME'),
          models: [Usuario, Spot, Especie, Carnada, SpotEspecie, Rol, UsuarioRol, NombreEspecie, SpotCarnadaEspecie],
          autoLoadModels: true,
          synchronize: true,
          logging: false,
        };
      },
      inject: [ConfigService],
    }),
  ],
  exports: [SequelizeModule],
})
export class DatabaseModule {}
