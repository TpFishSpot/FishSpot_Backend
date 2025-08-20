import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { SpotEspecie } from 'src/models/SpotEspecie';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { Especie } from 'src/models/Especie';
import { Spot, SpotCreationProps } from 'src/models/Spot';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { NotFoundException } from '@nestjs/common';
import { SpotTipoPesca } from 'src/models/SpotTipoPesca';
import { TipoPesca } from 'src/models/TipoPesca';

@Injectable()
export class SpotRepository {
  [x: string]: any;
  constructor(
    @InjectModel(Spot)
    private readonly spotModel: typeof Spot,
    @InjectModel(SpotEspecie)
    private readonly spotEspecieModel: typeof SpotEspecie,
     @InjectModel(SpotTipoPesca)
    private readonly spotTipoPescaModel: typeof SpotTipoPesca, 
  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotModel.findAll();
  }

  async create(spot: SpotCreationProps): Promise<Spot> {
    return this.spotModel.create(spot);
  }

  async findOne(id: string): Promise<Spot> {
    const spot = await this.spotModel.findOne({ where: { id } });
    if (!spot) {
      throw new NotFoundException(`No se encontró un spot con id ${id}`);
    }

    return spot;
  }


  async obtenerEspeciesPorSpot(spotId: string): Promise<EspecieConNombreComun[]> {
    const relaciones = await this.spotEspecieModel.findAll({
      where: { idSpot: spotId },
      include: [{ model: Especie, include: [NombreEspecie] }],    //aca se relacionan las 3 tablas (SpotEspecie, Especie, NombreComunEspecie)
    });

    return relaciones.map((rel) => {
      const especie = rel.especie;
      return {
        id: especie.idEspecie,
        nombre_cientifico: especie.nombreCientifico,
        descripcion: especie.descripcion,
        nombre_comun: especie.nombresComunes?.map(nc => nc.nombre) || [],
        imagen : especie.imagen
      };
    });
  }
  async obtenerTipoPesca(idSpot: string): Promise<SpotTipoPesca[]> {
  return this.spotTipoPescaModel.findAll({
    where: { idSpot },
    include: [TipoPesca], 
  });
}
}
