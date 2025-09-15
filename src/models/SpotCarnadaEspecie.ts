import { Column, Model, Table, DataType, PrimaryKey, Default, BelongsTo, ForeignKey } from 'sequelize-typescript';
import { Carnada } from './Carnada';
import { Especie } from './Especie';
import { Spot } from './Spot';

@Table({
  tableName: 'SpotCarnadaEspecie',
  timestamps: false,
})
export class SpotCarnadaEspecie extends Model<SpotCarnadaEspecie> {

  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column({ type: DataType.UUID, field: 'id'})
  declare idSpotCarnadaEspecie: string;

  @ForeignKey(() => Spot)
  @Column({ type: DataType.UUID, allowNull: false })
  declare idSpot: string;

  @ForeignKey(() => Carnada)
  @Column({ type: DataType.UUID, allowNull: false })
  declare idCarnada: string;

  @ForeignKey(() => Especie)
  @Column({ type: DataType.STRING, allowNull: false })
  declare idEspecie: string;

  @BelongsTo(() => Spot)
  declare spot: Spot;

  @BelongsTo(() => Carnada)
  declare carnada: Carnada;

  @BelongsTo(() => Especie)
  declare especie: Especie;
}
