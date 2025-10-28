import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class CrearComentarioDto {
  @IsString()
  @IsOptional()
  idSpot?: string;

  @IsString()
  @IsOptional()
  idCaptura?: string;

  @IsString()
  @IsNotEmpty()
  contenido: string;
}
