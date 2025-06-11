-- Analisis BI

-- Participación por barrio
SELECT db.barrio_normalizado, COUNT(*) AS respuestas
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
GROUP BY db.barrio_normalizado

ORDER BY COUNT(*) DESC;
Satisfaccion promedio por platos
SELECT db.barrio_normalizado, AVG(rl.calif_platos) AS promedio_satisfaccion
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
GROUP BY db.barrio_normalizado
ORDER BY COUNT(*) DESC;

-- Interés en eventos por barrio
SELECT db.barrio_normalizado, 
       COUNT(*) FILTER (WHERE rl.interes_eventos ILIKE '%sí%' OR rl.interes_eventos ILIKE '%si%') * 1.0 / COUNT(*) AS porcentaje_interes
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
GROUP BY db.barrio_normalizado
ORDER BY COUNT(*) DESC;

-- Edades de los clientes
SELECT ed.edad, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_edad ed ON rl.id_edad = ed.id_edad
GROUP BY ed.edad
ORDER BY cantidad DESC;

-- Motivos de visita más comunes
SELECT mv.motivo, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_motivo_visita mv ON rl.id_motivo = mv.id_motivo
GROUP BY mv.motivo
ORDER BY cantidad DESC;

-- Del barrio más visitado "carrasco" queremos ver a que vienen más comunmente
SELECT mv.motivo, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_motivo_visita mv ON rl.id_motivo = mv.id_motivo
WHERE db.barrio_normalizado = 'Carrasco'
GROUP BY db.barrio_normalizado, mv.motivo
ORDER BY cantidad DESC;

-- Frecuencia de nuestros clientes
SELECT fv.frecuencia, COUNT(*) AS cantidad
FROM encuesta.respuestas_limpias rl
JOIN encuesta.dim_barrio db ON rl.id_barrio = db.id_barrio
JOIN encuesta.dim_frecuencia_visita fv ON rl.id_frecuencia = fv.id_frecuencia
GROUP BY fv.frecuencia
ORDER BY cantidad DESC;
