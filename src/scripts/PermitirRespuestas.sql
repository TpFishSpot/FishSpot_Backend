-- modifico la tabla para que permita respuestas

ALTER TABLE "Comentario"
ADD COLUMN "idComentarioPadre" VARCHAR(255);

ALTER TABLE "Comentario"
ADD COLUMN "idCaptura" VARCHAR(255);

ALTER TABLE "Comentario"
ALTER COLUMN "contenido" TYPE VARCHAR(255);

ALTER TABLE "Comentario"
ALTER COLUMN "idSpot" DROP NOT NULL;

ALTER TABLE "Comentario"
ADD CONSTRAINT "fk_comentario_padre"
FOREIGN KEY ("idComentarioPadre")
REFERENCES "Comentario"("id")
ON DELETE CASCADE;

ALTER TABLE "Comentario"
ADD CONSTRAINT "fk_comentario_captura"
FOREIGN KEY ("idCaptura")
REFERENCES "Captura"("id")
ON DELETE CASCADE;
