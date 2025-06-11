BEGIN;

-- (1) Habilitar extensión para manejo de tildes en limpieza de datos
CREATE EXTENSION IF NOT EXISTS unaccent;

-- (2) Esquema propio para mantener ordenados los objetos
CREATE SCHEMA IF NOT EXISTS encuesta;
SET search_path TO encuesta, public;

-- (3) Dominio de puntuación 1-5, para validación centralizada
CREATE DOMAIN IF NOT EXISTS puntuacion_1_5 AS SMALLINT
      CHECK (VALUE BETWEEN 1 AND 5);

-- (4) Tabla raw: carga directa del CSV, sin transformación previa
CREATE TABLE IF NOT EXISTS respuestas_raw (
    id_respuesta        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    marca_temporal      TIMESTAMPTZ,
    sexo                TEXT,
    edad                TEXT,
    barrio              TEXT,
    frecuencia_visita   TEXT,
    motivo_visita       TEXT,
    aspecto_motivador   TEXT,
    definicion_lugar    TEXT,
    calif_platos        TEXT,
    calif_servicio      TEXT,
    calif_atmosfera     TEXT,
    sugerencia_ambiente TEXT,
    preferidos_menu     TEXT,
    desea_nuevo_menu    TEXT,
    problemas           TEXT,
    interes_eventos     TEXT,
    recomendacion       TEXT,
    puntuacion          TEXT
);

-- (5) Tablas de dimensión: para valores únicos de campos clave
CREATE TABLE IF NOT EXISTS dim_sexo (
    id_sexo SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sexo    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_edad (
    id_edad SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    edad    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_barrio (
    id_barrio SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    barrio   TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_frecuencia_visita (
    id_frecuencia SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    frecuencia    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_motivo_visita (
    id_motivo SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    motivo    TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_aspecto_motivador (
    id_aspecto SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aspecto    TEXT NOT NULL UNIQUE
);

-- (6) Tabla final limpia: respuestas estandarizadas y normalizadas
CREATE TABLE IF NOT EXISTS respuestas_limpias (
    id_respuesta      INTEGER PRIMARY KEY REFERENCES respuestas_raw(id_respuesta),
    marca_temporal    TIMESTAMPTZ NOT NULL,
    id_sexo           SMALLINT REFERENCES dim_sexo,
    id_edad           SMALLINT REFERENCES dim_edad,
    id_barrio         SMALLINT REFERENCES dim_barrio,
    id_frecuencia     SMALLINT REFERENCES dim_frecuencia_visita,
    id_motivo         SMALLINT REFERENCES dim_motivo_visita,
    id_aspecto        SMALLINT REFERENCES dim_aspecto_motivador,
    definicion_lugar  TEXT,
    calif_platos      puntuacion_1_5,
    calif_servicio    puntuacion_1_5,
    calif_atmosfera   puntuacion_1_5,
    sugerencia_ambiente TEXT,
    preferidos_menu     TEXT,
    desea_nuevo_menu    TEXT,
    problemas           TEXT,
    interes_eventos     TEXT,
    recomendacion       TEXT,
    puntuacion          puntuacion_1_5
);

-- (7) Índices útiles para análisis y BI
CREATE INDEX IF NOT EXISTS idx_limpias_fecha   ON respuestas_limpias (marca_temporal);
CREATE INDEX IF NOT EXISTS idx_limpias_barrio  ON respuestas_limpias (id_barrio);
CREATE INDEX IF NOT EXISTS idx_limpias_sexo    ON respuestas_limpias (id_sexo);

COMMIT;
