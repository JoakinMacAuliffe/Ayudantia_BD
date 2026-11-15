/* =====================================================================
   PREGUNTA 1 - SOLUCIÓN
   Nombre de los usuarios que están a un acceso erróneo para ser bloqueados.
   ===================================================================== */

-- IDEA: se bloquea al 3er intento fallido => "a uno del bloqueo" = 2 intentos.
--       La cantidad de intentos vive en intentosfallidos; el nombre en usuario.

SELECT u.usunom
FROM usuario u
JOIN intentosfallidos i ON i.usucod = u.usucod
WHERE i.intentos = 2
  AND u.usuest = 'S';      -- (opcional) solo usuarios aún activos

-- Resultado esperado con los datos de prueba:
--   Felipe Araya, Karen Silva, Valentina Ortiz


/* ---------------------------------------------------------------------
   VARIANTE más robusta: "intentos = 3 - 1" deja explícita la regla de negocio
   y sirve si algún día el límite cambia.
   --------------------------------------------------------------------- */
SELECT u.usucod, u.usunom, i.intentos
FROM usuario u
JOIN intentosfallidos i ON i.usucod = u.usucod
WHERE i.intentos = 3 - 1
ORDER BY u.usunom;


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   La pauta es correcta (JOIN + WHERE intentos = 2). No filtra por
   usuest = 'S', lo cual no cambia el resultado si los datos son
   consistentes (un usuario con 2 intentos no debería estar bloqueado).
   --------------------------------------------------------------------- */
