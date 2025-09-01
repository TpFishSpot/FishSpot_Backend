-- SCRIPT CORREGIDO: SOLO LOS NOMBRES COMUNES ARREGLADOS
-- Ejecutar después del script principal

-- Primero eliminar los nombres comunes problemáticos
DELETE FROM "NombreComunEspecie" WHERE "idEspecie" IN ('es11', 'es13', 'es17', 'es18', 'es19', 'es20');

-- Insertar los nombres comunes correctos
INSERT INTO "NombreComunEspecie" ("id", "idEspecie", "nombre") VALUES
  -- 11. Tararira azul (Hoplias lacerdae) - es11
  ('nc_ta1', 'es11', 'Tararira azul'),
  ('nc_ta2', 'es11', 'Tararira grande'),
  ('nc_ta3', 'es11', 'Lobito azul'),

  -- 13. Pejerrey bonaerense (Odontesthes bonariensis) - es13
  ('nc_pej1', 'es13', 'Pejerrey'),
  ('nc_pej2', 'es13', 'Pejerrey bonaerense'),
  ('nc_pej3', 'es13', 'Peje'),

  -- 17. Trucha arcoíris (Oncorhynchus mykiss) - es17
  ('nc_tra1', 'es17', 'Trucha arcoíris'),
  ('nc_tra2', 'es17', 'Rainbow trout'),

  -- 18. Trucha marrón (Salmo trutta) - es18
  ('nc_trm1', 'es18', 'Trucha marrón'),
  ('nc_trm2', 'es18', 'Brown trout'),

  -- 19. Trucha de arroyo (Salvelinus fontinalis) - es19
  ('nc_trar1', 'es19', 'Trucha de arroyo'),
  ('nc_trar2', 'es19', 'Brook trout'),

  -- 20. Bagre blanco (Pimelodus albicans) - es20
  ('nc_bb1', 'es20', 'Bagre blanco'),
  ('nc_bb2', 'es20', 'Bagre'),
  ('nc_bb3', 'es20', 'Bagre criollo');
