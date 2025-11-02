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
  @IsString() 
  spotId?: string; 

  @IsOptional()  
  @IsNumber() 
  latitud?: number;  

  @IsOptional() 
  @IsNumber()  
  longitud?: number;  

  @IsOptional()
  @IsNumber()
  peso?: number;

  @IsOptional()
  @IsNumber()
  tamanio?: number;

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
