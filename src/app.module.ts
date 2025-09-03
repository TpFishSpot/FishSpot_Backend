import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { DatabaseModule } from './database.module';
import { SpotModule } from './spots/spot.module';
import { CarnadaModule } from './carnada/carnada.module';
import { EspecieModule } from './especie/especie.module';
import { AuthModule } from './auth/auth.module';
import { AuthRolesGuard } from './auth/roles.guard';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsuarioModule } from './usuarios/usuario.module';
import { CapturaModule } from './captura/captura.module';
import { TipoPescaModule } from './tipopesca/tipopesca.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    AuthModule,
    SpotModule,
    CarnadaModule,
    EspecieModule,
    UsuarioModule,
    CapturaModule,
    TipoPescaModule,
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