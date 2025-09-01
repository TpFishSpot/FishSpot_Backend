import { Table, Column, DataType, Model, ForeignKey, BelongsTo } from 'sequelize-typescript';
import { Spot } from './Spot';
import { TipoPesca } from './TipoPesca';

@Table({
  tableName: 'SpotTipoPesca',
  timestamps: false,
})
export class SpotTipoPesca extends Model<SpotTipoPesca> {
  @Column({
    type: DataType.STRING,
    primaryKey: true,
    field: 'id',
  })
  declare id: string;

  @ForeignKey(() => Spot)
  @Column({
    type: DataType.STRING,
    allowNull: false,
    field: 'idSpot',
  })
  declare idSpot: string;

  @ForeignKey(() => TipoPesca)
  @Column({
    type: DataType.STRING,
    allowNull: false,
    field: 'idTipoPesca',
  })
  declare idTipoPesca: string;

  @BelongsTo(() => TipoPesca, 'idTipoPesca')
  declare tipoPesca: TipoPesca;
}
