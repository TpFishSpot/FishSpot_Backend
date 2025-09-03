import { Injectable } from '@nestjs/common';
import { CapturaRepository } from './captura.repository';
import { CapturaDto } from 'src/dto/CapturaDto';
import { Captura } from 'src/models/Captura';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class CapturaService {
  constructor(private readonly capturaRepository: CapturaRepository) {}

  async findAll(): Promise<Captura[]> {
    return this.capturaRepository.findAll();
  }

  async findOne(id: string): Promise<Captura> {
    return this.capturaRepository.findOne(id);
  }

  async findByUsuario(idUsuario: string): Promise<Captura[]> {
    return this.capturaRepository.findByUsuario(idUsuario);
  }

  async findByEspecie(especieId: string): Promise<Captura[]> {
    return this.capturaRepository.findByEspecie(especieId);
  }

  async create(
    capturaDto: CapturaDto,
    idUsuario: string,
    imagenPath?: string,
  ): Promise<Captura> {
    const nuevaCaptura = {
      id: uuidv4(),
      idUsuario,
      especieId: capturaDto.especieId,
      fecha: new Date(capturaDto.fecha),
      ubicacion: capturaDto.ubicacion,
      peso: capturaDto.peso,
      longitud: capturaDto.longitud,
      carnada: capturaDto.carnada,
      tipoPesca: capturaDto.tipoPesca,
      foto: imagenPath,
      notas: capturaDto.notas,
      clima: capturaDto.clima,
      horaCaptura: capturaDto.horaCaptura,
      fechaCreacion: new Date(),
      fechaActualizacion: new Date(),
    };

    return this.capturaRepository.create(nuevaCaptura);
  }

  async update(
    id: string,
    capturaDto: CapturaDto,
    imagenPath?: string,
  ): Promise<Captura> {
    const datosActualizados = {
      especieId: capturaDto.especieId,
      fecha: new Date(capturaDto.fecha),
      ubicacion: capturaDto.ubicacion,
      peso: capturaDto.peso,
      longitud: capturaDto.longitud,
      carnada: capturaDto.carnada,
      tipoPesca: capturaDto.tipoPesca,
      notas: capturaDto.notas,
      clima: capturaDto.clima,
      horaCaptura: capturaDto.horaCaptura,
      fechaActualizacion: new Date(),
      ...(imagenPath && { foto: imagenPath }),
    };

    return this.capturaRepository.update(id, datosActualizados);
  }

  async delete(id: string): Promise<void> {
    return this.capturaRepository.delete(id);
  }
}
