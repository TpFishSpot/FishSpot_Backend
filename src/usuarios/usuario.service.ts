import { Injectable, NotFoundException } from '@nestjs/common';
import { Usuario } from 'src/models/Usuario';
import { UsuarioRepository } from './usuario.repository';
import { ActualizarUsuarioDto } from 'src/dto/ActualizarUsuarioDto';

@Injectable()
export class UsuarioService {
  constructor(
    private readonly usuarioRepository: UsuarioRepository,
  ) {}

  async findAll(): Promise<Usuario[]> {
    return await this.usuarioRepository.findAll();
  }
  async hacerModerador(id: string): Promise<Usuario>{
    return await this.usuarioRepository.hacerModerador(id);
  }
  async rolesDelUsuario(uid: string):Promise<string[]>{
    return await this.usuarioRepository.getUserRoles(uid);
  }

  async findOrCreateUser(uid: string, email: string, name?: string, photoURL?: string): Promise<Usuario> {
    return await this.usuarioRepository.findOrCreateUser(uid, email, name, photoURL);
  }

  async actualizarUsuario(id: string, body: ActualizarUsuarioDto, foto?: Express.Multer.File) {
    if (foto) {
      body.foto = `${process.env.direccionDeFoto}/${foto.filename}`;
    } else if (body.foto) {
      body.foto = body.foto;
    } else {
      body.foto = null;
    }

    return await this.usuarioRepository.actualizarUsuario(id, body);
  }
  async findOne(id: string): Promise<Usuario> {
    return await this.usuarioRepository.findOne(id);
  }
}
