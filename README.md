# Restaurant-Survey-SQL

## Proyecto SQL - Análisis de Encuesta de Satisfacción de un Restaurante

Este proyecto demuestra cómo cargar, limpiar, transformar y analizar una encuesta de satisfacción usando únicamente SQL en PostgreSQL. El flujo es totalmente reproducible.

---

### 1. Carga y estructuración de datos

- Los datos originales provienen de un archivo CSV de respuestas de clientes.
- El script `01_crear_esquema.sql` crea la estructura en la base:
  - Tabla raw (`respuestas_raw`) para los datos originales, los importamos directo omitiendo columnas que ocasionaban problemas
  - Tablas de dimensión para cada categoría relevante
  - Tabla final (`respuestas_limpias`) con datos normalizados y validados

---

### 2. Limpieza y normalización

- Con el script `02_transformar_limpio.sql`:
  - Se poblan las tablas de dimensión con los valores únicos de cada campo categórico (sexo, edad, barrio, motivo de visita, etc.).
  - Se transforma cada respuesta de texto en claves numéricas usando JOIN.
  - Se convierten las columnas de calificación de texto a valores numéricos (escala 1-5) usando lógica de mapeo.

---

#### Ejemplo de mapeo de texto a número:

| Texto en encuesta                | Valor numérico |
|----------------------------------|:--------------:|
| Excelente                        |       5        |
| Bueno                            |       4        |
| Aceptable                        |       3        |
| Regular                          |       2        |
| Insatisfactorio / No me gusta    |       1        |
| *(otros valores o vacíos quedan como NULL)* |   |

---

#### Ejemplo de lógica SQL:

```sql
CASE
  WHEN calif_platos ILIKE 'Excelente' THEN 5
  WHEN calif_platos ILIKE 'Bueno' THEN 4
  WHEN calif_platos ILIKE 'Aceptable' THEN 3
  WHEN calif_platos ILIKE 'Regular' THEN 2
  ELSE NULL
END
```

## Agrupación y Normalización de Barrios
Para obtener análisis más significativos y evitar la dispersión de respuestas por variantes mínimas en los nombres de los barrios, se realizó una agrupación y normalización de las respuestas del campo “barrio”.

Por ejemplo:

“Carrasco”, “Carrasco Norte”, “Barra de Carrasco”, “Portones”, “Paso Carrasco”, “San José de Carrasco”, “Colinas de Carrasco”, “La Cruz de Carrasco” → Carrasco

“Malvín”, “Malvín Norte”, “Malvin Norte (Parque Rivera)”, “Malvín Alto”, “Malvín Sur” → Malvín

“Blanqueada”, “La Blanqueada”, “La Blanqueqda” → Blanqueada

“Parque Batlle”, “Parque Battle” → Parque Batlle

“Pocitos”, “Pocitos Nuevo” → Pocitos

“Parque Miramar”, “P Miramar” → Parque Miramar

“Punta Gorda”, “Punta Hirda” → Punta Gorda

“Lagomar”, “Lagomar, Canelones” → Lagomar

“Costa de Oro”, “El Pinar”, “El Pinar, Costa de Oro”, “Pinamar - Costa de Oro”, “Solymar”, “Lomas de Solymar”, “Tala - Canelones”, “Costa de Oro - Pinamar” → Costa de Oro

(Otras respuestas menos frecuentes se dejan como están para mantener su identidad local.)

# SQL utilizado para la normalización
```sql
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
```

# Ejemplo de análisis BI: Satisfacción y participación de los clientes (Analísis Básico)
Estas consultas permiten identificar oportunidades de mejora y segmentar acciones de marketing según la zona o satisfacción del cliente. En todos los ordene por cantidad de respuestas

### Participación por barrio
```sql
SELECT db.barrio_normalizado, COUNT(*) AS respuestas
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
GROUP BY db.barrio_normalizado
ORDER BY COUNT(*) DESC;
```
### Satisfaccion promedio por platos
```sql
SELECT db.barrio_normalizado, AVG(rl.calif_platos) AS promedio_satisfaccion
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
GROUP BY db.barrio_normalizado
ORDER BY COUNT(*) DESC;
```
### Interés en eventos por barrio
```sql
SELECT db.barrio_normalizado, 
       COUNT(*) FILTER (WHERE rl.interes_eventos ILIKE '%sí%' OR rl.interes_eventos ILIKE '%si%') * 1.0 / COUNT(*) AS porcentaje_interes
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
GROUP BY db.barrio_normalizado
ORDER BY COUNT(*) DESC;
```
### Edades de los clientes
```sql
SELECT ed.edad, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_edad ed ON rl.id_edad = ed.id_edad
GROUP BY ed.edad
ORDER BY cantidad DESC;
```
### Motivos de visita más comunes
```sql
SELECT mv.motivo, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_motivo_visita mv ON rl.id_motivo = mv.id_motivo
GROUP BY mv.motivo
ORDER BY cantidad DESC;
```
### Del barrio más visitado "carrasco" queremos ver a que vienen más comunmente
```sql
SELECT mv.motivo, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_motivo_visita mv ON rl.id_motivo = mv.id_motivo
WHERE db.barrio_normalizado = 'Carrasco'
GROUP BY db.barrio_normalizado, mv.motivo
ORDER BY cantidad DESC;
```
### Frecuencia de nuestros clientes
```sql
SELECT fv.frecuencia, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_frecuencia_visita fv ON rl.id_frecuencia = fv.id_frecuencia
GROUP BY fv.frecuencia
ORDER BY cantidad DESC;
```
