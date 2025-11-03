import { forwardRef, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { Usuario } from 'src/models/Usuario';
import { UsuarioRepository } from './usuario.repository';
import { ActualizarUsuarioDto } from 'src/dto/ActualizarUsuarioDto';
import { EstadisticasDto } from 'src/dto/EstadisticasDto';
import { ComentarioService } from 'src/comentario/comentario.service';
import { SpotService } from 'src/spots/spot.service';
import { CapturaService } from 'src/captura/captura.service';

@Injectable()
export class UsuarioService {
  constructor(
    private readonly usuarioRepository: UsuarioRepository,
    private readonly comentarioService: ComentarioService,
    private readonly spotService: SpotService,
    @Inject(forwardRef(() => CapturaService))
    private readonly capturaService: CapturaService,
  ) {}

  async findAll(): Promise<Usuario[]> {
    return await this.usuarioRepository.findAll();
  }
  async hacerModerador(id: string): Promise<Usuario>{
    return await this.usuarioRepository.hacerModerador(id);
  }
  async rolesDelUsuario(uid: string):Promise<string[]>{
    return await this.usuarioRepository.getUserRoles(uid);
  }

  async findOrCreateUser(uid: string, email: string, name?: string, photoURL?: string): Promise<Usuario> {
    return await this.usuarioRepository.findOrCreateUser(uid, email, name, photoURL);
  }

  async actualizarUsuario(id: string, body: ActualizarUsuarioDto, foto?: Express.Multer.File) {
    if (foto) {
      body.foto = `${process.env.direccionDeFoto}/${foto.filename}`;
    } else if (body.foto) {
      body.foto = body.foto;
    } else {
      body.foto = null;
    }

    return await this.usuarioRepository.actualizarUsuario(id, body);
  }
  async findOne(id: string): Promise<Usuario> {
    return await this.usuarioRepository.findOne(id);
  }

  async estadisticas(id: string): Promise<EstadisticasDto>{
    const cantCapturas = await this.capturaService.cantCapturas(id);
    const cantSpots = await this.spotService.cantSpots(id);
    const cantComentarios = await this.comentarioService.cantComentarios(id);
    const racha = await this.getRachaActual(id);
    const estadisticas: EstadisticasDto = {cantCapturas, cantSpots, cantComentarios, racha};
    return estadisticas;
  }

  async getRachaActual(usuarioId: string): Promise<number> {
    // cuenta cuantos dias consecutivos el usuario subio al menos una captura.
    const capturas = await this.capturaService.findByUsuario(usuarioId);

    if(capturas.length === 0) {
      return 0;
    }

    const capturasOrdenadas = capturas.sort((a, b) => b.fecha.getTime() - a.fecha.getTime()).slice(0, 100);
    let racha = 1;

    for (let i = 1; i < capturasOrdenadas.length; i++) {
      const anterior = capturasOrdenadas[i - 1].fecha;
      const actual = capturasOrdenadas[i].fecha;

      const diffDias = Math.floor(
        (anterior.getTime() - actual.getTime()) / (1000 * 60 * 60 * 24)
      );

      if (diffDias === 1) {
        racha++;
      } else if (diffDias > 1) {
        break;
      }
    }
    return racha;
  }

}
