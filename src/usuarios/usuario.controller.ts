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
import { ActualizarUsuarioDto } from 'src/dto/ActualizarUsuarioDto';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';

@Controller('usuario')
export class UsuarioController {
  constructor(private readonly usuarioService: UsuarioService) {}

  @Get()
  @Public()
  findAll(): Promise<Usuario[]> {
    return this.usuarioService.findAll();
  }
  @Get(':id')
  @Public()
  findOne(@Param('id')id: string): Promise<Usuario> {
    return this.usuarioService.findOne(id);
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

  @Patch(':id/actualizar')
  @UseInterceptors(
    FileInterceptor('foto', {
      storage: diskStorage({
        destination: './uploads/usuarios',
        filename: (req, file, cb) => {
          const ext = file.originalname.split('.').pop();
          cb(null, `${Date.now()}-${Math.random().toString(36).substr(2, 9)}.${ext}`);
        },
      }),
    }),
  )
  @Public()
  async actualizarUsuario(
    @Param('id') id: string,
    @Body() body: ActualizarUsuarioDto,
    @UploadedFile() foto: Express.Multer.File): Promise<Usuario> {
    return this.usuarioService.actualizarUsuario(id, body, foto);
  }
}
