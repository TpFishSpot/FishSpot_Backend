import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CrearRespuestaDto {
  @IsString()
  @IsNotEmpty()
  idSpot: string;

  @IsString()
  @IsNotEmpty()
  idComentarioPadre: string;

  @IsString()
  @IsNotEmpty()
  contenido: string;
}
