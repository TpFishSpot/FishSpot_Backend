import { Table, Column, DataType, Model } from 'sequelize-typescript';

@Table({
  tableName: 'TipoPesca',
  timestamps: false,
})
export class TipoPesca extends Model<TipoPesca> {
  @Column({
    type: DataType.STRING,
    primaryKey: true,
    field: 'id',
  })
  declare id: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare nombre: string;

  @Column({
    type: DataType.TEXT,
    allowNull: true,
  })
  declare descripcion: string;
}
