import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Usuario } from 'src/models/Usuario';
import { UsuarioRol } from 'src/models/UsuarioRol';
import { Rol } from 'src/models/Rol';
import { ActualizarUsuarioDto } from 'src/dto/ActualizarUsuarioDto';

@Injectable()
export class UsuarioRepository {
  constructor(
    @InjectModel(Usuario)
    private readonly usuarioModel: typeof Usuario,

    @InjectModel(UsuarioRol)
    private readonly usuarioRolModel: typeof UsuarioRol,

    @InjectModel(Rol)
    private readonly rolModel: typeof Rol,
  ) {}

  async findOrCreateUser(uid: string, email: string, name?: string, photoURL?: string): Promise<Usuario> {
    try {
      let user = await this.usuarioModel.findByPk(uid, {
        include: [
          {
            model: Rol,
            through: { attributes: [] },
            attributes: ['id', 'nombre'],
          },
        ],
      });

      if (!user) {
        user = await this.usuarioModel.create({
          id: uid,
          email,
          nombre: name || email.split('@')[0],
          foto: photoURL || null,
          nivelPescador: 'Principiante',
        } as any);

        const defaultRole = await this.rolModel.findOne({
          where: { nombre: 'usuario' },
        });

        if (defaultRole) {
          await this.usuarioRolModel.create({
            usuarioId: uid,
            rolId: defaultRole.id,
          } as any);
        }

        user = await this.usuarioModel.findByPk(uid, {
          include: [
            {
              model: Rol,
              through: { attributes: [] },
              attributes: ['id', 'nombre'],
            },
          ],
        });
      } else if (photoURL && user.foto !== photoURL) {
        await user.update({ foto: photoURL });
      }

      if (!user) {
        throw new Error('Failed to create or find user');
      }

      return user;
    } catch (error) {
      throw error;
    }
  }

  async findAll(): Promise<Usuario[]> {
    return this.usuarioModel.findAll({
      include: [Rol],
    });
  }

  async hacerModerador(id: string): Promise<Usuario> {
    const usuario = await this.usuarioModel.findByPk(id);
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const rolModerador = await this.rolModel.findOne({
      where: { nombre: 'moderador' },
    });

    if (!rolModerador) {
      throw new NotFoundException('Rol moderador no existe');
    }

    const usuarioRol = this.usuarioRolModel.build({
      usuarioId: usuario.id,
      rolId: rolModerador.id,
    } as any);

    await usuarioRol.save();

    const usuarioActualizado = await this.usuarioModel.findByPk(id, {
      include: [Rol],
    });

    if(!usuarioActualizado){
        throw new NotFoundException('Usuario no encontrado');
    }
    return usuarioActualizado;
  }

  async getUserRoles(uid: string): Promise<string[]> {
    try {
      const userRoles = await this.usuarioRolModel.findAll({
        where: { usuarioId: uid },
        include: [{
          model: Rol,
          attributes: ['id', 'nombre'],
          required: true
        }],
      });

      if (userRoles.length === 0 || !userRoles[0].rol) {
        const roleIds = await this.usuarioRolModel.findAll({
          where: { usuarioId: uid },
          attributes: ['rolId'],
        });

        if (roleIds.length === 0) {
          return [];
        }

        const roles = await this.rolModel.findAll({
          where: { id: roleIds.map(r => r.rolId) },
          attributes: ['nombre'],
        });

        const roleNames = roles.map(r => r.nombre);
        return roleNames;
      }

      const roles = userRoles.map(ur => {
        return ur.rol?.nombre;
      }).filter(Boolean);

      return roles;
    } catch (error) {
      throw error;
    }
  }

  async actualizarUsuario(id: string, body: any) {
    const usuario = await this.usuarioModel.findByPk(id);
    if (!usuario) throw new NotFoundException('Usuario no encontrado');
    await usuario.update(body);
    return usuario;
  }

  async findOne(id: string): Promise<Usuario> {
    const usuario = await this.usuarioModel.findOne({
      where: { id },
      include: [Rol],
    }); 
    if (!usuario) {
      throw new NotFoundException('Usuario no encontrado');
    }
    return usuario;
  }
}
