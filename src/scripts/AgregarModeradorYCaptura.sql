INSERT INTO "UsuarioRol" ("usuarioId", "rolId") VALUES
  ('wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'rol2')
ON CONFLICT DO NOTHING;

INSERT INTO "Captura" (
  "id", "idUsuario", "especieId", "fecha", "ubicacion", "spotId", "latitud", "longitud", 
  "peso", "tamanio", "carnada", "tipoPesca", "foto", "notas", "clima", "horaCaptura", 
  "fechaCreacion", "fechaActualizacion"
) VALUES
('cap022', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es1', '2024-03-25', 'Desembocadura del arrollito', 
 'spot1', -25.695350, -54.444610, 3, 52,
 'Rana artificial verde', 'Spinning', 'uploads/taruchini.png',
 'Tararira espectacular en el spot secreto. Ataque explosivo al amanecer entre los juncos. Técnica perfecta.',
 'Despejado, sin viento', '06:15:00', NOW(), NOW());