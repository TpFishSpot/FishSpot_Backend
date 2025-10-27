-- modifico la tabla para que permita respuestas

ALTER TABLE "Comentario"
ADD COLUMN "idComentarioPadre" VARCHAR(255);

ALTER TABLE "Comentario"
ALTER COLUMN "contenido" TYPE VARCHAR(255);

ALTER TABLE "Comentario"
ADD CONSTRAINT "fk_comentario_padre"
FOREIGN KEY ("idComentarioPadre")
REFERENCES "Comentario"("id")
ON DELETE CASCADE;
