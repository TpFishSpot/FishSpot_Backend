import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot } from 'src/models/Spot';

@Injectable()
export class SpotService {
  constructor(
    @InjectModel(Spot)
    private spotModel: typeof Spot
  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotModel.findAll();
  }
}
