import {
  Table,
  Column,
  Model,
  DataType,
  ForeignKey,
  BelongsTo,
} from 'sequelize-typescript';
import { Usuario } from './Usuario';
import { Especie } from './Especie';
import { Optional } from 'sequelize';
import { Spot } from './Spot';

export interface CapturaProps {
  id: string;
  idUsuario: string;
  especieId: string;
  fecha: Date;
  ubicacion: string;
  spotId?: string; 
  latitud?: number; 
  longitud?: number;
  peso?: number;
  tamanio?: number;
  carnada: string;
  tipoPesca: string;
  foto?: string;
  notas?: string;
  clima?: string;
  horaCaptura?: string;
  fechaCreacion: Date;
  fechaActualizacion: Date;
}

export interface CapturaCreationProps extends Optional<CapturaProps, 'id' | 'fechaCreacion' | 'fechaActualizacion'> {}

@Table({ tableName: 'Captura', timestamps: false })
export class Captura extends Model<CapturaProps, CapturaCreationProps> {
  @Column({ primaryKey: true, type: DataType.STRING })
  declare id: string;

  @ForeignKey(() => Usuario)
  @Column({ type: DataType.STRING })
  declare idUsuario: string;

  @ForeignKey(() => Especie)
  @Column({ type: DataType.STRING })
  declare especieId: string;

  @Column({ type: DataType.DATE })
  declare fecha: Date;

  @Column({ type: DataType.STRING(500) })
  declare ubicacion: string;

  @ForeignKey(() => Spot)
  @Column({ type: DataType.STRING, allowNull: true })
  declare spotId?: string;

  @Column({ type: DataType.DECIMAL(10, 8), allowNull: true })
  declare latitud?: number; 

  @Column({ type: DataType.DECIMAL(11, 8), allowNull: true })
  declare longitud?: number;  

  @Column({ type: DataType.DECIMAL(8, 2) })
  declare peso?: number;

  @Column({ type: DataType.DECIMAL(6, 2) })
  declare tamanio?: number;

  @Column({ type: DataType.STRING })
  declare carnada: string;

  @Column({ type: DataType.STRING })
  declare tipoPesca: string;

  @Column({ type: DataType.STRING })
  declare foto?: string;

  @Column({ type: DataType.TEXT })
  declare notas?: string;

  @Column({ type: DataType.STRING(100) })
  declare clima?: string;

  @Column({ type: DataType.TIME })
  declare horaCaptura?: string;

  @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
  declare fechaCreacion: Date;

  @Column({ type: DataType.DATE, defaultValue: DataType.NOW })
  declare fechaActualizacion: Date;

  @BelongsTo(() => Usuario)
  declare usuario: Usuario;

  @BelongsTo(() => Especie)
  declare especie: Especie;

  @BelongsTo(() => Spot)  
  declare spot?: Spot;
}
