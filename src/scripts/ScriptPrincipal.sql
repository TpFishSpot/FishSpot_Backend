-- SCRIPT PRINCIPAL FISHSPOT - VERSIÓN COMPLETA Y CORREGIDA

-- ============================================================
-- ELIMINACIÓN DE TABLAS Y TIPOS EN ORDEN CORRECTO
-- ============================================================

DROP TABLE IF EXISTS "Captura" CASCADE;
DROP TABLE IF EXISTS "Comentario" CASCADE;
DROP TABLE IF EXISTS "SolicitudDeDato" CASCADE;
DROP TABLE IF EXISTS "SpotCarnadaEspecie" CASCADE;
DROP TABLE IF EXISTS "SpotEspecie" CASCADE;
DROP TABLE IF EXISTS "SpotTipoPesca" CASCADE;
DROP TABLE IF EXISTS "EspecieTipoPesca" CASCADE;
DROP TABLE IF EXISTS "Spot" CASCADE;
DROP TABLE IF EXISTS "NombreComunEspecie" CASCADE;
DROP TABLE IF EXISTS "Especie" CASCADE;
DROP TABLE IF EXISTS "Carnada" CASCADE;
DROP TABLE IF EXISTS "Usuario" CASCADE;
DROP TABLE IF EXISTS "Rol" CASCADE;
DROP TABLE IF EXISTS "UsuarioRol" CASCADE;
DROP TABLE IF EXISTS "TipoPesca" CASCADE;

DROP TYPE IF EXISTS "NivelPescador" CASCADE;
DROP TYPE IF EXISTS "EstadoSpot" CASCADE;
DROP TYPE IF EXISTS "TipoCarnada" CASCADE;

-- ============================================================
-- CREACIÓN DE TIPOS ENUM
-- ============================================================

CREATE TYPE "NivelPescador" AS ENUM (
  'Principiante','Aficionado','Intermedio','Avanzado','Experto','Profesional'
);

CREATE TYPE "EstadoSpot" AS ENUM (
  'Esperando','Aceptado','Rechazado','Inactivo'
);

CREATE TYPE "TipoCarnada" AS ENUM (
  'ArtificialBlando', 'Natural' , 'ArtificialDuro','Viva','CarnadaMuerta','NaturalNoViva','MoscaArtificial','Otros'
);

-- ============================================================
-- CREACIÓN DE TABLAS EN ORDEN DE DEPENDENCIAS
-- ============================================================
-- Tablas independientes primero
CREATE TABLE "TipoPesca" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "descripcion" TEXT NOT NULL
);

CREATE TABLE "Usuario" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "nivelPescador" "NivelPescador",
  "email" VARCHAR(50) NOT NULL,
  "foto" VARCHAR(255)
);


CREATE TABLE "Rol" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE "UsuarioRol" (
  "usuarioId" VARCHAR(255) NOT NULL,
  "rolId" VARCHAR(255) NOT NULL,
  PRIMARY KEY ("usuarioId", "rolId"),
  FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE CASCADE,
  FOREIGN KEY ("rolId") REFERENCES "Rol"("id") ON DELETE CASCADE
);

CREATE TABLE "Especie" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombreCientifico" VARCHAR(255),
  "descripcion" TEXT,
  "imagen" VARCHAR(255)
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
  "descripcion" TEXT
);

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE "Spot" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idUsuario" VARCHAR(255),
  "idUsuarioActualizo" VARCHAR(255),
  "nombre" VARCHAR(255),
  "estado" "EstadoSpot",
  "descripcion" TEXT,
  "ubicacion" GEOGRAPHY(Point, 4326),
  "fechaPublicacion" DATE,
  "fechaActualizacion" DATE,
  "imagenPortada" VARCHAR(255),
  "isDeleted" BOOLEAN NOT NULL DEFAULT FALSE,
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
  "contenido" TEXT,
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
  "descripcion" TEXT,
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id"),
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id"),
  FOREIGN KEY ("idEspecie") REFERENCES "Especie"("id")
);

CREATE TABLE "EspecieTipoPesca" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idEspecie" VARCHAR(255) NOT NULL,
  "idTipoPesca" VARCHAR(255) NOT NULL,
  "descripcion" TEXT,
  FOREIGN KEY ("idEspecie") REFERENCES "Especie"("id"),
  FOREIGN KEY ("idTipoPesca") REFERENCES "TipoPesca"("id")
);

CREATE TABLE "Captura" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idUsuario" VARCHAR(255) NOT NULL,
  "especieId" VARCHAR(255) NOT NULL,
  "fecha" DATE NOT NULL,
  "ubicacion" VARCHAR(500) NOT NULL,
  "peso" DECIMAL(8,2),
  "longitud" DECIMAL(6,2),
  "carnada" VARCHAR(255) NOT NULL,
  "tipoPesca" VARCHAR(255) NOT NULL,
  "foto" VARCHAR(255),
  "notas" TEXT,
  "clima" VARCHAR(100),
  "horaCaptura" TIME,
  "fechaCreacion" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "fechaActualizacion" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id") ON DELETE CASCADE,
  FOREIGN KEY ("especieId") REFERENCES "Especie"("id") ON DELETE RESTRICT
);

-- ============================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================================

CREATE INDEX idx_captura_usuario ON "Captura"("idUsuario");
CREATE INDEX idx_captura_especie ON "Captura"("especieId");
CREATE INDEX idx_captura_fecha ON "Captura"("fecha");
CREATE INDEX idx_captura_fecha_creacion ON "Captura"("fechaCreacion");
CREATE INDEX idx_spot_ubicacion ON "Spot" USING GIST("ubicacion");
CREATE INDEX idx_spot_estado ON "Spot"("estado");

-- ============================================================
-- TRIGGERS Y FUNCIONES
-- ============================================================

CREATE OR REPLACE FUNCTION update_captura_fecha_actualizacion()
RETURNS TRIGGER AS $$
BEGIN
  NEW."fechaActualizacion" = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_captura_fecha
  BEFORE UPDATE ON "Captura"
  FOR EACH ROW
  EXECUTE FUNCTION update_captura_fecha_actualizacion();

--  DATOS BASE

INSERT INTO "Usuario" ("id", "nombre", "nivelPescador", "email") VALUES
  ('usuario1', 'Carlos Tarucha', 'Avanzado', 'carlos@example.com'),
  ('usuario2', 'Lucía Señuelera', 'Experto', 'lucia@example.com'),
  ('Dg5rIRf4FLRXcQ5BKwZJj5OFlCG2', 'Pescador Firebase', 'Intermedio', 'firebase@fishspot.com');

INSERT INTO "Rol" ("id", "nombre") VALUES
  ('rol1', 'usuario'),
  ('rol2', 'moderador');

INSERT INTO "UsuarioRol" ("usuarioId", "rolId") VALUES
  ('usuario1', 'rol1'),
  ('usuario1', 'rol2'),
  ('usuario2', 'rol1');


INSERT INTO "TipoPesca" ("id", "nombre", "descripcion") VALUES
  ('tp1', 'Spinning', 'Pesca con señuelos artificiales usando caña ligera y reel frontal (spinning). Caña entre 1,8 y 2,4 m, acción media, señuelos blandos o duros.'),
  ('tp2', 'Bait Casting', 'Pesca con caña corta y rígida (1,7 a 2,1 m) y reel rotativo baitcasting montado arriba de la caña. Ideal para precisión con señuelos.'),
  ('tp3', 'Pesca de Fondo', 'Caña larga y fuerte (2,7 a 4 m), reel frontal o rotativo, línea con plomada que descansa en el fondo. Usada con carnadas naturales.'),
  ('tp4', 'Pesca de Flote', 'Caña de 2 a 3,5 m, reel frontal ligero y boyas como indicador de pique. Ideal para pejerrey y especies de superficie.'),
  ('tp5', 'Mosca (Fly Fishing)', 'Caña flexible y ligera (2,1 a 3 m), carrete mosquero y línea pesada con moscas artificiales. Técnica de lanzado elegante.'),
  ('tp6', 'Trolling', 'Pesca desde embarcación en movimiento. Caña robusta, reel rotativo de gran capacidad y señuelos pesados o cucharas.'),
  ('tp7', 'Surfcasting', 'Pesca desde la playa. Cañas largas (3,6 a 4,5 m), potentes para lanzamientos lejanos, reels frontales de gran capacidad y plomos pesados.'),
  ('tp8', 'Curricán de Fondo', 'Variante del trolling con plomos para arrastrar señuelos a mayor profundidad. Cañas cortas y potentes, reels rotativos.'),
  ('tp9', 'Jigging', 'Caña corta y rígida (1,5 a 2 m), reel rotativo o frontal de alto poder, señuelos metálicos (jigs) trabajados verticalmente en aguas profundas.'),
  ('tp10', 'Mosca de Superficie', 'Variante del fly fishing con imitaciones flotantes. Caña mosquera ligera, línea flotante, moscas secas o poppers.'),
  ('tp11', 'Handline (Pesca a Mano)', 'Sin caña. Solo nylon y anzuelo con plomada o carnada. Técnica tradicional y simple.'),
  ('tp12', 'Pesca a Camalote', 'Caña media a larga, reel frontal, carnada natural. Se practica a la deriva siguiendo vegetación flotante en ríos.'),
  ('tp13', 'Pesca con Red de Mano', 'Sin caña ni reel. Uso de red de aro o trampa de mano, técnica artesanal para aguas bajas o charcos.'),
  ('tp14', 'Pesca con Cebado', 'Caña media, reel frontal o fijo. Se arroja alimento (maíz, masa, etc.) para atraer peces. Muy usada para carpas.'),
  ('tp15', 'Pesca Submarina', 'Sin caña ni reel. Uso de arpón, fusil submarino o hawaiana, practicada en apnea con snorkel o buceo.'),
  ('tp16', 'Mojarrero', 'Técnica argentina tradicional con equipos ultra livianos. Caña telescópica bambú o carbono 3,5-4,5 m, reel pequeño 1000-2000, línea monofilamento 0,14-0,18 mm. Para especies chicas en arroyos, canales y lagunas pampeanas: mojarras, dientudos, chanchitas. Anzuelos pequeños N°12-16. Carnadas: lombriz cortada, bolita de pan, larvas. Técnica de paciencia, presentación natural.'),
  ('tp17', 'Pesca a la Cueva', 'Técnica específica para estructuras cerradas. Caña corta 1,5-1,8 m, acción rápida, reel preciso. Lanzamientos cortos bajo troncos, ramas sumergidas, cuevas rocosas. Para tarariras, palometas, chanchitas territoriales. Requiere precisión milimétrica. Carnadas: señuelos compactos, carnada viva en anzuelo sin plomo. Líneas resistentes a abrasión.'),
  ('tp18', 'Variada', 'Técnica de río con múltiples anzuelos y carnadas simultáneas. Caña larga 3-4 m, reel frontal grande, línea madre gruesa 0,30-0,35 mm, ramales finos 0,20-0,25 mm. Para pescar varias especies juntas: bagres, bogas, mojarras, sábalos. Plomada corrida, 3-5 anzuelos diferentes tamaños y carnadas. Efectiva en correntadas medianas.'),
  ('tp19', 'Embarcado Fondeado', 'Pesca de espera desde embarcación anclada. Múltiples cañas largas 3-4 m, reels frontales grandes, portacañas. En pozones profundos para bagres grandes, surubíes, dorados de fondo. Carnadas vivas y muertas simultáneas. Fondos de 8-25 metros. Técnica nocturna principalmente. Requiere GPS y ecosonda.'),
  ('tp20', 'Pesca Nocturna Especializada', 'Equipos súper robustos para gigantes nocturnos. Cañas pesadas 3-3,5 m acción extra heavy, reels rotativos de alta capacidad, líneas gruesas 0,45-0,60 mm, leaders de acero 50-80 cm. Para manguruyús, surubíes gigantes, pacúes grandes. Carnadas vivas grandes (20-40 cm). Anzuelos 8/0-12/0. Plomos 100-200 gr.'),
  ('tp21', 'Pesca al Correntino', 'Técnica del nordeste argentino. Caña media 2,5-3 m, reel frontal, línea 0,25-0,30 mm. Se pesca dejando derivar la carnada en la corriente natural del río. Para dorados, surubíes, pacúes en ríos correntosos. Carnada natural en anzuelo simple, plomada ligera o sin plomo. Efectiva en barrancas y correderas.'),
  ('tp22', 'Carpfishing Argentino', 'Adaptación local del carpfishing europeo. Cañas largas 3,6-4,2 m, reels frontales grandes con freno suave, líneas 0,35-0,40 mm. Para carpas grandes en lagunas. Técnica de cebado previo, múltiples cañas, alarmas electrónicas. Carnadas: boilies caseros, maíz fermentado, papa hervida con esencias. Pesca de 24-48 horas.'),
  ('tp23', 'Pesca a la Madrugada', 'Técnica específica para primeras horas. Equipos medianos, carnadas naturales frescas. Efectiva para especies que se alimentan en bajante de temperatura nocturna: bagres, bogas, pacúes. Horario: 4:00-8:00 AM. Presentación silenciosa, movimientos mínimos. Muy productiva en verano.'),
  ('tp24', 'Técnica del Tarucho', 'Pesca especializada para tarariras grandes. Caña baitcasting 2-2,2 m, reel rotativo preciso, línea trenzada 0,25-0,30 mm, leader fluorocarbono 50-60 cm. Señuelos de superficie grandes (12-18 cm), trabajados agresivamente. Lanzamientos a vegetación densa, estructuras sumergidas.'),
  ('tp25', 'Spinning Patagónico', 'Técnica para truchas y salmones en lagos profundos. Caña spinning 2,4-2,7 m acción media-rápida, reel frontal 3000-4000, línea trenzada 0,14-0,18 mm, leader fluorocarbono 3-5 m. Cucharitas rotativas, spoons, jigs verticales. Pesca desde costa en lagos patagónicos. Efectiva todo el año.'),
  ('tp26', 'Trolling Lacustre', 'Pesca al curricán en grandes lagos patagónicos. Caña trolling 2,1-2,4 m acción parabólica, reel rotativo con contador línea, línea 0,35-0,50 mm, plomadas de trolling 100-300 g. Para truchas grandes, salmones encerrados, percas. Velocidad 2-4 nudos, profundidad 5-25 m.'),
  ('tp27', 'Fly Fishing Ninfeo', 'Pesca con mosca bajo superficie. Caña #4-6 de 2,7-3 m, línea hundimiento intermedio, tippet 0,14-0,18 mm, ninfas lastradas. Para truchas en ríos correntosos. Deriva natural, tensión controlada. Indicador de picada. Muy efectiva en aguas frías y claras.'),
  ('tp28', 'Pesca en Espejos', 'Técnica para lagunas pequeñas patagónicas. Caña ligera 1,8-2,4 m, reel pequeño 1000-2000, línea 0,16-0,20 mm, anzuelos #8-12, plomadas 5-15 g. Para puyenes, percas chicas, pejerreyes patagónicos. Presentación delicada, carnadas naturales pequeñas.');

