
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
  'ArtificialBlando', 'Natural' , 'ArtificialDuro','Viva','CarnadaMuerta','NaturalNoViva','MoscaArtificial','Otros'
);

-- TABLAS
CREATE TABLE "TipoPesca" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "descripcion" TEXT NOT NULL
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

--  DATOS BASE

INSERT INTO "Usuario" ("id", "nombre", "nivelPescador", "email") VALUES
  ('usuario1', 'Carlos Tarucha', 'Avanzado', 'carlos@example.com'),
  ('usuario2', 'Lucía Señuelera', 'Experto', 'lucia@example.com');

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
  ('tp15', 'Pesca Submarina', 'Sin caña ni reel. Uso de arpón, fusil submarino o hawaiana, practicada en apnea con snorkel o buceo.');

INSERT INTO "Especie" ("id", "nombreCientifico", "descripcion", "imagen") VALUES
('es2', 'Salminus brasiliensis',
'DORADO: Pez depredador muy combativo, conocido como el "tigre de los ríos". Habita aguas rápidas y correntosas. Se alimenta principalmente de peces pequeños y es activo durante todo el día, con picos de actividad al amanecer y atardecer. Se pesca mejor con señuelos artificiales (spinning, baitcasting, trolling) y también con carnada viva como mojarras o sabalitos. Necesita cañas potentes y reels con buen freno.', 
'uploads/dorado.png'),
('es3', 'Pseudoplatystoma corruscans',
'SURUBÍ PINTADO: Bagre de gran tamaño, cuerpo alargado con manchas características. Prefiere aguas profundas y correntosas, especialmente en grandes ríos como Paraná y Paraguay. Es nocturno, cazador de peces medianos y grandes. Se pesca de noche con carnadas naturales (anguilas, bogas chicas, morenas) al fondo, usando cañas pesadas y plomadas.', 
'uploads/surubi_pintado.png'),
('es4', 'Pseudoplatystoma reticulatum',
'SURUBÍ ATIGRADO: Similar al pintado pero con patrón reticulado. Vive en grandes ríos y prefiere zonas profundas con pozones. Cazador nocturno, se alimenta de peces y crustáceos. Técnica: pesca de fondo con carnadas vivas o muertas grandes. Equipo robusto es imprescindible.', 
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
'TARARIRA COMÚN: Depredador emboscador que vive en lagunas, arroyos y remansos con vegetación. Activa al amanecer y atardecer. Caza peces pequeños, anfibios e incluso aves. Se pesca con señuelos artificiales (ranas, paseantes, crankbaits) y carnadas vivas. Muy agresiva y combativa, requiere acero o fluorocarbono en la línea.', 
'uploads/tararira.png'),
('es11', 'Hoplias lacerdae',
'TARARIRA AZUL: De mayor tamaño que la común, habita ríos y lagunas profundas. Depredador muy agresivo. Prefiere horas bajas de luz. Técnicas: baitcasting y spinning con señuelos grandes, o carnada viva robusta.', 
'uploads/tararira_azul.png'),
('es12', 'Hoplias australis',
'TARARIRA PINTADA: Patrón moteado en el cuerpo. Vive en aguas tranquilas con vegetación abundante. Es cazadora de emboscada, activa en amanecer y atardecer. Se pesca con señuelos de superficie y medias aguas, también carnadas naturales.', 
'uploads/tararira_pintada.png'),
('es13', 'Odontesthes bonariensis',
'PEJERREY BONAERENSE: Muy popular en lagunas y ríos de llanura. Vive en cardúmenes, se alimenta de zooplancton, insectos y pequeños peces. Activo en horas de sol. Se pesca con boyas y carnada natural (mojarra viva o filet). Equipo liviano de flote es lo clásico.', 
'uploads/pejerrey.png'),
('es14', 'Odontesthes hatcheri',
'PEJERREY PATAGÓNICO: Adaptado a aguas frías de lagos y ríos de la Patagonia. Vive en cardúmenes y se alimenta de invertebrados y peces. Se pesca con boyas y mosca. Horarios: pleno día, mejor en mañanas despejadas.', 
'uploads/pejerrey_patagonico.png'),
('es15', 'Odontesthes nigricans',
'PEJERREY FUEGUINO: Habita aguas frías del extremo sur. Dieta basada en invertebrados acuáticos. Se pesca con moscas, pequeñas cucharas y carnada natural. Activo durante el día. Requiere equipos livianos.', 
'uploads/pejerrey_fueguino.png'),
('es16', 'Percichthys trucha',
'PERCA CRIOLLA: Habita lagos y ríos fríos de la Patagonia. Depredador de peces pequeños y crustáceos. Activa en horas crepusculares. Se pesca con spinning y mosca. Carne muy apreciada.', 
'uploads/perca_criolla.png'),
('es17', 'Oncorhynchus mykiss',
'TRUCHA ARCOÍRIS: Introducida, muy deportiva. Vive en aguas frías y oxigenadas. Se alimenta de insectos, crustáceos y peces pequeños. Muy activa en amanecer y atardecer. Se pesca con mosca, spinning y cucharas. Excelente combatividad.', 
'uploads/trucha_arcoiris.png'),
('es18', 'Salmo trutta',
'TRUCHA MARRÓN: Especie introducida, muy combativa y desconfiada. Se alimenta de insectos, crustáceos y peces. Activa en atardecer y noches nubladas. Se pesca con mosca y spinning. Alcanzan gran tamaño en ambientes adecuados.', 
'uploads/trucha_marron.png'),
('es19', 'Salvelinus fontinalis',
'TRUCHA DE ARROYO: Originaria de Norteamérica, introducida en aguas frías de Argentina. Prefiere arroyos y ríos serranos. Se alimenta de insectos, larvas y pequeños peces. Activa en horas frescas del día. Se pesca con mosca seca y ninfas.', 
'uploads/trucha_arroyo.png'),
('es20', 'Pimelodus albicans',
'BAGRE BLANCO: Muy común en ríos grandes. Se alimenta de pequeños peces, moluscos y detritos. Activo de noche, aunque también pica de día. Se pesca al fondo con lombrices, tripa de pollo o masa. Ideal con líneas pesadas y plomos. Muy buscado por pescadores de costa.', 
'uploads/bagre_blanco.png');

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

  -- 11. Pejerrey (Odontesthes bonariensis)
  ('nc28', 'es11', 'Pejerrey'),
  ('nc29', 'es11', 'Pejerrey bonaerense'),
  ('nc30', 'es11', 'Peje'),

  -- 12. Trucha arcoíris (Oncorhynchus mykiss)
  ('nc31', 'es12', 'Trucha arcoíris'),
  ('nc32', 'es12', 'Rainbow trout'),

  -- 13. Trucha marrón (Salmo trutta)
  ('nc33', 'es13', 'Trucha marrón'),
  ('nc34', 'es13', 'Brown trout'),

  -- 14. Bagre amarillo (Pimelodus clarias)
  ('nc35', 'es14', 'Bagre amarillo'),
  ('nc36', 'es14', 'Bagre criollo'),

  -- 15. Bagre sapo (Rhamdia quelen)
  ('nc37', 'es15', 'Bagre sapo'),
  ('nc38', 'es15', 'Bagre negro'),
  ('nc39', 'es15', 'Jundiá'),

  -- 16. Armado (Pterodoras granulosus)
  ('nc40', 'es16', 'Armado'),
  ('nc41', 'es16', 'Armado chancho'),

  -- 17. Patí (Luciopimelodus pati)
  ('nc42', 'es17', 'Patí'),
  ('nc43', 'es17', 'Bagre patí'),

  -- 18. Mojarra (Astyanax spp.)
  ('nc44', 'es18', 'Mojarra'),
  ('nc45', 'es18', 'Mojarrita'),
  ('nc46', 'es18', 'Pirincha'),

  -- 19. Carpa (Cyprinus carpio)
  ('nc47', 'es19', 'Carpa'),
  ('nc48', 'es19', 'Carpín'),
  ('nc49', 'es19', 'Carpa común'),

  -- 20. Anguila criolla (Synbranchus marmoratus)
  ('nc50', 'es20', 'Anguila criolla'),
  ('nc51', 'es20', 'Anguila'),
  ('nc52', 'es20', 'Morena');

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
  ('c30', 'Camarón vivo', 'Viva', 'Camarón de agua dulce usado como carnada.');

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
('etp15', 'es3', 'tp6', 'Trolling: Señuelos pesados arrastrados desde embarcación en ríos grandes. Línea 0,40 mm, reel rotativo grande. Horario: mañana y tarde, aguas profundas y lentas.');

