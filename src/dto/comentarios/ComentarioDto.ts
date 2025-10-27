import { IsDate, IsString } from "class-validator";
import { Usuario } from "src/models/Usuario";

export class ComentarioDto {
  @IsString()
  id: string;
  @IsString()
  contenido: string;
  @IsDate()
  fecha: Date;
  @IsString()
  idUsuario: string;
  @IsString()
  idSpot: string;
  
  usuario: Usuario;
  @IsString()
  idComentarioPadre?: string;
}
