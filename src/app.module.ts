import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { DatabaseModule } from './database.module'; 
import { SpotModule } from './spots/spot.module';
import { UploadModule } from 'src/upload/upload.module';
import { CarnadaModule } from './carnada/carnada.module';
import { EspecieModule } from './especie/especie.module';
import { AuthModule } from './auth/auth.module';
import { AuthRolesGuard } from './auth/roles.guard';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsuarioModule } from './usuarios/usuario.module';

@Module({
  imports: [
    UploadModule,
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    AuthModule,
    SpotModule,
    CarnadaModule,
    EspecieModule,
    UsuarioModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: AuthRolesGuard,
    },
  ],
})
export class AppModule {}