INSERT INTO "Spot" (
  "id", "idUsuario", "idUsuarioActualizo", "nombre", "estado", "descripcion", "ubicacion", "fechaPublicacion", "fechaActualizacion", "imagenPortada"
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
  'uploads/taruchini.png'
);


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
  'ArtificialBlando', 'Natural' , 'ArtificialDuro','Viva','CarnadaMuerta','NaturalNoViva','MoscaArtificial','Otros'
);

-- TABLAS
CREATE TABLE "TipoPesca" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "descripcion" TEXT NOT NULL
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

--  DATOS BASE

INSERT INTO "Usuario" ("id", "nombre", "nivelPescador", "email") VALUES
  ('usuario1', 'Carlos Tarucha', 'Avanzado', 'carlos@example.com'),
  ('usuario2', 'Lucía Señuelera', 'Experto', 'lucia@example.com');

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
  ('tp15', 'Pesca Submarina', 'Sin caña ni reel. Uso de arpón, fusil submarino o hawaiana, practicada en apnea con snorkel o buceo.');

INSERT INTO "Especie" ("id", "nombreCientifico", "descripcion", "imagen") VALUES
('es2', 'Salminus brasiliensis',
'DORADO: Pez depredador muy combativo, conocido como el "tigre de los ríos". Habita aguas rápidas y correntosas. Se alimenta principalmente de peces pequeños y es activo durante todo el día, con picos de actividad al amanecer y atardecer. Se pesca mejor con señuelos artificiales (spinning, baitcasting, trolling) y también con carnada viva como mojarras o sabalitos. Necesita cañas potentes y reels con buen freno.', 
'uploads/dorado.png'),
('es3', 'Pseudoplatystoma corruscans',
'SURUBÍ PINTADO: Bagre de gran tamaño, cuerpo alargado con manchas características. Prefiere aguas profundas y correntosas, especialmente en grandes ríos como Paraná y Paraguay. Es nocturno, cazador de peces medianos y grandes. Se pesca de noche con carnadas naturales (anguilas, bogas chicas, morenas) al fondo, usando cañas pesadas y plomadas.', 
'uploads/surubi_pintado.png'),
('es4', 'Pseudoplatystoma reticulatum',
'SURUBÍ ATIGRADO: Similar al pintado pero con patrón reticulado. Vive en grandes ríos y prefiere zonas profundas con pozones. Cazador nocturno, se alimenta de peces y crustáceos. Técnica: pesca de fondo con carnadas vivas o muertas grandes. Equipo robusto es imprescindible.', 
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
'TARARIRA COMÚN: Depredador emboscador que vive en lagunas, arroyos y remansos con vegetación. Activa al amanecer y atardecer. Caza peces pequeños, anfibios e incluso aves. Se pesca con señuelos artificiales (ranas, paseantes, crankbaits) y carnadas vivas. Muy agresiva y combativa, requiere acero o fluorocarbono en la línea.', 
'uploads/tararira.png'),
('es11', 'Hoplias lacerdae',
'TARARIRA AZUL: De mayor tamaño que la común, habita ríos y lagunas profundas. Depredador muy agresivo. Prefiere horas bajas de luz. Técnicas: baitcasting y spinning con señuelos grandes, o carnada viva robusta.', 
'uploads/tararira_azul.png'),
('es12', 'Hoplias australis',
'TARARIRA PINTADA: Patrón moteado en el cuerpo. Vive en aguas tranquilas con vegetación abundante. Es cazadora de emboscada, activa en amanecer y atardecer. Se pesca con señuelos de superficie y medias aguas, también carnadas naturales.', 
'uploads/tararira_pintada.png'),
('es13', 'Odontesthes bonariensis',
'PEJERREY BONAERENSE: Muy popular en lagunas y ríos de llanura. Vive en cardúmenes, se alimenta de zooplancton, insectos y pequeños peces. Activo en horas de sol. Se pesca con boyas y carnada natural (mojarra viva o filet). Equipo liviano de flote es lo clásico.', 
'uploads/pejerrey_bonaerense.png'),
('es14', 'Odontesthes hatcheri',
'PEJERREY PATAGÓNICO: Adaptado a aguas frías de lagos y ríos de la Patagonia. Vive en cardúmenes y se alimenta de invertebrados y peces. Se pesca con boyas y mosca. Horarios: pleno día, mejor en mañanas despejadas.', 
'uploads/pejerrey_patagonico.png'),
('es15', 'Odontesthes nigricans',
'PEJERREY FUEGUINO: Habita aguas frías del extremo sur. Dieta basada en invertebrados acuáticos. Se pesca con moscas, pequeñas cucharas y carnada natural. Activo durante el día. Requiere equipos livianos.', 
'uploads/pejerrey_fueguino.png'),
('es16', 'Percichthys trucha',
'PERCA CRIOLLA: Habita lagos y ríos fríos de la Patagonia. Depredador de peces pequeños y crustáceos. Activa en horas crepusculares. Se pesca con spinning y mosca. Carne muy apreciada.', 
'uploads/perca_criolla.png'),
('es17', 'Oncorhynchus mykiss',
'TRUCHA ARCOÍRIS: Introducida, muy deportiva. Vive en aguas frías y oxigenadas. Se alimenta de insectos, crustáceos y peces pequeños. Muy activa en amanecer y atardecer. Se pesca con mosca, spinning y cucharas. Excelente combatividad.', 
'uploads/trucha_arcoiris.png'),
('es18', 'Salmo trutta',
'TRUCHA MARRÓN: Especie introducida, muy combativa y desconfiada. Se alimenta de insectos, crustáceos y peces. Activa en atardecer y noches nubladas. Se pesca con mosca y spinning. Alcanzan gran tamaño en ambientes adecuados.', 
'uploads/trucha_marron.png'),
('es19', 'Salvelinus fontinalis',
'TRUCHA DE ARROYO: Originaria de Norteamérica, introducida en aguas frías de Argentina. Prefiere arroyos y ríos serranos. Se alimenta de insectos, larvas y pequeños peces. Activa en horas frescas del día. Se pesca con mosca seca y ninfas.', 
'uploads/trucha_arroyo.png'),
('es20', 'Pimelodus albicans',
'BAGRE BLANCO: Muy común en ríos grandes. Se alimenta de pequeños peces, moluscos y detritos. Activo de noche, aunque también pica de día. Se pesca al fondo con lombrices, tripa de pollo o masa. Ideal con líneas pesadas y plomos. Muy buscado por pescadores de costa.', 
'uploads/bagre_blanco.png');

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

  -- 11. Pejerrey (Odontesthes bonariensis)
  ('nc28', 'es11', 'Pejerrey'),
  ('nc29', 'es11', 'Pejerrey bonaerense'),
  ('nc30', 'es11', 'Peje'),

  -- 12. Trucha arcoíris (Oncorhynchus mykiss)
  ('nc31', 'es12', 'Trucha arcoíris'),
  ('nc32', 'es12', 'Rainbow trout'),

  -- 13. Trucha marrón (Salmo trutta)
  ('nc33', 'es13', 'Trucha marrón'),
  ('nc34', 'es13', 'Brown trout'),

  -- 14. Bagre amarillo (Pimelodus clarias)
  ('nc35', 'es14', 'Bagre amarillo'),
  ('nc36', 'es14', 'Bagre criollo'),

  -- 15. Bagre sapo (Rhamdia quelen)
  ('nc37', 'es15', 'Bagre sapo'),
  ('nc38', 'es15', 'Bagre negro'),
  ('nc39', 'es15', 'Jundiá'),

  -- 16. Armado (Pterodoras granulosus)
  ('nc40', 'es16', 'Armado'),
  ('nc41', 'es16', 'Armado chancho'),

  -- 17. Patí (Luciopimelodus pati)
  ('nc42', 'es17', 'Patí'),
  ('nc43', 'es17', 'Bagre patí'),

  -- 18. Mojarra (Astyanax spp.)
  ('nc44', 'es18', 'Mojarra'),
  ('nc45', 'es18', 'Mojarrita'),
  ('nc46', 'es18', 'Pirincha'),

  -- 19. Carpa (Cyprinus carpio)
  ('nc47', 'es19', 'Carpa'),
  ('nc48', 'es19', 'Carpín'),
  ('nc49', 'es19', 'Carpa común'),

  -- 20. Anguila criolla (Synbranchus marmoratus)
  ('nc50', 'es20', 'Anguila criolla'),
  ('nc51', 'es20', 'Anguila'),
  ('nc52', 'es20', 'Morena');

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
  ('c30', 'Camarón vivo', 'Viva', 'Camarón de agua dulce usado como carnada.');

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
('etp15', 'es3', 'tp6', 'Trolling: Señuelos pesados arrastrados desde embarcación en ríos grandes. Línea 0,40 mm, reel rotativo grande. Horario: mañana y tarde, aguas profundas y lentas.');