INSERT INTO "Especie" ("id", "nombreCientifico", "descripcion", "imagen") VALUES
('es2', 'Salminus brasiliensis',
'DORADO: El "tigre de los ríos". Pez icónico de la pesca deportiva argentina. Cuerpo fusiforme dorado con aletas amarillo-rojizas. Alcanza hasta 25 kg y 120 cm. Habita corrientes rápidas de ríos grandes (Paraná, Uruguay, Bermejo). Depredador voraz que se alimenta de sábalos, bogas y mojarras. Muy combativo, salta fuera del agua al ser capturado. Pesca: spinning con poppers al amanecer, trolling con cucharas grandes, carnada viva en pozones profundos. Mejor época: septiembre a marzo. Líneas mínimo 0,35 mm.', 
'uploads/dorado.png'),
('es3', 'Pseudoplatystoma corruscans',
'SURUBÍ PINTADO: Rey de los bagres sudamericanos. Cuerpo alargado gris plateado con manchas negras redondeadas. Alcanza 50 kg y 150 cm. Habita pozones profundos de ríos grandes, especialmente Paraná y Paraguay. Cazador nocturno solitario, se alimenta de peces grandes, anguilas y crustáceos. Migra grandes distancias para reproducirse. Pesca: exclusivamente nocturna con carnadas vivas grandes (morenas 20-30 cm, bogas enteras). Cañas pesadas 3-3,5 m, reels rotativos, líneas 0,50-0,60 mm. Anzuelos 6/0-8/0. Requiere embarcación para pozones de 15-30 m.', 
'uploads/surubi_pintado.png'),
('es4', 'Pseudoplatystoma reticulatum',
'SURUBÍ ATIGRADO: Bagre de río con patrón reticulado característico. Cuerpo más robusto que el pintado, manchas vermiculadas negras. Alcanza 40 kg y 130 cm. Prefiere aguas turbias y fondos fangosos. Cazador oportunista nocturno, dieta variada incluyendo peces, cangrejos y moluscos. Más sedentario que el pintado. Pesca: similar al pintado pero acepta carnadas más variadas. Efectivo con trozos grandes de pescado, hígado de pollo. Técnica de fondo con plomadas de 80-150 gr. Mejor en aguas en bajante, fondos entre 8-20 m.', 
'uploads/surubi_atigrado.png'),
('es5', 'Zungaro zungaro',
'MANGURUYÚ: Uno de los bagres más grandes de Sudamérica, puede superar los 100 kg. Habita en pozones profundos y correntosos. Es depredador nocturno, se alimenta de peces grandes y crustáceos. Se pesca con carnadas vivas o grandes trozos de pescado. Necesario equipo de alta resistencia.', 
'uploads/manguruyu.png'),
('es6', 'Piaractus mesopotamicus',
'PACÚ: Pez omnívoro de cuerpo alto y dientes molariformes. Se alimenta de frutas, semillas, moluscos y pequeños peces. Prefiere aguas tranquilas de lagunas y remansos. Se pesca con frutas (mburucuyá, higo), maíz, masa y también señuelos. Activo de día, con mejores resultados en la mañana y la tarde.', 
'uploads/pacu.png'),
('es7', 'Myloplus rubripinnis',
'PACÚ RELOJ: De menor tamaño que el pacú común, con aletas rojizas. Omnívoro, se alimenta de frutos y semillas en bajantes de ríos. Se pesca con masa, maíz y frutas. Es más activo en aguas cálidas y al mediodía. Prefiere sectores tranquilos.', 
'uploads/pacu_reloj.png'),
('es8', 'Colossoma mitrei',
'PACÚ CHATO: Similar al pacú común, de cuerpo más comprimido. Omnívoro oportunista. Se lo pesca con frutas, masa o granos. Frecuenta aguas calmas, arroyos y lagunas conectadas a grandes ríos.', 
'uploads/pacu_chato.png'),
('es9', 'Megaleporinus obtusidens',
'BOGA: Muy buscada por su combatividad. Omnívora con tendencia herbívora, se alimenta de vegetales, semillas y pequeños invertebrados. Activa durante el día, especialmente en corrientes medias. Se pesca con maíz, masa, lombrices y frutas. Técnica de fondo o flote con equipos medianos.', 
'uploads/boga.png'),
('es10', 'Prochilodus lineatus',
'SÁBALO: Especie abundante y base de la cadena trófica. Herbívoro-detritívoro, se alimenta del fondo filtrando sedimentos. No es muy deportiva pero sirve de carnada para especies mayores. Activo todo el día. Se captura con masas vegetales y harinas.', 
'uploads/sabalo.png'),
('es1', 'Hoplias malabaricus',
'TARARIRA COMÚN: Depredador emboscador icónico de lagunas y arroyos argentinos. Cuerpo cilíndrico color verde oliva con manchas oscuras. Alcanza 8 kg y 60 cm. Cabeza grande con mandíbulas poderosas llenas de dientes afilados. Habita aguas calmadas con vegetación densa, troncos sumergidos y camalotes. Cazadora de emboscada, ataca explosivamente desde la vegetación. Se alimenta de peces, ranas, reptiles pequeños y hasta aves acuáticas. Pesca: spinning con ranas artificiales, paseantes y poppers al amanecer/atardecer. Carnada viva efectiva con mojarras. Requiere leaders de acero 20-30 cm por sus dientes. Líneas 0,25-0,30 mm.', 
'uploads/tararira.png'),
('es11', 'Hoplias lacerdae',
'TARARIRA AZUL: Versión gigante de la familia. Cuerpo azul-verdoso brillante con reflejos metálicos. Alcanza 15 kg y 80 cm. Habita grandes ríos y lagunas profundas de la región mesopotámica. Depredador apex extremadamente agresivo. Prefiere pozones profundos con estructura. Caza en aguas abiertas a diferencia de su prima común. Dientes aún más desarrollados, mandíbulas más potentes. Pesca: baitcasting con señuelos grandes (12-15 cm), poppers robustos, stickbaits pesados. Carnada viva con mojarras grandes (15-20 cm). Leaders de acero obligatorios 40-50 cm. Líneas pesadas 0,35-0,40 mm. Mejor época: otoño-invierno.', 
'uploads/tararira_azul.png'),
('es12', 'Hoplias australis',
'TARARIRA PINTADA: Especie del sur con patrón moteado distintivo. Cuerpo marrón con manchas irregulares claras y oscuras. Tamaño intermedio: 5 kg, 50 cm. Habita lagunas pampeanas y arroyos de corriente lenta con abundante vegetación acuática. Comportamiento territorial durante reproducción (primavera). Menos agresiva que sus parientes pero igual de combativa. Dieta: peces pequeños, crustáceos, insectos acuáticos. Pesca: spinning liviano con señuelos medianos, ranas pequeñas, crankbaits someros. Muy efectiva con carnada viva nocturna. Líneas 0,20-0,25 mm, leaders fluorocarbono 30 cm.', 
'uploads/tararira_pintada.png'),
('es13', 'Odontesthes bonariensis',
'PEJERREY BONAERENSE: Pez emblemático de la pesca argentina. Cuerpo plateado fusiforme con banda lateral azul. Alcanza 2 kg y 50 cm. Forma cardúmenes en lagunas pampeanas, delta del Paraná y río de la Plata. Planctófago que se alimenta de zooplancton, larvas y pequeños peces. Muy sensible a cambios de presión atmosférica - pica mejor con tiempo estable. Horario: mañanas soleadas y atardeceres nublados. Pesca: técnica clásica con boya, línas finas 0,16-0,20 mm, anzuelos pequeños N°8-12. Carnadas: mojarra viva, filet cortado, lombriz partida. Mejor época: marzo-mayo y septiembre-noviembre. Requiere paciencia y fineza.', 
'uploads/pejerrey.png'),
('es14', 'Odontesthes hatcheri',
'PEJERREY PATAGÓNICO: Adaptación austral del pejerrey. Cuerpo más robusto, coloración más intensa. Alcanza 1,5 kg y 45 cm. Habita lagos fríos patagónicos (Nahuel Huapi, Traful, Aluminé). Forma grandes cardúmenes, migra estacionalmente buscando alimento. Dieta: invertebrados bentónicos, pequeños crustáceos, larvas de insectos. Resistente a temperaturas bajas. Pesca: técnicas de mosca con ninfas pequeñas, flote con carnada natural. Mejor horario: mañanas despejadas primavera-verano. Líneas finas, presentación delicada. Mosca ahogada muy efectiva en fondos de 3-8 metros.', 
'uploads/pejerrey_patagonico.png'),
('es15', 'Odontesthes nigricans',
'PEJERREY FUEGUINO: Especie del fin del mundo. El más austral de los pejerreyes. Cuerpo compacto adaptado a aguas extremadamente frías. Alcanza 800 gr y 35 cm. Exclusivo de lagos y ríos de Tierra del Fuego. Muy resistente a bajas temperaturas, activo incluso en invierno. Dieta especializada: invertebrados acuáticos, anfípodos, larvas de dípteros. Pesca: equipos ultra livianos, moscas diminutas, presentación natural. Mejor época: diciembre-marzo. Técnica similar al pejerrey patagónico pero con señuelos más pequeños. Muy selectivo, requiere gran habilidad.', 
'uploads/pejerrey_fueguino.png'),
('es16', 'Percichthys trucha',
'PERCA CRIOLLA: Habita lagos y ríos fríos de la Patagonia. Depredador de peces pequeños y crustáceos. Activa en horas crepusculares. Se pesca con spinning y mosca. Carne muy apreciada.', 
'uploads/perca_criolla.png'),
('es17', 'Oncorhynchus mykiss',
'TRUCHA ARCOÍRIS: Salmonido introducido, joya de la pesca patagónica. Cuerpo plateado con banda lateral rosada, manchas negras. Alcanza 8 kg y 70 cm en ríos grandes. Habita aguas frías oxigenadas (8-18°C) de ríos y lagos patagónicos. Muy combativa, salta espectacularmente. Dieta: insectos acuáticos (efímeras, tricópteros), crustáceos, pequeños peces. Pesca: fly fishing con moscas secas en eclosiones, ninfas en pozones, streamers para grandes ejemplares. Spinning con cucharitas giratorias N°2-4. Mejor época: octubre-abril. Horarios: amanecer, atardecer y días nublados. Líneas flotantes e intermedias.', 
'uploads/trucha_arcoiris.png'),
('es18', 'Salmo trutta',
'TRUCHA MARRÓN: La más desconfiada y combativa. Cuerpo dorado-marrón con puntos negros y rojos aureolados. Alcanza 12 kg y 80 cm. Introducida en ríos serranos y patagónicos. Extremadamente selectiva, inteligente y territorial. Prefiere pozones profundos y estructuras complejas. Nocturna, caza activamente en superficie durante eclosiones. Dieta oportunista: insectos, crustáceos, peces, ratones. Pesca: fly fishing técnico con moscas exactas, presentación perfecta. Spinning nocturno muy efectivo. Requiere sigilo absoluto. Mejor época: marzo-mayo (otoño), septiembre-noviembre. Líneas finas, leaders largos 3-4 metros.', 
'uploads/trucha_marron.png'),
('es19', 'Salvelinus fontinalis',
'TRUCHA DE ARROYO: Pequeña joya de montaña. Cuerpo oscuro con puntos claros, aletas inferiores naranjas con borde blanco. Alcanza 2 kg y 40 cm. Habita arroyos fríos de altura, vertientes cordilleranas. La más bella pero menos combativa. Prefiere aguas oxigenadas, fondos pedregosos, temperatura bajo 15°C. Dieta: insectos terrestres y acuáticos, larvas. Muy confiada comparada con otras truchas. Pesca: fly fishing con moscas secas pequeñas (N°14-18), técnica delicada. Spinning ultra liviano. Mejor época: noviembre-marzo. Horarios amplios, menos selectiva que sus primas.', 
'uploads/trucha_arroyo.png'),
('es20', 'Pimelodus albicans',
'BAGRE BLANCO: Muy común en ríos grandes. Se alimenta de pequeños peces, moluscos y detritos. Activo de noche, aunque también pica de día. Se pesca al fondo con lombrices, tripa de pollo o masa. Ideal con líneas pesadas y plomos. Muy buscado por pescadores de costa.', 
'uploads/bagre_blanco.png'),

