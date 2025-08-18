import { Injectable } from '@nestjs/common';
import { Carnada } from 'src/models/Carnada';
import { EspecieRepository } from './especie.repository';

@Injectable()
export class EspecieService {
  constructor(private readonly especieRepository: EspecieRepository) {}

  async findCarnadasRecomendadas(idEspecie: string): Promise<Carnada[]> {
    return this.especieRepository.findCarnadasByEspecie(idEspecie);
  }
}
