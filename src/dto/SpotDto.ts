import {
  IsString,
  IsObject,
  IsOptional
} from 'class-validator';
import { EstadoSpot } from 'src/models/EstadoSpot';

export class SpotDto {
  @IsString()
  nombre: string;

  @IsObject()
  ubicacion: {
    type: string;
    coordinates: [number, number];
  };

  @IsString()
  estado: EstadoSpot;

  @IsString()
  descripcion: string;

  @IsString()
  idUsuario: string;

  @IsString()
  idUsuarioActualizo: string;

  @IsOptional()
  @IsString()
  imagenPortada?: string;
}

