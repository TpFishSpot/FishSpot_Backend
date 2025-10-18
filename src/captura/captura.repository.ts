import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Captura, CapturaCreationProps } from 'src/models/Captura';
import { Usuario } from 'src/models/Usuario';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { Transaction } from 'sequelize';

@Injectable()
export class CapturaRepository {
  constructor(
    @InjectModel(Captura)
    private readonly capturaModel: typeof Captura,
  ) {}

  async create(captura: CapturaCreationProps, options?: { transaction?: Transaction }) {
    return this.capturaModel.create(captura, options);
  }

  async findAll(): Promise<Captura[]> {
    return this.capturaModel.findAll({
      include: [
        {
          model: Usuario,
          attributes: ['nombre', 'email']
        },
        {
          model: Especie,
          attributes: ['id', 'nombreCientifico', 'descripcion', 'imagen'],
          include: [
            {
              model: NombreEspecie,
              attributes: ['nombre']
            }
          ]
        }
      ],
      order: [['fechaCreacion', 'DESC']]
    });
  }

  async findOne(id: string): Promise<Captura> {
    const captura = await this.capturaModel.findOne({
      where: { id },
      include: [
        {
          model: Usuario,
          attributes: ['nombre', 'email']
        },
        {
          model: Especie,
          attributes: ['id', 'nombreCientifico', 'descripcion', 'imagen'],
          include: [
            {
              model: NombreEspecie,
              attributes: ['nombre']
            }
          ]
        }
      ]
    });
    
    if (!captura) {
      throw new NotFoundException(`Captura with ID ${id} not found`);
    }
    
    return captura;
  }

  async findByUsuario(usuarioId: string): Promise<Captura[]> {
    return this.capturaModel.findAll({
      where: { idUsuario: usuarioId },
      include: [
        {
          model: Especie,
          attributes: ['id', 'nombreCientifico', 'descripcion', 'imagen'],
          include: [
            {
              model: NombreEspecie,
              attributes: ['nombre']
            }
          ]
        }
      ],
      order: [['fechaCreacion', 'DESC']]
    });
  }

  async findByEspecie(especieId: string): Promise<Captura[]> {
    return this.capturaModel.findAll({
      where: { especieId },
      include: [
        {
          model: Usuario,
          attributes: ['nombre', 'email']
        }
      ],
      order: [['fechaCreacion', 'DESC']]
    });
  }

  async update(id: string, updateData: Partial<CapturaCreationProps>): Promise<Captura> {
    await this.capturaModel.update(updateData, { where: { id } });
    return this.findOne(id);
  }

  async delete(id: string): Promise<void> {
    const result = await this.capturaModel.destroy({ where: { id } });
    if (result === 0) {
      throw new NotFoundException(`Captura with ID ${id} not found`);
    }
  }

  async findCapturasDestacadasBySpot(spotId: string): Promise<Captura[]> {
    return this.capturaModel.findAll({
      where: { spotId },
      include: [
        {
          model: Usuario,
          attributes: ['id', 'nombre', 'email', 'foto']
        },
        {
          model: Especie,
          attributes: ['id', 'nombreCientifico', 'descripcion', 'imagen'],
          include: [
            {
              model: NombreEspecie,
              attributes: ['nombre']
            }
          ]
        }
      ],
      order: [
        ['peso', 'DESC NULLS LAST'],
        ['fechaCreacion', 'DESC']
      ],
      limit: 3
    });
  }
}
