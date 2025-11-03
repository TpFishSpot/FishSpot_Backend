import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Captura, CapturaCreationProps } from 'src/models/Captura';
import { Usuario } from 'src/models/Usuario';
import { Especie } from 'src/models/Especie';
import { NombreEspecie } from 'src/models/NombreEspecie';
import { Transaction, QueryTypes, Op } from 'sequelize';
import { fn, col, literal } from 'sequelize';

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

  async getEstadisticasBySpot(spotId: string): Promise<any> {
    const totalCapturas = await this.capturaModel.count({
      where: { spotId }
    });

    if (totalCapturas === 0) {
      return {
        totalCapturas: 0,
        especiesUnicas: 0,
        especiesDetalle: [],
        capturasPorMes: {},
        carnadasMasUsadas: [],
        tiposPescaMasUsados: [],
        mejoresHorarios: {
          madrugada: 0,
          mañana: 0,
          tarde: 0,
          noche: 0
        },
        climasRegistrados: {}
      };
    }

    const especiesUnicas = await this.capturaModel.count({
      where: { spotId },
      distinct: true,
      col: 'especieId'
    });

    const especiesDetalleRaw = await this.capturaModel.sequelize?.query(`
      SELECT 
        c."especieId",
        e."nombreCientifico",
        e."imagen",
        COUNT(c.id) as "totalCapturas",
        AVG(c.peso) as "pesoPromedio",
        MAX(c.peso) as "pesoMaximo",
        AVG(c.tamanio) as "tamanioPromedio",
        MAX(c.tamanio) as "tamanioMaximo",
        ARRAY_AGG(DISTINCT n.nombre) FILTER (WHERE n.nombre IS NOT NULL) as "nombresComunes"
      FROM "Captura" c
      JOIN "Especie" e ON c."especieId" = e.id
      LEFT JOIN "NombreComunEspecie" n ON e.id = n."idEspecie"
      WHERE c."spotId" = :spotId
      GROUP BY c."especieId", e."nombreCientifico", e."imagen"
      ORDER BY COUNT(c.id) DESC
    `, {
      replacements: { spotId },
      type: QueryTypes.SELECT
    }) || [];

    const especiesDetalle = especiesDetalleRaw.map((item: any) => ({
      especieId: item.especieId,
      nombreCientifico: item.nombreCientifico,
      nombresComunes: item.nombresComunes || [],
      imagen: item.imagen,
      totalCapturas: parseInt(item.totalCapturas),
      pesoPromedio: item.pesoPromedio ? parseFloat(item.pesoPromedio).toFixed(2) : null,
      pesoMaximo: item.pesoMaximo ? parseFloat(item.pesoMaximo).toFixed(2) : null,
      tamanioPromedio: item.tamanioPromedio ? parseFloat(item.tamanioPromedio).toFixed(2) : null,
      tamanioMaximo: item.tamanioMaximo ? parseFloat(item.tamanioMaximo).toFixed(2) : null
    }));

    const capturasPorMesRaw = await this.capturaModel.findAll({
      where: { spotId },
      attributes: [
        [fn('TO_CHAR', col('fecha'), 'YYYY-MM'), 'mes'],
        [fn('COUNT', col('id')), 'cantidad']
      ],
      group: [fn('TO_CHAR', col('fecha'), 'YYYY-MM')],
      order: [[fn('TO_CHAR', col('fecha'), 'YYYY-MM'), 'ASC']],
      raw: true
    });

    const capturasPorMes = capturasPorMesRaw.reduce((acc, item: any) => {
      acc[item.mes] = parseInt(item.cantidad);
      return acc;
    }, {});

    const carnadasMasUsadas = await this.capturaModel.findAll({
      where: { spotId },
      attributes: [
        'carnada',
        [fn('COUNT', col('id')), 'cantidad']
      ],
      group: ['carnada'],
      order: [[fn('COUNT', col('id')), 'DESC']],
      limit: 5,
      raw: true
    });

    const tiposPescaMasUsados = await this.capturaModel.findAll({
      where: { spotId },
      attributes: [
        'tipoPesca',
        [fn('COUNT', col('id')), 'cantidad']
      ],
      group: ['tipoPesca'],
      order: [[fn('COUNT', col('id')), 'DESC']],
      limit: 5,
      raw: true
    });

    const horariosRaw = await this.capturaModel.findAll({
      where: { spotId },
      attributes: [
        'horaCaptura',
        [fn('COUNT', col('id')), 'cantidad']
      ],
      group: ['horaCaptura'],
      raw: true
    });

    const mejoresHorarios = this.agruparPorFranjaHoraria(horariosRaw);

    const climasRaw = await this.capturaModel.findAll({
      where: { spotId },
      attributes: [
        'clima',
        [fn('COUNT', col('id')), 'cantidad']
      ],
      group: ['clima'],
      raw: true
    });

    const climasRegistrados = climasRaw.reduce((acc, item: any) => {
      if (item.clima) {
        acc[item.clima] = parseInt(item.cantidad);
      }
      return acc;
    }, {});

    return {
      totalCapturas,
      especiesUnicas,
      especiesDetalle,
      capturasPorMes,
      carnadasMasUsadas: carnadasMasUsadas.map((item: any) => ({
        nombre: item.carnada,
        cantidad: parseInt(item.cantidad)
      })),
      tiposPescaMasUsados: tiposPescaMasUsados.map((item: any) => ({
        nombre: item.tipoPesca,
        cantidad: parseInt(item.cantidad)
      })),
      mejoresHorarios,
      climasRegistrados
    };
  }

  private agruparPorFranjaHoraria(horariosRaw: any[]): any {
    const franjas = {
      madrugada: 0,
      mañana: 0,
      tarde: 0,
      noche: 0
    };

    horariosRaw.forEach((item: any) => {
      if (!item.horaCaptura) return;

      const hora = parseInt(item.horaCaptura.split(':')[0]);
      const cantidad = parseInt(item.cantidad);

      if (hora >= 0 && hora < 6) {
        franjas.madrugada += cantidad;
      } else if (hora >= 6 && hora < 12) {
        franjas.mañana += cantidad;
      } else if (hora >= 12 && hora < 18) {
        franjas.tarde += cantidad;
      } else {
        franjas.noche += cantidad;
      }
    });

    return franjas;
  }

  async cantCapturas(usuarioId: string): Promise<number> {
    return this.capturaModel.count({
        where: { idUsuario: usuarioId }
    });
  }
  
  async findUltimoAnoByUsuario(usuarioId: string): Promise<Captura[]> {
    const haceUnAno = new Date();
    haceUnAno.setFullYear(haceUnAno.getFullYear() - 1);

    return this.capturaModel.findAll({
      where: {
        idUsuario: usuarioId,
        fecha: {
          [Op.gte]: haceUnAno,
        },
      },
      order: [['fecha', 'ASC']],
    });
  }
}
