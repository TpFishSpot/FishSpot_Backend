
CREATE TYPE NivelPescador AS ENUM ('Principiante','Aficionado','Intermedio','Avanzado','Experto','Profesional');
CREATE TYPE EstadoSpot AS ENUM ('Esperando','Aceptado','Rechazado','Inactivo');
CREATE TYPE TipoCarnada AS ENUM ('ArtificialBlando','ArtificialDuro','CarnadaViva','CarnadaMuerta','NaturalNoViva','MoscaArtificial','Otros');

 
CREATE TABLE Tipo_Pesca (
    id VARCHAR(255) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE Usuario (
    id VARCHAR(255) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    nivel_pescador NivelPescador,
    email VARCHAR(50) NOT NULL
);

CREATE TABLE Nombre_Especie (
    id VARCHAR(255) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL
);

CREATE TABLE Especie (
    id VARCHAR(255) PRIMARY KEY,
    id_nombre_especie VARCHAR(255),
    nombre_cientifico VARCHAR(255),
    descripcion VARCHAR(255),
    FOREIGN KEY (id_nombre_especie) REFERENCES Nombre_Especie(id)
);

CREATE TABLE Carnada (
    id VARCHAR(255) PRIMARY KEY,
    nombre VARCHAR(255),
    tipo_carnada TipoCarnada,
    descripcion VARCHAR(255)
);

--  Spot

-- antes de crear hay que ejecutar esto 
CREATE EXTENSION IF NOT EXISTS postgis;


CREATE TABLE Spot (
    id VARCHAR(255) PRIMARY KEY,
    id_usuario VARCHAR(255),
    id_usuario_actualizo VARCHAR(255),
    nombre VARCHAR(255),
    estado EstadoSpot,
    descripcion VARCHAR(255),
    ubicacion GEOGRAPHY(Point, 4326),
    fecha_publicacion DATE,
    fecha_actualizacion DATE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id),
    FOREIGN KEY (id_usuario_actualizo) REFERENCES Usuario(id)
);

CREATE TABLE SpotTipoPesca (
    id VARCHAR(255) PRIMARY KEY,
    id_spot VARCHAR(255),
    id_tipo_pesca VARCHAR(255),
    FOREIGN KEY (id_spot) REFERENCES Spot(id),
    FOREIGN KEY (id_tipo_pesca) REFERENCES Tipo_Pesca(id)
);

CREATE TABLE SpotEspecie (
    id VARCHAR(255) PRIMARY KEY,
    id_spot VARCHAR(255),
    id_especie VARCHAR(255),
    FOREIGN KEY (id_spot) REFERENCES Spot(id),
    FOREIGN KEY (id_especie) REFERENCES Especie(id)
);

CREATE TABLE SpotCarnadaEspecie (
    id VARCHAR(255) PRIMARY KEY,
    id_spot VARCHAR(255),
    id_especie VARCHAR(255),
    id_carnada VARCHAR(255),
    FOREIGN KEY (id_spot) REFERENCES Spot(id),
    FOREIGN KEY (id_especie) REFERENCES Especie(id),
    FOREIGN KEY (id_carnada) REFERENCES Carnada(id)
);


CREATE TABLE Comentario (
    id VARCHAR(255) PRIMARY KEY,
    id_usuario VARCHAR(255),
    id_spot VARCHAR(255),
    contenido VARCHAR(255),
    fecha DATE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id),
    FOREIGN KEY (id_spot) REFERENCES Spot(id)
);

CREATE TABLE SolicitudDeDato (
    id VARCHAR(255) PRIMARY KEY,
    id_spot VARCHAR(255),
    id_usuario VARCHAR(255),
    nombre_comun VARCHAR(255),
    nombre_cientifico VARCHAR(255),
    descripcion VARCHAR(255),
    FOREIGN KEY (id_spot) REFERENCES Spot(id),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id)
);

