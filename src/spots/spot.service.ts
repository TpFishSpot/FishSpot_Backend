import { Injectable } from '@nestjs/common';
import { SpotRepository } from './spot.repository';
import { SpotDto } from 'src/dto/SpotDto';
import { Spot } from 'src/models/Spot';
import {  Sequelize } from 'sequelize';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { TipoPesca } from 'src/models/TipoPesca';
import { v4 as uuidv4 } from 'uuid';
import { EspecieRepository } from 'src/especie/especie.repository';
import { CarnadaRepository } from 'src/carnada/carnada.repository';
import { EstadoSpot } from 'src/models/EstadoSpot';

@Injectable()
export class SpotService {
  especieService: any;
  constructor(
    private readonly spotRepository: SpotRepository,
    private readonly especieRepository: EspecieRepository,
    private readonly carnadaRepository: CarnadaRepository,
  ) {}

 async findAll(especies: string[] = []): Promise<Spot[]> {
  if (especies.length > 0) {
    return this.spotRepository.findAllByEspecies(especies);
  }
  
  return this.spotRepository.findAll();
  }

  async agregarSpot(
    spotDto: SpotDto,
    imagenPath?: string,
    especies: string[] = [],
    carnadas: { idEspecie: string; idCarnada: string }[] = [],
  ): Promise<Spot> {
    const hoy = new Date();
    const soloFecha = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate());
    const [lng, lat] = spotDto.ubicacion.coordinates;

    const punto = Sequelize.fn(
      'ST_SetSRID',
      Sequelize.fn('ST_MakePoint', lng, lat),
      4326
    );

    if (!this.spotRepository['spotModel'].sequelize)
      throw new Error('Sequelize no está inicializado');

    return this.spotRepository['spotModel'].sequelize.transaction(async (t) => {
      const spot = await this.spotRepository.create({
        id: uuidv4(),
        nombre: spotDto.nombre,
        descripcion: spotDto.descripcion,
        ubicacion: punto,
        estado: spotDto.estado,
        fechaPublicacion: soloFecha,
        fechaActualizacion: soloFecha,
        idUsuario: spotDto.idUsuario,
        idUsuarioActualizo: spotDto.idUsuario,
        imagenPortada: imagenPath,
        isDeleted: false,
      }, { transaction: t });

      if (especies.length) {
        await this.especieRepository.bulkCreateSpotEspecie(spot.id, especies, t);
      }

      if (carnadas.length) {
        await this.carnadaRepository.bulkCreateSpotCarnadaEspecie(spot.id, carnadas, t);
      }

      return spot;
    });
  }

  async find(id: string): Promise<Spot> {
    return this.spotRepository.findOne(id);
  }

  async findAllEspecies(id: string): Promise<EspecieConNombreComun[]> {
    return this.spotRepository.obtenerEspeciesPorSpot(id);
  }

  async findCarnadasByEspecies(id: string){
    const idsEspecies: string[] = (await this.findAllEspecies(id)).map(( e => e.id))
    return this.especieService.findCarnadasByEspecies(idsEspecies);
  }

  async aprobar(id: string): Promise<Spot>{
   return await this.spotRepository.cambiarEstado(id, EstadoSpot.Aceptado)
  }
  async rechazar(id: string): Promise<Spot>{
   return await this.spotRepository.cambiarEstado(id, EstadoSpot.Rechazado)
  }

  async esperando(): Promise<Spot[]>{
    return await this.spotRepository.filtrarEsperando();
  }
  async aceptados(): Promise<Spot[]>{
    return await this.spotRepository.filtrarAceptados();
  }

  async borrarSpot(id: string, idUsuarioSolicitante: string): Promise<string>{
    return await this.spotRepository.borrarSpot(id, idUsuarioSolicitante);
  }

  async getSpotsByUser(idUsuario: string): Promise<Spot[]> {
    return await this.spotRepository.findByUser(idUsuario);
  }

  async cantSpots(usuarioId: string): Promise<number>{
    return this.spotRepository.cantSpots(usuarioId);
  }

  async findAllPaginado({
    idUsuario,
    estado,
    page,
    limite,
  }: {
    idUsuario?: string;
    estado?: string; 
    page: number;
    limite?: number 
  }) {
    const limit = limite ? limite : 4;
    const offset = (page - 1) * limit;
    return await this.spotRepository.findAllPaginado({
      idUsuario,
      estado,
      offset,
      limit,
    });
  }

}
