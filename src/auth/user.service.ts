import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Usuario } from 'src/models/Usuario';
import { UsuarioRol } from 'src/models/UsuarioRol';
import { Rol } from 'src/models/Rol';
import { UserRole } from './enums/roles.enum';
import { NivelPescador } from 'src/models/NivelPescador';

@Injectable()
export class UserService {
  constructor(
    @InjectModel(Usuario)
    private readonly usuarioModel: typeof Usuario,
    @InjectModel(UsuarioRol)
    private readonly usuarioRolModel: typeof UsuarioRol,
    @InjectModel(Rol)
    private readonly rolModel: typeof Rol,
  ) {}

  async findOrCreateUser(uid: string, email: string, name?: string): Promise<Usuario> {

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
          nivelPescador: NivelPescador.PRINCIPIANTE,
        } as any);

        const defaultRole = await this.rolModel.findOne({
          where: { nombre: UserRole.USER },
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
      }

      if (!user) {
        throw new Error('Failed to create or find user');
      }

      return user;
    } catch (error) {
      throw error;
    }
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
}
