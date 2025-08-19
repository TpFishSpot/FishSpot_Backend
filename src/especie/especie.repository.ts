import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { Carnada } from 'src/models/Carnada';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';

@Injectable()
export class EspecieRepository {
    constructor(
        @InjectModel(SpotCarnadaEspecie)
        private readonly spotCarnadaEspecieModel: typeof SpotCarnadaEspecie,
        @InjectModel(Especie)
        private readonly especieModel: typeof Especie,
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

  async findOne(idEspecie: string): Promise<EspecieConNombreComun>{
    const especie = await this.especieModel.findOne({
      where: { idEspecie },
      include: [
        {
          model: NombreEspecie,
          attributes: ['nombre'],
        },
      ],
    });

    if (!especie) {
      throw new NotFoundException(`Especie con id ${idEspecie} no encontrada`);
    }
    return {
      id: especie.idEspecie,
      nombre_cientifico: especie.nombreCientifico,
      descripcion: especie.descripcion,
      imagen: especie.imagen,
      nombre_comun: especie.nombresComunes?.map(n => n.nombre) || [], 
    };
  }
}
