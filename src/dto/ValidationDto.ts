import { IsUUID, IsOptional, IsString, MaxLength, Matches } from 'class-validator';
import { Transform } from 'class-transformer';

export class ParamIdDto {
  @IsUUID(4, { message: 'El ID debe ser un UUID válido' })
  id: string;
}

export class QueryUsuarioDto {
  @IsOptional()
  @IsUUID(4, { message: 'El ID de usuario debe ser un UUID válido' })
  usuario?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100, { message: 'El ID de especie no puede exceder 100 caracteres' })
  @Matches(/^[\w-]+$/, { message: 'El ID de especie solo puede contener letras, números y guiones' })
  @Transform(({ value }) => value?.trim())
  especie?: string;
}