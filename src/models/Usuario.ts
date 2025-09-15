import { Table, Column, Model, DataType, BelongsToMany, HasMany } from 'sequelize-typescript';
import { NivelPescador } from './NivelPescador';
import { Rol } from './Rol';
import { UsuarioRol } from './UsuarioRol';
import { Captura } from './Captura';

@Table({
  tableName: 'Usuario',
  timestamps: false
})
export class Usuario extends Model<Usuario> {
  @Column({
    primaryKey: true,
    type: DataType.STRING,
  })
  declare id: string;

  @Column
  declare nombre: string;

  @Column({
    type: DataType.ENUM(
      'Principiante',
      'Aficionado',
      'Intermedio',
      'Avanzado',
      'Experto',
      'Profesional'
    ),
    field: 'nivelPescador',
  })
  declare nivelPescador: NivelPescador;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare email: string;

  @Column({
    type: DataType.STRING,
    allowNull: true,
  })
  declare foto: string | null;

  @BelongsToMany(() => Rol, () => UsuarioRol)
  declare roles: Array<Rol & { UsuarioRol: UsuarioRol }>;

  @HasMany(() => Captura)
  declare capturas: Captura[];
}
