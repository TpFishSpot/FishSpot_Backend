import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot, SpotCreationProps } from 'src/models/Spot';
import { SpotEspecie } from 'src/models/SpotEspecie';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { Op, Transaction } from 'sequelize';
import { v4 as uuidv4 } from 'uuid';
import { EstadoSpot } from 'src/models/EstadoSpot';

@Injectable()
export class SpotRepository {
  constructor(
    @InjectModel(Spot)
    private readonly spotModel: typeof Spot,

    @InjectModel(SpotEspecie)
    private readonly spotEspecieModel: typeof SpotEspecie,

    @InjectModel(SpotCarnadaEspecie)
    private readonly spotCarnadaEspecieModel: typeof SpotCarnadaEspecie,
  ) {}

  async create(spot: SpotCreationProps, options?: { transaction?: Transaction }) {
  return this.spotModel.create(spot, options);
  }

  async findAll(): Promise<Spot[]> {
    return await this.spotModel.findAll({ where: { isDeleted: false } });
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

  async createSpotConTransaccion(
    spot: SpotCreationProps,
    especies: string[] = [],
    carnadas: { idEspecie: string; idCarnada: string }[] = [],
  ): Promise<Spot> {
    if (!this.spotModel.sequelize) throw new Error('Sequelize no inicializado');

    return this.spotModel.sequelize.transaction(async (t: Transaction) => {
      const nuevoSpot = await this.create(spot,{ transaction : t});

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

  async cambiarEstado(id: string, nuevoEstado: EstadoSpot): Promise<Spot> {
    const spot = await this.spotModel.findByPk(id);

    if (!spot) {
      throw new Error(`No se encontro spot con id ${id}`);
    }

    spot.estado = nuevoEstado;
    await spot.save();

    return spot;
  }

  async filtrarEsperando(): Promise<Spot[]>{
    return await this.spotModel.findAll({ where: {estado: "Esperando"}})
  }

  async filtrarAceptados(): Promise<Spot[]>{
    return await this.spotModel.findAll({ where: {estado: "Aceptado"}})
  }

  async borrarSpot(id: string, idUsuarioSolicitante: string): Promise<string>{
    const spotABorrar: Spot = await this.findOne(id);
    if (spotABorrar.idUsuario !== idUsuarioSolicitante) {
      throw new ForbiddenException('No puedes borrar un spot que no creaste');
    }
    if (spotABorrar.estado !== EstadoSpot.Esperando) {
      throw new BadRequestException('Solo puedes borrar spots pendientes');
    }
    spotABorrar.isDeleted = true;
    await spotABorrar.save();
    return `Spot ${id} marcado como borrado`;
  }
  async findByUser(idUsuario: string): Promise<Spot[]> {
    return await this.spotModel.findAll({ where: { idUsuario: idUsuario, isDeleted: false } });
  }

async findAllByEspecies(especies: string[]): Promise<Spot[]> {
  const especiesIds = await Especie.findAll({
    include: [
      {
        model: NombreEspecie,
        as: 'nombresComunes',
        required: false
      }
    ],
    where: {
      [Op.or]: [
        { nombreCientifico: { [Op.in]: especies } },
        { '$nombresComunes.nombre$': { [Op.in]: especies } }
      ]
    }
  });

  const idsEspecies = especiesIds.map(especie => especie.id);

  if (idsEspecies.length === 0) {
    return [];
  }

  return this.spotModel.findAll({
    where: { isDeleted: false },
    include: [
      {
        model: SpotEspecie,
        required: true,
        where: {
          idEspecie: { [Op.in]: idsEspecies }
        },
        include: [
          {
            model: Especie,
            include: [NombreEspecie]
          }
        ]
      }
    ]
  });
}
  async cantSpots(usuarioId: string): Promise<number>{
     return this.spotModel.count({
        where: { idUsuario: usuarioId }
    });
  }

  async findAllPaginado({
    idUsuario,
    estado,
    offset,
    limit,
  }: {
    idUsuario?: string
    estado?: string
    offset: number
    limit: number
  }) {
    const where: any = { isDeleted: false }

    if (idUsuario) where.idUsuario = idUsuario

    if (estado && estado.toLowerCase() !== "all") {
      const validStates = ["Esperando", "Aceptado", "Rechazado", "Inactivo"]

      const normalized =
        estado.charAt(0).toUpperCase() + estado.slice(1).toLowerCase()

      if (validStates.includes(normalized)) {
        where.estado = normalized
      } else {
        console.warn(`⚠️ Estado inválido recibido: ${estado}`)
      }
    }

    const { rows, count } = await this.spotModel.findAndCountAll({
      where,
      offset,
      limit,
      order: [["fechaPublicacion", "DESC"]],
      distinct: true,
    })

    const totalPages = Math.ceil(count / limit)

    return {
      data: rows,
      total: count,
      totalPages,
    }
  }
 
}