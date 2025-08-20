DROP TABLE IF EXISTS "Comentario" CASCADE;
DROP TABLE IF EXISTS "SolicitudDeDato" CASCADE;
DROP TABLE IF EXISTS "SpotCarnadaEspecie" CASCADE;
DROP TABLE IF EXISTS "SpotEspecie" CASCADE;
DROP TABLE IF EXISTS "SpotTipoPesca" CASCADE;
DROP TABLE IF EXISTS "Spot" CASCADE;
DROP TABLE IF EXISTS "NombreComunEspecie" CASCADE;
DROP TABLE IF EXISTS "Especie" CASCADE;
DROP TABLE IF EXISTS "Carnada" CASCADE;
DROP TABLE IF EXISTS "Usuario" CASCADE;
DROP TABLE IF EXISTS "TipoPesca" CASCADE;

DROP TYPE IF EXISTS "NivelPescador" CASCADE;
DROP TYPE IF EXISTS "EstadoSpot" CASCADE;
DROP TYPE IF EXISTS "TipoCarnada" CASCADE;


CREATE TYPE "NivelPescador" AS ENUM (
  'Principiante','Aficionado','Intermedio','Avanzado','Experto','Profesional'
);

CREATE TYPE "EstadoSpot" AS ENUM (
  'Esperando','Aceptado','Rechazado','Inactivo'
);

CREATE TYPE "TipoCarnada" AS ENUM (
  'ArtificialBlando','ArtificialDuro','CarnadaViva','CarnadaMuerta','NaturalNoViva','MoscaArtificial','Otros'
);

CREATE TABLE "TipoPesca" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "descripcion" VARCHAR(255) NOT NULL
);

CREATE TABLE "Usuario" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "nivelPescador" "NivelPescador",
  "email" VARCHAR(50) NOT NULL
);

CREATE TABLE "Especie" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombreCientifico" VARCHAR(255),
  "descripcion" VARCHAR(255)
);

CREATE TABLE "NombreComunEspecie" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idEspecie" VARCHAR(255),
  "nombre" VARCHAR(255) NOT NULL,
  FOREIGN KEY ("idEspecie") REFERENCES "Especie"("id")
);

CREATE TABLE "Carnada" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(255),
  "tipoCarnada" "TipoCarnada",
  "descripcion" VARCHAR(255)
);

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE "Spot" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idUsuario" VARCHAR(255),
  "idUsuarioActualizo" VARCHAR(255),
  "nombre" VARCHAR(255),
  "estado" "EstadoSpot",
  "descripcion" VARCHAR(255),
  "ubicacion" GEOGRAPHY(Point, 4326),
  "fechaPublicacion" DATE,
  "fechaActualizacion" DATE,
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id"),
  FOREIGN KEY ("idUsuarioActualizo") REFERENCES "Usuario"("id")
);

CREATE TABLE "SpotTipoPesca" (                                                
  "id" VARCHAR(255) PRIMARY KEY,
  "idSpot" VARCHAR(255),
  "idTipoPesca" VARCHAR(255),
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id"),
  FOREIGN KEY ("idTipoPesca") REFERENCES "TipoPesca"("id")
);

CREATE TABLE "SpotEspecie" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idSpot" VARCHAR(255),
  "idEspecie" VARCHAR(255),
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id"),
  FOREIGN KEY ("idEspecie") REFERENCES "Especie"("id")
);

CREATE TABLE "SpotCarnadaEspecie" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idSpot" VARCHAR(255),
  "idEspecie" VARCHAR(255),
  "idCarnada" VARCHAR(255),
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id"),
  FOREIGN KEY ("idEspecie") REFERENCES "Especie"("id"),
  FOREIGN KEY ("idCarnada") REFERENCES "Carnada"("id")
);

CREATE TABLE "Comentario" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idUsuario" VARCHAR(255),
  "idSpot" VARCHAR(255),
  "contenido" VARCHAR(255),
  "fecha" DATE,
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id"),
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id")
);

CREATE TABLE "SolicitudDeDato" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idSpot" VARCHAR(255),
  "idUsuario" VARCHAR(255),
  "idEspecie" VARCHAR(255),
  "nombreCientifico" VARCHAR(255),
  "descripcion" VARCHAR(255),
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id"),
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id"),
  FOREIGN KEY ("idEspecie") REFERENCES "Especie"("id")
);

-- DATOS DE PRUEBA

INSERT INTO "Usuario" ("id", "nombre", "nivelPescador", "email") VALUES
  ('usuario1', 'Carlos Tarucha', 'Avanzado', 'carlos@example.com'),
  ('usuario2', 'Lucía Señuelera', 'Experto', 'lucia@example.com');

INSERT INTO "TipoPesca" ("id", "nombre", "descripcion") VALUES
  ('tp1', 'Spinning', 'Pesca con señuelos artificiales usando caña y reel.');

INSERT INTO "Especie" ("id", "nombreCientifico", "descripcion") VALUES
  ('es1', 'Hoplias malabaricus', 'Depredador de aguas calmas y cálidas.');

