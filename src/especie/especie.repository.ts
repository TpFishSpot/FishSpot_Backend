import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Carnada } from 'src/models/Carnada';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';

@Injectable()
export class EspecieRepository {
    constructor(
        @InjectModel(SpotCarnadaEspecie)
        private readonly spotCarnadaEspecieModel: typeof SpotCarnadaEspecie,
    ) {}
    
    async findCarnadasByEspecie(idEspecie: string): Promise<Carnada[]> {
    const registros = await this.spotCarnadaEspecieModel.findAll({
      where: { idEspecie },
      include: [Carnada],
    });

    const carnadas = registros.map(r => r.carnada);
    const uniques = Array.from(new Map(carnadas.map(c => [c.idCarnada, c])).values());
    return uniques;
  }
}
