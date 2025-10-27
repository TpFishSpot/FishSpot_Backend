import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Op } from 'sequelize';
import { Comentario } from 'src/models/Comentario';
import { Spot } from 'src/models/Spot';
import { Usuario } from 'src/models/Usuario';

@Injectable()
export class ComentarioRepository {
  constructor(
    @InjectModel(Comentario)
    private readonly comentarioModel: typeof Comentario,
  ) {}
  async findBySpotId(spotId: string): Promise<Comentario[]> {
    return this.comentarioModel.findAll({
      where: { idSpot: spotId },
      order: [['fecha', 'DESC']],
      include: ['usuario'],
    });
  }

  async findPadresBySpotId(
    spotId: string,
    limit: number,
    lastFecha?: Date,
    lastId?: string
  ): Promise<Comentario[]> {
    const where: any = { idSpot: spotId, idComentarioPadre: null };

    if (lastFecha) {
      where[Op.or] = [
        { fecha: { [Op.lt]: lastFecha } },
        lastId ? { fecha: lastFecha, id: { [Op.lt]: lastId } } : undefined,
      ].filter(Boolean);
    }

    return this.comentarioModel.findAll({
      where,
      order: [
        ['fecha', 'DESC'],
        ['id', 'DESC'],
      ],
      include: ['usuario'],
      limit,
    });
  }

  async findRespuestasByPadresIds(padresIds: string[]): Promise<Comentario[]> {
    if (!padresIds.length) return [];

    return this.comentarioModel.findAll({
      where: { idComentarioPadre: { [Op.in]: padresIds } },
      order: [['fecha', 'ASC']],
      include: ['usuario'],
    });
  }


  async findById(id: string): Promise<Comentario> {
    const comentario = await this.comentarioModel.findByPk(id, {
      include: [Usuario, Spot],
    });

    if (!comentario) {
      throw new NotFoundException(`Comentario con id ${id} no encontrado`);
    }

    return comentario;
  }

  async createComentario(data: Partial<Comentario>): Promise<Comentario> {
    const comentario = await this.comentarioModel.create(data);

    const comentarioCompleto = await this.comentarioModel.findByPk(comentario.id, {
      include: [Usuario],
    });

    return comentarioCompleto!;
  }
}