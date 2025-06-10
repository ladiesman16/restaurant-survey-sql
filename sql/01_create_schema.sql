
BEGIN;

-- Creamos esta extencion para poder utilizar tildes libremente
CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE SCHEMA IF NOT EXISTS restaurant;
SET search_path TO restaurant, public;

CREATE DOMAIN IF NOT EXISTS calificacion_1_5 AS SMALLINT
      CHECK (VALUE BETWEEN 1 AND 5);

CREATE TABLE IF NOT EXISTS encuesta_raw (
    id_respuesta      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    marca_tiempo      TIMESTAMPTZ,
    sexo_txt               TEXT,
    rango_edad_txt         TEXT,
    barrio_txt             TEXT,
    frecuencia_visita_txt  TEXT,
    motivo_principal_txt   TEXT,
    aspecto_valorado_txt   TEXT,
    calif_platos_txt       TEXT,
    calif_servicio_txt     TEXT,
    calif_atmosfera_txt    TEXT,
    calif_ambientacion_txt TEXT,
    menu_favorito_txt      TEXT,
    recomendacion_txt      TEXT,
    problemas_txt          TEXT,
    extra_txt              TEXT,
    interes_eventos_txt    TEXT,
    calif_global_txt       TEXT,
    email_txt              TEXT
);

-- Creamos tablas de dimension
CREATE TABLE IF NOT EXISTS dim_sexo (
    id_sexo SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sexo    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_rango_edad (
    id_rango SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rango    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_barrio (
    id_barrio SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    barrio    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_frecuencia_visita (
    id_frecuencia SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    frecuencia    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_motivo_principal (
    id_motivo SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    motivo    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_aspecto_valorado (
    id_aspecto SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aspecto    TEXT NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS encuesta_resumen (
    id_respuesta   INTEGER PRIMARY KEY REFERENCES encuesta_raw(id_respuesta),
    marca_tiempo   TIMESTAMPTZ NOT NULL,

    id_sexo        SMALLINT REFERENCES dim_sexo,
    id_rango       SMALLINT REFERENCES dim_rango_edad,
    id_barrio      SMALLINT REFERENCES dim_barrio,
    id_frecuencia  SMALLINT REFERENCES dim_frecuencia_visita,
    id_motivo      SMALLINT REFERENCES dim_motivo_principal,
    id_aspecto     SMALLINT REFERENCES dim_aspecto_valorado,

    calif_platos     calificacion_1_5,
    calif_servicio   calificacion_1_5,
    calif_atmosfera  calificacion_1_5,
    calif_ambientacion calificacion_1_5,
    calif_global     calificacion_1_5,

    menu_favorito    TEXT,
    recomendacion    TEXT,
    problemas        TEXT,
    extra            TEXT,
    interes_eventos  TEXT
);

CREATE INDEX IF NOT EXISTS idx_resumen_fecha   ON encuesta_resumen (marca_tiempo);
CREATE INDEX IF NOT EXISTS idx_resumen_barrio  ON encuesta_resumen (id_barrio);
CREATE INDEX IF NOT EXISTS idx_resumen_sexo    ON encuesta_resumen (id_sexo);

COMMIT;
