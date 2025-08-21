import { Injectable } from '@nestjs/common';
import { Carnada } from 'src/models/Carnada';
import { EspecieRepository, TipoPescaEspecieDto } from './especie.repository';
import { Especie } from 'src/models/Especie';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { TipoPesca } from 'src/models/TipoPesca';

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
  async getTiposPescaByEspecie(idEspecie: string): Promise<TipoPescaEspecieDto[]> {
    return this.especieRepository.findTipoPescaEspecie(idEspecie);
  }
}