-- Especies adicionales argentinas
('es21', 'Rhamdia quelen', 'BAGRE SAPO: Bagre de cuerpo robusto, muy resistente. Activo de noche, se alimenta de todo. Habita pozones rocosos y fondos con troncos. Pesca nocturna con tripas, lombrices o masa.', 'uploads/bagre_sapo.png'),
('es22', 'Pterodoras granulosus', 'ARMADO: Bagre blindado con espinas laterales. Habita fondos duros de ríos grandes. Nocturno, se pesca con carnadas naturales fuertes como tripas o carne. Muy combativo.', 'uploads/armado.png'),
('es23', 'Luciopimelodus pati', 'PATÍ: Bagre de gran tamaño con cabeza ancha. Depredador nocturno de pozones profundos. Se pesca con carnadas vivas grandes como mojarras o trozos de pescado.', 'uploads/pati.png'),
('es24', 'Cyprinus carpio', 'CARPA COMÚN: Introducida, muy resistente. Omnívora, se alimenta del fondo. Activa todo el día, mejor en aguas cálidas. Se pesca con maíz, masa, papa hervida. Muy popular en lagunas.', 'uploads/carpa_comun.png'),
('es25', 'Astyanax fasciatus', 'MOJARRA: Pez pequeño muy común, base alimentaria de depredadores. Activa de día, se alimenta de insectos y plantas. Se pesca con lombriz, masa o mosca. Excelente carnada viva.', 'uploads/mojarra.png'),
('es26', 'Synbranchus marmoratus', 'ANGUILA CRIOLLA: Pez serpentiforme que habita en barro y vegetación. Nocturna, muy resistente fuera del agua. Se pesca con lombrices en fondos barrosos. Excelente carnada para grandes depredadores.', 'uploads/anguila_criolla.png'),
('es27', 'Brycon orbignyanus', 'PIRAPITÁ: Similar al dorado pero menor, muy combativo. Habita corrientes rápidas, se alimenta de peces e insectos. Se pesca con señuelos chicos y carnada viva.', 'uploads/pirapita.png'),
('es28', 'Leporinus friderici', 'BOGA LISA: Cuerpo alargado, habita corrientes medianas. Omnívora, activa de día. Se pesca con maíz, frutas y masa. Muy deportiva en equipos livianos.', 'uploads/boga_lisa.png'),
('es29', 'Crenicichla britskii', 'PALOMETA: Depredador de arroyos y lagunas. Agresiva, se alimenta de peces pequeños y crustáceos. Se pesca con señuelos chicos o carnada viva.', 'uploads/palometa.png'),
('es30', 'Micropogonias furnieri', 'CORVINA RUBIA: Marina, muy popular en costas atlánticas. Se alimenta de cangrejos, camarones y peces. Pesca desde costa con carnadas naturales.', 'uploads/corvina_rubia.png'),

-- Más especies argentinas
('es31', 'Crenicichla lacustris', 'CHANCHITA: Cíclido agresivo de arroyos y lagunas. Territorial, se alimenta de invertebrados y peces pequeños. Se pesca con lombriz, pequeños señuelos o mosca.', 'uploads/chanchita.png'),
('es32', 'Oligosarcus jenynsii', 'DIENTUDO: Characido pequeño muy combativo. Cardúmenes activos que persiguen insectos y alevines. Ideal con equipos ultra livianos y carnadas chicas.', 'uploads/dientudo.png'),
('es33', 'Jenynsia multidentata', 'MADRECITA: Pez muy pequeño, live bearer. Se alimenta de larvas de mosquitos. Se pesca con equipos finísimos, anzuelos pequeños.', 'uploads/madrecita.png'),
('es34', 'Cnesterodon decemmaculatus', 'PANZUDITO: Similar a madrecita, muy pequeño. Habita aguas quietas con vegetación. Anzuelos diminutos y carnada microscópica.', 'uploads/panzudito.png'),
('es35', 'Cichlasoma dimerus', 'CHANCHITA RAYADA: Cíclido de mayor tamaño que la común. Muy territorial en época reproductiva. Pesca con lombrices y pequeños artificiales.', 'uploads/chanchita_rayada.png'),
('es36', 'Heptapterus mustelinus', 'BAGRE NEGRO: Bagre pequeño de arroyos. Nocturno, se esconde bajo piedras. Se pesca con lombriz al fondo en aguas corrientes.', 'uploads/bagre_negro.png'),
('es37', 'Australoheros facetus', 'CASTAÑETA: Cíclido robusto de lagunas pampeanas. Omnívoro agresivo. Se pesca con lombrices, masa y pequeños señuelos.', 'uploads/castaneta.png'),
('es38', 'Cheirodon interruptus', 'MOJARRA COLA ROJA: Characido pequeño de cardúmen. Muy común en arroyos claros. Se pesca con anzuelos pequeños y lombriz.', 'uploads/mojarra_cola_roja.png'),

-- Especies adicionales muy argentinas
('es39', 'Galaxias maculatus', 'PUYÉN GRANDE: Pez primitivo endémico patagónico. Cuerpo alargado verde oliva con manchas oscuras. Alcanza 200 gr y 25 cm. Habita lagos y ríos fríos patagónicos, única especie nativa de la región junto a percas. Resistente a temperaturas extremas, sobrevive bajo hielo. Dieta: invertebrados bentónicos, huevos de otras especies. Pesca: equipos ultra livianos, moscas diminutas, señuelos micro. Técnica similar al pejerrey pero en aguas más frías. Muy deportivo por su combatividad relativa al tamaño.', 'uploads/puyen_grande.png'),

('es40', 'Percichthys colhuapiensis', 'PERCA PATAGÓNICA: Endémica de lagos patagónicos. Cuerpo robusto con aletas rojizas. Alcanza 3 kg y 45 cm. Habita lagos profundos y fríos (Nahuel Huapi, Traful, Lácar). Depredador bentónico, se alimenta de crustáceos, puyenes y alevines. Muy territorial durante reproducción (primavera). Pesca: jigging vertical en fondos rocosos, spinning con cucharitas pesadas, mosca con streamers grandes. Mejor época: diciembre-marzo. Profundidades 8-25 metros.', 'uploads/perca_patagonica.png'),

('es41', 'Diplomystes viedmensis', 'BAGRE BLANCO DEL SUR: Bagre primitivo endémico patagónico. Cuerpo alargado sin escamas, cabeza deprimida. Alcanza 1 kg y 35 cm. Habita ríos fríos patagónicos, muy escaso y protegido. Nocturno, se alimenta de invertebrados bentónicos. Especie relicta, testimonio de antiguos ecosistemas. Pesca: regulada, solo captura y devolución. Técnica: fondo con lombriz en pozones rocosos. Importante valor científico y conservacionista.', 'uploads/bagre_blanco_sur.png');

