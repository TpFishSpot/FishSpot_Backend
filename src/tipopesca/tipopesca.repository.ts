import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { TipoPesca } from 'src/models/TipoPesca';

@Injectable()
export class TipoPescaRepository {
  constructor(
    @InjectModel(TipoPesca)
    private readonly tipoPescaModel: typeof TipoPesca,
  ) {}

  async findAll(): Promise<TipoPesca[]> {
    return this.tipoPescaModel.findAll({
      order: [['nombre', 'ASC']]
    });
  }

  async findOne(id: string): Promise<TipoPesca | null> {
    return this.tipoPescaModel.findOne({ where: { id } });
  }
}
