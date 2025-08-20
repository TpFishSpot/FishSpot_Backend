import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';

@Injectable()
export class CarnadaRepository {
  constructor(
    @InjectModel(SpotCarnadaEspecie)
    private readonly spotCarnadaEspecieModel: SpotCarnadaEspecie,
  ) {}

}
