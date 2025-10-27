import { Table, Column, DataType, ForeignKey, BelongsTo, Model } from 'sequelize-typescript';
import { Usuario } from './Usuario';
import { Spot } from './Spot';

@Table({
  tableName: 'Comentario',
  timestamps: false,
})
export class Comentario extends Model {
  @Column({
    type: DataType.STRING,
    primaryKey: true,
  })
  declare id: string;

  @ForeignKey(() => Usuario)
  @Column({
    type: DataType.STRING,
    field: 'idUsuario',
    allowNull: false,
  })
  declare idUsuario: string;

  @ForeignKey(() => Spot)
  @Column({
    type: DataType.STRING,
    field: 'idSpot',
    allowNull: false,
  })
  declare idSpot: string;

  @Column({
    type: DataType.TEXT,
    allowNull: false,
  })
  declare contenido: string;

  @Column({
    type: DataType.DATE,
    allowNull: false,
    defaultValue: DataType.NOW,
  })
  declare fecha: Date;

  @BelongsTo(() => Usuario)
  declare usuario: Usuario;

  @BelongsTo(() => Spot)
  declare spot: Spot;
}