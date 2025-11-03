import { Injectable } from '@nestjs/common';
import { CapturaRepository } from './captura.repository';
import { CapturaDto } from 'src/dto/CapturaDto';
import { Captura } from 'src/models/Captura';
import { v4 as uuidv4 } from 'uuid';
import { InjectModel } from '@nestjs/sequelize'; 
import { Spot } from 'src/models/Spot';
import { SpotEspecie } from 'src/models/SpotEspecie';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { NotFoundException } from '@nestjs/common';
import { CapturasPorMesDto } from 'src/dto/CapturaPorMesDto';

interface GeoJSONPoint {
  type: 'Point';
  coordinates: [number, number];
}

@Injectable()
export class CapturaService {
  constructor(
    private readonly capturaRepository: CapturaRepository,
    @InjectModel(Spot)
    private readonly spotModel: typeof Spot,
    @InjectModel(SpotEspecie)
    private readonly spotEspecieModel: typeof SpotEspecie,
    @InjectModel(Especie)
    private readonly especieModel: typeof Especie,
  ) {}


  
  private calcularDistancia(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) ** 2;
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }


  private async buscarSpotCercano(
    latitud: number,
    longitud: number,
  ): Promise<string | undefined> {
    const spots = await this.spotModel.findAll();
    let spotMasCercano: string | undefined = undefined;
    let distanciaMinima = 1; 

    for (const spot of spots) {
      const ubicacion = spot.ubicacion as GeoJSONPoint;
      if (ubicacion && ubicacion.coordinates) {
        const [spotLon, spotLat] = ubicacion.coordinates;
        const distancia = this.calcularDistancia(
          latitud,
          longitud,
          spotLat,
          spotLon,
        );

        if (distancia < distanciaMinima) {
          distanciaMinima = distancia;
          spotMasCercano = spot.id;
        }
      }
    }

    return spotMasCercano;
  }

  private async registrarEspecieEnSpot(spotId: string, especieId: string): Promise<void> {
    const existeRelacion = await this.spotEspecieModel.findOne({
      where: {
        idSpot: spotId,
        idEspecie: especieId,
      },
    });

    if (!existeRelacion) {
      const nuevoRegistro = new this.spotEspecieModel();
      nuevoRegistro.idSpotEspecie = uuidv4();
      nuevoRegistro.idSpot = spotId;
      nuevoRegistro.idEspecie = especieId;
      await nuevoRegistro.save();
    }
  }

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
    let spotIdFinal = capturaDto.spotId;

    if (capturaDto.latitud && capturaDto.longitud && !capturaDto.spotId) {
      spotIdFinal = await this.buscarSpotCercano(
        capturaDto.latitud,
        capturaDto.longitud,
      );
    }

    const nuevaCaptura = {
      id: uuidv4(),
      idUsuario,
      especieId: capturaDto.especieId,
      fecha: new Date(capturaDto.fecha),
      ubicacion: capturaDto.ubicacion,
      spotId: spotIdFinal,
      latitud: capturaDto.latitud,
      longitud: capturaDto.longitud,
      peso: capturaDto.peso,
      tamanio: capturaDto.tamanio,
      carnada: capturaDto.carnada,
      tipoPesca: capturaDto.tipoPesca,
      foto: imagenPath,
      notas: capturaDto.notas,
      clima: capturaDto.clima,
      horaCaptura: capturaDto.horaCaptura,
      fechaCreacion: new Date(),
      fechaActualizacion: new Date(),
    };

    const captura = await this.capturaRepository.create(nuevaCaptura);

    if (spotIdFinal) {
      await this.registrarEspecieEnSpot(spotIdFinal, capturaDto.especieId);
    }

    return captura;
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
      spotId: capturaDto.spotId,
      latitud: capturaDto.latitud,
      longitud: capturaDto.longitud,
      peso: capturaDto.peso,
      tamanio: capturaDto.tamanio,
      carnada: capturaDto.carnada,
      tipoPesca: capturaDto.tipoPesca,
      notas: capturaDto.notas,
      clima: capturaDto.clima,
      horaCaptura: capturaDto.horaCaptura,
      fechaActualizacion: new Date(),
      ...(imagenPath && { foto: imagenPath }),
    };

    const captura = await this.capturaRepository.update(id, datosActualizados);

    if (capturaDto.spotId) {
      await this.registrarEspecieEnSpot(capturaDto.spotId, capturaDto.especieId);
    }

    return captura;
  }

  async delete(id: string): Promise<void> {
    return this.capturaRepository.delete(id);
  }

  async findCapturasDestacadasBySpot(spotId: string): Promise<Captura[]> {
    const capturas = await this.capturaRepository.findCapturasDestacadasBySpot(spotId);
    
    return capturas.map(captura => {
      const capturaJson = captura.toJSON();
      return {
        ...capturaJson,
        peso: capturaJson.peso ? parseFloat(capturaJson.peso.toString()) : null,
        tamanio: capturaJson.tamanio ? parseFloat(capturaJson.tamanio.toString()) : null,
      } as Captura;
    });
  }

  async obtenerDetalleEspecies(especiesIds: string[]): Promise<Map<string, any>> {
    const especies = await this.especieModel.findAll({
      where: { idEspecie: especiesIds },
      include: [
        {
          model: NombreEspecie,
          as: 'nombresComunes',
          attributes: ['id', 'nombre'],
          required: false,
        },
      ],
      attributes: ['idEspecie', 'nombreCientifico', 'imagen'],
    });

    const especiesMap = new Map();
    especies.forEach(especie => {
      const especieJson = especie.toJSON() as any;
      especiesMap.set(especieJson.idEspecie, {
        nombreCientifico: especieJson.nombreCientifico || especieJson.idEspecie,
        nombresComunes: especieJson.nombresComunes?.map((n: any) => n.nombre) || [],
        imagen: especieJson.imagen,
      });
    });

    return especiesMap;
  }

  async cantCapturas(usuarioId: string): Promise<number>{
    return this.capturaRepository.cantCapturas(usuarioId);
  }

  async getCapturasPorMes(usuarioId: string): Promise<CapturasPorMesDto[]> {
    const capturas = await this.capturaRepository.findUltimoAnoByUsuario(usuarioId);

    const resumen: CapturasPorMesDto[] = [];

    for (const captura of capturas) {
      const mes = captura.fecha.toLocaleString('default', { month: 'short' });
      const existente = resumen.find(r => r.mes === mes);

      if (existente) {
        existente.cantidad++;
      } else {
        resumen.push({ mes, cantidad: 1 });
      }
    }

    return resumen.sort(
      (a, b) =>
        new Date(`${a.mes} 1, 2000`).getTime() -
        new Date(`${b.mes} 1, 2000`).getTime()
    );
  }

}
