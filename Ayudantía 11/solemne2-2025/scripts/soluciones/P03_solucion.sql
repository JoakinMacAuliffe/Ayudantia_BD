/* =====================================================================
   PREGUNTA 3 - SOLUCIÓN
   Liste cuántas conexiones se han realizado por día.
   ===================================================================== */

-- IDEA: conexion ya tiene la fecha separada de la hora (fecha DATE, hora SMALLINT),
--       así que basta agrupar por fecha.

SELECT fecha, COUNT(*) AS total_conexiones
FROM conexion
GROUP BY fecha
ORDER BY fecha;


/* ---------------------------------------------------------------------
   EXTRA 1: cuántos usuarios DISTINTOS se conectaron cada día
   (buena pregunta para discutir COUNT(*) vs COUNT(DISTINCT ...))
   --------------------------------------------------------------------- */
SELECT fecha,
       COUNT(*)               AS total_conexiones,
       COUNT(DISTINCT usucod) AS usuarios_distintos
FROM conexion
GROUP BY fecha
ORDER BY fecha;


/* ---------------------------------------------------------------------
   EXTRA 2: incluir también los días SIN conexiones (aparecen con 0).
   Se genera el calendario con generate_series y se hace LEFT JOIN.
   --------------------------------------------------------------------- */
SELECT dia::date AS fecha, COUNT(c.usucod) AS total_conexiones
FROM generate_series(CURRENT_DATE - 15, CURRENT_DATE, INTERVAL '1 day') AS dia
LEFT JOIN conexion c ON c.fecha = dia::date
GROUP BY dia
ORDER BY dia;


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   La pauta usa DATE(fechahora), pero en el modelo NO existe la columna
   fechahora: la tabla tiene "fecha" (date) y "hora" (smallint).
   Esa consulta falla con: column "fechahora" does not exist.
   La idea (agrupar por día) es correcta; solo hay que usar "fecha".
   --------------------------------------------------------------------- */
