import {
  Table,
  Column,
  Model,
  DataType,
  ForeignKey,
} from 'sequelize-typescript';
import { EstadoSpot } from './EstadoSpot';
import { Usuario } from './Usuario';
import { Optional } from 'sequelize';


export interface SpotProps{
  id: string;
  nombre: string;
  descripcion: string;
  ubicacion: object;
  estado: EstadoSpot;
  fechaPublicacion: Date;
  fechaActualizacion: Date;
  idUsuario: string;
  idUsuarioActualizo: string;
  imagenPortada?: string;
  isDeleted: boolean;
}

export interface SpotCreationProps extends Optional<SpotProps, 'id'> {}


@Table({ tableName: 'Spot', timestamps: false })
export class Spot extends Model<SpotProps, SpotCreationProps> {
  @Column({ primaryKey: true, type: DataType.STRING })
  declare id: string;

  @Column
  declare nombre: string;

  @Column({
    type: DataType.ENUM('Esperando', 'Aceptado', 'Rechazado', 'Inactivo'), field: 'estado'
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

  @ForeignKey(() => Usuario)
  @Column
  declare idUsuario: string;

  @ForeignKey(() => Usuario)
  @Column
  declare idUsuarioActualizo: string;

  @Column({
    type: DataType.STRING,
    allowNull: true,
  })
  declare imagenPortada?: string;

  @Column({
    type: DataType.BOOLEAN,
    defaultValue: false,
  })
  declare isDeleted: boolean;
}
