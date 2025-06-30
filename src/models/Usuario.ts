import { Table, Column, Model, DataType } from 'sequelize-typescript';
import { NivelPescador } from './NivelPescador'; 

@Table({ tableName: 'Usuario' })
export class Usuario extends Model<Usuario> {
  @Column({
    primaryKey: true,
    type: DataType.STRING, 
  })
  declare id: string;

  @Column
  declare nombre: string;

  @Column({ type: DataType.ENUM('Principiante','Aficionado','Intermedio','Avanzado','Experto','Profesional'), field: 'nivel_pescador' })
  declare nivel_pescador: NivelPescador;

  @Column
  declare email: string;
}