INSERT INTO "NombreComunEspecie" ("id", "idEspecie", "nombre") VALUES
  -- 1. Tararira común (Hoplias malabaricus)
  ('nc1', 'es1', 'Tararira'),
  ('nc2', 'es1', 'Tarucha'),
  ('nc3', 'es1', 'Lobito'),
  ('nc4', 'es1', 'Cabeza amarga'),
  ('nc5', 'es1', 'Tigre de agua dulce'),

  -- 2. Dorado (Salminus brasiliensis)
  ('nc6', 'es2', 'Dorado'),
  ('nc7', 'es2', 'Tigre de los ríos'),
  ('nc8', 'es2', 'Salminus'),

  -- 3. Surubí pintado (Pseudoplatystoma corruscans)
  ('nc9', 'es3', 'Surubí'),
  ('nc10', 'es3', 'Surubí pintado'),
  ('nc11', 'es3', 'Bagre pintado'),

  -- 4. Surubí atigrado (Pseudoplatystoma reticulatum)
  ('nc12', 'es4', 'Surubí atigrado'),
  ('nc13', 'es4', 'Bagre atigrado'),

  -- 5. Manguruyú (Zungaro zungaro)
  ('nc14', 'es5', 'Manguruyú'),
  ('nc15', 'es5', 'Manguruyú gigante'),

  -- 6. Pacú (Piaractus mesopotamicus)
  ('nc16', 'es6', 'Pacú'),
  ('nc17', 'es6', 'Pacú negro'),
  ('nc18', 'es6', 'Pacuí'),

  -- 7. Pacú reloj (Myloplus rubripinnis)
  ('nc19', 'es7', 'Pacú reloj'),
  ('nc20', 'es7', 'Pacuí reloj'),

  -- 8. Pacú chato (Colossoma mitrei)
  ('nc21', 'es8', 'Pacú chato'),
  ('nc22', 'es8', 'Chato'),

  -- 9. Boga (Megaleporinus obtusidens)
  ('nc23', 'es9', 'Boga'),
  ('nc24', 'es9', 'Boga del Paraná'),
  ('nc25', 'es9', 'Leporinus'),

  -- 10. Sábalo (Prochilodus lineatus)
  ('nc26', 'es10', 'Sábalo'),
  ('nc27', 'es10', 'Saboga'),

  -- 11. Tararira azul (Hoplias lacerdae)
  ('nc28', 'es11', 'Tararira azul'),
  ('nc29', 'es11', 'Tararira grande'),
  ('nc30', 'es11', 'Lobito azul'),

  -- 12. Tararira pintada (Hoplias australis)
  ('nc31', 'es12', 'Tararira pintada'),
  ('nc32', 'es12', 'Tararira moteada'),

  -- 13. Pejerrey bonaerense (Odontesthes bonariensis)
  ('nc33', 'es13', 'Pejerrey'),
  ('nc34', 'es13', 'Pejerrey bonaerense'),
  ('nc35', 'es13', 'Peje'),

  -- 14. Pejerrey patagónico (Odontesthes hatcheri)
  ('nc36', 'es14', 'Pejerrey patagónico'),
  ('nc37', 'es14', 'Pejerrey austral'),

  -- 15. Pejerrey fueguino (Odontesthes nigricans)
  ('nc38', 'es15', 'Pejerrey fueguino'),
  ('nc39', 'es15', 'Pejerrey del sur'),

  -- 16. Perca criolla (Percichthys trucha)
  ('nc40', 'es16', 'Perca criolla'),
  ('nc41', 'es16', 'Perca'),

  -- 17. Trucha arcoíris (Oncorhynchus mykiss)
  ('nc42', 'es17', 'Trucha arcoíris'),
  ('nc43', 'es17', 'Rainbow trout'),

  -- 18. Trucha marrón (Salmo trutta)
  ('nc44', 'es18', 'Trucha marrón'),
  ('nc45', 'es18', 'Brown trout'),

  -- 19. Trucha de arroyo (Salvelinus fontinalis)
  ('nc46', 'es19', 'Trucha de arroyo'),
  ('nc47', 'es19', 'Brook trout'),

  -- 20. Bagre blanco (Pimelodus albicans)
  ('nc48', 'es20', 'Bagre blanco'),
  ('nc49', 'es20', 'Bagre'),
  ('nc50', 'es20', 'Bagre criollo'),

  -- 21. Bagre sapo (Rhamdia quelen)
  ('nc51', 'es21', 'Bagre sapo'),
  ('nc52', 'es21', 'Bagre negro'),
  ('nc53', 'es21', 'Jundiá'),

  -- 22. Armado (Pterodoras granulosus)
  ('nc54', 'es22', 'Armado'),
  ('nc55', 'es22', 'Armado chancho'),

  -- 23. Patí (Luciopimelodus pati)
  ('nc56', 'es23', 'Patí'),
  ('nc57', 'es23', 'Bagre patí'),

  -- 24. Carpa común (Cyprinus carpio)
  ('nc58', 'es24', 'Carpa'),
  ('nc59', 'es24', 'Carpa común'),
  ('nc60', 'es24', 'Carpín'),

  -- 25. Mojarra (Astyanax fasciatus)
  ('nc61', 'es25', 'Mojarra'),
  ('nc62', 'es25', 'Mojarrita'),
  ('nc63', 'es25', 'Dientudo'),

  -- 26. Anguila criolla (Synbranchus marmoratus)
  ('nc64', 'es26', 'Anguila criolla'),
  ('nc65', 'es26', 'Morena'),

  -- 27. Pirapitá (Brycon orbignyanus)
  ('nc66', 'es27', 'Pirapitá'),
  ('nc67', 'es27', 'Doradillo'),

  -- 28. Boga lisa (Leporinus friderici)
  ('nc68', 'es28', 'Boga lisa'),

  -- 29. Palometa (Crenicichla britskii)
  ('nc69', 'es29', 'Palometa'),
  ('nc70', 'es29', 'Chanchita'),

  -- 30. Corvina rubia (Micropogonias furnieri)
  ('nc71', 'es30', 'Corvina rubia'),
  ('nc72', 'es30', 'Corvina'),

  -- 31. Chanchita (Crenicichla lacustris)
  ('nc73', 'es31', 'Chanchita'),
  ('nc74', 'es31', 'Chanchita común'),
  ('nc75', 'es31', 'Cíclido'),

  -- 32. Dientudo (Oligosarcus jenynsii)
  ('nc76', 'es32', 'Dientudo'),
  ('nc77', 'es32', 'Dentudo'),
  ('nc78', 'es32', 'Oligosarcus'),

  -- 33. Madrecita (Jenynsia multidentata)
  ('nc79', 'es33', 'Madrecita'),
  ('nc80', 'es33', 'Madrecita de agua'),

  -- 34. Panzudito (Cnesterodon decemmaculatus)
  ('nc81', 'es34', 'Panzudito'),
  ('nc82', 'es34', 'Barrigón'),

  -- 35. Chanchita rayada (Cichlasoma dimerus)
  ('nc83', 'es35', 'Chanchita rayada'),
  ('nc84', 'es35', 'Chanchita grande'),

  -- 36. Bagre negro (Heptapterus mustelinus)
  ('nc85', 'es36', 'Bagre negro'),
  ('nc86', 'es36', 'Bagrecito'),

  -- 37. Castañeta (Australoheros facetus)
  ('nc87', 'es37', 'Castañeta'),
  ('nc88', 'es37', 'Chanchita castañeta'),

  -- 38. Mojarra cola roja (Cheirodon interruptus)
  ('nc89', 'es38', 'Mojarra cola roja'),
  ('nc90', 'es38', 'Mojarrita'),

  -- 39. Puyén grande (Galaxias maculatus)
  ('nc91', 'es39', 'Puyén grande'),
  ('nc92', 'es39', 'Puyén'),
  ('nc93', 'es39', 'Galaxia'),

  -- 40. Perca patagónica (Percichthys colhuapiensis)
  ('nc94', 'es40', 'Perca patagónica'),
  ('nc95', 'es40', 'Perca del Nahuel Huapi'),
  ('nc96', 'es40', 'Perca de los lagos'),

  -- 41. Bagre blanco del sur (Diplomystes viedmensis)
  ('nc97', 'es41', 'Bagre blanco del sur'),
  ('nc98', 'es41', 'Bagre patagónico'),
  ('nc99', 'es41', 'Diplomystes');

INSERT INTO "Carnada" ("id", "nombre", "tipoCarnada", "descripcion") VALUES
  -- Artificiales blandos
  ('c1', 'Señuelo rana', 'ArtificialBlando', 'Señuelo blando en forma de rana para superficie.'),
  ('c2', 'Señuelo lombriz siliconada', 'ArtificialBlando', 'Imitación de lombriz en silicona, muy usada para tarariras y black bass.'),
  ('c3', 'Grub de vinilo', 'ArtificialBlando', 'Señuelo blando en forma de larva o grub.'),
  ('c4', 'Shad siliconado', 'ArtificialBlando', 'Pez blando de vinilo con cola vibrátil.'),
  ('c5', 'Cangrejo artificial', 'ArtificialBlando', 'Imitación blanda de cangrejo para pesca de fondo.'),
  ('c6', 'Jig con vinilo', 'ArtificialBlando', 'Cabeza plomada con cuerpo de silicona.'),
  ('c7', 'Minnow blando', 'ArtificialBlando', 'Señuelo flexible imitando pez pequeño.'),
  ('c8', 'Lagartija blanda', 'ArtificialBlando', 'Imitación de lagarto o salamandra en goma blanda.'),

  -- Artificiales duros
  ('c9', 'Señuelo crankbait', 'ArtificialDuro', 'Señuelo duro con paleta para profundidad.'),
  ('c10', 'Popper', 'ArtificialDuro', 'Señuelo de superficie que genera burbujas y ruidos.'),
  ('c11', 'Paseante', 'ArtificialDuro', 'Señuelo de superficie zigzagueante (walk the dog).'),
  ('c12', 'Jerkbait', 'ArtificialDuro', 'Señuelo duro que se mueve con tirones de caña.'),
  ('c13', 'Spinnerbait', 'ArtificialDuro', 'Señuelo con cucharilla giratoria y faldín.'),
  ('c14', 'Cucharita ondulante', 'ArtificialDuro', 'Cucharilla metálica que oscila bajo el agua.'),
  ('c15', 'Cucharita giratoria', 'ArtificialDuro', 'Cucharilla con pala giratoria muy usada en truchas.'),
  ('c16', 'Lipless crankbait', 'ArtificialDuro', 'Señuelo duro sin paleta con vibración fuerte.'),
  ('c17', 'Stickbait', 'ArtificialDuro', 'Señuelo alargado de superficie, acción lineal.'),
  ('c18', 'Poppers articulado', 'ArtificialDuro', 'Popper de varios segmentos que genera salpicaduras.'),

  -- Naturales
  ('c19', 'Lombriz común', 'Natural', 'Carnada natural clásica para mojarras y bagres.'),
  ('c20', 'Tripas de pollo', 'Natural', 'Tripas frescas muy usadas para bagres y patí.'),
  ('c21', 'Carne vacuna', 'Natural', 'Trozos de carne usados para dorados y bagres grandes.'),
  ('c22', 'Masa casera', 'Natural', 'Masa de harina y esencia, usada para carpas.'),
  ('c23', 'Queso', 'Natural', 'Cubos de queso como carnada alternativa para carpas y bogas.'),
  ('c24', 'Panceta', 'Natural', 'Trozo de panceta salada para dorado o surubí.'),
  ('c25', 'Langostino', 'Natural', 'Carne de langostino como carnada de río o mar.'),
  ('c26', 'Pan remojado', 'Natural', 'Pan húmedo como carnada simple para mojarras.'),
  ('c27', 'Maíz hervido', 'Natural', 'Granos de maíz cocidos para carpas y bogas.'),

  -- Vivas
  ('c28', 'Mojarra viva', 'Viva', 'Pez pequeño vivo usado para dorado y tararira.'),
  ('c29', 'Morena viva', 'Viva', 'Anguila criolla usada como carnada viva en el río.'),
  ('c30', 'Camarón vivo', 'Viva', 'Camarón de agua dulce usado como carnada.'),

  -- Carnadas argentinas adicionales
  ('c31', 'Mburucuyá', 'Natural', 'Fruto del maracuyá muy efectivo para pacúes.'),
  ('c32', 'Papa hervida', 'Natural', 'Papa cocida, excelente para carpas y bogas.'),
  ('c33', 'Filet de mojarra', 'CarnadaMuerta', 'Trozo de mojarra para pejerrey y truchas.'),
  ('c34', 'Hígado de pollo', 'Natural', 'Víscera muy atractiva para bagres nocturnos.'),
  ('c35', 'Grillo', 'Natural', 'Insecto vivo ideal para truchas y pejerreyes.'),
  ('c36', 'Mosca ahogada', 'MoscaArtificial', 'Imitación sumergida de insectos acuáticos.'),
  ('c37', 'Ninfa', 'MoscaArtificial', 'Imitación de larva acuática para truchas.'),
  ('c38', 'Streamer', 'MoscaArtificial', 'Mosca que imita peces pequeños.'),
  ('c39', 'Mosca seca', 'MoscaArtificial', 'Imitación flotante de insectos adultos.'),
  ('c40', 'Sanguijuela', 'Natural', 'Gusano acuático natural muy efectivo.'),

  -- Carnadas para pesca fina y mojarrero
  ('c41', 'Lombriz cortada', 'Natural', 'Pedacito de lombriz para anzuelos pequeños.'),
  ('c42', 'Bolita de pan', 'Natural', 'Miga de pan húmeda, clásica para mojarras.'),
  ('c43', 'Larva de mosquito', 'Natural', 'Carnada viva diminuta para peces chicos.'),
  ('c44', 'Gusano de humedad', 'Natural', 'Pequeños gusanos de la tierra húmeda.'),
  ('c45', 'Bloodworm artificial', 'ArtificialBlando', 'Imitación de larva de mosquito en silicona.'),
  ('c46', 'Micro jig', 'ArtificialDuro', 'Señuelo diminuto con anzuelo pequeño.'),
  ('c47', 'Mosca mojada chica', 'MoscaArtificial', 'Imitación pequeña sumergida.'),
  ('c48', 'Hormiga', 'Natural', 'Insecto natural que cae al agua.'),
  ('c49', 'Cascarita', 'Natural', 'Pedacito de cáscara de huevo para chanchitas.'),
  ('c50', 'Mini cucharita', 'ArtificialDuro', 'Cucharilla diminuta para dientudos.'),

  -- Carnadas tradicionales argentinas adicionales
  ('c51', 'Isoca', 'Natural', 'Larva de mariposa nocturna, muy efectiva para truchas.'),
  ('c52', 'Renacuajo', 'Viva', 'Larva de rana, irresistible para tarariras.'),
  ('c53', 'Langostino de río', 'Natural', 'Crustáceo de agua dulce para grandes depredadores.'),
  ('c54', 'Boilies caseros', 'Natural', 'Masa hervida con proteínas para carpfishing.'),
  ('c55', 'Maíz fermentado', 'Natural', 'Maíz en proceso de fermentación, muy atractivo.'),
  ('c56', 'Higo maduro', 'Natural', 'Fruta natural para pacúes, efectiva en otoño.'),
  ('c57', 'Masa con anís', 'Natural', 'Masa aromatizada tradicionalmente argentina.'),
  ('c58', 'Chicharrón de chancho', 'Natural', 'Grasa de cerdo para bagres grandes.'),
  ('c59', 'Corazón de pollo', 'Natural', 'Víscera resistente para especies grandes.'),
  ('c60', 'Saltamontes', 'Natural', 'Insecto terrestre para truchas en verano.'),
  ('c61', 'Cangrejo de río', 'Natural', 'Crustáceo natural para dorados y surubíes.'),
  ('c62', 'Almeja', 'Natural', 'Molusco para pesca costera de corvinas.'),
  ('c63', 'Camarón salado', 'CarnadaMuerta', 'Camarón preservado para corvinas.'),
  ('c64', 'Tuco', 'Viva', 'Gusano grande para bagres, muy resistente.'),
  ('c65', 'Mojarra salada', 'CarnadaMuerta', 'Pez conservado en sal para grandes depredadores.'),
  ('c66', 'Ninfa artificial', 'MoscaArtificial', 'Mosca hundimiento para truchas bajo superficie.'),
  ('c67', 'Spinner Patagónico', 'ArtificialDuro', 'Cuchara giratoria específica para lagos fríos.'),
  ('c68', 'Pluma de gallina', 'Natural', 'Pluma natural para fly fishing tradicional.'),
  ('c69', 'Hormiga voladora', 'Natural', 'Insecto estacional muy efectivo en primavera.'),
  ('c70', 'Grillo de campo', 'Natural', 'Insecto terrestre para pesca en arroyos.'),
  ('c71', 'Hueva de pejerrey', 'Natural', 'Huevos naturales para especies nativas.'),
  ('c72', 'Caracol de agua', 'Natural', 'Molusco natural para peces herbívoros.'),
  ('c73', 'Streamer artesanal', 'MoscaArtificial', 'Mosca imitación pez para truchas grandes.'),
  ('c74', 'Pancora', 'Viva', 'Cangrejo de río patagónico, muy efectivo.'),
  ('c75', 'Libélula', 'Natural', 'Insecto acuático adulto para pesca superficial.'),
  ('c76', 'Masa con miel', 'Natural', 'Masa dulce tradicional para carpas y bogas.'),
  ('c77', 'Bicho candado', 'Natural', 'Larva acuática común en remansos.'),
  ('c78', 'Mosca ahogada', 'MoscaArtificial', 'Mosca húmeda tradicional patagónica.');

