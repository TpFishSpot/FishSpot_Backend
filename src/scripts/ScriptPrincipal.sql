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
DROP TABLE IF EXISTS "Reporte" CASCADE;

DROP TYPE IF EXISTS "NivelPescador" CASCADE;
DROP TYPE IF EXISTS "EstadoSpot" CASCADE;
DROP TYPE IF EXISTS "TipoCarnada" CASCADE;
DROP TYPE IF EXISTS "Reporte" CASCADE;

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
  "tamanio" DECIMAL(6,2),
  "carnada" VARCHAR(255) NOT NULL,
  "tipoPesca" VARCHAR(255) NOT NULL,
  "foto" VARCHAR(255),
  "notas" TEXT,
  "clima" VARCHAR(100),
  "horaCaptura" TIME,
  "spotId" VARCHAR(255),
  "latitud" DECIMAL(10,8),
  "longitud" DECIMAL(11,8),
  "fechaCreacion" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "fechaActualizacion" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id") ON DELETE CASCADE,
  FOREIGN KEY ("especieId") REFERENCES "Especie"("id") ON DELETE RESTRICT,
  FOREIGN KEY ("spotId") REFERENCES "Spot"("id") ON DELETE SET NULL
);

CREATE TABLE "Comentario" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idUsuario" VARCHAR(255),
  "idSpot" VARCHAR(255),
  "idCaptura" VARCHAR(255),
  "idComentarioPadre" VARCHAR(255),
  "contenido" VARCHAR(255),
  "fecha" DATE,
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id"),
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id"),
  FOREIGN KEY ("idCaptura") REFERENCES "Captura"("id") ON DELETE CASCADE,
  FOREIGN KEY ("idComentarioPadre") REFERENCES "Comentario"("id") ON DELETE CASCADE
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

CREATE TABLE "Reporte" (
  "id" VARCHAR(255) PRIMARY KEY,
  "idSpot" VARCHAR(255) NOT NULL,
  "idUsuario" VARCHAR(255) NOT NULL,
  "descripcion" VARCHAR(255),
  "fechaCreacion" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY ("idSpot") REFERENCES "Spot"("id") ON DELETE CASCADE,
  FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("id") ON DELETE CASCADE,
  CONSTRAINT unique_usuario_spot UNIQUE("idSpot", "idUsuario")
);

-- ============================================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ============================================================

CREATE INDEX idx_captura_usuario ON "Captura"("idUsuario");
CREATE INDEX idx_captura_especie ON "Captura"("especieId");
CREATE INDEX idx_captura_fecha ON "Captura"("fecha");
CREATE INDEX idx_captura_fecha_creacion ON "Captura"("fechaCreacion");
CREATE INDEX idx_captura_spotId ON "Captura"("spotId");
CREATE INDEX idx_captura_peso ON "Captura"("peso" DESC NULLS LAST);
CREATE INDEX idx_captura_tamanio ON "Captura"("tamanio" DESC NULLS LAST);
CREATE INDEX idx_spot_ubicacion ON "Spot" USING GIST("ubicacion");
CREATE INDEX idx_spot_estado ON "Spot"("estado");
CREATE INDEX idx_reporte_spot ON "Reporte"("idSpot");
CREATE INDEX idx_reporte_usuario ON "Reporte"("idUsuario");
CREATE INDEX idx_reporte_fecha ON "Reporte"("fechaCreacion");

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

-- ============================================================
-- DATOS DE EJEMPLO - USUARIOS Y ROLES
-- ============================================================

-- Tabla Rol
INSERT INTO "Rol" ("id", "nombre") VALUES
  ('rol1', 'usuario'),
  ('rol2', 'moderador'),
  ('rol3', 'administrador');

-- Tabla Usuario
INSERT INTO "Usuario" ("id", "nombre", "nivelPescador", "email", "foto") VALUES
  ('usuario1', 'Carlos Tarucha', 'Avanzado', 'carlos.tarucha@fishspot.com', 'uploads/usuarios/carlos.jpg'),
  ('usuario2', 'Lucía Señuelera', 'Experto', 'lucia.senuelera@fishspot.com', 'uploads/usuarios/lucia.jpg');

-- Tabla UsuarioRol
INSERT INTO "UsuarioRol" ("usuarioId", "rolId") VALUES
  ('usuario1', 'rol1'),
  ('usuario1', 'rol2'),
  ('usuario2', 'rol1');


-- ============================================================
-- DATOS DE EJEMPLO - TIPOS DE PESCA (18 TÉCNICAS ARGENTINAS)
-- ============================================================

INSERT INTO "TipoPesca" ("id", "nombre", "descripcion") VALUES
  ('tp1', 'Spinning', 'Técnica más popular en Argentina. Caña 1,8-2,4 m con reel frontal para lanzar señuelos artificiales (poppers, cucharitas, paseantes). Ideal para dorados, tarariras y truchas. Acción media, líneas 0,20-0,35 mm según especie objetivo.'),
  
  ('tp2', 'Bait Casting', 'Técnica de precisión con reel rotativo montado arriba de la caña. Caña 1,7-2,1 m rígida para señuelos pesados. Muy usada para dorados y tarariras grandes. Requiere práctica para evitar "pelucas". Líneas 0,25-0,40 mm.'),
  
  ('tp3', 'Pesca de Fondo', 'La más tradicional argentina. Caña 2,7-4 m con plomada al fondo y carnadas naturales. Para bagres, surubíes, pacúes. Desde costa o embarcación. Pesca de espera, mejor de noche. Líneas 0,30-0,50 mm.'),
  
  ('tp4', 'Pesca con Flote', 'Clásica para pejerrey en lagunas bonaerenses. Caña 2-3,5 m con boya como indicador. Carnadas pequeñas (mojarra, lombriz). Técnica delicada con líneas finas 0,16-0,20 mm. Muy popular en la Pampa húmeda.'),
  
  ('tp5', 'Fly Fishing (Mosca)', 'Técnica refinada para truchas patagónicas. Caña ligera 2,1-3 m con carrete mosquero. Moscas secas, ninfas o streamers según situación. Lanzado elegante, presentación natural. Muy popular en ríos del sur.'),
  
  ('tp6', 'Trolling (Curricán)', 'Pesca desde embarcación en movimiento. Señuelos o cucharas arrastradas detrás del bote. Para dorados, surubíes y truchas grandes. Caña robusta 2-2,4 m, reel rotativo, líneas 0,35-0,50 mm. Común en ríos grandes y lagos.'),
  
  ('tp7', 'Variada', 'Técnica de río con múltiples anzuelos (3-5) y carnadas simultáneas en la misma línea. Para pescar varias especies juntas: bagres, bogas, mojarras. Caña larga 3-4 m, efectiva en corrientes medianas. Muy práctica y productiva.'),
  
  ('tp8', 'Mojarrero', 'Técnica tradicional argentina para especies chicas. Equipos ultra livianos, caña telescópica 3,5-4,5 m, anzuelos pequeños N°12-16. Para mojarras, dientudos, chanchitas en arroyos y canales. Requiere paciencia y fineza.'),
  
  ('tp9', 'Embarcado Fondeado', 'Pesca de espera desde bote anclado en pozones profundos. Múltiples cañas simultáneas con carnadas vivas. Para grandes bagres y surubíes. Principalmente nocturna. Requiere ecosonda y GPS.'),
  
  ('tp10', 'Carpfishing', 'Técnica especializada para carpas grandes en lagunas. Cañas largas 3,6-4,2 m, cebado previo, múltiples líneas. Carnadas: boilies, maíz fermentado, papa. Pesca de larga duración (24-48 hs). Alarmas electrónicas.'),
  
  ('tp11', 'Spinning Patagónico', 'Variante para aguas frías del sur. Caña 2,4-2,7 m, cucharitas rotativas y spoons para truchas y percas. Línea trenzada fina con leader largo. Técnica desde costa en lagos y ríos patagónicos.'),
  
  ('tp12', 'Pesca a la Cueva', 'Técnica específica para tarariras bajo estructuras. Caña corta 1,5-1,8 m, lanzamientos precisos bajo troncos, ramas y vegetación densa. Señuelos compactos o carnada viva. Requiere precisión milimétrica.'),
  
  ('tp13', 'Pesca al Correntino', 'Técnica del litoral argentino. Se deja derivar la carnada naturalmente en la corriente del río. Para dorados, surubíes y pacúes. Caña 2,5-3 m, plomada ligera o sin plomo. Efectiva en barrancas y correderas.'),
  
  ('tp14', 'Surfcasting', 'Pesca desde playa en costa atlántica. Cañas largas 3,6-4,5 m para lanzamientos lejanos. Para corvinas, pescadillas, gatuzos. Carnadas naturales: camarón, calamar, filet. Mar del Plata, Necochea, Miramar.'),
  
  ('tp15', 'Jigging Vertical', 'Técnica moderna con jigs metálicos trabajados verticalmente. Para percas patagónicas en lagos profundos y dorados en pozones. Caña corta rígida 1,5-2 m, movimientos de muñeca. Muy efectiva pero demandante.'),
  
  ('tp16', 'Pesca Nocturna de Bagres', 'Especializada para bagres gigantes (surubíes, manguruyús, patíes). Equipos robustos, carnadas vivas grandes (20-40 cm), líneas gruesas 0,45-0,60 mm. Anzuelos 8/0-12/0. Solo de noche en pozones profundos.'),
  
  ('tp17', 'Pesca con Boya Corrediza', 'Técnica mixta entre flote y fondo. Boya deslizante que permite regular profundidad. Para bogas, sábalos y carpas en corrientes. Caña 2,5-3 m, línea 0,25-0,30 mm. Muy versátil y efectiva.');


