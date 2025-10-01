import { IsString, IsNotEmpty } from 'class-validator';

export class CreateReporteDto {
  @IsString()
  @IsNotEmpty()
  idSpot: string;

  @IsString()
  descripcion: string;
}
