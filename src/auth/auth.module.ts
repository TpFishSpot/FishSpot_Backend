import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Usuario } from 'src/models/Usuario';
import { UsuarioRol } from 'src/models/UsuarioRol';
import { Rol } from 'src/models/Rol';
import { UserService } from './user.service';
import { AuthRolesGuard } from './roles.guard';

@Module({
  imports: [
    SequelizeModule.forFeature([Usuario, UsuarioRol, Rol]),
  ],
  providers: [UserService, AuthRolesGuard],
  exports: [UserService, AuthRolesGuard],
})
export class AuthModule {}