-- ============================================================
-- DATOS DE EJEMPLO - ESPECIES (41 ESPECIES ARGENTINAS)
-- ============================================================

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

-- ============================================================
-- DATOS DE EJEMPLO - CARNADAS (30 MÁS REPRESENTATIVAS)
-- ============================================================

INSERT INTO "Carnada" ("id", "nombre", "tipoCarnada", "descripcion") VALUES
  -- ARTIFICIALES BLANDOS (4)
  ('c1', 'Rana artificial', 'ArtificialBlando', 'Señuelo blando imitación rana para superficie. Clásico para tarariras en lagunas con vegetación. Colores naturales verde y marrón.'),
  ('c2', 'Lombriz siliconada', 'ArtificialBlando', 'Imitación realista de lombriz en silicona. Versátil para tarariras, bagres y black bass. Acción natural bajo el agua.'),
  ('c3', 'Shad vinilo', 'ArtificialBlando', 'Pez blando con cola vibrátil tipo paddle tail. Efectivo para dorados y surubíes. Tamaños 8-15 cm.'),
  ('c4', 'Jig cabeza plomada', 'ArtificialBlando', 'Cabeza de plomo con cuerpo de silicona. Versátil para pesca vertical y casting. Varios pesos según profundidad.'),

  -- ARTIFICIALES DUROS (6)
  ('c5', 'Popper', 'ArtificialDuro', 'Señuelo de superficie que genera burbujas y estallidos. Icónico para dorados al amanecer. Acción "pop" con pausas.'),
  ('c6', 'Paseante', 'ArtificialDuro', 'Señuelo flotante zigzagueante (walk the dog). Excelente para tarariras y dorados. Acción errática en superficie.'),
  ('c7', 'Cucharita giratoria', 'ArtificialDuro', 'Cuchara con pala giratoria. La más popular para truchas patagónicas. Plateada o dorada, tamaños N°2-4.'),
  ('c8', 'Cucharita ondulante', 'ArtificialDuro', 'Cuchara metálica que oscila. Efectiva para dorados y truchas grandes. Acción errática imitando pez herido.'),
  ('c9', 'Crankbait', 'ArtificialDuro', 'Señuelo con paleta para alcanzar profundidad. Para dorados y tarariras en pozones. Colores naturales y llamativos.'),
  ('c10', 'Spinnerbait', 'ArtificialDuro', 'Señuelo con cucharilla giratoria y faldín. Bueno para aguas con vegetación. Efectivo para tarariras y black bass.'),

  -- MOSCAS ARTIFICIALES (4)
  ('c11', 'Mosca seca', 'MoscaArtificial', 'Imitación flotante de insectos adultos. Esencial para truchas en eclosión. Tamaños #12-18 según especie.'),
  ('c12', 'Ninfa', 'MoscaArtificial', 'Imitación de larva acuática sumergida. Muy efectiva para truchas en pozones. Con o sin lastre.'),
  ('c13', 'Streamer', 'MoscaArtificial', 'Mosca grande imitando pez pequeño. Para truchas grandes y percas. Colores natural, blanco y negro.'),
  ('c14', 'Mosca ahogada', 'MoscaArtificial', 'Imitación sumergida de insectos. Técnica tradicional patagónica. Deriva natural bajo superficie.'),

  -- CARNADAS NATURALES (11)
  ('c15', 'Lombriz común', 'Natural', 'La carnada más universal argentina. Efectiva para casi todas las especies. Fresca o salada. Imprescindible.'),
  ('c16', 'Maíz hervido', 'Natural', 'Granos cocidos amarillos. Clásico para carpas, bogas y pacúes. Se puede aromatizar con esencias.'),
  ('c17', 'Masa casera', 'Natural', 'Masa de harina con agua y esencia. Tradicional para pejerrey, carpa y boga. Se amasa en anzuelo.'),
  ('c18', 'Mburucuyá', 'Natural', 'Fruto del maracuyá (pasionaria). Irresistible para pacúes. Muy efectivo en verano y otoño.'),
  ('c19', 'Papa hervida', 'Natural', 'Papa cocida en cubos. Excelente para carpas grandes. Aguanta bien en anzuelo. Popular en carpfishing.'),
  ('c20', 'Tripas de pollo', 'Natural', 'Vísceras frescas o saladas. Carnada fuerte para bagres nocturnos. Olor potente atrae desde lejos.'),
  ('c21', 'Hígado de pollo', 'Natural', 'Víscera blanda muy atractiva. Para bagres, surubíes y patíes. Mejor de noche. Requiere anzuelo grande.'),
  ('c22', 'Pan mojado', 'Natural', 'Miga de pan húmeda en bolita. Carnada simple para mojarras y pejerrey chico. Ideal para principiantes.'),
  ('c23', 'Grillo', 'Natural', 'Insecto vivo muy efectivo. Para truchas, pejerreyes y dientudos. Se engancha por el lomo. Estacional.'),
  ('c24', 'Isoca', 'Natural', 'Larva de mariposa nocturna verde. Carnada premium para truchas. Difícil de conseguir, muy efectiva.'),
  ('c25', 'Boilies', 'Natural', 'Masa hervida con proteínas. Especializada para carpfishing. Varios sabores: frutos rojos, pescado, hígado.'),

  -- CARNADAS VIVAS (3)
  ('c26', 'Mojarra viva', 'Viva', 'Pez pequeño vivo 8-15 cm. Carnada premium para dorados, tarariras y surubíes. Se engancha por el lomo.'),
  ('c27', 'Morena viva', 'Viva', 'Anguila criolla 15-30 cm. La mejor carnada para surubíes gigantes. Muy resistente, nada activamente.'),
  ('c28', 'Renacuajo', 'Viva', 'Larva de rana. Irresistible para tarariras. Se engancha por la cola. Efectiva en primavera-verano.'),

  -- CARNADAS MUERTAS (2)
  ('c29', 'Filet de mojarra', 'CarnadaMuerta', 'Trozo de pez cortado. Tradicional para pejerrey bonaerense. También truchas. Cortes de 2-3 cm.'),
  ('c30', 'Camarón', 'CarnadaMuerta', 'Camarón fresco o salado. Carnada costera para corvinas. También dorados en río. Pelado o entero.');

-- ============================================================
-- DATOS DE EJEMPLO - RELACIONES ESPECIE-TIPO DE PESCA
-- ============================================================

INSERT INTO "EspecieTipoPesca" ("id", "idEspecie", "idTipoPesca", "descripcion") VALUES
-- DORADO (Salminus brasiliensis) - es2
('etp1', 'es2', 'tp1', 'Spinning: Señuelos tipo minnows y poppers en corrientes rápidas y pozones profundos. Caña 2 m, acción media. Horario: amanecer y atardecer.'),
('etp2', 'es2', 'tp2', 'Bait Casting: Señuelos de media agua en correderas. Caña 1,8-2,1 m rígida. Ideal con poppers, stickbaits y crankbaits.'),
('etp3', 'es2', 'tp6', 'Trolling: Desde embarcación con cucharas grandes. Cañas robustas, línea 0,35 mm. Mejor en pozones y saltos.'),
('etp4', 'es2', 'tp3', 'Pesca de Fondo: Carnada viva (mojarra, sabalito) en pozones profundos. Caña 2,7 m. Mejor en bajantes.'),
('etp5', 'es2', 'tp13', 'Pesca al Correntino: Dejando derivar carnada en corriente natural. Efectiva en barrancas y correderas.'),

-- TARARIRA COMÚN (Hoplias malabaricus) - es1
('etp6', 'es1', 'tp1', 'Spinning: Ranas, paseantes y crankbaits. Caña 1,8-2,2 m. Lagunas con vegetación densa. Amanecer y atardecer.'),
('etp7', 'es1', 'tp2', 'Bait Casting: Señuelos grandes tipo stickbait o frog. Lanzamientos precisos a vegetación.'),
('etp8', 'es1', 'tp3', 'Pesca de Fondo: Carnada viva o muerta. Caña 2,7 m. Efectiva cerca de troncos y raíces.'),
('etp9', 'es1', 'tp12', 'Pesca a la Cueva: Lanzamientos bajo estructuras. Caña corta 1,5-1,8 m, precisión milimétrica.'),

