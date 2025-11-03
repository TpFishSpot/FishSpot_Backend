import { IsNotEmpty, IsString, IsUUID } from 'class-validator';

export class CrearComentarioDto {
  @IsString()
  @IsNotEmpty()
  idSpot: string;

  @IsString()
  @IsNotEmpty()
  contenido: string;
}
