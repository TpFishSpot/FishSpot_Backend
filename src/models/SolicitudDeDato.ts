
export class SolicitudDeDato{
    idSolicitud        : string;
    idUsuario          : string;
    idSpot ?           : string;   //este es por si hay que editar un spot 
    nombreComun ?      : string;
    idEspecie ?        : string;   //este es por si hay que editar una especiee
    nombreCientifico ? : string;
    descripcion   ?    : string;
    comentario    ?    : string;   // por si el usuario quiere que agregemos algo de carnadas o funcionalidad a modo de sugerencia
}