-- PEJERREY BONAERENSE (Odontesthes bonariensis) - es13
('etp10', 'es13', 'tp4', 'Pesca de Flote: Línea fina con boya pequeña. Carnada: mojarra viva o filet. Mañanas soleadas y tardes nubladas.'),
('etp11', 'es13', 'tp5', 'Mosca: Imitaciones de larvas o ninfas. Caña 2,1 m, línea liviana. Todo el día con picos a media mañana.'),
('etp12', 'es13', 'tp3', 'Pesca de Fondo: Masa o filet pequeño al fondo. Madrugadas o anochecer. Cañas flexibles.'),
('etp13', 'es13', 'tp17', 'Pesca con Boya Corrediza: Boya deslizante regulando profundidad. Versátil en corrientes.'),

-- SURUBÍ PINTADO (Pseudoplatystoma corruscans) - es3
('etp14', 'es3', 'tp3', 'Pesca de Fondo: Carnadas vivas grandes. Cañas largas 3 m, pozones profundos. Nocturno.'),
('etp15', 'es3', 'tp16', 'Pesca Nocturna de Bagres: Equipos robustos, carnadas vivas 20-40 cm, líneas 0,45-0,60 mm. Solo de noche.'),
('etp16', 'es3', 'tp9', 'Embarcado Fondeado: Múltiples cañas desde bote anclado. Principalmente nocturna en pozones.'),
('etp17', 'es3', 'tp6', 'Trolling: Señuelos pesados desde embarcación. Línea 0,40 mm. Mañana y tarde en aguas profundas.'),

-- SURUBÍ ATIGRADO (Pseudoplatystoma reticulatum) - es4
('etp18', 'es4', 'tp3', 'Pesca de Fondo: Similar al pintado, carnadas vivas grandes. Nocturno en pozones profundos.'),
('etp19', 'es4', 'tp16', 'Pesca Nocturna de Bagres: Equipos robustos especializado para grandes bagres. Pozones rocosos.'),
('etp20', 'es4', 'tp9', 'Embarcado Fondeado: Desde bote anclado con múltiples carnadas. Técnica nocturna.'),

-- MANGURUYÚ (Zungaro zungaro) - es5
('etp21', 'es5', 'tp3', 'Pesca de Fondo: Carnadas muy grandes, equipos de alta resistencia. Solo ríos grandes.'),
('etp22', 'es5', 'tp16', 'Pesca Nocturna de Bagres: Técnica para bagres gigantes. Cañas pesadas 3-3,5 m, líneas gruesas.'),
('etp23', 'es5', 'tp9', 'Embarcado Fondeado: Pozones profundos 15-30 m. Múltiples cañas robustas.'),

-- PACÚ (Piaractus mesopotamicus) - es6
('etp24', 'es6', 'tp3', 'Pesca de Fondo: Frutas (mburucuyá, higo) o masa. Caña 2,5 m en remansos. Mañana y tarde.'),
('etp25', 'es6', 'tp1', 'Spinning: Señuelos pequeños imitando frutas. Aguas tranquilas cerca de árboles frutales.'),
('etp26', 'es6', 'tp7', 'Variada: Múltiples anzuelos con carnadas diversas. Efectiva para pacúes en río.'),

-- PACÚ RELOJ (Myloplus rubripinnis) - es7
('etp27', 'es7', 'tp3', 'Pesca de Fondo: Frutas y masa en remansos. Equipos medianos, horario de mediodía.'),
('etp28', 'es7', 'tp7', 'Variada: Técnica de múltiples anzuelos efectiva para pacúes chicos.'),

-- PACÚ CHATO (Colossoma mitrei) - es8
('etp29', 'es8', 'tp3', 'Pesca de Fondo: Frutas, maíz y masa en lagunas conectadas a ríos.'),
('etp30', 'es8', 'tp7', 'Variada: Múltiples carnadas para captura mixta con otras especies.'),

-- BOGA (Megaleporinus obtusidens) - es9
('etp31', 'es9', 'tp3', 'Pesca de Fondo: Maíz, masa, lombrices en corrientes medianas. Caña 2,7 m. Muy combativa.'),
('etp32', 'es9', 'tp4', 'Pesca de Flote: Boya en corrientes suaves. Carnada: maíz o masa. Todo el día.'),
('etp33', 'es9', 'tp7', 'Variada: Técnica ideal para bogas. Múltiples anzuelos con maíz y masa.'),
('etp34', 'es9', 'tp17', 'Pesca con Boya Corrediza: Muy efectiva regulando profundidad según corriente.'),

-- SÁBALO (Prochilodus lineatus) - es10
('etp35', 'es10', 'tp3', 'Pesca de Fondo: Masa vegetal, harinas. Principalmente usado como carnada para predadores.'),
('etp36', 'es10', 'tp7', 'Variada: Múltiples anzuelos con masa vegetal. Abundantes en ríos grandes.'),

-- TARARIRA AZUL (Hoplias lacerdae) - es11
('etp37', 'es11', 'tp2', 'Bait Casting: Señuelos grandes, poppers potentes. Muy agresiva. Lanzamientos precisos.'),
('etp38', 'es11', 'tp1', 'Spinning: Paseantes y stickbaits grandes. Caña robusta 2,2 m. Amanecer y atardecer.'),
('etp39', 'es11', 'tp12', 'Pesca a la Cueva: Especialmente efectiva para tarariras azules bajo estructuras.'),

-- TARARIRA PINTADA (Hoplias australis) - es12
('etp40', 'es12', 'tp1', 'Spinning: Señuelos de superficie medianos. Lagunas con vegetación.'),
('etp41', 'es12', 'tp12', 'Pesca a la Cueva: Bajo vegetación flotante. Lanzamientos precisos.'),
('etp42', 'es12', 'tp3', 'Pesca de Fondo: Carnada viva en lagunas pampeanas.'),

-- PEJERREY PATAGÓNICO (Odontesthes hatcheri) - es14
('etp43', 'es14', 'tp5', 'Mosca: Lagos fríos con ninfas pequeñas. Línea flotante. Mañanas despejadas.'),
('etp44', 'es14', 'tp4', 'Pesca de Flote: Carnada pequeña en aguas frías. Equipos livianos y líneas finas.'),
('etp45', 'es14', 'tp11', 'Spinning Patagónico: Cucharitas rotativas en lagos patagónicos desde costa.'),

-- PEJERREY FUEGUINO (Odontesthes nigricans) - es15
('etp46', 'es15', 'tp5', 'Mosca: Aguas extremadamente frías. Moscas diminutas. Técnica muy delicada.'),
('etp47', 'es15', 'tp4', 'Pesca de Flote: Equipos ultra livianos en lagos fueguinos. Líneas finísimas.'),

-- PERCA CRIOLLA (Percichthys trucha) - es16
('etp48', 'es16', 'tp1', 'Spinning: Cucharitas pequeñas en lagos patagónicos. Señuelos brillantes.'),
('etp49', 'es16', 'tp5', 'Mosca: Streamers y ninfas en aguas frías. Técnica similar a truchas.'),
('etp50', 'es16', 'tp11', 'Spinning Patagónico: Técnica específica para percas en lagos profundos.'),

-- TRUCHA ARCOÍRIS (Oncorhynchus mykiss) - es17
('etp51', 'es17', 'tp5', 'Mosca: Moscas secas, ninfas, streamers. Caña 2,4 m en ríos serranos. Amanecer y atardecer.'),
('etp52', 'es17', 'tp1', 'Spinning: Cucharitas giratorias en corrientes rápidas. Caña liviana 2 m.'),
('etp53', 'es17', 'tp11', 'Spinning Patagónico: Cucharitas y spoons en lagos fríos. Línea trenzada fina.'),
('etp54', 'es17', 'tp6', 'Trolling: Pesca al curricán en lagos patagónicos para truchas grandes.'),

-- TRUCHA MARRÓN (Salmo trutta) - es18
('etp55', 'es18', 'tp5', 'Mosca: Técnica refinada, moscas secas grandes. Pesca selectiva en pozones profundos.'),
('etp56', 'es18', 'tp1', 'Spinning: Señuelos pequeños tipo minnow. Horario: atardecer y noche.'),
('etp57', 'es18', 'tp11', 'Spinning Patagónico: Muy efectiva para marrones grandes en lagos.'),

-- TRUCHA DE ARROYO (Salvelinus fontinalis) - es19
('etp58', 'es19', 'tp5', 'Mosca: Moscas secas pequeñas en arroyos serranos. Equipos ultra livianos.'),
('etp59', 'es19', 'tp1', 'Spinning: Señuelos diminutos en arroyos de montaña.'),

-- BAGRE BLANCO (Pimelodus albicans) - es20
('etp60', 'es20', 'tp3', 'Pesca de Fondo: Lombrices, tripas, masa. Nocturno desde costa. Plomos pesados.'),
('etp61', 'es20', 'tp7', 'Variada: Múltiples anzuelos con carnadas variadas. Muy efectiva para bagres.'),

-- BAGRE SAPO (Rhamdia quelen) - es21
('etp62', 'es21', 'tp3', 'Pesca de Fondo: Carnadas fuertes como tripas, hígado. Nocturno en pozones rocosos.'),
('etp63', 'es21', 'tp16', 'Pesca Nocturna de Bagres: Equipos robustos para ejemplares grandes.'),

