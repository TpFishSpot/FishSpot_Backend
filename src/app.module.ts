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

   ThrottlerModule.forRoot([
  {
    name: 'default',
    ttl: 60000,        
    limit: 10000,       
  },
  {
    name: 'auth',
    ttl: 300000,       
    limit: 20000,        
  },
  {
    name: 'uploads',
    ttl: 60000,        
    limit: 50000,         
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
    consumer
      .apply(SecurityMiddleware)
      .forRoutes('*');
  }
}