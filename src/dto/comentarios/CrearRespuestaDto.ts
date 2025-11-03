import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class CrearRespuestaDto {
  @IsString()
  @IsOptional()
  idSpot?: string;

  @IsString()
  @IsOptional()
  idCaptura?: string;

  @IsString()
  @IsNotEmpty()
  idComentarioPadre: string;

  @IsString()
  @IsNotEmpty()
  contenido: string;
}
