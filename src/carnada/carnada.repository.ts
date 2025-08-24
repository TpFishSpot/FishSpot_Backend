import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class CarnadaRepository {
  constructor(
    @InjectModel(SpotCarnadaEspecie)
    private readonly spotCarnadaEspecieModel: typeof SpotCarnadaEspecie,
  ) {}

  async findAll(): Promise<SpotCarnadaEspecie[]> {
    return this.spotCarnadaEspecieModel.findAll();
  }

  async bulkCreateSpotCarnadaEspecie(
    idSpot: string,
    registros: { idEspecie: string; idCarnada: string }[],
    transaction?: any,
  ): Promise<void> {
    const data = registros.map(c => ({
      idSpotCarnadaEspecie: uuidv4(),
      idSpot,
      idEspecie: c.idEspecie,
      idCarnada: c.idCarnada,
    }));
    await this.spotCarnadaEspecieModel.bulkCreate(data as any[], { transaction });
  }
}
