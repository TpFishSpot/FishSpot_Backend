import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot, SpotCreationProps } from 'src/models/Spot';
import { SpotEspecie } from 'src/models/SpotEspecie';
import { SpotTipoPesca } from 'src/models/SpotTipoPesca';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { TipoPesca } from 'src/models/TipoPesca';
import { Transaction, fn } from 'sequelize';
import { v4 as uuidv4 } from 'uuid';


@Injectable()
export class SpotRepository {
  constructor(
    @InjectModel(Spot)
    private readonly spotModel: typeof Spot,

    @InjectModel(SpotEspecie)
    private readonly spotEspecieModel: typeof SpotEspecie,

    @InjectModel(SpotTipoPesca)
    private readonly spotTipoPescaModel: typeof SpotTipoPesca,

    @InjectModel(SpotCarnadaEspecie)
    private readonly spotCarnadaEspecieModel: typeof SpotCarnadaEspecie,
  ) {}


  async create(spot: SpotCreationProps, options?: { transaction?: Transaction }) {
  return this.spotModel.create(spot, options);
  }

  async findAll(): Promise<Spot[]> {
    return this.spotModel.findAll();
  }

  async findOne(id: string): Promise<Spot> {
    const spot = await this.spotModel.findOne({ where: { id } });
    if (!spot) throw new NotFoundException(`No se encontró un spot con id ${id}`);
    return spot;
  }

  async obtenerEspeciesPorSpot(spotId: string): Promise<EspecieConNombreComun[]> {
    const relaciones = await this.spotEspecieModel.findAll({
      where: { idSpot: spotId },
      include: [{ model: Especie, include: [NombreEspecie] }],
    });

    return relaciones.map(rel => {
      const especie = rel.especie;
      return {
        id: especie.idEspecie,
        nombre_cientifico: especie.nombreCientifico,
        descripcion: especie.descripcion,
        nombre_comun: especie.nombresComunes?.map(nc => nc.nombre) || [],
        imagen: especie.imagen,
      };
    });
  }

  async obtenerTipoPesca(idSpot: string): Promise<SpotTipoPesca[]> {
    return this.spotTipoPescaModel.findAll({
      where: { idSpot },
      include: [TipoPesca],
    });
  }
  async createSpotConTransaccion(
    spot: SpotCreationProps,
    especies: string[] = [],
    tiposPesca: string[] = [],
    carnadas: { idEspecie: string; idCarnada: string }[] = [],
  ): Promise<Spot> {
    if (!this.spotModel.sequelize) throw new Error('Sequelize no inicializado');

    return this.spotModel.sequelize.transaction(async (t: Transaction) => {
      const nuevoSpot = await this.create(spot,{ transaction : t});

      // Asociar especies
      if (especies.length) {
        await this.spotEspecieModel.bulkCreate(
          especies.map(idEspecie => ({
            id: uuidv4(),
            idSpot: nuevoSpot.id,
            idEspecie,
          })) as any[],
          { transaction: t },
        );
      }

      if (tiposPesca.length) {
        await this.spotTipoPescaModel.bulkCreate(
          tiposPesca.map(idTipoPesca => ({
            id: uuidv4(),
            idSpot: nuevoSpot.id,
            idTipoPesca,
          })) as any[],
          { transaction: t },
        );
      }

      if (carnadas.length) {
        await this.spotCarnadaEspecieModel.bulkCreate(
          carnadas.map(c => ({
            idSpotCarnadaEspecie: uuidv4(),
            idSpot: nuevoSpot.id,
            idEspecie: c.idEspecie,
            idCarnada: c.idCarnada,
          })) as any[],
          { transaction: t },
        );
      }

      return nuevoSpot;
    });
  }
}
