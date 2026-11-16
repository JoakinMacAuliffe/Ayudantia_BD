/* =====================================================================
   CONTROL 3 - EJERCICIO 1: SOLUCIÓN (según la pauta)    BD: biblioteca
   Las pruebas están en E1.sql.
   ===================================================================== */

-- ---------------------------------------------------------------------
-- (a) Procedimiento registrar_prestamo (25 pts)
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE registrar_prestamo(p_socio_id INT, p_libro_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_disp     INT;
    v_vigentes INT;
BEGIN
    -- 1. Libro existe y tiene ejemplares
    SELECT ejemplares_disponibles INTO v_disp
    FROM libros WHERE id = p_libro_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El libro % no existe', p_libro_id;
    END IF;

    -- Debe ir DESPUÉS de verificar que existe
    IF v_disp <= 0 THEN
        RAISE EXCEPTION 'No hay ejemplares disponibles del libro %', p_libro_id;
    END IF;

    -- 2. Máximo 3 préstamos vigentes (IS NULL, no "= NULL")
    SELECT COUNT(*) INTO v_vigentes
    FROM prestamos
    WHERE socio_id = p_socio_id AND fecha_devolucion IS NULL;

    IF v_vigentes >= 3 THEN
        RAISE EXCEPTION 'El socio % ya tiene % prestamos vigentes (maximo 3)',
                        p_socio_id, v_vigentes;
    END IF;

    -- 3. Registrar y descontar stock
    INSERT INTO prestamos(socio_id, libro_id, fecha_prestamo)
    VALUES (p_socio_id, p_libro_id, CURRENT_DATE);

    UPDATE libros
    SET ejemplares_disponibles = ejemplares_disponibles - 1
    WHERE id = p_libro_id;
END;
$$;

-- Invocación:
-- CALL registrar_prestamo(15, 40);


-- ---------------------------------------------------------------------
-- (b) Trigger de devolución y multa (25 pts)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_devolucion()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_atraso INT;
BEGIN
    IF NEW.fecha_devolucion < OLD.fecha_prestamo THEN
        RAISE EXCEPTION 'La fecha de devolucion (%) es anterior al prestamo (%)',
                        NEW.fecha_devolucion, OLD.fecha_prestamo;
    END IF;

    -- días de atraso = días transcurridos - plazo (7), nunca negativo.
    -- La resta de dos DATE ya entrega un entero.
    v_atraso := GREATEST((NEW.fecha_devolucion - OLD.fecha_prestamo) - 7, 0);
    NEW.multa := v_atraso * 500;

    UPDATE libros
    SET ejemplares_disponibles = ejemplares_disponibles + 1
    WHERE id = NEW.libro_id;

    RETURN NEW;
END;
$$;

-- BEFORE: así se modifica NEW.multa sin un segundo UPDATE sobre la misma fila.
-- Con AFTER, cambiar NEW no tiene efecto.
CREATE TRIGGER trg_devolucion
BEFORE UPDATE OF fecha_devolucion ON prestamos
FOR EACH ROW
WHEN (OLD.fecha_devolucion IS NULL AND NEW.fecha_devolucion IS NOT NULL)
EXECUTE FUNCTION fn_devolucion();
