import { Injectable } from '@nestjs/common';
import { Usuario } from 'src/models/Usuario';
import { UsuarioRepository } from './usuario.repository';

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
}
