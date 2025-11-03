import { forwardRef, Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Usuario } from 'src/models/Usuario';
import { UsuarioService } from './usuario.service';
import { UsuarioRepository } from './usuario.repository';
import { UsuarioController } from './usuario.controller';
import { UsuarioRol } from '../models/UsuarioRol';
import { Rol } from 'src/models/Rol';
import { ComentarioModule } from '../comentario/comentario.module';
import { SpotModule } from '../spots/spot.module';
import { CapturaModule } from '../captura/captura.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    SequelizeModule.forFeature([
        Usuario,
        UsuarioRol,
        Rol,
    ]),
    forwardRef(() => ComentarioModule),
    forwardRef(() => SpotModule),
    forwardRef(() => CapturaModule),
    forwardRef(() => AuthModule),
  ],
  providers: [
    UsuarioService,
    UsuarioRepository,
  ],
  controllers: [UsuarioController],
  exports: [UsuarioService],
})
export class UsuarioModule {}
