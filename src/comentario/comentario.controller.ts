import { Body, Controller, Get, Param, ParseUUIDPipe, Post, Req, UseGuards } from '@nestjs/common';
import { Public, Roles } from 'src/auth/decorator';
import { ComentarioService } from './comentario.service';
import { UserRole } from 'src/auth/enums/roles.enum';
import { Usuario } from 'src/models/Usuario';
import { RequestWithUser } from 'src/auth/interfaces/auth.interface';
import { Comentario } from 'src/models/Comentario';
import { ComentarioDto } from 'src/dto/ComentarioDto';

@Controller('comentario')
export class ComentarioController {
  constructor(private readonly comentarioService: ComentarioService) {}

  @Get(':spotId')
  @Public()
  async listarPorSpot(@Param('spotId') spotId: string) : Promise<ComentarioDto[]>{
    return this.comentarioService.listarPorSpot(spotId);
  }

  @Roles(UserRole.USER)
  @Post()
  async agregarComentario(
    @Req() req: RequestWithUser,
    @Body() body: { idSpot: string; contenido: string },
  ): Promise<ComentarioDto> {
    const idUsuario = req.user.uid;

    return this.comentarioService.agregarComentario(idUsuario, body.idSpot, body.contenido);
  }
}
