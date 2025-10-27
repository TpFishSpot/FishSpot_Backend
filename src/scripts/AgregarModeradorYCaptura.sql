INSERT INTO "UsuarioRol" ("usuarioId", "rolId") VALUES
  ('wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'rol2')
ON CONFLICT DO NOTHING;

INSERT INTO "Captura" (
  "id", "idUsuario", "especieId", "fecha", "ubicacion", "spotId", "latitud", "longitud", 
  "peso", "tamanio", "carnada", "tipoPesca", "foto", "notas", "clima", "horaCaptura", 
  "fechaCreacion", "fechaActualizacion"
) VALUES

('cap022', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es1', '2024-11-15', 'Entre juncos cerca de la costa', 
 'SpotSecreto', -25.695350, -54.444610, 2.8, 48,
 'Rana artificial verde', 'Spinning', 'uploads/taruchini.png',
 'Tararira al amanecer. Ataque explosivo entre la vegetación densa.',
 'Despejado, sin viento', '06:15:00', NOW(), NOW()),

('cap023', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es1', '2024-10-22', 'Zona de troncos sumergidos', 
 'SpotSecreto', -25.695400, -54.444580, 3.5, 53,
 'Mojarra viva', 'Pesca a la Cueva', 'uploads/taruchini.png',
 'Hermosa tararira sacada de bajo un tronco. Carnada viva funcionó perfecto.',
 'Nublado, viento suave', '18:45:00', NOW(), NOW()),

('cap024', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es1', '2024-09-08', 'Desembocadura del arrollito', 
 'SpotSecreto', -25.695320, -54.444650, 4.2, 56,
 'Paseante rojo', 'Técnica del Tarucho', 'uploads/taruchini.png',
 'Mejor captura de la temporada. Pelea de casi 10 minutos en primavera.',
 'Despejado, cálido', '07:30:00', NOW(), NOW()),

('cap025', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es20', '2024-11-20', 'Pozón profundo del arroyo', 
 'SpotSecreto', -25.695380, -54.444620, 1.2, 35,
 'Lombriz', 'Variada', 'uploads/bagre_blanco.png',
 'Bagre blanco nocturno. Muy activo con luna llena.',
 'Despejado, noche clara', '22:15:00', NOW(), NOW()),

('cap026', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es20', '2024-10-05', 'Remanso cerca de piedras', 
 'SpotSecreto', -25.695360, -54.444590, 0.8, 28,
 'Tripa de pollo', 'Pesca de Fondo', 'uploads/bagre_blanco.png',
 'Bagre capturado al atardecer. Carnada clásica que nunca falla.',
 'Nublado, fresco', '19:30:00', NOW(), NOW()),

('cap027', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es20', '2024-12-02', 'Fondo del canal principal', 
 'SpotSecreto', -25.695340, -54.444600, 1.5, 38,
 'Hígado de pollo', 'Variada', 'uploads/bagre_blanco.png',
 'Bagre de buen tamaño. Verano arranca bien en el spot.',
 'Caluroso, despejado', '21:45:00', NOW(), NOW()),

('cap028', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es21', '2024-11-10', 'Pozón con troncos', 
 'SpotSecreto', -25.695370, -54.444640, 0.9, 30,
 'Lombriz', 'Pesca de Fondo', 'uploads/bagre_sapo.png',
 'Bagre sapo nocturno. Siempre están en los rincones rocosos.',
 'Nublado, húmedo', '23:00:00', NOW(), NOW()),

('cap029', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es25', '2024-10-18', 'Orilla con vegetación', 
 'SpotSecreto', -25.695330, -54.444570, 0.15, 12,
 'Lombriz pequeña', 'Mojarrero', 'uploads/mojarra.png',
 'Mojarra para usar como carnada viva. Muy abundantes en esta época.',
 'Soleado, viento suave', '10:30:00', NOW(), NOW()),

('cap030', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es25', '2024-09-25', 'Zona de juncos', 
 'SpotSecreto', -25.695355, -54.444585, 0.12, 11,
 'Bolita de pan', 'Mojarrero', 'uploads/mojarra.png',
 'Mojarras para carnada. Pan siempre funciona bien.',
 'Despejado, primavera', '11:15:00', NOW(), NOW()),

('cap031', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es25', '2024-12-08', 'Canal secundario', 
 'SpotSecreto', -25.695365, -54.444595, 0.18, 13,
 'Lombriz', 'Mojarrero', 'uploads/mojarra.png',
 'Mojarra de buen tamaño. Verano trae las más grandes.',
 'Caluroso, sin viento', '09:45:00', NOW(), NOW()),

('cap032', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es32', '2024-11-05', 'Aguas poco profundas', 
 'SpotSecreto', -25.695345, -54.444575, 0.08, 9,
 'Lombriz', 'Mojarrero', 'uploads/dientudo.png',
 'Dientudo muy combativo. Equipo liviano es clave para estos peces.',
 'Soleado, primavera', '16:20:00', NOW(), NOW()),

('cap033', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es32', '2024-10-30', 'Corriente suave', 
 'SpotSecreto', -25.695335, -54.444605, 0.10, 10,
 'Bolita de masa', 'Mojarrero', 'uploads/dientudo.png',
 'Dientudo en cardumen. Había varios atacando la carnada.',
 'Nublado, fresco', '15:45:00', NOW(), NOW()),

('cap034', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es32', '2024-09-15', 'Cerca de la desembocadura', 
 'SpotSecreto', -25.695325, -54.444615, 0.09, 9,
 'Lombriz pequeña', 'Mojarrero', 'uploads/dientudo.png',
 'Dientudo al mediodía. Primavera trae buena actividad.',
 'Soleado, viento moderado', '12:30:00', NOW(), NOW()),

('cap035', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es1', '2024-12-15', 'Estructura con ramas', 
 'SpotSecreto', -25.695390, -54.444560, 3.2, 50,
 'Señuelo tipo popper', 'Spinning', 'uploads/taruchini.png',
 'Tararira de verano. Ataque en superficie espectacular.',
 'Caluroso, despejado', '06:45:00', NOW(), NOW()),

('cap036', 'wEYvKSOGSqcriUpIUEbx6gDVmJv2', 'es20', '2024-09-20', 'Fondo barroso', 
 'SpotSecreto', -25.695375, -54.444625, 1.1, 33,
 'Masa con ajo', 'Pesca de Fondo', 'uploads/bagre_blanco.png',
 'Bagre blanco de primavera. Masa con ajo nunca falla.',
 'Nublado, fresco', '20:15:00', NOW(), NOW());