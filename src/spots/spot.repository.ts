import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { todo } from 'node:test';
import { where } from 'sequelize';
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
  async findOne( id : string ): Promise<Spot>{
     const spot = await this.spotModel.findOne({ where: { id } });
     if (!spot) {
       throw new Error(`No se encontró un spot con id ${id}`); // TODO: agregar al middleware de manejo de errores
      }
     return spot;
  }
}