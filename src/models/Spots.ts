import { EstadoSpot } from "./EstadoSpot";

export class Spot{
    idSpot            : string;
    nombre            : string;
    estado            : EstadoSpot;
    descripcion       : string;
    ubicacion         : string; //postgis;
    fechaPublicacion  : Date;
    idUsuario         : string;
    fechaActualizacion: Date;
    idUsuarioActualizo: string; 
    idSpotTipoPesca   : string;
    idSpotEspecie     : string;
}