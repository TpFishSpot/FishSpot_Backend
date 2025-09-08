import { Injectable } from '@nestjs/common';
import { CarnadaRepository } from './carnada.repository';
import { Carnada } from 'src/models/Carnada';

@Injectable()
export class CarnadaService {
  constructor(private readonly carnadaRepository: CarnadaRepository) {}

  async findAll(): Promise<Carnada[]> {
    return this.carnadaRepository.findAll();
  }

  async findOne(id: string): Promise<Carnada | null> {
    return this.carnadaRepository.findById(id);
  }

}
