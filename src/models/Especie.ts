import { Column, DataType, HasMany, Model, Table } from "sequelize-typescript";
import { NombreEspecie } from "./NombreEspecie";

@Table({ tableName: 'Especie', timestamps: false })
export class Especie extends Model<Especie>{
    @Column({field: 'id', primaryKey: true, type: DataType.STRING })
    declare idEspecie: string;

    @Column
    declare nombreCientifico: string;

    @Column
    declare descripcion: string;

    @Column({ allowNull: true })
    declare imagen?: string;

    @HasMany(() => NombreEspecie)
    declare nombresComunes: NombreEspecie[];
}