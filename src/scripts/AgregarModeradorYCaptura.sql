-- SCRIPT PARA AGREGAR ROL MODERADOR Y CAPTURA A USUARIO EXISTENTE
INSERT INTO "UsuarioRol" ("usuarioId", "rolId") VALUES
  ('Dg5rIRf4FLRXcQ5BKwZJj5OFlCG2', 'rol2')

ON CONFLICT DO NOTHING;
INSERT INTO "Captura" (
  "id", "idUsuario", "especieId", "fecha", "ubicacion", "peso", "longitud", 
  "carnada", "tipoPesca", "foto", "notas", "clima", "horaCaptura", 
  "fechaCreacion", "fechaActualizacion"
) VALUES
('cap021', 'Dg5rIRf4FLRXcQ5BKwZJj5OFlCG2', 'es1', '2024-03-25', 'Desembocadura del arrollito', 3, 52,
 'Rana artificial verde', 'Spinning', 'uploads/taruchini.png',
 'Tararira espectacular en el spot secreto. Ataque explosivo al amanecer entre los juncos. Técnica perfecta.',
 'Despejado, sin viento', '06:15:00', NOW(), NOW());


