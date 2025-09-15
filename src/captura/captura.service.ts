import { Injectable } from '@nestjs/common';
import { CapturaRepository } from './captura.repository';
import { CapturaDto } from 'src/dto/CapturaDto';
import { Captura } from 'src/models/Captura';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class CapturaService {
  constructor(private readonly capturaRepository: CapturaRepository) {}

  async findAll(): Promise<Captura[]> {
    const capturas = await this.capturaRepository.findAll();
    
    
    return capturas.map(captura => {
      const capturaJson = captura.toJSON();
      return {
        ...capturaJson,
        peso: capturaJson.peso ? parseFloat(capturaJson.peso.toString()) : null,
        longitud: capturaJson.longitud ? parseFloat(capturaJson.longitud.toString()) : null,
      } as Captura;
    });
  }

  async findOne(id: string): Promise<Captura> {
    const captura = await this.capturaRepository.findOne(id);
    
   
    const capturaJson = captura.toJSON();
    return {
      ...capturaJson,
      peso: capturaJson.peso ? parseFloat(capturaJson.peso.toString()) : null,
      longitud: capturaJson.longitud ? parseFloat(capturaJson.longitud.toString()) : null,
    } as Captura;
  }

  async findByUsuario(idUsuario: string): Promise<Captura[]> {
    const capturas = await this.capturaRepository.findByUsuario(idUsuario);
    
    return capturas.map(captura => {
      const capturaJson = captura.toJSON();
      return {
        ...capturaJson,
        peso: capturaJson.peso ? parseFloat(capturaJson.peso.toString()) : null,
        longitud: capturaJson.longitud ? parseFloat(capturaJson.longitud.toString()) : null,
      } as Captura;
    });
  }

  async findByEspecie(especieId: string): Promise<Captura[]> {
    const capturas = await this.capturaRepository.findByEspecie(especieId);
    

    return capturas.map(captura => {
      const capturaJson = captura.toJSON();
      return {
        ...capturaJson,
        peso: capturaJson.peso ? parseFloat(capturaJson.peso.toString()) : null,
        longitud: capturaJson.longitud ? parseFloat(capturaJson.longitud.toString()) : null,
      } as Captura;
    });
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
