import { BelongsTo, Column, DataType, ForeignKey, Model, Table } from "sequelize-typescript";
import { Spot } from "./Spot";
import { Especie } from "./Especie";

@Table({ tableName: 'SpotEspecie', timestamps: false })
export class SpotEspecie extends Model<SpotEspecie> {
    @Column({ field: 'id', primaryKey: true, type: DataType.STRING })
    declare idSpotEspecie: string;

    @ForeignKey(() => Spot)
    @Column
    declare idSpot: string;

    @BelongsTo(() => Spot)
    declare spot: Spot;

    
    @ForeignKey(() => Especie)
    @Column
    declare idEspecie: string;

    @BelongsTo(() => Especie)
    declare especie: Especie;
}