import {
  Table,
  Column,
  DataType,
  Model,
  PrimaryKey,
  BelongsToMany,
} from 'sequelize-typescript';
import { Spot } from './Spot';
import { Especie } from './Especie';
import { SpotCarnadaEspecie } from './SpotCarnadaEspecie';
import { TipoCarnada } from './TipoCarnada';

@Table({
  tableName: 'Carnada',
  timestamps: false,
})
export class Carnada extends Model<Carnada> {
    @PrimaryKey
    @Column({
        type: DataType.STRING,
        field: 'id',
    })
    declare idCarnada: string;

    @Column({
        type: DataType.STRING,
        allowNull: false,
    })
    declare nombre: string;

    @Column({
        type: DataType.ENUM(
            'ArtificialBlando',
            'ArtificialDuro',
            'CarnadaViva',
            'CarnadaMuerta',
            'NaturalNoViva',
            'MoscaArtificial',
            'Otros'
        ),
        allowNull: false,
        field: 'tipoCarnada',
    })
    declare tipo: TipoCarnada;

    @Column({
        type: DataType.TEXT,
        allowNull: true,
    })
    declare descripcion: string;

    @BelongsToMany(() => Spot, () => SpotCarnadaEspecie, {
        foreignKey: 'idCarnada',
        otherKey: 'idSpot',
        } as any)
    declare spots: Spot[];

    @BelongsToMany(() => Especie, () => SpotCarnadaEspecie, {
        foreignKey: 'idCarnada',
        otherKey: 'idEspecie',
        } as any)
    declare especies: Especie[];
}
