import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op, Transaction } from 'sequelize';
import { v4 as uuidv4 } from 'uuid';
import { EspecieConNombreComun } from 'src/dto/EspecieConNombreComun';
import { Carnada } from 'src/models/Carnada';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { TipoPesca } from 'src/models/TipoPesca';
import { EspecieTipoPesca } from 'src/models/EspecieTipoPesca';
import { SpotEspecie } from 'src/models/SpotEspecie';
import { SpotCarnadaEspecie } from 'src/models/SpotCarnadaEspecie';

export interface TipoPescaEspecieDto {
  id: string;
  nombre: string;
  descripcion?: string; 
}

@Injectable()
export class EspecieRepository {
    constructor(
        @InjectModel(SpotCarnadaEspecie)
        private readonly spotCarnadaEspecieModel: typeof SpotCarnadaEspecie,  
        @InjectModel(Especie)
        private readonly especieModel: typeof Especie,
        @InjectModel(EspecieTipoPesca)
        private readonly  especieTipoPesca: typeof EspecieTipoPesca,
        @InjectModel(SpotEspecie)
        private readonly spotEspecieModel: typeof SpotEspecie,
    ) {}
    
    async findCarnadasByEspecie(idEspecie: string): Promise<Carnada[]> {
    const registros = await this.spotCarnadaEspecieModel.findAll({
      where: { idEspecie },
      include: [Carnada],
    });

    // Si no hay carnadas, devolvemos array vacío
    if (!registros.length) {
      return [];
    }

    const carnadas = registros.map(r => r.carnada);
    const uniques = Array.from(new Map(carnadas.map(c => [c.idCarnada, c])).values());
    return uniques;
  }

  async findOne(idEspecie: string): Promise<EspecieConNombreComun>{
    const especie = await this.especieModel.findOne({
      where: { idEspecie },
      include: [
        {
          model: NombreEspecie,
          attributes: ['nombre'],
        },
      ],
    });

    if (!especie) {
      throw new NotFoundException(`Especie con id ${idEspecie} no encontrada`);
    }
    return {
      id: especie.idEspecie,
      nombre_cientifico: especie.nombreCientifico,
      descripcion: especie.descripcion,
      imagen: especie.imagen,
      nombre_comun: especie.nombresComunes?.map(n => n.nombre) || [], 
    };
  }

  async findCarnadasByEspecies(idsEspecies: string[]): Promise<Record<string, Carnada[]>> {
    const registrosCarnadas = await this.spotCarnadaEspecieModel.findAll({
      where: { idEspecie: { [Op.in]: idsEspecies } },
      include: [Carnada],
    });

    const carnadasPorEspecie: Record<string, Carnada[]> = {};

    for (const registro of registrosCarnadas) {
      const idEspecieActual = registro.idEspecie;
      const carnadaActual = registro.carnada;

      if (!carnadasPorEspecie[idEspecieActual]) {
        carnadasPorEspecie[idEspecieActual] = [];
      }

      const yaExiste = carnadasPorEspecie[idEspecieActual].some(
        c => c.idCarnada === carnadaActual.idCarnada
      );

      if (!yaExiste) {
        carnadasPorEspecie[idEspecieActual].push(carnadaActual);
      }
    }

        return carnadasPorEspecie;
    }

    async findTipoPescaEspecie(idEspecie: string): Promise<TipoPescaEspecieDto[]> {
        const registros = await this.especieTipoPesca.findAll({
            where: { idEspecie },
            include: [{ model: TipoPesca, as: 'tipoPesca' }],
        });

        // Si no hay registros, devolvemos array vacío en lugar de error
        if (!registros.length) {
            return [];
        }

        return registros.map(registro => ({
            id: registro.tipoPesca.id,
            nombre: registro.tipoPesca.nombre,
            descripcion: registro.descripcion || registro.tipoPesca.descripcion,
        }));
    }

    async bulkCreateSpotEspecie(idSpot: string, especies: string[], transaction: Transaction) {
        const registros = especies.map(idEspecie => ({
            idSpotEspecie: uuidv4(),
            idSpot,
            idEspecie
        })) as  any[];

        await this.spotEspecieModel.bulkCreate(registros, { transaction });
    }

    async getEspecies(): Promise<EspecieConNombreComun[]> {
        const especies = await this.especieModel.findAll({
            include: [{ model: NombreEspecie, attributes: ['nombre'] }],
        });

        return especies.map(e => ({
            id: e.idEspecie,
            nombre_cientifico: e.nombreCientifico,
            descripcion: e.descripcion,
            imagen: e.imagen,
            nombre_comun: e.nombresComunes?.map(n => n.nombre) || [],
        }));
    }
}

