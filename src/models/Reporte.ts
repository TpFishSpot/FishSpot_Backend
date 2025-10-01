import { Column, DataType, ForeignKey, Model, Table } from "sequelize-typescript";
import { Spot } from "./Spot";
import { Usuario } from "./Usuario";

@Table({ tableName: 'Reporte', timestamps: false })
export class Reporte extends Model<Reporte> {
    @Column({
        type: DataType.STRING,
        defaultValue: DataType.STRING,
        primaryKey: true,
    })
    declare id: string;

    @ForeignKey(() => Spot)
    @Column({ type: DataType.STRING, allowNull: false })
    declare idSpot: string;

    @ForeignKey(() => Usuario)
    @Column({ type: DataType.STRING, allowNull: false })
    declare idUsuario: string;

    @Column({ type: DataType.STRING, allowNull: true })
    declare descripcion?: string;

    @Column({ type: DataType.DATE })
    declare fechaCreacion: Date;
}
