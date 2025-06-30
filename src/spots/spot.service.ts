import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Spot } from 'src/models/Spot';
import { SpotRepository } from './spot.repository';
import { SpotDto } from 'src/dto/SpotDto';
import { EstadoSpot } from 'src/models/EstadoSpot';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class SpotService {
  constructor(
    @InjectModel(Spot)
    private readonly spotRepository: SpotRepository,
  ) {}

  async findAll(): Promise<Spot[]> {
    return this.spotRepository.findAll();
  }

  async agregarSpot(spotDto: SpotDto): Promise<Spot> {
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
    });
  }
}
