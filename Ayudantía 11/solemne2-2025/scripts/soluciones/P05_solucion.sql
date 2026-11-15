/* =====================================================================
   PREGUNTA 5 - SOLUCIÓN
   Cada sistema puede tener máximo 10 usuarios conectados en paralelo.
   Cree un trigger que haga cumplir la regla. Un usuario con un perfil que
   da acceso al sistema se considera conectado a él. Se mira el día actual.
   ===================================================================== */

-- IDEA
--  * El evento es "un usuario se conecta" => BEFORE INSERT ON conexion.
--  * conexion NO tiene siscod: el sistema se deduce con
--        conexion -> usuper -> persis   (usuario -> perfiles -> sistemas)
--  * Al conectarse, el usuario "entra" a TODOS los sistemas de sus perfiles,
--    así que hay que revisar cada uno de esos sistemas.
--  * Por cada sistema se cuentan los usuarios DISTINTOS conectados hoy
--    (un mismo usuario puede tener varias conexiones en el día).
--  * Si el usuario ya estaba conectado hoy no ocupa un cupo nuevo,
--    por eso se excluye a NEW.usucod del conteo.

-- Para entender los datos: usuarios distintos conectados HOY por sistema
SELECT s.siscod, s.sisnom, COUNT(DISTINCT c.usucod) AS conectados_hoy
FROM conexion c
JOIN usuper  up ON up.usucod = c.usucod
JOIN persis  ps ON ps.percod = up.percod
JOIN sistema s  ON s.siscod  = ps.siscod
WHERE c.fecha = CURRENT_DATE
GROUP BY s.siscod, s.sisnom
ORDER BY conectados_hoy DESC;
-- => Comercial ya tiene 10 usuarios conectados hoy.


CREATE OR REPLACE FUNCTION validar_max_conectados()
RETURNS trigger AS $$
DECLARE
    v_sisnom     sistema.sisnom%TYPE;
    v_conectados INT;
BEGIN
    -- Busca algún sistema del usuario que ya tenga 10 o más conectados hoy
    SELECT s.sisnom, COUNT(DISTINCT c.usucod)
      INTO v_sisnom, v_conectados
    FROM conexion c
    JOIN usuper  up ON up.usucod = c.usucod
    JOIN persis  ps ON ps.percod = up.percod
    JOIN sistema s  ON s.siscod  = ps.siscod
    WHERE c.fecha = CURRENT_DATE             -- "día actual" (también: now()::date)
      AND c.usucod <> NEW.usucod             -- el propio usuario no cuenta dos veces
      AND ps.siscod IN (                     -- solo los sistemas a los que accede NEW.usucod
            SELECT ps2.siscod
            FROM usuper up2
            JOIN persis ps2 ON ps2.percod = up2.percod
            WHERE up2.usucod = NEW.usucod)
    GROUP BY s.siscod, s.sisnom
    HAVING COUNT(DISTINCT c.usucod) >= 10
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'El sistema % ya tiene % usuarios conectados (máximo 10). Usuario % rechazado.',
                        v_sisnom, v_conectados, NEW.usucod;
    END IF;

    RETURN NEW;   -- BEFORE INSERT: devolver NEW = "sí, inserta la fila"
END;              --                 (devolver NULL la descartaría en silencio)
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_max_conectados ON conexion;

CREATE TRIGGER trg_max_conectados
BEFORE INSERT ON conexion
FOR EACH ROW
EXECUTE FUNCTION validar_max_conectados();


/* ---------------------------------------------------------------------
   PRUEBA 1 (sin error): ejecuta este bloque completo
   --------------------------------------------------------------------- */
BEGIN;
    -- Gabriela (7) ya estaba conectada hoy -> no ocupa cupo nuevo -> OK
    INSERT INTO conexion VALUES (7, CURRENT_DATE, 11);
    -- Olga (15) no tiene acceso a Comercial; sus sistemas tienen cupo -> OK
    INSERT INTO conexion VALUES (15, CURRENT_DATE, 11);
    SELECT * FROM conexion WHERE fecha = CURRENT_DATE AND hora = 11;
ROLLBACK;


/* ---------------------------------------------------------------------
   PRUEBA 2 (con error): SELECCIONA solo estas líneas y ejecútalas (F5).
   Yerko (24) tiene perfil Vendedor -> Comercial, que ya está lleno.
   Debe aparecer: "El sistema Comercial ya tiene 10 usuarios conectados..."

INSERT INTO conexion VALUES (24, CURRENT_DATE, 11);

   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   PARA DISCUTIR EN CLASES
   - Concurrencia: si dos usuarios se conectan exactamente al mismo
     tiempo, ambas transacciones pueden contar 9 y ambas insertar (=> 11).
     Soluciones: aislamiento SERIALIZABLE, o serializar con un lock, p.ej.
         PERFORM pg_advisory_xact_lock(<siscod>);   -- por cada sistema
     o LOCK TABLE conexion IN SHARE ROW EXCLUSIVE MODE (más grueso).
   - "Conectado en paralelo" con este modelo solo se puede aproximar a
     "se conectó hoy": no hay hora de desconexión.

   COMPARACIÓN CON LA PAUTA
   - Usa NEW.siscod, pero conexion NO tiene siscod -> la función falla
     en tiempo de ejecución ("record new has no field siscod").
     Hay que deducir los sistemas desde usuper/persis del NEW.usucod.
   - Usa COUNT(*): cuenta conexiones (y filas multiplicadas por los
     JOIN con perfiles), no usuarios. Debe ser COUNT(DISTINCT c.usucod).
   - Usa usuariocod / perfilcod / fechahora, que no existen
     (son usucod / percod / fecha).
   --------------------------------------------------------------------- */
