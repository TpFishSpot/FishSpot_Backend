import { BadRequestException, Injectable } from '@nestjs/common';
import { ComentarioRepository } from './comentario.repository';
import { v4 as uuidv4 } from 'uuid';
import { ComentarioDto } from 'src/dto/comentarios/ComentarioDto';
import { Comentario } from 'src/models/Comentario';

@Injectable()
export class ComentarioService {
  constructor(private readonly comentarioRepository: ComentarioRepository) {}

  async listarComentarios(entityId: string, lastFecha?: Date, lastId?: string): Promise<ComentarioDto[]> {
    const limit = 5;

    const comentariosPadre = await this.comentarioRepository.findPadresByEntity(
      entityId,
      limit,
      lastFecha,
      lastId
    );

    const padresIds = comentariosPadre.map(c => c.id);
    const respuestas = await this.comentarioRepository.findRespuestasByPadresIds(padresIds);

    const respuesta: ComentarioDto[] = comentariosPadre.map(comentario => ({
      ...comentario.get(),
      respuestas: respuestas
        .filter(r => r.idComentarioPadre === comentario.id)
        .map(r => r.get()),
    }));
    return respuesta;
  }

  async agregarComentario(idUsuario: string, idSpot?: string, idCaptura?: string, contenido?: string): Promise<ComentarioDto> {
    if (!contenido?.trim()) {
      throw new BadRequestException('El comentario no puede estar vacío');
    }

    if (!idSpot && !idCaptura) {
      throw new BadRequestException('Debe proporcionar idSpot o idCaptura');
    }

    const nuevoComentario = {
      id: uuidv4(),
      idUsuario,
      ...(idSpot && { idSpot }),
      ...(idCaptura && { idCaptura }),
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
      idCaptura: comentario.idCaptura,
      usuario: comentario.usuario,
    };
  }

  async buscarComentario(id: string):Promise<Comentario>{
    return await this.comentarioRepository.findById(id);
  }

  async responderComentario(
    idUsuario: string,
    idSpot?: string,
    idCaptura?: string,
    idComentarioPadre?: string,
    contenido?: string,
  ): Promise<ComentarioDto> {
    if (!contenido?.trim()) {
      throw new BadRequestException('La respuesta no puede estar vacía');
    }

    if (!idSpot && !idCaptura) {
      throw new BadRequestException('Debe proporcionar idSpot o idCaptura');
    }

    const comentarioPadre = await this.buscarComentario(idComentarioPadre!);

    const nuevaRespuesta = {
      id: uuidv4(),
      idUsuario,
      ...(idSpot && { idSpot }),
      ...(idCaptura && { idCaptura }),
      idComentarioPadre,
      contenido,
      fecha: new Date(),
    };

    const respuesta = await this.comentarioRepository.createComentario(nuevaRespuesta);
    return {
      id: respuesta.id,
      contenido: respuesta.contenido,
      fecha: respuesta.fecha,
      idUsuario: respuesta.idUsuario,
      idSpot: respuesta.idSpot,
      idCaptura: respuesta.idCaptura,
      usuario: respuesta.usuario,
      idComentarioPadre: respuesta.idComentarioPadre,
    };
  }
}
