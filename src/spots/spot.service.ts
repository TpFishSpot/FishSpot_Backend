import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot } from 'src/models/Spot';
import { SpotRepository } from './spot.repository';

@Injectable()
export class SpotService {
  constructor(
    @InjectModel(Spot)
    private readonly spotRepository: SpotRepository,
  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotRepository.findAll();
  }
  async find(id: string): Promise<Spot> {
   return await this.spotRepository.findOne(id)
  }

  async agregarSpot(spotDto: Spot): Promise<Spot> {
    return await this.spotRepository.create(spotDto);
  }
}
