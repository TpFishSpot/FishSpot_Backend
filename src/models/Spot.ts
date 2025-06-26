// src/models/spot.model.ts
import {
  Table,
  Column,
  Model,
  DataType,
  ForeignKey,
} from 'sequelize-typescript';
import { EstadoSpot } from './EstadoSpot';

@Table({ tableName: 'Spot' })
export class Spot extends Model<Spot> {
  @Column({ primaryKey: true, type: DataType.STRING })
  declare id: string;

  @Column
  declare nombre: string;

  @Column({
    type: DataType.ENUM('Esperando', 'Aceptado', 'Rechazado', 'Inactivo'),
  })
  declare estado: EstadoSpot;

  @Column
  declare descripcion: string;

  @Column({ type: DataType.GEOGRAPHY('POINT', 4326) })
  declare ubicacion: object;

  @Column
  declare fechaPublicacion: Date;

  @Column
  declare fechaActualizacion: Date;

  @ForeignKey(() => Spot)
  @Column
  declare idUsuario: string;

  @ForeignKey(() => Spot)
  @Column
  declare idUsuarioActualizo: string;
}
