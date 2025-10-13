import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Comentario } from 'src/models/Comentario';

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

  async createComentario(data: Partial<Comentario>): Promise<Comentario> {
    return this.comentarioModel.create(data);
  }
}