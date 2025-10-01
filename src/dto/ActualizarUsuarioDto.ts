import { IsOptional, IsString, IsEmail } from 'class-validator';

export class ActualizarUsuarioDto {
  @IsOptional()
  @IsString()
  nombre?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  foto?: string | null;
}