INSERT INTO "Spot" (
  "id", "idUsuario", "idUsuarioActualizo", "nombre", "estado", "descripcion", "ubicacion", "fechaPublicacion", "fechaActualizacion", "imagenPortada"
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
  'uploads/taruchini.png'
);



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
  'ArtificialBlando', 'Natural' , 'ArtificialDuro','Viva','CarnadaMuerta','NaturalNoViva','MoscaArtificial','Otros'
);

-- TABLAS
CREATE TABLE "TipoPesca" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "descripcion" TEXT NOT NULL
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

--  DATOS BASE

INSERT INTO "Usuario" ("id", "nombre", "nivelPescador", "email") VALUES
  ('usuario1', 'Carlos Tarucha', 'Avanzado', 'carlos@example.com'),
  ('usuario2', 'Lucía Señuelera', 'Experto', 'lucia@example.com');

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
  ('tp15', 'Pesca Submarina', 'Sin caña ni reel. Uso de arpón, fusil submarino o hawaiana, practicada en apnea con snorkel o buceo.');

INSERT INTO "Especie" ("id", "nombreCientifico", "descripcion", "imagen") VALUES
('es1', 'Hoplias malabaricus',
'TARARIRA COMÚN: Depredador emboscador que vive en lagunas, arroyos y remansos con vegetación. Activa al amanecer y atardecer. Caza peces pequeños, anfibios e incluso aves. Se pesca con señuelos artificiales (ranas, paseantes, crankbaits) y carnadas vivas. Muy agresiva y combativa, requiere acero o fluorocarbono en la línea.', 
'uploads/tararira.png'),
('es2', 'Salminus brasiliensis',
'DORADO: Pez depredador muy combativo, conocido como el ''tigre de los ríos''. Habita aguas rápidas y correntosas. Se alimenta principalmente de peces pequeños y es activo durante todo el día, con picos de actividad al amanecer y atardecer. Se pesca mejor con señuelos artificiales (spinning, baitcasting, trolling) y también con carnada viva como mojarras o sabalitos. Necesita cañas potentes y reels con buen freno.', 
'uploads/dorado.png'),
('es3', 'Pseudoplatystoma corruscans',
'SURUBÍ PINTADO: Bagre de gran tamaño, cuerpo alargado con manchas características. Prefiere aguas profundas y correntosas, especialmente en grandes ríos como Paraná y Paraguay. Es nocturno, cazador de peces medianos y grandes. Se pesca de noche con carnadas naturales (anguilas, bogas chicas, morenas) al fondo, usando cañas pesadas y plomadas.', 
'uploads/surubi_pintado.png'),
('es4', 'Pseudoplatystoma reticulatum',
'SURUBÍ ATIGRADO: Similar al pintado pero con patrón reticulado. Vive en grandes ríos y prefiere zonas profundas con pozones. Cazador nocturno, se alimenta de peces y crustáceos. Técnica: pesca de fondo con carnadas vivas o muertas grandes. Equipo robusto es imprescindible.', 
'uploads/surubi_atigrado.png'),
('es5', 'Zungaro zungaro',
'MANGURUYÚ: Uno de los bagres más grandes de Sudamérica, puede superar los 100 kg. Habita en pozones profundos y correntosos. Depredador nocturno, se alimenta de peces grandes y crustáceos. Se pesca con carnadas vivas o grandes trozos de pescado. Necesario equipo de alta resistencia.', 
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
('es11', 'Hoplias lacerdae',
'TARARIRA AZUL: De mayor tamaño que la común, habita ríos y lagunas profundas. Depredador muy agresivo. Prefiere horas bajas de luz. Técnicas: baitcasting y spinning con señuelos grandes, o carnada viva robusta.', 
'uploads/tararira_azul.png'),
('es12', 'Hoplias australis',
'TARARIRA PINTADA: Patrón moteado en el cuerpo. Vive en aguas tranquilas con vegetación abundante. Es cazadora de emboscada, activa en amanecer y atardecer. Se pesca con señuelos de superficie y medias aguas, también carnadas naturales.', 
'uploads/tararira_pintada.png'),
('es13', 'Odontesthes bonariensis',
'PEJERREY BONAERENSE: Muy popular en lagunas y ríos de llanura. Vive en cardúmenes, se alimenta de zooplancton, insectos y pequeños peces. Activo en horas de sol. Se pesca con boyas y carnada natural (mojarra viva o filet). Equipo liviano de flote es lo clásico.', 
'uploads/pejerrey.png'),
('es14', 'Odontesthes hatcheri',
'PEJERREY PATAGÓNICO: Adaptado a aguas frías de lagos y ríos de la Patagonia. Vive en cardúmenes y se alimenta de invertebrados y peces. Se pesca con boyas y mosca. Horarios: pleno día, mejor en mañanas despejadas.', 
'uploads/pejerrey_patagonico.png'),
('es15', 'Odontesthes nigricans',
'PEJERREY FUEGUINO: Habita aguas frías del extremo sur. Dieta basada en invertebrados acuáticos. Se pesca con moscas, pequeñas cucharas y carnada natural. Activo durante el día. Requiere equipos livianos.', 
'uploads/pejerrey_fueguino.png'),
('es16', 'Percichthys trucha',
'PERCA CRIOLLA: Habita lagos y ríos fríos de la Patagonia. Depredador de peces pequeños y crustáceos. Activa en horas crepusculares. Se pesca con spinning y mosca. Carne muy apreciada.', 
'uploads/perca_criolla.png'),
('es17', 'Oncorhynchus mykiss',
'TRUCHA ARCOÍRIS: Introducida, muy deportiva. Vive en aguas frías y oxigenadas. Se alimenta de insectos, crustáceos y peces pequeños. Muy activa en amanecer y atardecer. Se pesca con mosca, spinning y cucharas. Excelente combatividad.', 
'uploads/trucha_arcoiris.png'),
('es18', 'Salmo trutta',
'TRUCHA MARRÓN: Especie introducida, muy combativa y desconfiada. Se alimenta de insectos, crustáceos y peces. Activa en atardecer y noches nubladas. Se pesca con mosca y spinning. Alcanzan gran tamaño en ambientes adecuados.', 
'uploads/trucha_marron.png'),
('es19', 'Salvelinus fontinalis',
'TRUCHA DE ARROYO: Originaria de Norteamérica, introducida en aguas frías de Argentina. Prefiere arroyos y ríos serranos. Se alimenta de insectos, larvas y pequeños peces. Activa en horas frescas del día. Se pesca con mosca seca y ninfas.', 
'uploads/trucha_arroyo.png'),
('es20', 'Pimelodus albicans',
'BAGRE BLANCO: Muy común en ríos grandes. Se alimenta de pequeños peces, moluscos y detritos. Activo de noche, aunque también pica de día. Se pesca al fondo con lombrices, tripa de pollo o masa. Ideal con líneas pesadas y plomos. Muy buscado por pescadores de costa.', 
'uploads/bagre_blanco.png');

-- INSERT DE NOMBRES COMUNES
INSERT INTO "NombreComunEspecie" ("id", "idEspecie", "nombre") VALUES
('nc1', 'es1', 'Tararira'),
('nc2', 'es1', 'Tarucha'),
('nc3', 'es1', 'Lobito'),
('nc4', 'es1', 'Cabeza amarga'),
('nc5', 'es1', 'Tigre de agua dulce'),

('nc6', 'es2', 'Dorado'),
('nc7', 'es2', 'Tigre de los ríos'),
('nc8', 'es2', 'Salminus'),

('nc9', 'es3', 'Surubí'),
('nc10', 'es3', 'Surubí pintado'),
('nc11', 'es3', 'Bagre pintado'),

('nc12', 'es4', 'Surubí atigrado'),
('nc13', 'es4', 'Bagre atigrado'),

('nc14', 'es5', 'Manguruyú'),
('nc15', 'es5', 'Manguruyú gigante'),

('nc16', 'es6', 'Pacú'),
('nc17', 'es6', 'Pacú negro'),
('nc18', 'es6', 'Pacuí'),

('nc19', 'es7', 'Pacú reloj'),
('nc20', 'es7', 'Pacuí reloj'),

('nc21', 'es8', 'Pacú chato'),
('nc22', 'es8', 'Chato'),

('nc23', 'es9', 'Boga'),
('nc24', 'es9', 'Boga del Paraná'),
('nc25', 'es9', 'Leporinus'),

('nc26', 'es10', 'Sábalo'),
('nc27', 'es10', 'Saboga'),

('nc28', 'es13', 'Pejerrey'),
('nc29', 'es13', 'Pejerrey bonaerense'),
('nc30', 'es13', 'Peje'),

('nc31', 'es17', 'Trucha arcoíris'),
('nc32', 'es17', 'Rainbow trout'),

('nc33', 'es18', 'Trucha marrón'),
('nc34', 'es18', 'Brown trout'),

('nc35', 'es20', 'Bagre blanco'),
('nc36', 'es20', 'Bagre criollo'),

('nc37', 'es15', 'Bagre sapo'),
('nc38', 'es15', 'Bagre negro'),
('nc39', 'es15', 'Jundiá'),

('nc40', 'es16', 'Armado'),
('nc41', 'es16', 'Armado chancho'),

('nc42', 'es19', 'Trucha de arroyo'),

('nc43', 'es11', 'Tararira azul'),
('nc44', 'es12', 'Tararira pintada');

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
  ('c30', 'Camarón vivo', 'Viva', 'Camarón de agua dulce usado como carnada.');

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
('etp15', 'es3', 'tp6', 'Trolling: Señuelos pesados arrastrados desde embarcación en ríos grandes. Línea 0,40 mm, reel rotativo grande. Horario: mañana y tarde, aguas profundas y lentas.');

INSERT INTO "Spot" (
  "id", "idUsuario", "idUsuarioActualizo", "nombre", "estado", "descripcion", "ubicacion", "fechaPublicacion", "fechaActualizacion", "imagenPortada"
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
  'uploads/taruchini.png'
);



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
  'ArtificialBlando', 'Natural' , 'ArtificialDuro','Viva','CarnadaMuerta','NaturalNoViva','MoscaArtificial','Otros'
);

