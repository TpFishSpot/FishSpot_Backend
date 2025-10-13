import { BadRequestException, Injectable } from '@nestjs/common';
import { ComentarioRepository } from './comentario.repository';
import { v4 as uuidv4 } from 'uuid';
import { ComentarioDto } from 'src/dto/ComentarioDto';
import { Usuario } from 'src/models/Usuario';

@Injectable()
export class ComentarioService {
  constructor(private readonly comentarioRepository: ComentarioRepository) {}

  async listarPorSpot(idSpot: string): Promise<ComentarioDto[]> {
    const comentarios = await this.comentarioRepository.findBySpotId(idSpot);

    return comentarios.map((comentario) => ({
      id: comentario.id,
      contenido: comentario.contenido,
      fecha: comentario.fecha,
      idUsuario: comentario.idUsuario,
      idSpot: comentario.idSpot,
      usuario: comentario.usuario,
    }));
  }

  async agregarComentario(idUsuario: string, idSpot: string, contenido: string): Promise<ComentarioDto> {
    if (!contenido?.trim()) {
      throw new BadRequestException('El comentario no puede estar vacío');
    }

    const nuevoComentario = {
      id: uuidv4(),
      idUsuario,
      idSpot,
      contenido,
      fecha: new Date(),
    };

    const comentario = await this.comentarioRepository.createComentario(nuevoComentario);
    return {
      id: comentario.id,
      contenido: comentario.contenido,
      fecha: comentario.fecha,
      idUsuario: comentario.idUsuario,
      idSpot: comentario.idSpot,
      usuario: comentario.usuario,
    };
  }
}