INSERT INTO "EspecieTipoPesca" ("id", "idEspecie", "idTipoPesca", "descripcion") VALUES
('etp1', 'es2', 'tp1', 'Spinning: Señuelos tipo minnows y poppers en corrientes rápidas y pozones profundos. Caña 2 m, acción media, reel frontal con buen freno. Horario: amanecer y atardecer, cuando hay actividad en superficie.'),
('etp2', 'es2', 'tp2', 'Bait Casting: Lanzar señuelos de media agua en correderas con amplio caudal. Caña 1,8-2,1 m rígida, reel baitcasting potente. Ideal con poppers, stickbaits y crankbaits. Horario: amanecer y atardecer.'),
('etp3', 'es2', 'tp6', 'Trolling: Desde embarcación en movimiento, con cucharas y señuelos de gran tamaño. Cañas robustas y reels rotativos con línea de 0,35 mm. Mejor en sectores con pozones y saltos de agua.'),
('etp4', 'es2', 'tp3', 'Pesca de Fondo: Usando carnada viva (mojarra, sabalito) en sectores profundos y lentos del río. Caña de fondo 2,7 m y reel resistente. Horario: todo el día, mejor en bajantes de agua.');

-- TARARIRA COMÚN (Hoplias malabaricus)
INSERT INTO "EspecieTipoPesca" ("id", "idEspecie", "idTipoPesca", "descripcion") VALUES
('etp5', 'es1', 'tp1', 'Spinning: Señuelos de superficie y medias aguas como ranas, paseantes y crankbaits. Caña 1,8-2,2 m, reel frontal. Ubicación: lagunas con vegetación densa, canales y arroyos. Horario: amanecer y atardecer.'),
('etp6', 'es1', 'tp3', 'Pesca de Fondo: Carnada viva o muerta (lombriz, pez pequeño). Línea con plomada descansando en fondo. Caña de 2,7 m y reel resistente. Efectiva en aguas profundas cerca de troncos y raíces.'),
('etp7', 'es1', 'tp2', 'Bait Casting: Señuelos grandes tipo stickbait o frog. Lanzamientos cortos y precisos a la vegetación. Horario: primeras horas de la mañana y últimas de la tarde.'),
('etp8', 'es1', 'tp5', 'Mosca: Imitaciones de insectos grandes o pequeños peces. Ideal para aguas calmadas con mucha cobertura. Caña 2,1 m, línea flotante o intermedia.');

-- PEJERREY BONAERENSE (Odontesthes bonariensis)
INSERT INTO "EspecieTipoPesca" ("id", "idEspecie", "idTipoPesca", "descripcion") VALUES
('etp9', 'es13', 'tp4', 'Pesca de Flote: Línea fina con boya pequeña. Carnada: mojarra viva o filet. Caña liviana 2-3 m, reel pequeño. Horario: mañanas soleadas y tardes nubladas.'),
('etp10', 'es13', 'tp5', 'Mosca: Pequeñas imitaciones de larvas o ninfas. Caña 2,1 m, línea liviana. Agua calma de lagunas o arroyos. Horario: todo el día con picos a media mañana.'),
('etp11', 'es13', 'tp3', 'Pesca de Fondo: Masa o filet pequeño con línea fina al fondo. Efectivo en madrugadas o anochecer. Cañas cortas y flexibles, reel liviano.');

-- SURUBÍ PINTADO (Pseudoplatystoma corruscans)
INSERT INTO "EspecieTipoPesca" ("id", "idEspecie", "idTipoPesca", "descripcion") VALUES
('etp12', 'es3', 'tp3', 'Pesca de Fondo: Carnadas vivas como anguilas, bogas o trozos de pescado. Cañas largas 3 m y reels rotativos resistentes. Ubicación: pozones profundos y corrientes fuertes. Horario: nocturno, especialmente después del atardecer.'),
('etp13', 'es3', 'tp2', 'Bait Casting: Señuelos grandes tipo jerkbait o popper pesado. Se lanzan cerca de troncos y rocas sumergidas. Horario: atardecer y primeras horas de la noche.'),
('etp14', 'es3', 'tp1', 'Spinning: Grandes minnows o stickbaits en corrientes profundas. Ideal para pescar durante el día en pozones y remansos. Caña 2,4 m, reel frontal robusto.'),
('etp15', 'es3', 'tp6', 'Trolling: Señuelos pesados arrastrados desde embarcación en ríos grandes. Línea 0,40 mm, reel rotativo grande. Horario: mañana y tarde, aguas profundas y lentas.'),

-- CARPA COMÚN (Cyprinus carpio)
('etp16', 'es24', 'tp3', 'Pesca de Fondo: Masa con esencias, maíz hervido, papa. Cañas largas 3-4 m, reel frontal grande. Ubicación: lagunas cálidas. Horario: todo el día, mejor en verano.'),
('etp17', 'es24', 'tp14', 'Pesca con Cebado: Arrojar maíz molido para atraer cardúmenes. Masa dulce como carnada. Técnica de paciencia en aguas tranquilas.'),

-- BAGRE SAPO (Rhamdia quelen)
('etp18', 'es21', 'tp3', 'Pesca de Fondo: Carnadas fuertes como tripas, hígado o lombrices. Nocturno en pozones rocosos. Cañas resistentes y plomos pesados.'),

-- ARMADO (Pterodoras granulosus)
('etp19', 'es22', 'tp3', 'Pesca de Fondo: Carnadas grandes y resistentes. Equipos muy robustos por su fuerza. Pesca nocturna en corrientes fuertes.'),

-- CORVINA RUBIA (Micropogonias furnieri)
('etp20', 'es30', 'tp7', 'Surfcasting: Desde playa con carnadas naturales como camarón y cangrejo. Cañas largas 4 m, lanzamientos lejanos. Mejor con marea entrante.'),

-- PACÚ (Piaractus mesopotamicus)
('etp21', 'es6', 'tp3', 'Pesca de Fondo: Con frutas como mburucuyá, higo, o masa. Caña media 2,5 m en remansos y lagunas. Horario: mañana y tarde.'),
('etp22', 'es6', 'tp1', 'Spinning: Señuelos pequeños que imitan frutas o crankbaits. En aguas tranquilas cerca de árboles frutales.'),

-- BOGA (Megaleporinus obtusidens)  
('etp23', 'es9', 'tp3', 'Pesca de Fondo: Maíz, masa, lombrices en corrientes medianas. Caña 2,7 m, reel resistente. Muy combativa.'),
('etp24', 'es9', 'tp4', 'Pesca de Flote: Con boya en corrientes suaves. Carnada: maíz o masa. Horario: todo el día.'),

-- SÁBALO (Prochilodus lineatus)
('etp25', 'es10', 'tp3', 'Pesca de Fondo: Masa vegetal, harinas. Caña larga en ríos grandes. Se usa principalmente como carnada.'),

-- TARARIRA AZUL (Hoplias lacerdae)
('etp26', 'es11', 'tp2', 'Bait Casting: Señuelos grandes, poppers potentes. Lanzamientos precisos a estructuras. Muy agresiva.'),
('etp27', 'es11', 'tp1', 'Spinning: Paseantes y stickbaits grandes. Caña robusta 2,2 m. Horario: amanecer y atardecer.'),

-- TARARIRA PINTADA (Hoplias australis)
('etp28', 'es12', 'tp1', 'Spinning: Señuelos de superficie medianos. En lagunas con vegetación. Similar a tararira común.'),

-- PEJERREY PATAGÓNICO (Odontesthes hatcheri)
('etp29', 'es14', 'tp5', 'Mosca: En lagos fríos con ninfas pequeñas. Caña liviana, línea flotante. Horario: mañanas claras.'),
('etp30', 'es14', 'tp4', 'Pesca de Flote: Con carnada pequeña en aguas frías. Equipos livianos y líneas finas.'),

-- PERCA CRIOLLA (Percichthys trucha)
('etp31', 'es16', 'tp1', 'Spinning: Cucharitas pequeñas en lagos patagónicos. Caña liviana, señuelos brillantes.'),
('etp32', 'es16', 'tp5', 'Mosca: Streamers y ninfas en aguas frías. Técnica similar a truchas.'),

-- TRUCHA ARCOÍRIS (Oncorhynchus mykiss)
('etp33', 'es17', 'tp5', 'Mosca: Moscas secas, ninfas, streamers. Caña 2,4 m en ríos serranos. Horario: amanecer y atardecer.'),
('etp34', 'es17', 'tp1', 'Spinning: Cucharitas giratorias en corrientes rápidas. Caña liviana 2 m, señuelos brillantes.'),

-- TRUCHA MARRÓN (Salmo trutta)
('etp35', 'es18', 'tp5', 'Mosca: Técnica refinada, moscas secas grandes. Pesca selectiva en pozones profundos.'),
('etp36', 'es18', 'tp1', 'Spinning: Señuelos pequeños tipo minnow. Horario: atardecer y noche.'),

