import { Injectable } from '@nestjs/common';
import { SpotRepository } from './spot.repository';
import { SpotDto } from 'src/dto/SpotDto';
import { Spot } from 'src/models/Spot';
import { Sequelize } from 'sequelize';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { SpotTipoPesca } from 'src/models/SpotTipoPesca';
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
    // STipoPescaRepository 
  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotRepository.findAll();
  }

  async agregarSpot(
    spotDto: SpotDto,
    imagenPath?: string,
    especies: string[] = [],
    tiposPesca: string[] = [],
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
      }, { transaction: t });

      if (especies.length) {
        await this.especieRepository.bulkCreateSpotEspecie(spot.id, especies, t);
      }

      if (tiposPesca.length) {
        // await this.tipoPescaRepository.bulkCreateSpotTipoPesca(spot.id, tiposPesca, t);
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

  async findAllTipoPesca(id: string): Promise<SpotTipoPesca[]> {
    return this.spotRepository.obtenerTipoPesca(id);
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
}
