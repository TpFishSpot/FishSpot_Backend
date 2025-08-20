import { Injectable } from '@nestjs/common';
import { CarnadaRepository } from './carnada.repository';

@Injectable()
export class CarnadaService {
  constructor(private readonly carnadaRepository: CarnadaRepository) {}


}
