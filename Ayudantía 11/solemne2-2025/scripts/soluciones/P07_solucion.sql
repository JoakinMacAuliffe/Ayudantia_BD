/* =====================================================================
   PREGUNTA 7 - SOLUCIÓN
   Liste los usuarios que tienen la capacidad de escribir y de leer a un
   mismo sistema (porque tienen dos perfiles distintos para ese sistema).
   ===================================================================== */

-- IDEA: el modo (E/L) está en persis, por par (sistema, perfil).
--       usuario -> usuper -> persis  da todas las (usuario, sistema, modo).
--       Se busca un (usuario, sistema) que tenga AMBOS modos: 'E' y 'L'.

-- Solución 1: GROUP BY + HAVING con COUNT(DISTINCT modo)
SELECT u.usucod, u.usunom, s.sisnom
FROM usuario u
JOIN usuper  up ON up.usucod = u.usucod
JOIN persis  ps ON ps.percod = up.percod
JOIN sistema s  ON s.siscod  = ps.siscod
GROUP BY u.usucod, u.usunom, s.siscod, s.sisnom
HAVING COUNT(DISTINCT ps.modo) = 2          -- tiene 'E' y 'L'
ORDER BY u.usucod;

-- Solución 2: auto-JOIN (una "copia" para escritura y otra para lectura)
SELECT DISTINCT u.usucod, u.usunom, s.sisnom
FROM usuario u
JOIN usuper up_e ON up_e.usucod = u.usucod
JOIN persis ps_e ON ps_e.percod = up_e.percod AND ps_e.modo = 'E'
JOIN usuper up_l ON up_l.usucod = u.usucod
JOIN persis ps_l ON ps_l.percod = up_l.percod AND ps_l.modo = 'L'
JOIN sistema s   ON s.siscod = ps_e.siscod
WHERE ps_e.siscod = ps_l.siscod
ORDER BY u.usucod;

-- Solución 3: INTERSECT (operaciones de conjuntos)
SELECT up.usucod, ps.siscod FROM usuper up JOIN persis ps ON ps.percod = up.percod WHERE ps.modo = 'E'
INTERSECT
SELECT up.usucod, ps.siscod FROM usuper up JOIN persis ps ON ps.percod = up.percod WHERE ps.modo = 'L';

-- Resultado esperado:
--   2 Bruno Díaz     - Contabilidad          (Contador E + Auditor L)
--   5 Elena Fuentes  - RRHH                  (Analista RRHH E + Auditor L)
--   8 Hugo Vera      - Comercial             (Vendedor E + Consulta Comercial L)
--  17 Rocío Campos   - Business Intelligence (Analista BI E + Contador L)


/* ---------------------------------------------------------------------
   PARA VER EL DETALLE (qué perfil da qué modo)
   --------------------------------------------------------------------- */
SELECT u.usunom, s.sisnom, p.pernom, ps.modo
FROM usuario u
JOIN usuper  up ON up.usucod = u.usucod
JOIN perfil  p  ON p.percod  = up.percod
JOIN persis  ps ON ps.percod = up.percod
JOIN sistema s  ON s.siscod  = ps.siscod
WHERE u.usucod IN (2, 5, 8, 17, 20)
ORDER BY u.usunom, s.sisnom, ps.modo;


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   - SQL1 usa p.tipoperfil, que no existe: el modo E/L está en persis.modo
     (depende del par sistema-perfil, no solo del perfil).
     También usa "sistemas" (la tabla es sistema), usuariocod y perfilcod.
   - SQL2 usa COUNT(DISTINCT perfilcod) >= 2. ES INCORRECTA: dos perfiles
     distintos pueden dar el MISMO modo. Ejecuta esto y verás a
     Ulises Bravo (20) en Inventario, que tiene 2 perfiles pero
     ambos de lectura (Vendedor L + Lector Inventario L):
   --------------------------------------------------------------------- */
SELECT u.usucod, u.usunom, s.sisnom,
       COUNT(DISTINCT ps.percod) AS perfiles,
       STRING_AGG(DISTINCT ps.modo, ',') AS modos
FROM usuario u
JOIN usuper  up ON up.usucod = u.usucod
JOIN persis  ps ON ps.percod = up.percod
JOIN sistema s  ON s.siscod  = ps.siscod
GROUP BY u.usucod, u.usunom, s.siscod, s.sisnom
HAVING COUNT(DISTINCT ps.percod) >= 2      -- criterio de la pauta
ORDER BY u.usucod;