-- TRUCHA DE ARROYO (Salvelinus fontinalis)
('etp37', 'es19', 'tp5', 'Mosca: Moscas secas pequeñas en arroyos serranos. Equipos ultra livianos.'),

-- ESPECIES PEQUEÑAS - MOJARRERO Y PESCA FINA
-- CHANCHITA (Crenicichla lacustris)
('etp38', 'es31', 'tp16', 'Mojarrero: Caña telescópica 3,5 m, reel pequeño, línea fina 0,16 mm. Lombriz cortada en pozones de arroyos. Horario: todo el día.'),
('etp39', 'es31', 'tp17', 'Pesca a la Cueva: Lanzamientos cortos bajo troncos y raíces. Caña corta rígida, carnada cerca del fondo.'),

-- DIENTUDO (Oligosarcus jenynsii)  
('etp40', 'es32', 'tp16', 'Mojarrero: Equipos ultra livianos, anzuelos pequeños. Lombriz cortada en corrientes rápidas. Muy combativo para su tamaño.'),
('etp41', 'es32', 'tp1', 'Spinning Ultra Liviano: Mini cucharitas y micro jigs. Caña 1,8 m acción ultra rápida, reel 1000.'),

-- MOJARRA (Astyanax fasciatus)
('etp42', 'es25', 'tp16', 'Mojarrero: Técnica clásica con bolitas de pan, lombriz cortada. Caña telescópica, anzuelos pequeños N° 12-14.'),
('etp43', 'es25', 'tp4', 'Pesca de Flote Liviano: Boya pequeña, línea fina. Pan, lombriz cortada. Ideal para principiantes.'),

-- MADRECITA Y PANZUDITO (especies diminutas)
('etp44', 'es33', 'tp16', 'Mojarrero Ultra Fino: Anzuelos N° 16-18, línea 0,12 mm. Larvas de mosquito, miga de pan microscópica.'),
('etp45', 'es34', 'tp16', 'Mojarrero Ultra Fino: Similar a madrecita, equipos finísimos. Paciencia y precisión extrema.'),

-- CHANCHITA RAYADA (Cichlasoma dimerus)
('etp46', 'es35', 'tp16', 'Mojarrero: Lombriz, cascarita de huevo. Territorial, buscar en nidos cerca de vegetación.'),
('etp47', 'es35', 'tp17', 'Pesca a la Cueva: En estructuras rocosas y troncos. Muy agresiva en época reproductiva.'),

-- BAGRE NEGRO (Heptapterus mustelinus)
('etp48', 'es36', 'tp3', 'Pesca de Fondo Liviano: Lombriz al fondo en arroyos pedregosos. Nocturno, caña media 2,5 m.'),

-- CASTAÑETA (Australoheros facetus)
('etp49', 'es37', 'tp16', 'Mojarrero: Lombriz, masa pequeña. Lagunas pampeanas, muy resistente al frío.'),

-- MOJARRA COLA ROJA (Cheirodon interruptus)
('etp50', 'es38', 'tp16', 'Mojarrero: Cardúmenes en aguas claras. Anzuelos diminutos, lombriz cortadita.'),

-- TÉCNICAS FALTANTES PARA COMPLETAR TODAS LAS ESPECIES

-- SURUBÍ ATIGRADO (Pseudoplatystoma reticulatum) - es4
('etp51', 'es4', 'tp3', 'Pesca de Fondo: Similar al pintado, carnadas vivas grandes. Nocturno en pozones profundos.'),
('etp52', 'es4', 'tp20', 'Pesca Nocturna Especializada: Equipos robustos, carnadas grandes. Pozones rocosos.'),

-- MANGURUYÚ (Zungaro zungaro) - es5
('etp53', 'es5', 'tp3', 'Pesca de Fondo: Carnadas muy grandes, equipos de alta resistencia. Solo en ríos grandes.'),
('etp54', 'es5', 'tp20', 'Pesca Nocturna Especializada: Técnica para bagres gigantes. Cañas pesadas, líneas gruesas.'),

-- PACÚ RELOJ (Myloplus rubripinnis) - es7
('etp55', 'es7', 'tp3', 'Pesca de Fondo: Frutas y masa en remansos. Equipos medianos, horario de mediodía.'),

-- PACÚ CHATO (Colossoma mitrei) - es8
('etp56', 'es8', 'tp3', 'Pesca de Fondo: Frutas, maíz y masa en lagunas conectadas a ríos.'),

-- SÁBALO (Prochilodus lineatus) - es10
('etp57', 'es10', 'tp3', 'Pesca de Fondo: Masa vegetal, principalmente usado como carnada para grandes depredadores.'),

-- TARARIRA PINTADA (Hoplias australis) - es12
('etp58', 'es12', 'tp1', 'Spinning: Señuelos de superficie en lagunas con vegetación. Similar a tararira común.'),
('etp59', 'es12', 'tp17', 'Pesca a la Cueva: Bajo vegetación flotante, lanzamientos precisos.'),

-- PEJERREY PATAGÓNICO (Odontesthes hatcheri) - es14
('etp60', 'es14', 'tp5', 'Mosca: Lagos fríos con ninfas pequeñas. Mañanas despejadas.'),
('etp61', 'es14', 'tp4', 'Pesca de Flote: Carnada pequeña en aguas frías, equipos livianos.'),

-- PEJERREY FUEGUINO (Odontesthes nigricans) - es15
('etp62', 'es15', 'tp5', 'Mosca: Aguas extremadamente frías, moscas diminutas.'),
('etp63', 'es15', 'tp4', 'Pesca de Flote: Equipos ultra livianos en lagos fueguinos.'),

-- PATÍ (Luciopimelodus pati) - es23
('etp64', 'es23', 'tp3', 'Pesca de Fondo: Carnadas vivas grandes, pozones profundos. Nocturno.'),
('etp65', 'es23', 'tp20', 'Pesca Nocturna Especializada: Bagre de gran tamaño, equipos robustos.'),

-- PIRAPITÁ (Brycon orbignyanus) - es27
('etp66', 'es27', 'tp1', 'Spinning: Señuelos pequeños tipo dorado. Corrientes rápidas.'),
('etp67', 'es27', 'tp2', 'Bait Casting: Poppers chicos en correntadas. Muy combativo.'),

-- BOGA LISA (Leporinus friderici) - es28
('etp68', 'es28', 'tp3', 'Pesca de Fondo: Maíz, frutas. Corrientes medianas, equipos livianos.'),
('etp69', 'es28', 'tp4', 'Pesca de Flote: Boya en corrientes suaves, carnada vegetal.'),

-- PALOMETA (Crenicichla britskii) - es29
('etp70', 'es29', 'tp1', 'Spinning: Señuelos pequeños en arroyos y lagunas. Agresiva.'),
('etp71', 'es29', 'tp17', 'Pesca a la Cueva: Bajo estructuras, lanzamientos precisos.'),

-- PUYÉN GRANDE (Galaxias maculatus) - es39
('etp72', 'es39', 'tp28', 'Pesca en Espejos: Carnadas pequeñas en lagunas patagónicas. Anzuelos diminutos.'),
('etp73', 'es39', 'tp27', 'Fly Fishing Ninfeo: Ninfas microscópicas en aguas frías.'),

-- PERCA PATAGÓNICA (Percichthys colhuapiensis) - es40
('etp74', 'es40', 'tp25', 'Spinning Patagónico: Cucharitas rotativas en lagos profundos.'),
('etp75', 'es40', 'tp26', 'Trolling Lacustre: Pesca al curricán en grandes lagos.'),

-- BAGRE BLANCO DEL SUR (Diplomystes viedmensis) - es41
('etp76', 'es41', 'tp3', 'Pesca de Fondo: Carnadas naturales en pozones patagónicos. Especie protegida.'),
('etp77', 'es41', 'tp28', 'Pesca en Espejos: Solo captura y liberación, conservación extrema.');

INSERT INTO "Spot" (
  "id", "idUsuario", "idUsuarioActualizo", "nombre", "estado", "descripcion", "ubicacion", "fechaPublicacion", "fechaActualizacion", "imagenPortada", "isDeleted"
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
  CURRENT_DATE,
  'uploads/taruchini.png',
  FALSE
),
(
  'SpotParana',
  'usuario1',
  'usuario1', 
  'Río Paraná - Puerto Iguazú',
  'Aceptado',
  'Excelente para dorados y surubíes. Pozones profundos con buena corriente.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point", 
    "coordinates": [-54.588249, -25.695365]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/dorado.png',
  FALSE
),
(
  'SpotDelta',
  'usuario2',
  'usuario2',
  'Delta del Tigre - Canal principal', 
  'Aceptado',
  'Variedad de especies: tarariras, bogas, bagres. Navegable en lancha.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-58.574181, -34.426218] 
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/boga.png',
  FALSE
),
(
  'SpotGeneral',
  'usuario1',
  'usuario1',
  'Spot Genérico - Todas las especies',
  'Aceptado',
  'Spot genérico para asignación de carnadas a todas las especies.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-60.000000, -35.000000] 
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/dorado.png',
  FALSE
);

INSERT INTO "SpotEspecie" ("id", "idSpot", "idEspecie") VALUES
  -- Spot Secreto
  ('se1', 'SpotSecreto', 'es1'),  -- Tararira
  ('se2', 'SpotSecreto', 'es13'), -- Pejerrey
  ('se3', 'SpotSecreto', 'es2'),  -- Dorado
  -- Spot Paraná
  ('se4', 'SpotParana', 'es2'),   -- Dorado
  ('se5', 'SpotParana', 'es3'),   -- Surubí pintado  
  ('se6', 'SpotParana', 'es6'),   -- Pacú
  ('se7', 'SpotParana', 'es9'),   -- Boga
  -- Spot Delta
  ('se8', 'SpotDelta', 'es1'),    -- Tararira
  ('se9', 'SpotDelta', 'es9'),    -- Boga
  ('se10', 'SpotDelta', 'es20'),  -- Bagre blanco
  ('se11', 'SpotDelta', 'es25'),  -- Mojarra
  ('se12', 'SpotDelta', 'es24'),  -- Carpa
  
  -- Spot General - Todas las especies restantes
  ('se13', 'SpotGeneral', 'es4'),   -- Surubí atigrado
  ('se14', 'SpotGeneral', 'es5'),   -- Manguruyú
  ('se15', 'SpotGeneral', 'es7'),   -- Pacú reloj
  ('se16', 'SpotGeneral', 'es8'),   -- Pacú chato
  ('se17', 'SpotGeneral', 'es10'),  -- Sábalo
  ('se18', 'SpotGeneral', 'es11'),  -- Tararira azul
  ('se19', 'SpotGeneral', 'es12'),  -- Tararira pintada
  ('se20', 'SpotGeneral', 'es14'),  -- Pejerrey patagónico
  ('se21', 'SpotGeneral', 'es15'),  -- Pejerrey fueguino
  ('se22', 'SpotGeneral', 'es16'),  -- Perca criolla
  ('se23', 'SpotGeneral', 'es17'),  -- Trucha arcoíris
  ('se24', 'SpotGeneral', 'es18'),  -- Trucha marrón
  ('se25', 'SpotGeneral', 'es19'),  -- Trucha de arroyo
  ('se26', 'SpotGeneral', 'es21'),  -- Bagre sapo
  ('se27', 'SpotGeneral', 'es22'),  -- Armado
  ('se28', 'SpotGeneral', 'es23'),  -- Patí
  ('se29', 'SpotGeneral', 'es26'),  -- Anguila criolla
  ('se30', 'SpotGeneral', 'es27'),  -- Pirapitá
  ('se31', 'SpotGeneral', 'es28'),  -- Boga lisa
  ('se32', 'SpotGeneral', 'es29'),  -- Palometa
  ('se33', 'SpotGeneral', 'es31'),  -- Chanchita
  ('se34', 'SpotGeneral', 'es32'),  -- Dientudo
  ('se35', 'SpotGeneral', 'es33'),  -- Madrecita
  ('se36', 'SpotGeneral', 'es34'),  -- Panzudito
  ('se37', 'SpotGeneral', 'es35'),  -- Chanchita rayada
  ('se38', 'SpotGeneral', 'es36'),  -- Bagre negro
  ('se39', 'SpotGeneral', 'es37'),  -- Castañeta
  ('se40', 'SpotGeneral', 'es38');  -- Mojarra cola roja 


