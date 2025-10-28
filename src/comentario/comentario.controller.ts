import { Body, Controller, Get, Param, ParseUUIDPipe, Post, Query, Req, UseGuards } from '@nestjs/common';
import { Public, Roles } from 'src/auth/decorator';
import { ComentarioService } from './comentario.service';
import { UserRole } from 'src/auth/enums/roles.enum';
import { Usuario } from 'src/models/Usuario';
import { RequestWithUser } from 'src/auth/interfaces/auth.interface';
import { Comentario } from 'src/models/Comentario';
import { ComentarioDto } from 'src/dto/comentarios/ComentarioDto';
import { CrearRespuestaDto } from 'src/dto/comentarios/CrearRespuestaDto';
import { CrearComentarioDto } from 'src/dto/comentarios/CrearComentarioDto';

@Controller('comentario')
export class ComentarioController {
  constructor(private readonly comentarioService: ComentarioService) {}

  @Get(':entityId')
  @Public()
  async listarComentarios(
    @Param('entityId') entityId: string,
    @Query('lastFecha') lastFecha?: string,
    @Query('lastId') lastId?: string,
  ): Promise<ComentarioDto[]> {
    const fecha = lastFecha ? new Date(lastFecha) : undefined;
    return this.comentarioService.listarComentarios(entityId, fecha, lastId);
  }

  @Roles(UserRole.USER)
  @Post()
  async agregarComentario(
    @Req() req: RequestWithUser,
    @Body() body: CrearComentarioDto,
  ): Promise<ComentarioDto> {
    const idUsuario = req.user.uid;
    return this.comentarioService.agregarComentario(idUsuario, body.idSpot, body.idCaptura, body.contenido);
  }
  
  @Roles(UserRole.USER)
  @Roles(UserRole.USER)
  @Post('responder')
  async responderComentario(
    @Req() req: RequestWithUser,
    @Body() body: CrearRespuestaDto,
  ): Promise<ComentarioDto> {
    const idUsuario = req.user.uid;
    return this.comentarioService.responderComentario(
      idUsuario,
      body.idSpot,
      body.idCaptura,
      body.idComentarioPadre,
      body.contenido,
    );
  }
}
