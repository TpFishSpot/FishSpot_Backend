import { EstadoSpot } from 'src/models/EstadoSpot';

export class SpotDto {
  id: string;
  nombre: string;
  estado: EstadoSpot;
  descripcion: string;
  ubicacion: object;
  fechaPublicacion: Date;
  fechaActualizacion: Date;
  idUsuario: string;
  idUsuarioActualizo: string;
}
