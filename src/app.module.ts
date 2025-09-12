import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { DatabaseModule } from './database.module';
import { SpotModule } from './spots/spot.module';
import { CarnadaModule } from './carnada/carnada.module';
import { EspecieModule } from './especie/especie.module';
import { AuthModule } from './auth/auth.module';
import { AuthRolesGuard } from './auth/roles.guard';
import { SecurityMiddleware } from './middleware/security.middleware';
import { SecurityLogger } from './security/security-logger.service';
import { SecurityController } from './security/security.controller';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsuarioModule } from './usuarios/usuario.module';
import { CapturaModule } from './captura/captura.module';
import { TipoPescaModule } from './tipopesca/tipopesca.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    
    // Rate limiting configurado por endpoint
    ThrottlerModule.forRoot([
      {
        name: 'default',
        ttl: 60000, // 1 minuto
        limit: 100, // 100 requests por minuto por IP
      },
      {
        name: 'auth',
        ttl: 900000, // 15 minutos 
        limit: 5, // Solo 5 intentos de login por 15 minutos
      },
      {
        name: 'uploads',
        ttl: 60000, // 1 minuto
        limit: 10, // 10 uploads por minuto
      }
    ]),
    
    DatabaseModule,
    AuthModule,
    SpotModule,
    CarnadaModule,
    EspecieModule,
    UsuarioModule,
    CapturaModule,
    TipoPescaModule,
  ],
  controllers: [AppController, SecurityController],
  providers: [
    AppService,
    SecurityLogger,
    {
      provide: APP_GUARD,
      useClass: AuthRolesGuard,
    },
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    // Aplicar middleware de seguridad a todas las rutas
    consumer
      .apply(SecurityMiddleware)
      .forRoutes('*');
  }
}