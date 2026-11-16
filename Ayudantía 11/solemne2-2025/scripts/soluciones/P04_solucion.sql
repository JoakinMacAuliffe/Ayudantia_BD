/* =====================================================================
   PREGUNTA 4 - SOLUCIÓN
   a. Update que permite desbloquear el usuario.
   b. Trigger que, cuando un usuario queda desbloqueado, elimina su
      registro en intentosfallidos.
   ===================================================================== */

/* ---------------------------------------------------------------------
   a) UPDATE para desbloquear (ejemplo con el usuario 3, Carla Soto)
      El "AND usuest = 'N'" evita "desbloquear" a alguien que no lo estaba.
      ** No lo ejecutes todavía: primero crea el trigger (paso b) y luego
         usa la PRUEBA de más abajo. **

   UPDATE usuario
   SET usuest = 'S'
   WHERE usucod = 3
     AND usuest = 'N';
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   b) TRIGGER
   En PostgreSQL un trigger son 2 piezas:
     1. una FUNCIÓN que RETURNS trigger (tiene acceso a OLD y NEW)
     2. el TRIGGER, que dice cuándo se dispara esa función
   --------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION limpiar_fallos()
RETURNS trigger AS $$
BEGIN
    DELETE FROM intentosfallidos
    WHERE usucod = NEW.usucod;      -- NEW = la fila de usuario ya actualizada
    RETURN NEW;                     -- en un AFTER el valor de retorno se ignora,
END;                                -- pero es buena costumbre devolver NEW
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_desbloqueo ON usuario;

CREATE TRIGGER trg_desbloqueo
AFTER UPDATE OF usuest ON usuario          -- solo si se actualiza la columna usuest
FOR EACH ROW
WHEN (OLD.usuest = 'N' AND NEW.usuest = 'S'  )   -- solo la transición bloqueado -> activo
EXECUTE FUNCTION limpiar_fallos();


/* ---------------------------------------------------------------------
   PRUEBA (dentro de una transacción con ROLLBACK para no alterar los datos)
   Ejecuta todo el bloque y mira las salidas de cada SELECT.
   --------------------------------------------------------------------- */
BEGIN;

    -- Antes: Carla está bloqueada y tiene 3 intentos
    SELECT u.usucod, u.usunom, u.usuest, i.intentos
    FROM usuario u LEFT JOIN intentosfallidos i ON i.usucod = u.usucod
    WHERE u.usucod = 3;

    -- a) el UPDATE
    UPDATE usuario SET usuest = 'S' WHERE usucod = 3 AND usuest = 'N';

    -- Después: usuest = 'S' e intentos = NULL (el trigger borró la fila)
    SELECT u.usucod, u.usunom, u.usuest, i.intentos
    FROM usuario u LEFT JOIN intentosfallidos i ON i.usucod = u.usucod
    WHERE u.usucod = 3;

ROLLBACK;   -- deshace el UPDATE y el DELETE del trigger (el trigger sigue creado)


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   - Usa "usuariocod", que no existe en el modelo: la columna es usucod.
   - El resto (AFTER UPDATE + WHEN OLD='N' AND NEW='S') es correcto.
   - Mejora opcional: "AFTER UPDATE OF usuest" evita evaluar el trigger
     cuando se actualizan otras columnas (p.ej. la clave).
   --------------------------------------------------------------------- */