INSERT INTO "NombreComunEspecie" ("id", "idEspecie", "nombre") VALUES
  ('nc1', 'es1', 'Tararira'),
  ('nc2', 'es1', 'Tarucha'),
  ('nc3', 'es1', 'Dientudo'),
  ('nc4', 'es1', 'Lobito'),
  ('nc5', 'es1', 'Cabeza amarga'),
  ('nc6', 'es1', 'Hoplias'),
  ('nc7', 'es1', 'Trucha criolla'),
  ('nc8', 'es1', 'Moncholo loco'),
  ('nc9', 'es1', 'Tigre de agua dulce');

INSERT INTO "Carnada" ("id", "nombre", "tipoCarnada", "descripcion") VALUES
  ('c1', 'Señuelo rana', 'ArtificialBlando', 'Señuelo blando en forma de rana.');

INSERT INTO "Spot" (
  "id", "idUsuario", "idUsuarioActualizo", "nombre", "estado", "descripcion", "ubicacion", "fechaPublicacion", "fechaActualizacion"
) VALUES (
  'SpotSecreto',
  'usuario1',
  'usuario2',
  'Desembocadura del arrollito',
  'Esperando',
  'Un lugar excelente para pescar tarariras con señuelos, pero solo para entendidos.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-58.500998126994794, -35.75352487481563]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE
);

INSERT INTO "SpotTipoPesca" ("id", "idSpot", "idTipoPesca") VALUES
  ('stp1', 'SpotSecreto', 'tp1');

INSERT INTO "SpotEspecie" ("id", "idSpot", "idEspecie") VALUES
  ('se1', 'SpotSecreto', 'es1');

INSERT INTO "SpotCarnadaEspecie" ("id", "idSpot", "idEspecie", "idCarnada") VALUES
  ('sce1', 'SpotSecreto', 'es1', 'c1');

INSERT INTO "Comentario" ("id", "idUsuario", "idSpot", "contenido", "fecha") VALUES
  ('com1', 'usuario1', 'SpotSecreto', 'Fui hace poco y saqué dos tarus hermosas.', CURRENT_DATE);

INSERT INTO "SolicitudDeDato" (
  "id", "idSpot", "idUsuario", "idEspecie", "nombreCientifico", "descripcion"
) VALUES (
  'sol1', 'SpotSecreto', 'usuario2', 'es1', 'Hoplias lacerdae', 'Vi otra especie parecida, se mueve más lento.'
);



ALTER TABLE "Spot"
ADD COLUMN "imagenPortada" VARCHAR(255);


ALTER TABLE "Especie"
ADD COLUMN "imagen" VARCHAR(255);

UPDATE "Especie"
SET "imagen" = 'uploads/tararira.png'
WHERE "id" = 'es1';


-- 1. Nuevas especies
INSERT INTO "Especie" ("id", "nombreCientifico", "descripcion", "imagen") VALUES
('es2', 'Odontesthes bonariensis', 'Pez de agua dulce típico de ríos y lagunas.', 'uploads/pejerrey.png'),
('es3', 'Cyprinus carpio', 'Pez de cuerpo robusto y escamas grandes, muy común en estanques y ríos lentos.', 'uploads/carpa_comun.png'),
('es4', 'Ictalurus punctatus', 'Bagre de agua dulce, de hábitos nocturnos.', 'uploads/bagre.png');

-- 2. Nombres comunes
INSERT INTO "NombreComunEspecie" ("id", "idEspecie", "nombre") VALUES
('nc10', 'es2', 'Pejerrey'),
('nc11', 'es3', 'Carpa común'),
('nc12', 'es4', 'Bagre');

-- 3. Asociar al SpotSecreto
INSERT INTO "SpotEspecie" ("id", "idSpot", "idEspecie") VALUES
('se2', 'SpotSecreto', 'es2'),
('se3', 'SpotSecreto', 'es3'),
('se4', 'SpotSecreto', 'es4');


INSERT INTO "TipoPesca" ("id", "nombre", "descripcion") VALUES
  ('tp2', 'Bait Casting', 'Pesca con caña y reel tipo baitcasting, ideal para especies depredadoras.'),
  ('tp3', 'Pesca de Fondo', 'Pesca con línea en el fondo del agua, efectiva para bagres y carpas.'),
  ('tp4', 'Pesca de Flote', 'Pesca usando boya o flotador, ideal para especies que se alimentan en superficie o media agua.');


INSERT INTO "SpotTipoPesca" ("id", "idSpot", "idTipoPesca") VALUES
  ('stp2', 'SpotSecreto', 'tp1'),
  ('stp3', 'SpotSecreto', 'tp2'),
  ('stp4', 'SpotSecreto', 'tp3'), 
  ('stp5', 'SpotSecreto', 'tp4'); 

INSERT INTO "SpotTipoPesca" ("id", "idSpot", "idTipoPesca") VALUES
  ('stp6', 'SpotSecreto', 'tp3'); 

INSERT INTO "SpotTipoPesca" ("id", "idSpot", "idTipoPesca") VALUES
  ('stp7', 'SpotSecreto', 'tp3'); 

INSERT INTO "SpotTipoPesca" ("id", "idSpot", "idTipoPesca") VALUES
  ('stp8', 'SpotSecreto', 'tp3'), 
  ('stp9', 'SpotSecreto', 'tp4'); 


  select * from "Spot";

DELETE FROM "Spot"
WHERE "id" NOT IN (
  'SpotSecreto'
);

