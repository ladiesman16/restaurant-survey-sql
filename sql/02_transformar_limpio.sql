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

# Normalizamos los datos de barrios para que esten bien organizados

INSERT INTO encuesta.dim_barrio (barrio)
SELECT DISTINCT barrio FROM encuesta.respuestas_raw WHERE barrio IS NOT NULL
ON CONFLICT DO NOTHING;

UPDATE encuesta.dim_barrio
SET barrio_normalizado = CASE
    -- MALDONADO y Punta del Este
    WHEN lower(barrio) LIKE '%punta del este%' OR lower(barrio) LIKE '%maldonado%' OR lower(barrio) LIKE '%san francisco%' OR lower(barrio) LIKE '%pinares%' THEN 'Maldonado'
    -- CANELONES: La Floresta, Atlántida, Parque del Plata, Salinas, Pinamar, Colonia Valdense, Barros Blancos, Tala
    WHEN lower(barrio) LIKE '%la floresta%' OR lower(barrio) LIKE '%tlantida%' OR lower(barrio) LIKE '%parque del plata%' OR lower(barrio) LIKE '%salinas%' OR lower(barrio) LIKE '%pinamar%' OR lower(barrio) LIKE '%colonia valdense%' OR lower(barrio) LIKE '%barros blancos%' OR lower(barrio) LIKE '%tala%' THEN 'Canelones'
    -- Ciudad de la Costa
    WHEN lower(barrio) LIKE '%ciudad de la costa%' THEN 'Ciudad de la Costa'
    -- Carrasco y variantes
    WHEN lower(barrio) LIKE '%carrasco%' OR lower(barrio) LIKE '%portones%' OR lower(barrio) LIKE '%aeropuerto%' THEN 'Carrasco'
    -- Malvin y variantes
    WHEN lower(barrio) LIKE 'malvin%' OR lower(barrio) LIKE 'malvín%' OR lower(barrio) LIKE '%parque rivera%' THEN 'Malvin'
    -- Pocitos
    WHEN lower(barrio) LIKE 'pocitos%' THEN 'Pocitos'
    -- Costa de Oro y variantes (excepto Ciudad de la Costa y Canelones ya tratados arriba)
    WHEN lower(barrio) LIKE '%lagomar%' OR lower(barrio) LIKE '%el pinar%' OR lower(barrio) LIKE '%solymar%' OR lower(barrio) LIKE '%lomas de solymar%' OR lower(barrio) LIKE '%shangril%' OR lower(barrio) LIKE '%inar' OR lower(barrio) LIKE '%ando' OR lower(barrio) LIKE '%osta de oro' THEN 'Costa de Oro'
    -- Blanqueada
    WHEN lower(barrio) LIKE '%blanqueada%' THEN 'Blanqueada'
    -- Punta Gorda
    WHEN lower(barrio) LIKE '%punta gorda%' OR lower(barrio) LIKE '%punta hirda%' THEN 'Punta Gorda'
    -- Parque Batlle
    WHEN lower(barrio) LIKE '%parque batlle%' OR lower(barrio) LIKE '%parque battle%' THEN 'Parque Batlle'
    -- Cordón
    WHEN lower(barrio) LIKE '%cordon%' OR lower(barrio) LIKE '%cordón%' THEN 'Cordón'
    -- Centro
    WHEN lower(barrio) LIKE '%centro%' THEN 'Centro'
    -- Buceo
    WHEN lower(barrio) LIKE '%buceo%' THEN 'Buceo'
    -- Sayago
    WHEN lower(barrio) LIKE '%sayago%' THEN 'Sayago'
    -- Prado
    WHEN lower(barrio) LIKE '%prado%' THEN 'Prado'
    -- Jardines
    WHEN lower(barrio) LIKE '%jardines%' THEN 'Jardines'
    -- Flor de Maroñas
    WHEN lower(barrio) LIKE '%flor de maroñas%' THEN 'Flor de Maroñas'
    -- Curva de Maroñas
    WHEN lower(barrio) LIKE '%curva de maroñas%' THEN 'Curva de Maroñas'
    -- Palermo
    WHEN lower(barrio) LIKE '%palermo%' THEN 'Palermo'
    -- Punta Carretas
    WHEN lower(barrio) LIKE '%punta carretas%' THEN 'Punta Carretas'
    -- Tres Cruces
    WHEN lower(barrio) LIKE '%tres cruces%' OR lower(barrio) LIKE '%la comercial tres cruces%' THEN 'Tres Cruces'
    -- Unión
    WHEN lower(barrio) LIKE '%union%' OR lower(barrio) LIKE '%unión%' THEN 'Unión'
    -- Parque Miramar
    WHEN lower(barrio) LIKE '%iramar%' THEN 'Parque Miramar'
    ELSE barrio
END;

COMMIT;
