import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot, SpotCreationProps } from 'src/models/Spot';

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
}
