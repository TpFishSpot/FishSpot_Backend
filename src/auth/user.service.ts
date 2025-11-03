import { forwardRef, Inject, Injectable } from '@nestjs/common';
import { UsuarioService } from 'src/usuarios/usuario.service';
import { Usuario } from 'src/models/Usuario';

@Injectable()
export class UserService {
  constructor(
    @Inject(forwardRef(() => UsuarioService))
    private readonly usuarioService: UsuarioService,
  ) {}

  async findOrCreateUser(uid: string, email: string, name?: string, photoURL?: string): Promise<Usuario> {
    return await this.usuarioService.findOrCreateUser(uid, email, name, photoURL);
  }

  async getUserRoles(uid: string): Promise<string[]> {
    return await this.usuarioService.rolesDelUsuario(uid);
  }
}
