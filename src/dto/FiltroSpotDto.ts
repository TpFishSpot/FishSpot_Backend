import { IsOptional, IsString, Matches, MaxLength } from 'class-validator';
import { Transform } from 'class-transformer';

export class FiltroSpotDto {
  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'La lista de tipos de pesca no puede exceder 500 caracteres' })
  @Matches(/^[\w\s,áéíóúñÁÉÍÓÚÑ-]+$/, { 
    message: 'Los tipos de pesca solo pueden contener letras, números, espacios, comas y guiones' 
  })
  @Transform(({ value }) => value?.trim())
  tipoPesca?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500, { message: 'La lista de especies no puede exceder 500 caracteres' })
  @Matches(/^[\w\s,áéíóúñÁÉÍÓÚÑ-]+$/, { 
    message: 'Las especies solo pueden contener letras, números, espacios, comas y guiones' 
  })
  @Transform(({ value }) => value?.trim())
  especies?: string;


  get tiposPescaArray(): string[] {
    if (!this.tipoPesca) return [];
    return this.tipoPesca
      .split(',')
      .map(tipo => tipo.trim())
      .filter(tipo => tipo.length > 0)
      .slice(0, 20); 
  }
  get especiesArray(): string[] {
    if (!this.especies) return [];
    return this.especies
      .split(',')
      .map(especie => especie.trim())
      .filter(especie => especie.length > 0)
      .slice(0, 20);
  }
}