import { Injectable } from '@nestjs/common';
import { TipoPescaRepository } from './tipopesca.repository';
import { TipoPesca } from 'src/models/TipoPesca';

@Injectable()
export class TipoPescaService {
  constructor(
    private readonly tipoPescaRepository: TipoPescaRepository,
  ) {}

  async findAll(): Promise<TipoPesca[]> {
    return this.tipoPescaRepository.findAll();
  }

  async findOne(id: string): Promise<TipoPesca | null> {
    return this.tipoPescaRepository.findOne(id);
  }
}
