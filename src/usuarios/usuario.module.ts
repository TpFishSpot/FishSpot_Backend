import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Usuario } from 'src/models/Usuario';
import { UsuarioService } from './usuario.service';
import { UsuarioRepository } from './usuario.repository';
import { UsuarioController } from './usuario.controller';
import { UsuarioRol } from 'src/models/UsuarioRol';
import { Rol } from 'src/models/Rol';

@Module({
  imports: [
    SequelizeModule.forFeature([
        Usuario,
        UsuarioRol,
        Rol,
    ]),
  ],
  providers: [
    UsuarioService,
    UsuarioRepository,
  ],
  controllers: [UsuarioController],
})
export class UsuarioModule {}
