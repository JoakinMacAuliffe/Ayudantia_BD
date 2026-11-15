/* =====================================================================
   PREGUNTA 6 - SOLUCIÓN
   Reporte que por cada departamento muestre la cantidad de conexiones
   totales de cada usuario junto con el número de intentos fallidos que
   lleva a la fecha.
   ===================================================================== */

-- IDEA: departamento -> usuario -> (conexion, intentosfallidos)
--  * LEFT JOIN a conexion e intentosfallidos: un usuario sin conexiones o
--    sin fallos igual debe aparecer (con 0).
--  * El número de intentos es la COLUMNA intentos, no la cantidad de filas.
--  * CUIDADO: si se hace JOIN con conexion e intentosfallidos a la vez,
--    la fila de intentos se repite una vez por conexión (ver la trampa abajo).

-- Solución 1: subconsultas escalares (no hay multiplicación de filas)
SELECT d.depnom,
       u.usucod,
       u.usunom,
       (SELECT COUNT(*) FROM conexion c
         WHERE c.usucod = u.usucod)                          AS total_conexiones,
       COALESCE((SELECT SUM(i.intentos) FROM intentosfallidos i
                  WHERE i.usucod = u.usucod), 0)             AS intentos_fallidos
FROM departamento d
JOIN usuario u ON u.depcod = d.depcod
ORDER BY d.depnom, u.usunom;


-- Solución 2: GROUP BY con LEFT JOIN
--  COUNT(c.usucod) cuenta solo filas con conexión (no cuenta NULLs).
--  Como intentosfallidos tiene a lo más 1 fila por usuario, MAX(i.intentos)
--  devuelve ese valor aunque la fila se repita por el JOIN con conexion.
SELECT d.depnom,
       u.usucod,
       u.usunom,
       COUNT(c.usucod)              AS total_conexiones,
       COALESCE(MAX(i.intentos), 0) AS intentos_fallidos
FROM departamento d
JOIN usuario u               ON u.depcod = d.depcod
LEFT JOIN conexion c         ON c.usucod = u.usucod
LEFT JOIN intentosfallidos i ON i.usucod = u.usucod
GROUP BY d.depnom, u.usucod, u.usunom
ORDER BY d.depnom, u.usunom;


/* ---------------------------------------------------------------------
   LA TRAMPA: SUM(i.intentos) con los dos JOIN.
   Mira a Felipe Araya: tiene 2 intentos, pero acá sale 2 x (nº de conexiones).
   --------------------------------------------------------------------- */
SELECT u.usunom,
       COUNT(c.usucod)  AS total_conexiones,
       SUM(i.intentos)  AS intentos_MAL_CALCULADOS,
       MAX(i.intentos)  AS intentos_reales
FROM usuario u
LEFT JOIN conexion c         ON c.usucod = u.usucod
LEFT JOIN intentosfallidos i ON i.usucod = u.usucod
WHERE i.usucod IS NOT NULL
GROUP BY u.usunom
ORDER BY u.usunom;


/* ---------------------------------------------------------------------
   EXTRA: mostrar también departamentos sin usuarios (Gerencia) y una
   fila de subtotal por departamento con GROUPING SETS.
   --------------------------------------------------------------------- */
WITH por_usuario AS (
    SELECT d.depnom,
           u.usunom,
           (SELECT COUNT(*) FROM conexion c WHERE c.usucod = u.usucod)                    AS conexiones,
           COALESCE((SELECT SUM(i.intentos) FROM intentosfallidos i WHERE i.usucod = u.usucod), 0) AS intentos
    FROM departamento d
    LEFT JOIN usuario u ON u.depcod = d.depcod
)
SELECT depnom,
       COALESCE(usunom, '** TOTAL DEPTO **') AS usuario,
       COALESCE(SUM(conexiones), 0)          AS total_conexiones,
       COALESCE(SUM(intentos), 0)            AS intentos_fallidos
FROM por_usuario
GROUP BY GROUPING SETS ((depnom, usunom), (depnom))
ORDER BY depnom, GROUPING(usunom), usunom;


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   - Usa c.idconexion y f.idfallo: esas columnas no existen en el modelo.
     conexion tiene PK compuesta (usucod, fecha, hora) y intentosfallidos
     no tiene id.
   - COUNT(f.idfallo) contaría FILAS de intentosfallidos (0 o 1), no el
     número de intentos. Lo pedido es el valor de la columna "intentos".
   - Usa depnombre / usuariocod (son depnom / usucod).
   - Agrupa por u.usunom: si dos usuarios se llamaran igual se mezclarían;
     conviene agrupar también por u.usucod.
   --------------------------------------------------------------------- */
