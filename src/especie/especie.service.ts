import { Injectable } from '@nestjs/common';
import { Carnada } from 'src/models/Carnada';
import { EspecieRepository } from './especie.repository';
import { Especie } from 'src/models/Especie';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';

@Injectable()
export class EspecieService {
  constructor(private readonly especieRepository: EspecieRepository) {}

  async findCarnadasRecomendadas(idEspecie: string): Promise<Carnada[]> {
    return this.especieRepository.findCarnadasByEspecie(idEspecie);
  }
  async findOne(idEspecie:string): Promise<EspecieConNombreComun>{
    return this.especieRepository.findOne(idEspecie);
  }
  async findCarnadasByEspecies(ids: string[]): Promise<Record<string, Carnada[]>> {
    return this.especieRepository.findCarnadasByEspecies(ids);
  }
}
