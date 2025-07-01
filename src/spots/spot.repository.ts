import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { NotFoundException } from '@nestjs/common';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { Spot, SpotCreationProps } from 'src/models/Spot';
import { SpotEspecie } from 'src/models/SpotEspecie';

@Injectable()
export class SpotRepository {
  constructor(
    @InjectModel(Spot)
    private readonly spotModel: typeof Spot,

  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotModel.findAll();
  }

  async create(spot: SpotCreationProps): Promise<Spot> {
    return this.spotModel.create(spot);
  }
  async findOne(id: string): Promise<Spot> {
    const spot = await this.spotModel.findOne({ where: { id } });
    if (!spot) {
      throw new NotFoundException(`No se encontró un spot con id ${id}`);
    }

    return spot;
  }
}