-- ARMADO (Pterodoras granulosus) - es22
('etp64', 'es22', 'tp3', 'Pesca de Fondo: Carnadas grandes y resistentes. Equipos muy robustos. Nocturna en corrientes.'),
('etp65', 'es22', 'tp16', 'Pesca Nocturna de Bagres: Especializada para armados grandes. Muy combativos.'),

-- PATÍ (Luciopimelodus pati) - es23
('etp66', 'es23', 'tp3', 'Pesca de Fondo: Carnadas vivas grandes. Pozones profundos. Nocturno.'),
('etp67', 'es23', 'tp16', 'Pesca Nocturna de Bagres: Bagre de gran tamaño. Equipos robustos. Líneas gruesas.'),
('etp68', 'es23', 'tp9', 'Embarcado Fondeado: Desde bote en pozones profundos. Carnadas vivas.'),

-- CARPA COMÚN (Cyprinus carpio) - es24
('etp69', 'es24', 'tp3', 'Pesca de Fondo: Masa, maíz hervido, papa. Cañas largas 3-4 m. Lagunas cálidas.'),
('etp70', 'es24', 'tp10', 'Carpfishing: Técnica especializada. Cebado previo, múltiples líneas, boilies. Pesca 24-48 hs.'),
('etp71', 'es24', 'tp17', 'Pesca con Boya Corrediza: Muy efectiva para carpas regulando profundidad.'),

-- MOJARRA (Astyanax fasciatus) - es25
('etp72', 'es25', 'tp8', 'Mojarrero: Técnica clásica con bolitas de pan, lombriz cortada. Anzuelos N°12-14.'),
('etp73', 'es25', 'tp4', 'Pesca de Flote: Boya pequeña, línea fina. Ideal para principiantes.'),
('etp74', 'es25', 'tp7', 'Variada: Efectiva para capturar múltiples mojarras simultáneamente.'),

-- ANGUILA CRIOLLA (Synbranchus marmoratus) - es26
('etp75', 'es26', 'tp3', 'Pesca de Fondo: Lombriz en fondos barrosos. Nocturna. Muy resistente.'),

-- PIRAPITÁ (Brycon orbignyanus) - es27
('etp76', 'es27', 'tp1', 'Spinning: Señuelos pequeños tipo dorado. Corrientes rápidas. Muy combativo.'),
('etp77', 'es27', 'tp2', 'Bait Casting: Poppers chicos en correntadas. Similar al dorado.'),

-- BOGA LISA (Leporinus friderici) - es28
('etp78', 'es28', 'tp3', 'Pesca de Fondo: Maíz, frutas. Corrientes medianas. Equipos livianos.'),
('etp79', 'es28', 'tp4', 'Pesca de Flote: Boya en corrientes suaves. Carnada vegetal.'),

-- PALOMETA (Crenicichla britskii) - es29
('etp80', 'es29', 'tp1', 'Spinning: Señuelos pequeños en arroyos y lagunas. Agresiva.'),
('etp81', 'es29', 'tp12', 'Pesca a la Cueva: Bajo estructuras. Lanzamientos precisos.'),

-- CORVINA RUBIA (Micropogonias furnieri) - es30
('etp82', 'es30', 'tp14', 'Surfcasting: Desde playa con camarón y cangrejo. Cañas largas 4 m. Marea entrante.'),
('etp83', 'es30', 'tp3', 'Pesca de Fondo: Desde costa con carnadas naturales.'),

-- CHANCHITA (Crenicichla lacustris) - es31
('etp84', 'es31', 'tp8', 'Mojarrero: Caña 3,5 m, línea fina 0,16 mm. Lombriz cortada en arroyos.'),
('etp85', 'es31', 'tp12', 'Pesca a la Cueva: Lanzamientos bajo troncos y raíces. Territorial.'),

-- DIENTUDO (Oligosarcus jenynsii) - es32
('etp86', 'es32', 'tp8', 'Mojarrero: Equipos ultra livianos. Lombriz cortada. Muy combativo para su tamaño.'),
('etp87', 'es32', 'tp1', 'Spinning Ultra Liviano: Mini cucharitas y micro jigs. Reel 1000.'),

-- MADRECITA (Jenynsia multidentata) - es33
('etp88', 'es33', 'tp8', 'Mojarrero Ultra Fino: Anzuelos N°16-18. Larvas de mosquito. Extremadamente delicado.'),

-- PANZUDITO (Cnesterodon decemmaculatus) - es34
('etp89', 'es34', 'tp8', 'Mojarrero Ultra Fino: Similar a madrecita. Equipos finísimos. Paciencia extrema.'),

-- CHANCHITA RAYADA (Cichlasoma dimerus) - es35
('etp90', 'es35', 'tp8', 'Mojarrero: Lombriz, cascarita. Territorial cerca de vegetación.'),
('etp91', 'es35', 'tp12', 'Pesca a la Cueva: Estructuras rocosas. Agresiva en reproducción.'),

-- BAGRE NEGRO (Heptapterus mustelinus) - es36
('etp92', 'es36', 'tp3', 'Pesca de Fondo: Lombriz al fondo en arroyos pedregosos. Nocturno.'),

-- CASTAÑETA (Australoheros facetus) - es37
('etp93', 'es37', 'tp8', 'Mojarrero: Lombriz, masa pequeña. Lagunas pampeanas. Resistente al frío.'),

-- MOJARRA COLA ROJA (Cheirodon interruptus) - es38
('etp94', 'es38', 'tp8', 'Mojarrero: Cardúmenes en aguas claras. Anzuelos diminutos. Lombriz cortada.'),

-- PUYÉN GRANDE (Galaxias maculatus) - es39
('etp95', 'es39', 'tp5', 'Mosca: Ninfas microscópicas en aguas frías. Técnica ultra delicada.'),
('etp96', 'es39', 'tp4', 'Pesca de Flote: Carnadas diminutas en lagunas patagónicas. Anzuelos pequeñísimos.'),

-- PERCA PATAGÓNICA (Percichthys colhuapiensis) - es40
('etp97', 'es40', 'tp11', 'Spinning Patagónico: Cucharitas rotativas en lagos profundos. Desde costa.'),
('etp98', 'es40', 'tp15', 'Jigging Vertical: Jigs metálicos verticales. Muy efectiva en lagos profundos.'),
('etp99', 'es40', 'tp6', 'Trolling: Al curricán en grandes lagos patagónicos para percas grandes.'),

-- BAGRE BLANCO DEL SUR (Diplomystes viedmensis) - es41
('etp100', 'es41', 'tp3', 'Pesca de Fondo: Carnadas naturales en pozones patagónicos. Especie protegida - captura y devolución.');

