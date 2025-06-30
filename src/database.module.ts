import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Sequelize } from 'sequelize-typescript';
// import { User } from './user.entity'; -> este es un ejemplo:  aca van las entidades

@Module({
  imports: [
    SequelizeModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        dialect: 'postgres',
        host: configService.get<string>('DATABASE_HOST'),
        port: configService.get<number>('DATABASE_PORT'),
        username: configService.get<string>('DATABASE_USER'),
        password: configService.get<string>('DATABASE_PASSWORD'),
        database: configService.get<string>('DATABASE_NAME'),
        //  models: [User], // aca van los modulos de entidades
        synchronize: true, //  esto en produccion tiene que quedar facle
        autoLoadModels: true,
        logging: false, // hay que setearlo como verdadero para tener los zequelice logs
      }),
    }),
  ],
  exports: [SequelizeModule],
})
export class DatabaseModule {}
