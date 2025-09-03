import { Table, Column, Model, ForeignKey, DataType, BelongsTo } from 'sequelize-typescript';
import { Usuario } from './Usuario';
import { Rol } from './Rol';

@Table({
  tableName: 'UsuarioRol',
  timestamps: false
})
export class UsuarioRol extends Model<UsuarioRol> {
  @ForeignKey(() => Usuario)
  @Column({ type: DataType.STRING, primaryKey: true })
  declare usuarioId: string;

  @ForeignKey(() => Rol)
  @Column({ type: DataType.STRING, primaryKey: true })
  declare rolId: string;

  @BelongsTo(() => Rol, 'rolId')
  rol: Rol;

  @BelongsTo(() => Usuario, 'usuarioId')
  usuario: Usuario;
}

