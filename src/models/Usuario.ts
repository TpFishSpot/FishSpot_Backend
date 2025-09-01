import { Table, Column, Model, DataType, BelongsToMany } from 'sequelize-typescript';
import { NivelPescador } from './NivelPescador';
import { Rol } from './Rol';
import { UsuarioRol } from './UsuarioRol';

@Table({ 
  tableName: 'Usuario',
  timestamps: false // Deshabilita createdAt y updatedAt
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

  @BelongsToMany(() => Rol, () => UsuarioRol)
  declare roles: Array<Rol & { UsuarioRol: UsuarioRol }>;
}
