import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot } from 'src/models/Spot';
import { SpotRepository } from './spot.repository';
import { SpotDto } from 'src/dto/SpotDto';
import { v4 as uuidv4 } from 'uuid';
import { SpotEspecie } from 'src/models/SpotEspecie';

@Injectable()
export class SpotService {
  constructor(
    private readonly spotRepository: SpotRepository,
  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotRepository.findAll();
  }

  async agregarSpot(spotDto: SpotDto, imagenPath: string | undefined ): Promise<Spot> {
    const hoy = new Date();
    const soloFecha = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate());

    return this.spotRepository.create({
      id: uuidv4(),
      nombre: spotDto.nombre,
      descripcion: spotDto.descripcion,
      ubicacion: spotDto.ubicacion,
      estado: spotDto.estado,
      fechaPublicacion: soloFecha,
      fechaActualizacion: soloFecha,
      idUsuario: spotDto.idUsuario,
      idUsuarioActualizo: spotDto.idUsuario,
      imagenPortada: imagenPath || undefined,
    });
  }

  async find(id: string): Promise<Spot> {
   return await this.spotRepository.findOne(id)
  }
  
  async findAllEspecies(id: string): Promise<EspecieConNombreComun[]> {
    return await this.spotRepository.obtenerEspeciesPorSpot(id);
  }
}
