/* =====================================================================
   PREGUNTA 2 - SOLUCIÓN
   Liste los sistemas que aún no están asociados a ningún perfil.
   ===================================================================== */

-- IDEA: la asociación sistema <-> perfil está en persis.
--       Un sistema "huérfano" es uno que NO aparece en persis.

-- Forma 1: LEFT JOIN ... IS NULL (la de la pauta)
SELECT s.siscod, s.sisnom
FROM sistema s
LEFT JOIN persis p ON p.siscod = s.siscod
WHERE p.siscod IS NULL;

-- Forma 2: NOT EXISTS (suele ser la más clara de leer)
SELECT s.siscod, s.sisnom
FROM sistema s
WHERE NOT EXISTS (SELECT 1 FROM persis p WHERE p.siscod = s.siscod);

-- Forma 3: NOT IN (ojo: si la subconsulta pudiera traer NULL, NOT IN devuelve vacío)
SELECT s.siscod, s.sisnom
FROM sistema s
WHERE s.siscod NOT IN (SELECT p.siscod FROM persis p);

-- Forma 4: EXCEPT (operación de conjuntos)
SELECT siscod FROM sistema
EXCEPT
SELECT siscod FROM persis;

-- Resultado esperado: 7 Tesorería, 8 Portal Proveedores


/* ---------------------------------------------------------------------
   PARA EXPLICAR EL LEFT JOIN: mira el resultado SIN el WHERE.
   Los sistemas sin perfil aparecen con percod/modo en NULL.
   --------------------------------------------------------------------- */
SELECT s.siscod, s.sisnom, p.percod, p.modo
FROM sistema s
LEFT JOIN persis p ON p.siscod = s.siscod
ORDER BY s.siscod;


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   Correcta. Filtra por p.percod IS NULL; es lo mismo filtrar por
   cualquier columna NOT NULL de persis (ambas son PK).
   --------------------------------------------------------------------- */
