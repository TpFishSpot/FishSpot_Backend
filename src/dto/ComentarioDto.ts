import { Usuario } from "src/models/Usuario";

export class ComentarioDto {
  id: string;
  contenido: string;
  fecha: Date;
  idUsuario: string;
  idSpot: string;
  usuario: Usuario;
}
