import { Column, DataType, ForeignKey, Model, Table } from "sequelize-typescript";
import { Especie } from "./Especie";

@Table({ tableName: 'NombreComunEspecie', timestamps: false })
export class NombreEspecie extends Model<NombreEspecie>{

    @Column({field: 'id', primaryKey: true, type: DataType.STRING})
    declare idNombreEspecie : string;

    @ForeignKey(() => Especie)
    @Column
    declare idEspecie: string;

    @Column
    declare nombre: string;

}