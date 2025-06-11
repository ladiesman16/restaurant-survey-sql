BEGIN;

-- Poblar tablas de dimensión (igual que antes)
INSERT INTO encuesta.dim_sexo (sexo)
SELECT DISTINCT sexo FROM encuesta.respuestas_raw WHERE sexo IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO encuesta.dim_edad (edad)
SELECT DISTINCT edad FROM encuesta.respuestas_raw WHERE edad IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO encuesta.dim_barrio (barrio)
SELECT DISTINCT barrio FROM encuesta.respuestas_raw WHERE barrio IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO encuesta.dim_frecuencia_visita (frecuencia)
SELECT DISTINCT frecuencia_visita FROM encuesta.respuestas_raw WHERE frecuencia_visita IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO encuesta.dim_motivo_visita (motivo)
SELECT DISTINCT motivo_visita FROM encuesta.respuestas_raw WHERE motivo_visita IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO encuesta.dim_aspecto_motivador (aspecto)
SELECT DISTINCT aspecto_motivador FROM encuesta.respuestas_raw WHERE aspecto_motivador IS NOT NULL
ON CONFLICT DO NOTHING;

-- Poblar tabla respuestas_limpias, mapeando textos a números
INSERT INTO encuesta.respuestas_limpias (
    id_respuesta, marca_temporal, id_sexo, id_edad, id_barrio, id_frecuencia, id_motivo, id_aspecto,
    definicion_lugar, calif_platos, calif_servicio, calif_atmosfera, sugerencia_ambiente,
    preferidos_menu, desea_nuevo_menu, problemas, interes_eventos, recomendacion, puntuacion
)
SELECT
    r.id_respuesta,
    r.marca_temporal::timestamptz,
    s.id_sexo,
    e.id_edad,
    b.id_barrio,
    f.id_frecuencia,
    m.id_motivo,
    a.id_aspecto,
    r.definicion_lugar,

    -- calif_platos: texto a número
    CASE
      WHEN r.calif_platos ILIKE 'Excelente' THEN 5
      WHEN r.calif_platos ILIKE 'Bueno' THEN 4
      WHEN r.calif_platos ILIKE 'Aceptable' THEN 3
      WHEN r.calif_platos ILIKE 'Regular' THEN 2
      ELSE NULL
    END::encuesta.puntuacion_1_5,

    -- calif_servicio: texto a número
    CASE
      WHEN r.calif_servicio ILIKE 'Excepcional: el personal es amable, atento y servicial' THEN 5
      WHEN r.calif_servicio ILIKE 'Bueno: en general estoy satisfecho con el servicio' THEN 4
      WHEN r.calif_servicio ILIKE 'Aceptable: podría mejorar en algunos aspectos' THEN 3
      WHEN r.calif_servicio ILIKE 'Insatisfactorio: el servicio necesita una mejora significativa' THEN 1
      ELSE NULL
    END::encuesta.puntuacion_1_5,

    -- calif_atmosfera: texto a número
    CASE
      WHEN r.calif_atmosfera ILIKE 'Me encanta, es un ambiente acogedor y agradable' THEN 5
      WHEN r.calif_atmosfera ILIKE 'No me importa mucho, lo importante es la comida' THEN 3
      WHEN r.calif_atmosfera ILIKE 'Es agradable pero podría mejorarse en ciertos aspectos' THEN 2
      WHEN r.calif_atmosfera ILIKE 'No me gusta, creo que necesita un rediseño' THEN 1
      ELSE NULL
    END::encuesta.puntuacion_1_5,

    r.sugerencia_ambiente,
    r.preferidos_menu,
    r.desea_nuevo_menu,
    r.problemas,
    r.interes_eventos,
    r.recomendacion,

    -- puntuacion: SOLO si está entre 1 y 5, si no NULL
    CASE
      WHEN r.puntuacion ~ '^[1-5]$' THEN r.puntuacion::smallint
      ELSE NULL
    END::encuesta.puntuacion_1_5

FROM encuesta.respuestas_raw r
LEFT JOIN encuesta.dim_sexo s ON r.sexo = s.sexo
LEFT JOIN encuesta.dim_edad e ON r.edad = e.edad
LEFT JOIN encuesta.dim_barrio b ON r.barrio = b.barrio
LEFT JOIN encuesta.dim_frecuencia_visita f ON r.frecuencia_visita = f.frecuencia
LEFT JOIN encuesta.dim_motivo_visita m ON r.motivo_visita = m.motivo
LEFT JOIN encuesta.dim_aspecto_motivador a ON r.aspecto_motivador = a.aspecto;

COMMIT;