INSERT INTO "SpotTipoPesca" ("id", "idSpot", "idTipoPesca") VALUES
  -- Spot Secreto
  ('stp1', 'SpotSecreto', 'tp1'),  -- Spinning
  ('stp2', 'SpotSecreto', 'tp4'),  -- Flote
  -- Spot Paraná  
  ('stp3', 'SpotParana', 'tp1'),   -- Spinning
  ('stp4', 'SpotParana', 'tp2'),   -- Bait Casting
  ('stp5', 'SpotParana', 'tp6'),   -- Trolling
  ('stp6', 'SpotParana', 'tp3'),   -- Fondo
  -- Spot Delta
  ('stp7', 'SpotDelta', 'tp1'),    -- Spinning
  ('stp8', 'SpotDelta', 'tp3'),    -- Fondo
  ('stp9', 'SpotDelta', 'tp4');    -- Flote


INSERT INTO "SpotCarnadaEspecie" ("id", "idSpot", "idEspecie", "idCarnada") VALUES
  -- SPOT SECRETO - Tararira
  ('sce1', 'SpotSecreto', 'es1', 'c1'),   -- Rana artificial
  ('sce2', 'SpotSecreto', 'es1', 'c28'),  -- Mojarra viva
  ('sce3', 'SpotSecreto', 'es1', 'c11'),  -- Paseante
  ('sce4', 'SpotSecreto', 'es1', 'c2'),   -- Lombriz siliconada
  -- SPOT SECRETO - Dorado  
  ('sce5', 'SpotSecreto', 'es2', 'c10'),  -- Popper
  ('sce6', 'SpotSecreto', 'es2', 'c14'),  -- Cucharita ondulante
  ('sce7', 'SpotSecreto', 'es2', 'c28'),  -- Mojarra viva
  -- SPOT SECRETO - Pejerrey
  ('sce8', 'SpotSecreto', 'es13', 'c33'), -- Filet de mojarra
  ('sce9', 'SpotSecreto', 'es13', 'c35'), -- Grillo
  
  -- SPOT PARANÁ - Dorado
  ('sce10', 'SpotParana', 'es2', 'c10'),  -- Popper
  ('sce11', 'SpotParana', 'es2', 'c11'),  -- Paseante  
  ('sce12', 'SpotParana', 'es2', 'c14'),  -- Cucharita ondulante
  ('sce13', 'SpotParana', 'es2', 'c28'),  -- Mojarra viva
  ('sce14', 'SpotParana', 'es2', 'c21'),  -- Carne vacuna
  -- SPOT PARANÁ - Surubí
  ('sce15', 'SpotParana', 'es3', 'c29'),  -- Morena viva
  ('sce16', 'SpotParana', 'es3', 'c21'),  -- Carne vacuna
  ('sce17', 'SpotParana', 'es3', 'c28'),  -- Mojarra viva
  ('sce18', 'SpotParana', 'es3', 'c20'),  -- Tripas de pollo
  -- SPOT PARANÁ - Pacú
  ('sce19', 'SpotParana', 'es6', 'c31'),  -- Mburucuyá
  ('sce20', 'SpotParana', 'es6', 'c27'),  -- Maíz hervido
  ('sce21', 'SpotParana', 'es6', 'c22'),  -- Masa casera
  -- SPOT PARANÁ - Boga
  ('sce22', 'SpotParana', 'es9', 'c27'),  -- Maíz hervido
  ('sce23', 'SpotParana', 'es9', 'c22'),  -- Masa casera
  ('sce24', 'SpotParana', 'es9', 'c19'),  -- Lombriz común
  
  -- SPOT DELTA - Tararira
  ('sce25', 'SpotDelta', 'es1', 'c1'),    -- Rana artificial
  ('sce26', 'SpotDelta', 'es1', 'c11'),   -- Paseante
  ('sce27', 'SpotDelta', 'es1', 'c28'),   -- Mojarra viva
  -- SPOT DELTA - Boga
  ('sce28', 'SpotDelta', 'es9', 'c27'),   -- Maíz hervido
  ('sce29', 'SpotDelta', 'es9', 'c32'),   -- Papa hervida
  ('sce30', 'SpotDelta', 'es9', 'c19'),   -- Lombriz común
  -- SPOT DELTA - Bagre blanco
  ('sce31', 'SpotDelta', 'es20', 'c20'),  -- Tripas de pollo
  ('sce32', 'SpotDelta', 'es20', 'c19'),  -- Lombriz común
  ('sce33', 'SpotDelta', 'es20', 'c34'),  -- Hígado de pollo
  -- SPOT DELTA - Mojarra
  ('sce34', 'SpotDelta', 'es25', 'c19'),  -- Lombriz común
  ('sce35', 'SpotDelta', 'es25', 'c26'),  -- Pan remojado
  -- SPOT DELTA - Carpa
  ('sce36', 'SpotDelta', 'es24', 'c27'),  -- Maíz hervido
  ('sce37', 'SpotDelta', 'es24', 'c32'),  -- Papa hervida
  ('sce38', 'SpotDelta', 'es24', 'c22'),  -- Masa casera

  -- CARNADAS PARA ESPECIES SIN ASIGNAR - SPOT GENERAL

  -- Surubí atigrado (es4) - Similar al pintado
  ('sce39', 'SpotGeneral', 'es4', 'c29'),  -- Morena viva
  ('sce40', 'SpotGeneral', 'es4', 'c21'),  -- Carne vacuna
  ('sce41', 'SpotGeneral', 'es4', 'c28'),  -- Mojarra viva

  -- Manguruyú (es5) - Carnadas grandes
  ('sce42', 'SpotGeneral', 'es5', 'c29'),  -- Morena viva
  ('sce43', 'SpotGeneral', 'es5', 'c21'),  -- Carne vacuna
  ('sce44', 'SpotGeneral', 'es5', 'c24'),  -- Panceta

  -- Pacú reloj (es7) - Frutas y masa
  ('sce45', 'SpotGeneral', 'es7', 'c31'),  -- Mburucuyá
  ('sce46', 'SpotGeneral', 'es7', 'c27'),  -- Maíz hervido
  ('sce47', 'SpotGeneral', 'es7', 'c22'),  -- Masa casera

  -- Pacú chato (es8) - Similar al común
  ('sce48', 'SpotGeneral', 'es8', 'c31'),  -- Mburucuyá
  ('sce49', 'SpotGeneral', 'es8', 'c27'),  -- Maíz hervido
  ('sce50', 'SpotGeneral', 'es8', 'c32'),  -- Papa hervida

  -- Sábalo (es10) - Masa vegetal
  ('sce51', 'SpotGeneral', 'es10', 'c22'), -- Masa casera
  ('sce52', 'SpotGeneral', 'es10', 'c26'), -- Pan remojado

  -- Tararira azul (es11) - Como tararira común pero señuelos más grandes
  ('sce53', 'SpotGeneral', 'es11', 'c11'), -- Paseante
  ('sce54', 'SpotGeneral', 'es11', 'c28'), -- Mojarra viva
  ('sce55', 'SpotGeneral', 'es11', 'c10'), -- Popper

  -- Tararira pintada (es12) - Similar a común
  ('sce56', 'SpotGeneral', 'es12', 'c1'),  -- Rana artificial
  ('sce57', 'SpotGeneral', 'es12', 'c28'), -- Mojarra viva
  ('sce58', 'SpotGeneral', 'es12', 'c11'), -- Paseante

  -- Pejerrey patagónico (es14) - Carnadas frías
  ('sce59', 'SpotGeneral', 'es14', 'c33'), -- Filet de mojarra
  ('sce60', 'SpotGeneral', 'es14', 'c35'), -- Grillo
  ('sce61', 'SpotGeneral', 'es14', 'c39'), -- Mosca seca

  -- Pejerrey fueguino (es15) - Similar al patagónico
  ('sce62', 'SpotGeneral', 'es15', 'c33'), -- Filet de mojarra
  ('sce63', 'SpotGeneral', 'es15', 'c47'), -- Mosca mojada chica

  -- Perca criolla (es16) - Como truchas
  ('sce64', 'SpotGeneral', 'es16', 'c15'), -- Cucharita giratoria
  ('sce65', 'SpotGeneral', 'es16', 'c38'), -- Streamer
  ('sce66', 'SpotGeneral', 'es16', 'c19'), -- Lombriz común

  -- Trucha arcoíris (es17) - Clásicas de trucha
  ('sce67', 'SpotGeneral', 'es17', 'c15'), -- Cucharita giratoria
  ('sce68', 'SpotGeneral', 'es17', 'c39'), -- Mosca seca
  ('sce69', 'SpotGeneral', 'es17', 'c37'), -- Ninfa

  -- Trucha marrón (es18) - Selectiva
  ('sce70', 'SpotGeneral', 'es18', 'c39'), -- Mosca seca
  ('sce71', 'SpotGeneral', 'es18', 'c7'),  -- Minnow blando
  ('sce72', 'SpotGeneral', 'es18', 'c15'), -- Cucharita giratoria

  -- Trucha de arroyo (es19) - Moscas pequeñas
  ('sce73', 'SpotGeneral', 'es19', 'c39'), -- Mosca seca
  ('sce74', 'SpotGeneral', 'es19', 'c47'), -- Mosca mojada chica

  -- Bagre sapo (es21) - Carnadas fuertes
  ('sce75', 'SpotGeneral', 'es21', 'c20'), -- Tripas de pollo
  ('sce76', 'SpotGeneral', 'es21', 'c34'), -- Hígado de pollo
  ('sce77', 'SpotGeneral', 'es21', 'c19'), -- Lombriz común

  -- Armado (es22) - Carnadas robustas
  ('sce78', 'SpotGeneral', 'es22', 'c20'), -- Tripas de pollo
  ('sce79', 'SpotGeneral', 'es22', 'c21'), -- Carne vacuna
  ('sce80', 'SpotGeneral', 'es22', 'c19'), -- Lombriz común

  -- Patí (es23) - Carnadas grandes
  ('sce81', 'SpotGeneral', 'es23', 'c28'), -- Mojarra viva
  ('sce82', 'SpotGeneral', 'es23', 'c20'), -- Tripas de pollo
  ('sce83', 'SpotGeneral', 'es23', 'c29'), -- Morena viva

  -- Anguila criolla (es26) - En barro
  ('sce84', 'SpotGeneral', 'es26', 'c19'), -- Lombriz común
  ('sce85', 'SpotGeneral', 'es26', 'c40'), -- Sanguijuela

  -- Pirapitá (es27) - Como doradillo
  ('sce86', 'SpotGeneral', 'es27', 'c14'), -- Cucharita ondulante
  ('sce87', 'SpotGeneral', 'es27', 'c28'), -- Mojarra viva
  ('sce88', 'SpotGeneral', 'es27', 'c10'), -- Popper

  -- Boga lisa (es28) - Vegetarianas
  ('sce89', 'SpotGeneral', 'es28', 'c27'), -- Maíz hervido
  ('sce90', 'SpotGeneral', 'es28', 'c31'), -- Mburucuyá
  ('sce91', 'SpotGeneral', 'es28', 'c19'), -- Lombriz común

  -- Palometa (es29) - Agresiva
  ('sce92', 'SpotGeneral', 'es29', 'c46'), -- Micro jig
  ('sce93', 'SpotGeneral', 'es29', 'c41'), -- Lombriz cortada
  ('sce94', 'SpotGeneral', 'es29', 'c28'), -- Mojarra viva

  -- Chanchita (es31) - Territorial
  ('sce95', 'SpotGeneral', 'es31', 'c41'), -- Lombriz cortada
  ('sce96', 'SpotGeneral', 'es31', 'c49'), -- Cascarita
  ('sce97', 'SpotGeneral', 'es31', 'c46'), -- Micro jig

  -- Dientudo (es32) - Combativo pequeño
  ('sce98', 'SpotGeneral', 'es32', 'c41'), -- Lombriz cortada
  ('sce99', 'SpotGeneral', 'es32', 'c50'), -- Mini cucharita
  ('sce100', 'SpotGeneral', 'es32', 'c42'), -- Bolita de pan

  -- Madrecita (es33) - Diminuta
  ('sce101', 'SpotGeneral', 'es33', 'c43'), -- Larva de mosquito
  ('sce102', 'SpotGeneral', 'es33', 'c42'), -- Bolita de pan

  -- Panzudito (es34) - También diminuto
  ('sce103', 'SpotGeneral', 'es34', 'c43'), -- Larva de mosquito
  ('sce104', 'SpotGeneral', 'es34', 'c44'), -- Gusano de humedad

  -- Chanchita rayada (es35) - Más grande
  ('sce105', 'SpotGeneral', 'es35', 'c19'), -- Lombriz común
  ('sce106', 'SpotGeneral', 'es35', 'c49'), -- Cascarita
  ('sce107', 'SpotGeneral', 'es35', 'c46'), -- Micro jig

  -- Bagre negro (es36) - Arroyo
  ('sce108', 'SpotGeneral', 'es36', 'c19'), -- Lombriz común
  ('sce109', 'SpotGeneral', 'es36', 'c44'), -- Gusano de humedad

  -- Castañeta (es37) - Resistente
  ('sce110', 'SpotGeneral', 'es37', 'c19'), -- Lombriz común
  ('sce111', 'SpotGeneral', 'es37', 'c22'), -- Masa casera
  ('sce112', 'SpotGeneral', 'es37', 'c41'), -- Lombriz cortada

  -- Mojarra cola roja (es38) - Cardumen
  ('sce113', 'SpotGeneral', 'es38', 'c41'), -- Lombriz cortada
  ('sce114', 'SpotGeneral', 'es38', 'c42'), -- Bolita de pan

  -- Puyén grande (es39) - Patagónico diminuto
  ('sce115', 'SpotGeneral', 'es39', 'c66'), -- Ninfa artificial
  ('sce116', 'SpotGeneral', 'es39', 'c51'), -- Isoca
  ('sce117', 'SpotGeneral', 'es39', 'c69'), -- Hormiga voladora

  -- Perca patagónica (es40) - Lagos fríos
  ('sce118', 'SpotGeneral', 'es40', 'c67'), -- Spinner Patagónico
  ('sce119', 'SpotGeneral', 'es40', 'c73'), -- Streamer artesanal
  ('sce120', 'SpotGeneral', 'es40', 'c28'), -- Mojarra viva

  -- Bagre blanco del sur (es41) - Protegido
  ('sce121', 'SpotGeneral', 'es41', 'c19'); -- Lombriz común

