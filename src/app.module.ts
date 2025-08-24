import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './database.module'; 
import { SpotModule } from './spots/spot.module';
import { UploadModule } from 'src/upload/upload.module';
import { CarnadaModule } from './carnada/carnada.module';
import { EspecieModule } from './especie/especie.module';

@Module({
  imports: [
    UploadModule,
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    SpotModule,
    CarnadaModule,
    EspecieModule,
  ],
})
export class AppModule {}