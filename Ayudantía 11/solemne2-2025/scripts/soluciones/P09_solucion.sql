/* =====================================================================
   PREGUNTA 9 - SOLUCIÓN
   usucod, usunom y cantidad de sistemas DISTINTOS a los que tiene acceso
   cada usuario, solo usuarios con al menos un perfil. Mostrar 0 para los
   que tienen perfiles pero sin sistemas asociados.
   ===================================================================== */

-- IDEA
--  * "solo usuarios con al menos un perfil"  => INNER JOIN con usuper
--    (deja fuera a quien no tiene perfiles: Zoe Alarcón).
--  * "mostrar 0 si el perfil no tiene sistemas" => LEFT JOIN con persis
--    (el perfil Practicante no tiene sistemas: Sebastián Vargas).
--  * "sistemas distintos" => COUNT(DISTINCT ps.siscod)
--    (dos perfiles pueden apuntar al mismo sistema).
--  * COUNT(columna) ignora NULLs => cuando no hay persis da 0.

SELECT u.usucod,
       u.usunom,
       COUNT(DISTINCT ps.siscod) AS cantidad_sistemas
FROM usuario u
JOIN usuper up      ON up.usucod = u.usucod
LEFT JOIN persis ps ON ps.percod = up.percod
GROUP BY u.usucod, u.usunom
ORDER BY u.usucod;

-- El enunciado menciona la tabla sistema; si se quiere unir (p.ej. para
-- mostrar nombres), también debe ser LEFT JOIN para no perder los ceros:
SELECT u.usucod,
       u.usunom,
       COUNT(DISTINCT s.siscod)                           AS cantidad_sistemas,
       STRING_AGG(DISTINCT s.sisnom, ', ')                AS sistemas
FROM usuario u
JOIN usuper up       ON up.usucod = u.usucod
LEFT JOIN persis ps  ON ps.percod = up.percod
LEFT JOIN sistema s  ON s.siscod  = ps.siscod
GROUP BY u.usucod, u.usunom
ORDER BY u.usucod;


/* ---------------------------------------------------------------------
   ERRORES TÍPICOS PARA MOSTRAR
   --------------------------------------------------------------------- */
-- (1) JOIN (inner) con persis: Sebastián desaparece en vez de salir con 0
SELECT u.usucod, u.usunom, COUNT(DISTINCT ps.siscod) AS cantidad_sistemas
FROM usuario u
JOIN usuper up ON up.usucod = u.usucod
JOIN persis ps ON ps.percod = up.percod
GROUP BY u.usucod, u.usunom
ORDER BY u.usucod;

-- (2) COUNT(*) en vez de COUNT(DISTINCT siscod): Sebastián sale con 1 y
--     quien tiene 2 perfiles hacia el mismo sistema lo cuenta doble
SELECT u.usucod, u.usunom, COUNT(*) AS cantidad_MAL
FROM usuario u
JOIN usuper up      ON up.usucod = u.usucod
LEFT JOIN persis ps ON ps.percod = up.percod
GROUP BY u.usucod, u.usunom
ORDER BY u.usucod;


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   La lógica es correcta (JOIN usuper + LEFT JOIN persis + COUNT DISTINCT).
   Solo cambian los nombres: usuariocod -> usucod, perfilcod -> percod.
   --------------------------------------------------------------------- */