INSERT INTO "Spot" (
  "id", "idUsuario", "idUsuarioActualizo", "nombre", "estado", "descripcion", "ubicacion", "fechaPublicacion", "fechaActualizacion", "imagenPortada", "isDeleted"
) VALUES (
  'SpotSecreto',
  'usuario1',
  'usuario2',
  'Desembocadura del arrollito',
  'Aceptado',
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
),
-- ============================================================
-- SPOTS RÍO SALADO - CARLOS
-- ============================================================
(
  'SpotPuenteGaviotas',
  'usuario1',
  'usuario1',
  'Puente Gaviotas - Río Salado',
  'Aceptado',
  'Zona clásica del Río Salado. Excelente para pejerrey, tarariras y bagres. Estructura del puente atrae peces.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-58.21856962523311, -35.76542656433006]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/pejerrey.png',
  FALSE
),
(
  'SpotCanalAliviador',
  'usuario1',
  'usuario1',
  'Canal Aliviador - Río Salado',
  'Aceptado',
  'Canal con corriente moderada. Ideal para carpas grandes, pejerreyes y bogas. Aguas más profundas.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-58.09736829811158, -35.750086754706095]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/carpa.png',
  FALSE
),
(
  'SpotPuente41',
  'usuario1',
  'usuario1',
  'Puente 41 - Río Salado',
  'Aceptado',
  'Spot emblemático para pejerrey argentino. Aguas claras y corriente suave. Mejor con flote.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-57.98199742419953, -35.73658874176168]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/pejerrey.png',
  FALSE
),
-- ============================================================
-- SPOTS RÍO PARANÁ - LUCÍA
-- ============================================================
(
  'SpotItaIbate',
  'usuario2',
  'usuario2',
  'Itá Ibaté - Río Paraná',
  'Aceptado',
  'Paraná entrerriano con grandes dorados y surubíes. Pozones profundos con excelente corriente.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-59.20694076805208, -31.348611068177423]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/dorado.png',
  FALSE
),
(
  'SpotGoya',
  'usuario2',
  'usuario2',
  'Goya - Río Paraná',
  'Aceptado',
  'Zona correntina del Paraná. Dorados, bogas y tarariras. Costas con vegetación abundante.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-59.26544244843749, -29.139437530308674]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/dorado.png',
  FALSE
),
(
  'SpotPasoDeLaPatria',
  'usuario2',
  'usuario2',
  'Paso de la Patria - Capital del Dorado',
  'Aceptado',
  'La meca de la pesca en Argentina. Dorados trofeo y surubíes gigantes. Torneo nacional anual.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-59.11302697011719, -27.311481568694984]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/dorado.png',
  FALSE
),
-- ============================================================
-- SPOTS PATAGONIA - LUCÍA
-- ============================================================
(
  'SpotRioLimay',
  'usuario2',
  'usuario2',
  'Río Limay - Patagonia',
  'Aceptado',
  'Río patagónico con truchas arcoíris y marrones. Aguas cristalinas de montaña. Fly fishing.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-71.34124481924113, -40.96826103651293]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/trucha.png',
  FALSE
),
(
  'SpotRioChimehuin',
  'usuario2',
  'usuario2',
  'Río Chimehuín - Junín de los Andes',
  'Aceptado',
  'Río de truchas trofeo. Moscas secas y ninfas. Paisajes de bosque andino patagónico.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-71.0633587292683, -39.87997896458389]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/trucha.png',
  FALSE
),
(
  'SpotRioTraful',
  'usuario2',
  'usuario2',
  'Río Traful - Villa Traful',
  'Aceptado',
  'Río y lago con truchas y percas criollas. Aguas profundas y frías. Pesca embarcada y desde costa.',
  ST_SetSRID(ST_GeomFromGeoJSON('{
    "type": "Point",
    "coordinates": [-71.29338522436461, -40.66268370204022]
  }'), 4326),
  CURRENT_DATE,
  CURRENT_DATE,
  'uploads/trucha.png',
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
  ('se40', 'SpotGeneral', 'es38'),  -- Mojarra cola roja
  
  -- Puente Gaviotas - Río Salado
  ('se41', 'SpotPuenteGaviotas', 'es13'), -- Pejerrey
  ('se42', 'SpotPuenteGaviotas', 'es1'),  -- Tararira
  ('se43', 'SpotPuenteGaviotas', 'es20'), -- Bagre blanco
  
  -- Canal Aliviador
  ('se44', 'SpotCanalAliviador', 'es13'), -- Pejerrey
  ('se45', 'SpotCanalAliviador', 'es24'), -- Carpa
  ('se46', 'SpotCanalAliviador', 'es9'),  -- Boga
  
  -- Puente 41
  ('se47', 'SpotPuente41', 'es13'),       -- Pejerrey
  
  -- Itá Ibaté - Paraná
  ('se48', 'SpotItaIbate', 'es2'),        -- Dorado
  ('se49', 'SpotItaIbate', 'es3'),        -- Surubí pintado
  ('se50', 'SpotItaIbate', 'es6'),        -- Pacú
  
  -- Goya - Paraná
  ('se51', 'SpotGoya', 'es2'),            -- Dorado
  ('se52', 'SpotGoya', 'es9'),            -- Boga
  ('se53', 'SpotGoya', 'es1'),            -- Tararira
  
  -- Paso de la Patria
  ('se54', 'SpotPasoDeLaPatria', 'es2'),  -- Dorado
  ('se55', 'SpotPasoDeLaPatria', 'es3'),  -- Surubí pintado
  ('se56', 'SpotPasoDeLaPatria', 'es6'),  -- Pacú
  
  -- Río Limay - Patagonia
  ('se57', 'SpotRioLimay', 'es17'),       -- Trucha arcoíris
  ('se58', 'SpotRioLimay', 'es18'),       -- Trucha marrón
  
  -- Río Chimehuín
  ('se59', 'SpotRioChimehuin', 'es17'),   -- Trucha arcoíris
  ('se60', 'SpotRioChimehuin', 'es18'),   -- Trucha marrón
  
  -- Río Traful
  ('se61', 'SpotRioTraful', 'es17'),      -- Trucha arcoíris
  ('se62', 'SpotRioTraful', 'es16');      -- Perca criolla 


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
  ('stp9', 'SpotDelta', 'tp4'),    -- Flote
  
  -- Puente Gaviotas
  ('stp10', 'SpotPuenteGaviotas', 'tp4'),  -- Flote
  ('stp11', 'SpotPuenteGaviotas', 'tp1'),  -- Spinning
  ('stp12', 'SpotPuenteGaviotas', 'tp3'),  -- Fondo
  
  -- Canal Aliviador
  ('stp13', 'SpotCanalAliviador', 'tp4'),  -- Flote
  ('stp14', 'SpotCanalAliviador', 'tp10'), -- Carpfishing
  ('stp15', 'SpotCanalAliviador', 'tp3'),  -- Fondo
  
  -- Puente 41
  ('stp16', 'SpotPuente41', 'tp4'),        -- Flote
  
  -- Itá Ibaté
  ('stp17', 'SpotItaIbate', 'tp1'),        -- Spinning
  ('stp18', 'SpotItaIbate', 'tp6'),        -- Trolling
  ('stp19', 'SpotItaIbate', 'tp13'),       -- Pesca al Correntino
  
  -- Goya
  ('stp20', 'SpotGoya', 'tp1'),            -- Spinning
  ('stp21', 'SpotGoya', 'tp2'),            -- Bait Casting
  ('stp22', 'SpotGoya', 'tp3'),            -- Fondo
  
  -- Paso de la Patria
  ('stp23', 'SpotPasoDeLaPatria', 'tp1'),  -- Spinning
  ('stp24', 'SpotPasoDeLaPatria', 'tp6'),  -- Trolling
  ('stp25', 'SpotPasoDeLaPatria', 'tp13'), -- Pesca al Correntino
  
  -- Río Limay
  ('stp26', 'SpotRioLimay', 'tp5'),        -- Fly Fishing
  ('stp27', 'SpotRioLimay', 'tp11'),       -- Spinning Patagónico
  
  -- Río Chimehuín
  ('stp28', 'SpotRioChimehuin', 'tp5'),    -- Fly Fishing
  ('stp29', 'SpotRioChimehuin', 'tp11'),   -- Spinning Patagónico
  
  -- Río Traful
  ('stp30', 'SpotRioTraful', 'tp5'),       -- Fly Fishing
  ('stp31', 'SpotRioTraful', 'tp11');      -- Spinning Patagónico


-- ============================================================
-- DATOS DE EJEMPLO - RELACIONES SPOT-CARNADA-ESPECIE
-- ============================================================

INSERT INTO "SpotCarnadaEspecie" ("id", "idSpot", "idEspecie", "idCarnada") VALUES
  -- SPOT SECRETO - Tararira común (es1)
  ('sce1', 'SpotSecreto', 'es1', 'c1'),   -- Rana artificial
  ('sce2', 'SpotSecreto', 'es1', 'c26'),  -- Mojarra viva
  ('sce3', 'SpotSecreto', 'es1', 'c6'),   -- Paseante
  ('sce4', 'SpotSecreto', 'es1', 'c2'),   -- Lombriz siliconada
  
  -- SPOT SECRETO - Dorado (es2)
  ('sce5', 'SpotSecreto', 'es2', 'c5'),   -- Popper
  ('sce6', 'SpotSecreto', 'es2', 'c8'),   -- Cucharita ondulante
  ('sce7', 'SpotSecreto', 'es2', 'c26'),  -- Mojarra viva
  
  -- SPOT SECRETO - Pejerrey (es13)
  ('sce8', 'SpotSecreto', 'es13', 'c29'), -- Filet de mojarra
  ('sce9', 'SpotSecreto', 'es13', 'c23'), -- Grillo
  
  -- SPOT PARANÁ - Dorado (es2)
  ('sce10', 'SpotParana', 'es2', 'c5'),   -- Popper
  ('sce11', 'SpotParana', 'es2', 'c6'),   -- Paseante  
  ('sce12', 'SpotParana', 'es2', 'c8'),   -- Cucharita ondulante
  ('sce13', 'SpotParana', 'es2', 'c26'),  -- Mojarra viva
  
  -- SPOT PARANÁ - Surubí pintado (es3)
  ('sce14', 'SpotParana', 'es3', 'c27'),  -- Morena viva
  ('sce15', 'SpotParana', 'es3', 'c26'),  -- Mojarra viva
  ('sce16', 'SpotParana', 'es3', 'c20'),  -- Tripas de pollo
  ('sce17', 'SpotParana', 'es3', 'c21'),  -- Hígado de pollo
  
  -- SPOT PARANÁ - Pacú (es6)
  ('sce18', 'SpotParana', 'es6', 'c18'),  -- Mburucuyá
  ('sce19', 'SpotParana', 'es6', 'c16'),  -- Maíz hervido
  ('sce20', 'SpotParana', 'es6', 'c17'),  -- Masa casera
  
  -- SPOT PARANÁ - Boga (es9)
  ('sce21', 'SpotParana', 'es9', 'c16'),  -- Maíz hervido
  ('sce22', 'SpotParana', 'es9', 'c17'),  -- Masa casera
  ('sce23', 'SpotParana', 'es9', 'c15'),  -- Lombriz común
  
  -- SPOT DELTA - Tararira común (es1)
  ('sce24', 'SpotDelta', 'es1', 'c1'),    -- Rana artificial
  ('sce25', 'SpotDelta', 'es1', 'c6'),    -- Paseante
  ('sce26', 'SpotDelta', 'es1', 'c26'),   -- Mojarra viva
  ('sce27', 'SpotDelta', 'es1', 'c28'),   -- Renacuajo
  
  -- SPOT DELTA - Boga (es9)
  ('sce28', 'SpotDelta', 'es9', 'c16'),   -- Maíz hervido
  ('sce29', 'SpotDelta', 'es9', 'c19'),   -- Papa hervida
  ('sce30', 'SpotDelta', 'es9', 'c15'),   -- Lombriz común
  
  -- SPOT DELTA - Bagre blanco (es20)
  ('sce31', 'SpotDelta', 'es20', 'c20'),  -- Tripas de pollo
  ('sce32', 'SpotDelta', 'es20', 'c15'),  -- Lombriz común
  ('sce33', 'SpotDelta', 'es20', 'c21'),  -- Hígado de pollo
  
  -- SPOT DELTA - Mojarra (es25)
  ('sce34', 'SpotDelta', 'es25', 'c15'),  -- Lombriz común
  ('sce35', 'SpotDelta', 'es25', 'c22'),  -- Pan mojado
  
  -- SPOT DELTA - Carpa (es24)
  ('sce36', 'SpotDelta', 'es24', 'c16'),  -- Maíz hervido
  ('sce37', 'SpotDelta', 'es24', 'c19'),  -- Papa hervida
  ('sce38', 'SpotDelta', 'es24', 'c25'),  -- Boilies
  ('sce39', 'SpotDelta', 'es24', 'c17'),  -- Masa casera

  -- SPOT GENERAL - ESPECIES RESTANTES

  -- Surubí atigrado (es4)
  ('sce40', 'SpotGeneral', 'es4', 'c27'), -- Morena viva
  ('sce41', 'SpotGeneral', 'es4', 'c26'), -- Mojarra viva
  ('sce42', 'SpotGeneral', 'es4', 'c20'), -- Tripas de pollo

  -- Manguruyú (es5)
  ('sce43', 'SpotGeneral', 'es5', 'c27'), -- Morena viva
  ('sce44', 'SpotGeneral', 'es5', 'c26'), -- Mojarra viva
  ('sce45', 'SpotGeneral', 'es5', 'c21'), -- Hígado de pollo

  -- Pacú reloj (es7)
  ('sce46', 'SpotGeneral', 'es7', 'c18'), -- Mburucuyá
  ('sce47', 'SpotGeneral', 'es7', 'c16'), -- Maíz hervido
  ('sce48', 'SpotGeneral', 'es7', 'c17'), -- Masa casera

  -- Pacú chato (es8)
  ('sce49', 'SpotGeneral', 'es8', 'c18'), -- Mburucuyá
  ('sce50', 'SpotGeneral', 'es8', 'c16'), -- Maíz hervido
  ('sce51', 'SpotGeneral', 'es8', 'c19'), -- Papa hervida

  -- Sábalo (es10)
  ('sce52', 'SpotGeneral', 'es10', 'c17'), -- Masa casera
  ('sce53', 'SpotGeneral', 'es10', 'c22'), -- Pan mojado

  -- Tararira azul (es11)
  ('sce54', 'SpotGeneral', 'es11', 'c6'),  -- Paseante
  ('sce55', 'SpotGeneral', 'es11', 'c26'), -- Mojarra viva
  ('sce56', 'SpotGeneral', 'es11', 'c5'),  -- Popper

  -- Tararira pintada (es12)
  ('sce57', 'SpotGeneral', 'es12', 'c1'),  -- Rana artificial
  ('sce58', 'SpotGeneral', 'es12', 'c26'), -- Mojarra viva
  ('sce59', 'SpotGeneral', 'es12', 'c6'),  -- Paseante

  -- Pejerrey patagónico (es14)
  ('sce60', 'SpotGeneral', 'es14', 'c29'), -- Filet de mojarra
  ('sce61', 'SpotGeneral', 'es14', 'c23'), -- Grillo
  ('sce62', 'SpotGeneral', 'es14', 'c11'), -- Mosca seca

  -- Pejerrey fueguino (es15)
  ('sce63', 'SpotGeneral', 'es15', 'c29'), -- Filet de mojarra
  ('sce64', 'SpotGeneral', 'es15', 'c14'), -- Mosca ahogada

  -- Perca criolla (es16)
  ('sce65', 'SpotGeneral', 'es16', 'c7'),  -- Cucharita giratoria
  ('sce66', 'SpotGeneral', 'es16', 'c13'), -- Streamer
  ('sce67', 'SpotGeneral', 'es16', 'c15'), -- Lombriz común

  -- Trucha arcoíris (es17)
  ('sce68', 'SpotGeneral', 'es17', 'c7'),  -- Cucharita giratoria
  ('sce69', 'SpotGeneral', 'es17', 'c11'), -- Mosca seca
  ('sce70', 'SpotGeneral', 'es17', 'c12'), -- Ninfa
  ('sce71', 'SpotGeneral', 'es17', 'c24'), -- Isoca

  -- Trucha marrón (es18)
  ('sce72', 'SpotGeneral', 'es18', 'c11'), -- Mosca seca
  ('sce73', 'SpotGeneral', 'es18', 'c13'), -- Streamer
  ('sce74', 'SpotGeneral', 'es18', 'c7'),  -- Cucharita giratoria
  ('sce75', 'SpotGeneral', 'es18', 'c3'),  -- Shad vinilo

  -- Trucha de arroyo (es19)
  ('sce76', 'SpotGeneral', 'es19', 'c11'), -- Mosca seca
  ('sce77', 'SpotGeneral', 'es19', 'c14'), -- Mosca ahogada
  ('sce78', 'SpotGeneral', 'es19', 'c24'), -- Isoca

  -- Bagre sapo (es21)
  ('sce79', 'SpotGeneral', 'es21', 'c20'), -- Tripas de pollo
  ('sce80', 'SpotGeneral', 'es21', 'c21'), -- Hígado de pollo
  ('sce81', 'SpotGeneral', 'es21', 'c15'), -- Lombriz común

  -- Armado (es22)
  ('sce82', 'SpotGeneral', 'es22', 'c20'), -- Tripas de pollo
  ('sce83', 'SpotGeneral', 'es22', 'c21'), -- Hígado de pollo
  ('sce84', 'SpotGeneral', 'es22', 'c15'), -- Lombriz común

  -- Patí (es23)
  ('sce85', 'SpotGeneral', 'es23', 'c26'), -- Mojarra viva
  ('sce86', 'SpotGeneral', 'es23', 'c20'), -- Tripas de pollo
  ('sce87', 'SpotGeneral', 'es23', 'c27'), -- Morena viva

  -- Anguila criolla (es26)
  ('sce88', 'SpotGeneral', 'es26', 'c15'), -- Lombriz común

  -- Pirapitá (es27)
  ('sce89', 'SpotGeneral', 'es27', 'c8'),  -- Cucharita ondulante
  ('sce90', 'SpotGeneral', 'es27', 'c26'), -- Mojarra viva
  ('sce91', 'SpotGeneral', 'es27', 'c5'),  -- Popper

  -- Boga lisa (es28)
  ('sce92', 'SpotGeneral', 'es28', 'c16'), -- Maíz hervido
  ('sce93', 'SpotGeneral', 'es28', 'c18'), -- Mburucuyá
  ('sce94', 'SpotGeneral', 'es28', 'c15'), -- Lombriz común

  -- Palometa (es29)
  ('sce95', 'SpotGeneral', 'es29', 'c4'),  -- Jig cabeza plomada
  ('sce96', 'SpotGeneral', 'es29', 'c15'), -- Lombriz común
  ('sce97', 'SpotGeneral', 'es29', 'c26'), -- Mojarra viva

  -- Corvina rubia (es30)
  ('sce98', 'SpotGeneral', 'es30', 'c30'), -- Camarón
  ('sce99', 'SpotGeneral', 'es30', 'c29'), -- Filet de mojarra

  -- Chanchita (es31)
  ('sce100', 'SpotGeneral', 'es31', 'c15'), -- Lombriz común
  ('sce101', 'SpotGeneral', 'es31', 'c4'),  -- Jig cabeza plomada

  -- Dientudo (es32)
  ('sce102', 'SpotGeneral', 'es32', 'c15'), -- Lombriz común
  ('sce103', 'SpotGeneral', 'es32', 'c22'), -- Pan mojado

  -- Madrecita (es33)
  ('sce104', 'SpotGeneral', 'es33', 'c15'), -- Lombriz común
  ('sce105', 'SpotGeneral', 'es33', 'c22'), -- Pan mojado

  -- Panzudito (es34)
  ('sce106', 'SpotGeneral', 'es34', 'c15'), -- Lombriz común
  ('sce107', 'SpotGeneral', 'es34', 'c22'), -- Pan mojado

  -- Chanchita rayada (es35)
  ('sce108', 'SpotGeneral', 'es35', 'c15'), -- Lombriz común
  ('sce109', 'SpotGeneral', 'es35', 'c4'),  -- Jig cabeza plomada

  -- Bagre negro (es36)
  ('sce110', 'SpotGeneral', 'es36', 'c15'), -- Lombriz común
  ('sce111', 'SpotGeneral', 'es36', 'c20'), -- Tripas de pollo

  -- Castañeta (es37)
  ('sce112', 'SpotGeneral', 'es37', 'c15'), -- Lombriz común
  ('sce113', 'SpotGeneral', 'es37', 'c17'), -- Masa casera

  -- Mojarra cola roja (es38)
  ('sce114', 'SpotGeneral', 'es38', 'c15'), -- Lombriz común
  ('sce115', 'SpotGeneral', 'es38', 'c22'), -- Pan mojado

  -- Puyén grande (es39)
  ('sce116', 'SpotGeneral', 'es39', 'c12'), -- Ninfa
  ('sce117', 'SpotGeneral', 'es39', 'c24'), -- Isoca
  ('sce118', 'SpotGeneral', 'es39', 'c23'), -- Grillo

  -- Perca patagónica (es40)
  ('sce119', 'SpotGeneral', 'es40', 'c7'),  -- Cucharita giratoria
  ('sce120', 'SpotGeneral', 'es40', 'c13'), -- Streamer
  ('sce121', 'SpotGeneral', 'es40', 'c4'),  -- Jig cabeza plomada

  -- Bagre blanco del sur (es41)
  ('sce122', 'SpotGeneral', 'es41', 'c15'); -- Lombriz común

-- ============================================================
-- DATOS DE EJEMPLO - CAPTURAS NOVIEMBRE 2025 (25 CAPTURAS REALISTAS)
-- ============================================================

INSERT INTO "Captura" (
  "id", "idUsuario", "especieId", "fecha", "ubicacion", "peso", "tamanio", 
  "carnada", "tipoPesca", "foto", "notas", "clima", "horaCaptura", "spotId", "latitud", "longitud"
) VALUES

-- ============================================================
-- SPOT SECRETO - CARLOS (usuario1) - 3 TARARIRAS
-- Ubicación: -35.75352487481563, -58.500998126994794
-- ============================================================
('cap001', 'usuario1', 'es1', '2025-11-03', 'Desembocadura del Arrollito - Río Salado', 3.20, 52.0,
 'Filet de mojarra', 'Bait Casting', 'tararuchini.jpg',
 'Tararira hermosa al atardecer. Pesca con flote y filet de mojarra cerca de los juncales. Picó suave y luego estalló la pelea. Agua tranquila ideal para la técnica.',
 'Parcialmente nublado, viento norte suave', '18:45:00', 'SpotSecreto', -35.75352487, -58.50099813),

('cap002', 'usuario1', 'es1', '2025-11-05', 'Desembocadura del Arrollito - Río Salado', 2.80, 48.0,
 'Filet de dientudo', 'Bait Casting', 'uploads/tararira_002.jpg',
 'Segunda salida al spot secreto. Esta vez con filet de dientudo al mediodía. Tararira activa, atacó apenas cayó la carnada. Técnica baitcasting con señuelo blando.',
 'Soleado, calmo', '12:30:00', 'SpotSecreto', -35.75352487, -58.50099813),

('cap003', 'usuario1', 'es1', '2025-11-08', 'Desembocadura del Arrollito - Río Salado', 4.10, 57.0,
 'Mojarra viva', 'Pesca de Flote', 'uploads/tararira_003.jpg',
 '¡La más grande del spot! Pesca con flote y mojarra viva de 10 cm. Esperé 40 minutos pero valió la pena. Pelea épica de 15 minutos. Este spot nunca falla para tarariras.',
 'Nublado, fresco', '17:15:00', 'SpotSecreto', -35.75352487, -58.50099813),

-- ============================================================
-- RÍO SALADO - PUENTE GAVIOTAS - CARLOS (usuario1) - 3 CAPTURAS
-- Ubicación: -35.76542656433006, -58.21856962523311
-- ============================================================
('cap004', 'usuario1', 'es13', '2025-11-01', 'Puente de las Gaviotas - Río Salado', 0.920, 34.0,
 'Filet de mojarra', 'Pesca de Flote', 'uploads/pejerrey_004.jpg',
 'Primer pejerrey del mes. Mañana soleada perfecta. Cardumen activo, capturé 8 ejemplares. Este fue el más grande. Línea fina 0,18 mm con boya chica.',
 'Soleado, sin viento', '09:20:00', 'SpotPuenteGaviotas', -35.76542656, -58.21856963),

('cap005', 'usuario1', 'es20', '2025-11-02', 'Puente de las Gaviotas - Río Salado', 1.45, 40.0,
 'Lombriz común', 'Pesca de Fondo', 'uploads/bagre_005.jpg',
 'Bagre nocturno bajo el puente. Pesca de fondo con lombriz y plomada de 60 gr. Picó a las 11 PM, muy combativo. Zona profunda del canal.',
 'Noche despejada, fresca', '23:00:00', 'SpotPuenteGaviotas', -35.76542656, -58.21856963),

('cap006', 'usuario1', 'es1', '2025-11-04', 'Puente de las Gaviotas - Río Salado', 2.50, 46.0,
 'Rana artificial', 'Spinning', 'uploads/tararira_006.jpg',
 'Tararira con señuelo! Primer lanzamiento al amanecer con rana artificial verde. Atacó explosivamente cerca de la vegetación. Spinning ligero 2 m.',
 'Amanecer despejado', '06:45:00', 'SpotPuenteGaviotas', -35.76542656, -58.21856963),

-- ============================================================
-- RÍO SALADO - CANAL ALIVIADOR - CARLOS (usuario1) - 3 CAPTURAS
-- Ubicación: -35.750086754706095, -58.09736829811158
-- ============================================================
('cap007', 'usuario1', 'es13', '2025-11-06', 'Canal Aliviador - Río Salado', 1.10, 37.0,
 'Filet de mojarra', 'Pesca de Flote', 'uploads/pejerrey_007.jpg',
 'Canal tranquilo, agua clara. Pejerrey selectivo, probé 3 carnadas antes de acertar. Tarde nublada ideal. Técnica clásica con boya corrediza.',
 'Nublado, viento este suave', '16:30:00', 'SpotCanalAliviador', -35.75008675, -58.09736830),

('cap008', 'usuario1', 'es24', '2025-11-07', 'Canal Aliviador - Río Salado', 5.80, 65.0,
 'Maíz hervido', 'Carpfishing', 'uploads/carpa_008.jpg',
 'Carpa grande después de 3 horas de cebado. Maíz fermentado en hair rig. Pelea de 25 minutos, múltiples corridas. Equipo al límite. Vale la pena la espera.',
 'Caluroso, tarde pesada', '19:45:00', 'SpotCanalAliviador', -35.75008675, -58.09736830),

('cap009', 'usuario1', 'es9', '2025-11-09', 'Canal Aliviador - Río Salado', 1.85, 41.0,
 'Maíz hervido', 'Pesca de Fondo', 'uploads/boga_009.jpg',
 'Boga muy combativa en equipo liviano. Técnica variada con múltiples anzuelos. Cardumen alimentándose activamente en el fondo. Capturé 5 ejemplares.',
 'Soleado, calmo', '14:00:00', 'SpotCanalAliviador', -35.75008675, -58.09736830),

-- ============================================================
-- RÍO SALADO - PUENTE 41 - CARLOS (usuario1) - 3 CAPTURAS PEJERREY
-- Ubicación: -35.73658874176168, -57.98199742419953
-- ============================================================
('cap010', 'usuario1', 'es13', '2025-11-10', 'Puente de la Ruta 41 - Río Salado', 0.850, 32.0,
 'Grillo', 'Pesca de Flote', 'uploads/pejerrey_010.jpg',
 'Spot pejerrerero clásico. Mañana fría perfecta. Grillo vivo irresistible. Picada suave, hay que estar atento. Línea 0,16 mm, anzuelo N°10.',
 'Frío, despejado', '08:30:00', 'SpotPuente41', -35.73658874, -57.98199742),

('cap011', 'usuario1', 'es13', '2025-11-10', 'Puente de la Ruta 41 - Río Salado', 1.05, 36.0,
 'Filet de mojarra', 'Pesca de Flote', 'uploads/pejerrey_011.jpg',
 'Segunda captura de la mañana. Cambié a filet y siguieron picando. Cardumen grande bajo el puente. Este es un spot que nunca falla para pejerrey.',
 'Frío, despejado', '10:15:00', 'SpotPuente41', -35.73658874, -57.98199742),

('cap012', 'usuario1', 'es13', '2025-11-10', 'Puente de la Ruta 41 - Río Salado', 0.780, 31.0,
 'Masa casera', 'Pesca de Flote', 'uploads/pejerrey_012.jpg',
 'Tercero del día. Probé con masa para variar y funcionó. Total de la jornada: 12 pejerreyes. Excelente día de pesca. Spot súper productivo.',
 'Frío, despejado', '11:45:00', 'SpotPuente41', -35.73658874, -57.98199742),

-- ============================================================
-- RÍO PARANÁ - ITÁ IBATÉ - LUCÍA (usuario2) - 3 CAPTURAS
-- Ubicación: -31.348611068177423, -59.20694076805208
-- ============================================================
('cap013', 'usuario2', 'es2', '2025-11-01', 'Itá Ibaté - Río Paraná', 7.20, 72.0,
 'Popper', 'Spinning', 'uploads/dorado_013.jpg',
 'Dorado explosivo al amanecer! Popper amarillo con rojo, trabajado agresivamente. Saltó 4 veces fuera del agua. Corriente rápida, pelea de 18 minutos. Pura adrenalina.',
 'Amanecer despejado, calmo', '06:15:00', 'SpotItaIbate', -31.34861107, -59.20694077),

('cap014', 'usuario2', 'es3', '2025-11-02', 'Itá Ibaté - Río Paraná', 12.50, 88.0,
 'Morena viva', 'Pesca Nocturna de Bagres', 'uploads/surubi_014.jpg',
 'Surubí nocturno en pozón profundo. Morena viva de 25 cm en anzuelo 6/0. Picó a la medianoche. Pelea brutal de 35 minutos. Equipo pesado necesario. ¡Bestia!',
 'Noche cerrada, húmeda', '00:30:00', 'SpotItaIbate', -31.34861107, -59.20694077),

('cap015', 'usuario2', 'es6', '2025-11-03', 'Itá Ibaté - Río Paraná', 3.80, 54.0,
 'Mburucuyá', 'Pesca de Fondo', 'uploads/pacu_015.jpg',
 'Pacú con fruta! Mburucuyá maduro en remanso. Tarde tranquila, picó después de 1 hora. Muy combativo, corridas largas. Carne excelente para la parrilla.',
 'Caluroso, parcialmente nublado', '17:20:00', 'SpotItaIbate', -31.34861107, -59.20694077),

-- ============================================================
-- RÍO PARANÁ - GOYA - LUCÍA (usuario2) - 3 CAPTURAS
-- Ubicación: -29.139437530308674, -59.26544244843749
-- ============================================================
('cap016', 'usuario2', 'es2', '2025-11-04', 'Goya - Río Paraná', 6.50, 68.0,
 'Cucharita ondulante', 'Bait Casting', 'uploads/dorado_016.jpg',
 'Dorado con cuchara plateada N°4. Lanzamiento largo a correntada. Ataque violento, típico de esta zona. Goya nunca decepciona para dorados. Spinning medio.',
 'Soleado, viento norte', '07:30:00', 'SpotGoya', -29.13943753, -59.26544245),

('cap017', 'usuario2', 'es9', '2025-11-05', 'Goya - Río Paraná', 2.10, 43.0,
 'Maíz hervido', 'Variada', 'uploads/boga_017.jpg',
 'Boga en técnica variada. 4 anzuelos con maíz. Corriente media, muy combativa. Capturé 6 bogas en 2 horas. Esta fue la más grande. Excelente para carnada.',
 'Parcialmente nublado', '15:00:00', 'SpotGoya', -29.13943753, -59.26544245),

('cap018', 'usuario2', 'es1', '2025-11-06', 'Goya - Río Paraná', 3.50, 54.0,
 'Paseante', 'Spinning', 'uploads/tararira_018.jpg',
 'Tararira grande del Paraná. Paseante blanco trabajado en vegetación flotante. Más oscura que las del Salado. Ataque explosivo típico. ¡Qué pelea!',
 'Nublado, fresco', '18:00:00', 'SpotGoya', -29.13943753, -59.26544245),

-- ============================================================
-- RÍO PARANÁ - PASO DE LA PATRIA - LUCÍA (usuario2) - 3 CAPTURAS
-- Ubicación: -27.311481568694984, -59.11302697011719
-- ============================================================
('cap019', 'usuario2', 'es2', '2025-11-07', 'Paso de la Patria - Río Paraná', 9.80, 82.0,
 'Popper', 'Spinning', 'uploads/dorado_019.jpg',
 'Dorado trofeo en la capital del dorado! Popper de 15 cm trabajado explosivo. Saltó 7 veces. Pelea inolvidable de 28 minutos. La Meca del doradista hecha realidad.',
 'Soleado, caluroso', '06:00:00', 'SpotPasoDeLaPatria', -27.31148157, -59.11302697),

('cap020', 'usuario2', 'es3', '2025-11-08', 'Paso de la Patria - Río Paraná', 14.20, 94.0,
 'Morena viva', 'Pesca al Correntino', 'uploads/surubi_020.jpg',
 'Surubí monstruoso! La captura de mi vida. Morena de 30 cm en deriva natural. Picó suave, luego el infierno. 45 minutos de pelea pura. Línea 0,50 al límite. ¡Increíble!',
 'Noche cálida, luna llena', '22:00:00', 'SpotPasoDeLaPatria', -27.31148157, -59.11302697),

('cap021', 'usuario2', 'es6', '2025-11-09', 'Paso de la Patria - Río Paraná', 4.50, 58.0,
 'Maíz hervido', 'Pesca de Fondo', 'uploads/pacu_021.jpg',
 'Pacú en bajante. Maíz hervido con anís. Remanso tranquilo cerca de árboles. Muy combativo para su tamaño. Paso de la Patria es el paraíso de la pesca.',
 'Caluroso, atardecer', '19:30:00', 'SpotPasoDeLaPatria', -27.31148157, -59.11302697),

-- ============================================================
-- SUR - RÍO LIMAY - LUCÍA (usuario2) - 2 CAPTURAS
-- Ubicación: -40.96826103651293, -71.34124481924113
-- ============================================================
('cap022', 'usuario2', 'es17', '2025-11-02', 'Río Limay - Bariloche', 2.80, 48.0,
 'Cucharita giratoria', 'Spinning Patagónico', 'uploads/trucha_arcoiris_022.jpg',
 'Trucha arcoíris hermosa del Limay. Cucharita plateada N°3 en corriente rápida. Agua cristalina a 10°C. Colores intensos típicos del río. Liberada después de foto.',
 'Frío, parcialmente nublado', '08:45:00', 'SpotRioLimay', -40.96826104, -71.34124482),

('cap023', 'usuario2', 'es18', '2025-11-03', 'Río Limay - Bariloche', 3.90, 56.0,
 'Mosca seca', 'Fly Fishing (Mosca)', 'uploads/trucha_marron_023.jpg',
 'Trucha marrón selectiva. Mosca seca #14 en eclosión de efímeras. Tardé 2 horas en conseguir la presentación perfecta. La espera valió la pena. ¡Qué hermosura!',
 'Fresco, despejado', '19:15:00', 'SpotRioLimay', -40.96826104, -71.34124482),

-- ============================================================
-- SUR - RÍO CHIMEHUÍN - LUCÍA (usuario2) - 1 CAPTURA
-- Ubicación: -39.87997896458389, -71.0633587292683
-- ============================================================
('cap024', 'usuario2', 'es17', '2025-11-05', 'Río Chimehuín - Junín de los Andes', 4.20, 62.0,
 'Ninfa', 'Fly Fishing (Mosca)', 'uploads/trucha_arcoiris_024.jpg',
 '¡Trucha trofeo del Chimehuín! Ninfa con lastre en pozón profundo. Río mítico, no decepciona. Pelea de 20 minutos. Ejemplar perfecto en excelente estado. Devuelta al agua.',
 'Frío intenso, despejado', '11:30:00', 'SpotRioChimehuin', -39.87997896, -71.06335873),

-- ============================================================
-- SUR - RÍO TRAFUL - LUCÍA (usuario2) - 1 CAPTURA
-- Ubicación: -40.66268370204022, -71.29338522436461
-- ============================================================
('cap025', 'usuario2', 'es16', '2025-11-07', 'Río Traful - Villa Traful', 2.40, 38.0,
 'Streamer', 'Fly Fishing (Mosca)', 'uploads/perca_025.jpg',
 'Perca criolla del Traful. Streamer zonker trabajado cerca del fondo. Agua profunda y fría. Menos conocida que las truchas pero igual de combativa. Hermosa captura nativa.',
 'Frío, viento oeste', '16:00:00', 'SpotRioTraful', -40.66268370, -71.29338522);

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

-- Las siguientes líneas eran para agregar columnas en pruebas anteriores
-- Ahora las columnas spotId, latitud, longitud ya están incluidas en los INSERTs
-- y tamanio fue reemplazado por longitud

-- ALTER TABLE "Captura" 
-- ADD COLUMN "spotId" VARCHAR(255),
-- ADD COLUMN "latitud" DECIMAL(10,8),
-- ADD COLUMN "longitud" DECIMAL(11,8),
-- ADD COLUMN "tamanio" DECIMAL(6,2);

-- ALTER TABLE "Captura"
-- ADD CONSTRAINT "fk_captura_spot" 
-- FOREIGN KEY ("spotId") REFERENCES "Spot"("id") ON DELETE SET NULL;

-- CREATE INDEX idx_captura_spotId ON "Captura"("spotId");
-- CREATE INDEX idx_captura_peso ON "Captura"("peso" DESC NULLS LAST);
-- CREATE INDEX idx_captura_tamanio ON "Captura"("tamanio" DESC NULLS LAST);

-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_schema = 'public' 
--   AND table_name = 'Captura' 
--   AND column_name IN ('spotId', 'latitud', 'longitud', 'tamanio');
