/* =====================================================================
   PREGUNTA 8 - SOLUCIÓN
   Construya un trigger que, dada una conexión (login correcto), elimine
   el registro del usuario en intentosfallidos (punto b).
   ===================================================================== */

-- IDEA
--  * Cada fila insertada en conexion = un login correcto.
--  * AFTER INSERT ON conexion: primero queda registrada la conexión y
--    luego se borran los intentos.
--  * El trigger corre DENTRO de la misma transacción que el INSERT:
--    si algo falla, se deshace todo junto (eso pide la "única transacción").

CREATE OR REPLACE FUNCTION resetear_intentos()
RETURNS trigger AS $$
BEGIN
    DELETE FROM intentosfallidos
    WHERE usucod = NEW.usucod;      -- NEW = la conexión recién insertada
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_reset_intentos ON conexion;

CREATE TRIGGER trg_reset_intentos
AFTER INSERT ON conexion
FOR EACH ROW
EXECUTE FUNCTION resetear_intentos();


/* ---------------------------------------------------------------------
   PRUEBA (con ROLLBACK). Felipe Araya (6) tiene 2 intentos fallidos.
   --------------------------------------------------------------------- */
BEGIN;
    SELECT * FROM intentosfallidos WHERE usucod = 6;          -- antes: 2 intentos

    INSERT INTO conexion VALUES (6, CURRENT_DATE, 12);        -- login correcto

    SELECT * FROM intentosfallidos WHERE usucod = 6;          -- después: vacío
    SELECT * FROM conexion WHERE usucod = 6 AND fecha = CURRENT_DATE;
ROLLBACK;


/* ---------------------------------------------------------------------
   PARA DISCUTIR
   - ¿BEFORE o AFTER? Con AFTER el DELETE se hace solo si el INSERT pasó
     todas las validaciones (PK, FK y otros BEFORE triggers como el de la
     pregunta 5). Con BEFORE también funcionaría porque un error posterior
     haría ROLLBACK, pero AFTER expresa mejor "después de conectarse".
   - ¿Y si el usuario está bloqueado (usuest = 'N')? El enunciado no lo
     pide, pero se podría agregar en un BEFORE INSERT que rechace la
     conexión de usuarios bloqueados.

   COMPARACIÓN CON LA PAUTA
   - Usa WHEN (NEW.estado = 'E'), pero conexion NO tiene columna estado
     -> el CREATE TRIGGER falla. En este modelo toda fila de conexion ya
     es un login correcto, así que no se necesita WHEN.
   - Usa usuariocod (es usucod).
   --------------------------------------------------------------------- */
