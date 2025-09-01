import { Table, Column, Model, DataType, BelongsToMany } from 'sequelize-typescript';
import { Usuario } from './Usuario';
import { UsuarioRol } from './UsuarioRol';

@Table({ tableName: 'Rol' })
export class Rol extends Model<Rol> {
  @Column({
    primaryKey: true,
    type: DataType.STRING,
  })
  declare id: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
    unique: true,
  })
  declare nombre: string;

  @BelongsToMany(() => Usuario, () => UsuarioRol)
  declare usuarios: Array<Usuario & { UsuarioRol: UsuarioRol }>;
}