-- TABLAS
CREATE TABLE "TipoPesca" (
  "id" VARCHAR(255) PRIMARY KEY,
  "nombre" VARCHAR(50) NOT NULL,
  "descripcion" TEXT NOT NULL
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

--  DATOS BASE

INSERT INTO "Usuario" ("id", "nombre", "nivelPescador", "email") VALUES
  ('usuario1', 'Carlos Tarucha', 'Avanzado', 'carlos@example.com'),
  ('usuario2', 'Lucía Señuelera', 'Experto', 'lucia@example.com');

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
  ('tp15', 'Pesca Submarina', 'Sin caña ni reel. Uso de arpón, fusil submarino o hawaiana, practicada en apnea con snorkel o buceo.');

INSERT INTO "Especie" ("id", "nombreCientifico", "descripcion", "imagen") VALUES
('es2', 'Salminus brasiliensis',
'DORADO: Pez depredador muy combativo, conocido como el "tigre de los ríos". Habita aguas rápidas y correntosas. Se alimenta principalmente de peces pequeños y es activo durante todo el día, con picos de actividad al amanecer y atardecer. Se pesca mejor con señuelos artificiales (spinning, baitcasting, trolling) y también con carnada viva como mojarras o sabalitos. Necesita cañas potentes y reels con buen freno.', 
'uploads/dorado.png'),
('es3', 'Pseudoplatystoma corruscans',
'SURUBÍ PINTADO: Bagre de gran tamaño, cuerpo alargado con manchas características. Prefiere aguas profundas y correntosas, especialmente en grandes ríos como Paraná y Paraguay. Es nocturno, cazador de peces medianos y grandes. Se pesca de noche con carnadas naturales (anguilas, bogas chicas, morenas) al fondo, usando cañas pesadas y plomadas.', 
'uploads/surubi_pintado.png'),
('es4', 'Pseudoplatystoma reticulatum',
'SURUBÍ ATIGRADO: Similar al pintado pero con patrón reticulado. Vive en grandes ríos y prefiere zonas profundas con pozones. Cazador nocturno, se alimenta de peces y crustáceos. Técnica: pesca de fondo con carnadas vivas o muertas grandes. Equipo robusto es imprescindible.', 
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
'TARARIRA COMÚN: Depredador emboscador que vive en lagunas, arroyos y remansos con vegetación. Activa al amanecer y atardecer. Caza peces pequeños, anfibios e incluso aves. Se pesca con señuelos artificiales (ranas, paseantes, crankbaits) y carnadas vivas. Muy agresiva y combativa, requiere acero o fluorocarbono en la línea.', 
'uploads/tararira.png'),
('es11', 'Hoplias lacerdae',
'TARARIRA AZUL: De mayor tamaño que la común, habita ríos y lagunas profundas. Depredador muy agresivo. Prefiere horas bajas de luz. Técnicas: baitcasting y spinning con señuelos grandes, o carnada viva robusta.', 
'uploads/tararira_azul.png'),
('es12', 'Hoplias australis',
'TARARIRA PINTADA: Patrón moteado en el cuerpo. Vive en aguas tranquilas con vegetación abundante. Es cazadora de emboscada, activa en amanecer y atardecer. Se pesca con señuelos de superficie y medias aguas, también carnadas naturales.', 
'uploads/tararira_pintada.png'),
('es13', 'Odontesthes bonariensis',
'PEJERREY BONAERENSE: Muy popular en lagunas y ríos de llanura. Vive en cardúmenes, se alimenta de zooplancton, insectos y pequeños peces. Activo en horas de sol. Se pesca con boyas y carnada natural (mojarra viva o filet). Equipo liviano de flote es lo clásico.', 
'uploads/pejerrey.png'),
('es14', 'Odontesthes hatcheri',
'PEJERREY PATAGÓNICO: Adaptado a aguas frías de lagos y ríos de la Patagonia. Vive en cardúmenes y se alimenta de invertebrados y peces. Se pesca con boyas y mosca. Horarios: pleno día, mejor en mañanas despejadas.', 
'uploads/pejerrey_patagonico.png'),
('es15', 'Odontesthes nigricans',
'PEJERREY FUEGUINO: Habita aguas frías del extremo sur. Dieta basada en invertebrados acuáticos. Se pesca con moscas, pequeñas cucharas y carnada natural. Activo durante el día. Requiere equipos livianos.', 
'uploads/pejerrey_fueguino.png'),
('es16', 'Percichthys trucha',
'PERCA CRIOLLA: Habita lagos y ríos fríos de la Patagonia. Depredador de peces pequeños y crustáceos. Activa en horas crepusculares. Se pesca con spinning y mosca. Carne muy apreciada.', 
'uploads/perca_criolla.png'),
('es17', 'Oncorhynchus mykiss',
'TRUCHA ARCOÍRIS: Introducida, muy deportiva. Vive en aguas frías y oxigenadas. Se alimenta de insectos, crustáceos y peces pequeños. Muy activa en amanecer y atardecer. Se pesca con mosca, spinning y cucharas. Excelente combatividad.', 
'uploads/trucha_arcoiris.png'),
('es18', 'Salmo trutta',
'TRUCHA MARRÓN: Especie introducida, muy combativa y desconfiada. Se alimenta de insectos, crustáceos y peces. Activa en atardecer y noches nubladas. Se pesca con mosca y spinning. Alcanzan gran tamaño en ambientes adecuados.', 
'uploads/trucha_marron.png'),
('es19', 'Salvelinus fontinalis',
'TRUCHA DE ARROYO: Originaria de Norteamérica, introducida en aguas frías de Argentina. Prefiere arroyos y ríos serranos. Se alimenta de insectos, larvas y pequeños peces. Activa en horas frescas del día. Se pesca con mosca seca y ninfas.', 
'uploads/trucha_arroyo.png'),
('es20', 'Pimelodus albicans',
'BAGRE BLANCO: Muy común en ríos grandes. Se alimenta de pequeños peces, moluscos y detritos. Activo de noche, aunque también pica de día. Se pesca al fondo con lombrices, tripa de pollo o masa. Ideal con líneas pesadas y plomos. Muy buscado por pescadores de costa.', 
'uploads/bagre_blanco.png');

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
  ('nc9', 'es3', 'Surubí pintado'),
  ('nc10', 'es3', 'Bagre pintado'),

  -- 4. Surubí atigrado (Pseudoplatystoma reticulatum)
  ('nc11', 'es4', 'Surubí atigrado'),
  ('nc12', 'es4', 'Bagre atigrado'),

  -- 5. Manguruyú (Zungaro zungaro)
  ('nc13', 'es5', 'Manguruyú'),
  ('nc14', 'es5', 'Manguruyú gigante'),

  -- 6. Pacú (Piaractus mesopotamicus)
  ('nc15', 'es6', 'Pacú'),
  ('nc16', 'es6', 'Pacú negro'),
  ('nc17', 'es6', 'Pacuí'),

  -- 7. Pacú reloj (Myloplus rubripinnis)
  ('nc18', 'es7', 'Pacú reloj'),
  ('nc19', 'es7', 'Pacuí reloj'),

  -- 8. Pacú chato (Colossoma mitrei)
  ('nc20', 'es8', 'Pacú chato'),
  ('nc21', 'es8', 'Chato'),

  -- 9. Boga (Megaleporinus obtusidens)
  ('nc22', 'es9', 'Boga'),
  ('nc23', 'es9', 'Boga del Paraná'),
  ('nc24', 'es9', 'Leporinus'),

  -- 10. Sábalo (Prochilodus lineatus)
  ('nc25', 'es10', 'Sábalo'),
  ('nc26', 'es10', 'Saboga'),

  -- 11. Tararira azul (Hoplias lacerdae)
  ('nc27', 'es11', 'Tararira azul'),

  -- 12. Tararira pintada (Hoplias australis)
  ('nc28', 'es12', 'Tararira pintada'),

  -- 13. Pejerrey bonaerense (Odontesthes bonariensis)
  ('nc29', 'es13', 'Pejerrey bonaerense'),
  ('nc30', 'es13', 'Peje'),

  -- 14. Pejerrey patagónico (Odontesthes hatcheri)
  ('nc31', 'es14', 'Pejerrey patagónico'),

  -- 15. Pejerrey fueguino (Odontesthes nigricans)
  ('nc32', 'es15', 'Pejerrey fueguino'),

  -- 16. Perca criolla (Percichthys trucha)
  ('nc33', 'es16', 'Perca criolla'),

  -- 17. Trucha arcoíris (Oncorhynchus mykiss)
  ('nc34', 'es17', 'Trucha arcoíris'),

  -- 18. Trucha marrón (Salmo trutta)
  ('nc35', 'es18', 'Trucha marrón'),

  -- 19. Trucha de arroyo (Salvelinus fontinalis)
  ('nc36', 'es19', 'Trucha de arroyo'),

  -- 20. Bagre blanco (Pimelodus albicans)
  ('nc37', 'es20', 'Bagre blanco');


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
  ('c30', 'Camarón vivo', 'Viva', 'Camarón de agua dulce usado como carnada.');

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
('etp15', 'es3', 'tp6', 'Trolling: Señuelos pesados arrastrados desde embarcación en ríos grandes. Línea 0,40 mm, reel rotativo grande. Horario: mañana y tarde, aguas profundas y lentas.');

INSERT INTO "Spot" (
  "id", "idUsuario", "idUsuarioActualizo", "nombre", "estado", "descripcion", "ubicacion", "fechaPublicacion", "fechaActualizacion", "imagenPortada"
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
  'uploads/taruchini.png'
);


INSERT INTO "SpotEspecie" ("id", "idSpot", "idEspecie") VALUES
  ('se1', 'SpotSecreto', 'es1'),  
  ('se2', 'SpotSecreto', 'es13'), 
  ('se3', 'SpotSecreto', 'es2'); 


INSERT INTO "SpotTipoPesca" ("id", "idSpot", "idTipoPesca") VALUES
  ('stp1', 'SpotSecreto', 'tp1'), 
  ('stp2', 'SpotSecreto', 'tp4');


INSERT INTO "SpotCarnadaEspecie" ("id", "idSpot", "idEspecie", "idCarnada") VALUES
  ('sce1', 'SpotSecreto', 'es1', 'c1'),  
  ('sce2', 'SpotSecreto', 'es1', 'c28'), 
  ('sce3', 'SpotSecreto', 'es15', 'c20'); 



