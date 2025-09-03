import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';
import { Carnada } from 'src/models/Carnada';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class CarnadaRepository {
  constructor(
    @InjectModel(SpotCarnadaEspecie)
    private readonly spotCarnadaEspecieModel: typeof SpotCarnadaEspecie,
    @InjectModel(Carnada)
    private readonly carnadaModel: typeof Carnada,
  ) {}

  async findAll(): Promise<Carnada[]> {
    return this.carnadaModel.findAll();
  }

  async findById(id: string): Promise<Carnada | null> {
    return this.carnadaModel.findByPk(id);
  }

  async findAllSpotCarnadaEspecie(): Promise<SpotCarnadaEspecie[]> {
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
