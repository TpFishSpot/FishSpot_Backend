import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot } from 'src/models/Spot';

@Injectable()
export class SpotRepository {
  constructor(
    @InjectModel(Spot)
    private readonly spotModel: typeof Spot,
  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotModel.findAll();
  }

  async create(spot: Spot): Promise<Spot> {
    return this.spotModel.create(spot);
  }
}
