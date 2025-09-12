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
import { Captura } from './models/Captura';
import { TipoPesca } from './models/TipoPesca';
import { SpotTipoPesca } from './models/SpotTipoPesca';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    SequelizeModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const isProduction = configService.get('NODE_ENV') === 'production';
        
        return {
          dialect: 'postgres',
          host: configService.get('DATABASE_HOST') || 'localhost',
          port: parseInt(configService.get('DATABASE_PORT') || '5432', 10),
          username: configService.get('DATABASE_USER'),
          password: configService.get('DATABASE_PASSWORD'),
          database: configService.get('DATABASE_NAME'),
          models: [Usuario, Spot, Especie, Carnada, SpotEspecie, Rol, UsuarioRol, NombreEspecie, SpotCarnadaEspecie, Captura, TipoPesca, SpotTipoPesca],
          autoLoadModels: true,
          synchronize: !isProduction, // Solo en desarrollo
          
          // Configuraciones de seguridad
          pool: {
            max: 10,
            min: 0,
            acquire: 30000,
            idle: 10000,
          },
          
          // Logging seguro - solo errores en producción
          logging: isProduction 
            ? (sql, timing) => {
                // Solo log de errores en producción
                if (sql.toLowerCase().includes('error')) {
                  console.error('[DB ERROR]', sql);
                }
              }
            : console.log, // Log completo en desarrollo
          
          // Opciones de seguridad adicionales
          dialectOptions: {
            ssl: isProduction ? {
              require: true,
              rejectUnauthorized: false
            } : false,
            statement_timeout: 60000, // 60 segundos timeout
            query_timeout: 60000,
          },
          
          // Benchmark para detectar consultas lentas sospechosas
          benchmark: true,
          
          // Validar tipos de datos estrictamente
          typeValidation: true,
        };
      },
      inject: [ConfigService],
    }),
  ],
  exports: [SequelizeModule],
})
export class DatabaseModule {}