-- DATOS DE EJEMPLO DE CAPTURAS
INSERT INTO "Captura" (
  "id", "idUsuario", "especieId", "fecha", "ubicacion", "peso", "longitud", 
  "carnada", "tipoPesca", "foto", "notas", "clima", "horaCaptura"
) VALUES
-- Capturas de Carlos Tarucha (usuario1)
('cap001', 'usuario1', 'es2', '2024-03-15', 'Río Paraná - Puerto Iguazú', 8.50, 75.0, 
 'Popper dorado', 'Spinning', 'uploads/dorado_cap_001.jpg', 
 'Excelente pelea de 20 minutos. El dorado saltó 6 veces fuera del agua. Condiciones perfectas al amanecer.',
 'Despejado, sin viento', '06:30:00'),

('cap002', 'usuario1', 'es1', '2024-03-20', 'Laguna Los Patos - San Pedro', 2.80, 48.0,
 'Rana artificial verde', 'Spinning', 'uploads/tararira_cap_002.jpg',
 'Tararira muy agresiva, atacó la rana en la primera pasada. Perfecta para la parrilla.',
 'Nublado, brisa suave', '18:45:00'),

('cap003', 'usuario1', 'es13', '2024-02-28', 'Laguna de Chascomús', 0.850, 32.0,
 'Filet de mojarra', 'Pesca de Flote', 'uploads/pejerrey_cap_003.jpg',
 'Día ideal para pejerrey. Cardumen muy activo en la mañana. Capturé 12 ejemplares.',
 'Soleado, calmo', '09:15:00'),

('cap004', 'usuario1', 'es3', '2024-03-10', 'Río Uruguay - Gualeguaychú', 15.20, 95.0,
 'Morena viva grande', 'Pesca de Fondo', 'uploads/surubi_cap_004.jpg',
 'Surubí nocturno de gran porte. Pesca desde la costa con equipo pesado. Pelea de 45 minutos.',
 'Noche despejada, sin luna', '23:30:00'),

('cap005', 'usuario1', 'es6', '2024-03-25', 'Río Paraná - Rosario', 4.10, 55.0,
 'Mburucuyá maduro', 'Pesca de Fondo', 'uploads/pacu_cap_005.jpg',
 'Pacú capturado con fruta en bajante. Muy combativo para su tamaño. Excelente carne.',
 'Parcialmente nublado', '16:20:00'),

-- Capturas de Lucía Señuelera (usuario2)
('cap006', 'usuario2', 'es17', '2024-01-18', 'Río Limay - Bariloche', 3.40, 52.0,
 'Cucharita giratoria #3', 'Spinning', 'uploads/trucha_cap_006.jpg',
 'Trucha arcoíris en perfecto estado. Agua cristalina a 12°C. Liberada después de la foto.',
 'Fresco, parcialmente nublado', '07:00:00'),

('cap007', 'usuario2', 'es18', '2024-01-22', 'Río Traful - Villa Traful', 5.80, 68.0,
 'Mosca seca #14', 'Mosca (Fly Fishing)', 'uploads/trucha_marron_cap_007.jpg',
 'Trucha marrón selectiva. Tardé 3 horas en encontrar la mosca correcta. Vale la pena la paciencia.',
 'Nublado, ideal para moscas', '19:30:00'),

('cap008', 'usuario2', 'es2', '2024-02-14', 'Río Paraná - Delta del Tigre', 6.20, 68.0,
 'Paseante plateado', 'Bait Casting', 'uploads/dorado_cap_008.jpg',
 'Dorado del Delta, más oscuro que los de río arriba. Ataque explosivo en canal profundo.',
 'Caluroso, húmedo', '17:45:00'),

('cap009', 'usuario2', 'es9', '2024-03-08', 'Río Paraná - Puerto Gaboto', 1.90, 42.0,
 'Maíz hervido', 'Pesca de Flote', 'uploads/boga_cap_009.jpg',
 'Boga muy combativa en equipo liviano. Cardumen numeroso alimentándose activamente.',
 'Viento sur moderado', '14:30:00'),

('cap010', 'usuario2', 'es24', '2024-02-20', 'Laguna San Roque - Córdoba', 7.80, 72.0,
 'Boilies de frutos rojos', 'Pesca con Cebado', 'uploads/carpa_cap_010.jpg',
 'Carpa gigante después de 6 horas de cebado. Pelea épica de una hora. Equipo al límite.',
 'Calmo, atardecer dorado', '20:15:00'),

-- Capturas adicionales para mostrar diversidad
('cap011', 'usuario1', 'es11', '2024-03-18', 'Río Paraná - Paso de la Patria', 7.50, 72.0,
 'Paseante gigante', 'Bait Casting', 'uploads/tararira_azul_cap_011.jpg',
 'Tararira azul de gran tamaño. Muy agresiva, destrozó dos señuelos antes de este.',
 'Tormentoso, pre-tormenta', '18:00:00'),

('cap012', 'usuario2', 'es20', '2024-03-12', 'Río de la Plata - Tigre', 1.20, 38.0,
 'Lombriz de mar', 'Pesca de Fondo', 'uploads/bagre_cap_012.jpg',
 'Bagre blanco nocturno. Pesca desde muelle, muy común en esta zona del río.',
 'Noche húmeda', '22:00:00'),

('cap013', 'usuario1', 'es25', '2024-03-22', 'Arroyo Pergamino', 0.15, 12.0,
 'Lombriz cortada', 'Mojarrero', 'uploads/mojarra_cap_013.jpg',
 'Sesión de mojarrero en arroyo cristalino. Capturé 30 ejemplares con equipo ultra liviano.',
 'Fresco, ideal', '10:30:00'),

('cap014', 'usuario2', 'es16', '2024-01-25', 'Lago Nahuel Huapi - Bariloche', 2.10, 35.0,
 'Streamer zonker', 'Mosca (Fly Fishing)', 'uploads/perca_cap_014.jpg',
 'Perca criolla en aguas profundas. Excelente pelea y sabor. Técnica de hundimiento.',
 'Frío, viento norte', '15:45:00'),

('cap015', 'usuario1', 'es4', '2024-03-05', 'Río Uruguay - Concordia', 12.30, 85.0,
 'Mojarra viva 20cm', 'Pesca Nocturna Especializada', 'uploads/surubi_atigrado_cap_015.jpg',
 'Surubí atigrado nocturno. Equipo pesado necesario. Pelea brutal de 35 minutos en correntada.',
 'Noche cerrada, húmeda', '01:15:00'),

-- Capturas estacionales y técnicas especiales
('cap016', 'usuario2', 'es19', '2024-01-10', 'Arroyo Pescado - El Bolsón', 0.680, 28.0,
 'Mosca seca hormiga #16', 'Mosca (Fly Fishing)', 'uploads/trucha_arroyo_cap_016.jpg',
 'Trucha de arroyo en agua cristalina de montaña. La más bella de todas. Liberada inmediatamente.',
 'Perfecto, sin viento', '11:00:00'),

('cap017', 'usuario1', 'es32', '2024-03-28', 'Arroyo Los Ingleses - Tandil', 0.08, 8.0,
 'Mini cucharita dorada', 'Spinning Ultra Liviano', 'uploads/dientudo_cap_017.jpg',
 'Dientudo combativo en arroyo serrano. Equipo ultra liviano, anzuelo N°16. Muy deportivo.',
 'Soleado, brisa suave', '16:00:00'),

('cap018', 'usuario2', 'es14', '2024-12-15', 'Lago Traful - Villa Traful', 1.10, 35.0,
 'Ninfa patagónica', 'Fly Fishing Ninfeo', 'uploads/pejerrey_patagonico_cap_018.jpg',
 'Pejerrey patagónico en lago frío. Técnica específica con mosca hundida. Agua a 8°C.',
 'Frío intenso, calmo', '13:30:00'),

('cap019', 'usuario1', 'es29', '2024-03-30', 'Arroyo Dulce - Villa María', 0.45, 18.0,
 'Micro jig verde', 'Pesca a la Cueva', 'uploads/palometa_cap_019.jpg',
 'Palometa territorial bajo tronco caído. Lanzamiento preciso necesario. Muy agresiva.',
 'Cálido, sin viento', '17:30:00'),

('cap020', 'usuario2', 'es39', '2024-01-20', 'Lago Gutiérrez - Bariloche', 0.18, 22.0,
 'Ninfa microscópica', 'Pesca en Espejos', 'uploads/puyen_cap_020.jpg',
 'Puyén grande endémico patagónico. Especie nativa muy especial. Técnica ultra fina requerida.',
 'Frío, lago como espejo', '14:00:00');

select * from "Usuario";



SELECT 'USUARIOS' as tabla, COUNT(*) as registros FROM "Usuario"
UNION ALL
SELECT 'ESPECIES' as tabla, COUNT(*) as registros FROM "Especie"
UNION ALL  
SELECT 'CARNADAS' as tabla, COUNT(*) as registros FROM "Carnada"
UNION ALL
SELECT 'TIPOS_PESCA' as tabla, COUNT(*) as registros FROM "TipoPesca"
UNION ALL
SELECT 'SPOTS' as tabla, COUNT(*) as registros FROM "Spot"
UNION ALL
SELECT 'CAPTURAS' as tabla, COUNT(*) as registros FROM "Captura"
ORDER BY tabla;

-- ALTER TABLE "Usuario"
-- ADD COLUMN "foto" VARCHAR(255) NULL;


select * from "Usuario";