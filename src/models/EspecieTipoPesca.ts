import { BelongsTo, Column, DataType, ForeignKey, Model, PrimaryKey, Table } from "sequelize-typescript";
import { TipoPesca } from "./TipoPesca";
import { Especie } from "./Especie";

@Table({
  tableName: "EspecieTipoPesca",
  timestamps: false,
})
export class EspecieTipoPesca extends Model {
  @PrimaryKey
  @Column({
    type: DataType.UUID,
    defaultValue: DataType.UUIDV4,
    field: "id",
  })
  declare id: string;

  @ForeignKey(() => Especie)
  @Column({
    type: DataType.UUID,
    allowNull: false,
    field: "idEspecie",
  })
  declare idEspecie: string;

  @ForeignKey(() => TipoPesca)
  @Column({
    type: DataType.UUID,
    allowNull: false,
    field: "idTipoPesca",
  })
  declare idTipoPesca: string;

  @Column({
    type: DataType.STRING,
    allowNull: true,
    field: "descripcion",
  })
  declare descripcion?: string;

  @BelongsTo(() => TipoPesca, 'idTipoPesca')
   declare tipoPesca: TipoPesca;
}
