// src/models/spot.model.ts
import { Table, Column, Model, DataType, ForeignKey } from 'sequelize-typescript';

@Table({ tableName: 'Spot' })
export class Spot extends Model<Spot> {
  @Column({ primaryKey: true, type: DataType.STRING })
  declare id: string;

  @Column
  nombre: string;

  @Column({ type: DataType.ENUM('Esperando','Aceptado','Rechazado','Inactivo') })
  estado: string;

  @Column
  descripcion: string;

  @Column({ type: DataType.GEOGRAPHY('POINT', 4326) })
  ubicacion: object;

  @Column
  fechaPublicacion: Date;

  @Column
  fechaActualizacion: Date;

  @ForeignKey(() => Spot)
  @Column
  idUsuario: string;

  @ForeignKey(() => Spot)
  @Column
  idUsuarioActualizo: string;
}
