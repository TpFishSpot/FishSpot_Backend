import {
  IsString,
  IsOptional,
  IsNumber,
  IsDateString,
} from 'class-validator';

export class CapturaDto {
  @IsString()
  especieId: string;

  @IsDateString()
  fecha: string;

  @IsString()
  ubicacion: string;

  @IsOptional()
  @IsNumber()
  peso?: number;

  @IsOptional()
  @IsNumber()
  longitud?: number;

  @IsString()
  carnada: string;

  @IsString()
  tipoPesca: string;

  @IsOptional()
  @IsString()
  notas?: string;

  @IsOptional()
  @IsString()
  clima?: string;

  @IsOptional()
  @IsString()
  horaCaptura?: string;
}
