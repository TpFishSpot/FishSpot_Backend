import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  Get,
  Param,
  BadRequestException,
  Patch,
  Req,
} from '@nestjs/common';
import { Roles, Public } from 'src/auth/decorator';
import { UsuarioService } from './usuario.service';
import { Usuario } from 'src/models/Usuario';
import { UserRole } from 'src/auth/enums/roles.enum';

@Controller('usuario')
export class UsuarioController {
  constructor(private readonly usuarioService: UsuarioService) {}

  @Get()
  @Public()
  findAll(): Promise<Usuario[]> {
    return this.usuarioService.findAll();
  }

  @Patch(':id/rol/moderador')
  @Roles(UserRole.MODERATOR)
  async hacerModerador(@Param('id') id: string): Promise<Usuario>{
    return this.usuarioService.hacerModerador(id);
  }
  @Get(':uid/roles')
  @Public()
  async rolesDelUsuario(@Param('uid') uid:string):Promise<string[]>{
    return await this.usuarioService.rolesDelUsuario(uid);
  }
}
