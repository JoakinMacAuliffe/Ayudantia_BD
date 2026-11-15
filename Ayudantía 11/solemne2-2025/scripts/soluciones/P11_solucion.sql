/* =====================================================================
   PREGUNTA 11 - SOLUCIÓN
   Tabla desnormalizada dept_connection_summary + trigger que incrementa
   total_conexiones al insertar en conexion. Consideraciones de
   integridad y concurrencia.
   ===================================================================== */

/* ---------------------------------------------------------------------
   DDL
   --------------------------------------------------------------------- */
DROP TABLE IF EXISTS dept_connection_summary;

CREATE TABLE dept_connection_summary (
    depcod           INT       PRIMARY KEY                    -- 1 fila por departamento
                               REFERENCES departamento(depcod),
    total_conexiones BIGINT    NOT NULL DEFAULT 0
                               CHECK (total_conexiones >= 0),
    last_update      TIMESTAMP NOT NULL DEFAULT now()
);

-- Carga inicial: la tabla debe partir consistente con lo que YA existe
-- en conexion (si parte vacía, el contador quedaría desfasado para siempre).
INSERT INTO dept_connection_summary (depcod, total_conexiones, last_update)
SELECT d.depcod, COUNT(c.usucod), now()
FROM departamento d
LEFT JOIN usuario  u ON u.depcod = d.depcod
LEFT JOIN conexion c ON c.usucod = u.usucod
GROUP BY d.depcod;

SELECT * FROM dept_connection_summary ORDER BY depcod;


/* ---------------------------------------------------------------------
   TRIGGER
   --------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION actualizar_resumen_dep()
RETURNS trigger AS $$
DECLARE
    v_depcod usuario.depcod%TYPE;
BEGIN
    -- Departamento del usuario que se conectó
    SELECT depcod INTO v_depcod
    FROM usuario
    WHERE usucod = NEW.usucod;

    IF v_depcod IS NULL THEN          -- usuario sin departamento: nada que sumar
        RETURN NEW;
    END IF;

    -- UPSERT atómico: si no existe la fila la crea con 1; si existe suma 1.
    -- "total = total + 1" se resuelve en el servidor sobre la fila bloqueada
    -- (no es leer-sumar-escribir desde la aplicación).
    INSERT INTO dept_connection_summary (depcod, total_conexiones, last_update)
    VALUES (v_depcod, 1, now())
    ON CONFLICT (depcod) DO UPDATE
        SET total_conexiones = dept_connection_summary.total_conexiones + 1,
            last_update      = now();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_resumen_dep ON conexion;

CREATE TRIGGER trg_resumen_dep
AFTER INSERT ON conexion
FOR EACH ROW
EXECUTE FUNCTION actualizar_resumen_dep();


/* ---------------------------------------------------------------------
   PRUEBA (con ROLLBACK). Ana Rojas (1) es de Contabilidad (depcod 1).
   --------------------------------------------------------------------- */
BEGIN;
    SELECT * FROM dept_connection_summary WHERE depcod = 1;   -- antes

    INSERT INTO conexion VALUES (1, CURRENT_DATE, 15);
    INSERT INTO conexion VALUES (1, CURRENT_DATE, 16);

    SELECT * FROM dept_connection_summary WHERE depcod = 1;   -- después: +2
ROLLBACK;


/* ---------------------------------------------------------------------
   AUDITORÍA: ¿el resumen coincide con la realidad?
   (útil para detectar desfases; debería devolver 0 filas)
   --------------------------------------------------------------------- */
SELECT s.depcod, s.total_conexiones AS en_resumen, COUNT(c.usucod) AS real
FROM dept_connection_summary s
LEFT JOIN usuario  u ON u.depcod = s.depcod
LEFT JOIN conexion c ON c.usucod = u.usucod
GROUP BY s.depcod, s.total_conexiones
HAVING s.total_conexiones <> COUNT(c.usucod);


/* =====================================================================
   CONSIDERACIONES DE INTEGRIDAD
   1. Carga inicial: poblar la tabla con los conteos actuales antes de
      activar el trigger (ver INSERT ... SELECT arriba).
   2. FK depcod -> departamento: no puede haber resumen de un depto
      inexistente. NOT NULL + DEFAULT 0 + CHECK >= 0 en el contador.
   3. El trigger solo cubre INSERT. Para que el resumen no se desfase
      también habría que manejar:
        - DELETE en conexion        -> restar 1
        - UPDATE de conexion.usucod -> mover el conteo de depto
        - UPDATE de usuario.depcod  -> ¿se mueven sus conexiones históricas?
          (decisión de negocio; con este diseño quedan en el depto original)
   4. Usuario sin departamento (depcod NULL): se ignora explícitamente.
   5. El trigger corre en la MISMA transacción que el INSERT: si la
      transacción hace ROLLBACK, el incremento también se revierte.
   6. Es un dato redundante: conviene una consulta de auditoría (arriba)
      o un recálculo periódico.

   CONSIDERACIONES DE CONCURRENCIA
   1. Nunca hacer "SELECT total ... ; UPDATE SET total = valor_leido + 1"
      desde la aplicación: dos sesiones leen el mismo valor y se pierde
      un incremento (lost update). "SET total = total + 1" es atómico.
   2. El UPDATE toma un lock de fila sobre la fila del departamento:
      conexiones simultáneas del MISMO depto se serializan (esperan a que
      la otra transacción termine). Es correcto, pero esa fila se vuelve
      un "hot spot" si hay mucho tráfico; transacciones largas lo empeoran.
   3. ON CONFLICT resuelve la carrera de "dos sesiones crean la fila del
      depto al mismo tiempo" (sin él, una fallaría por PK duplicada).
   4. Si hay muchísima concurrencia: acumular en una tabla de deltas y
      consolidar periódicamente, o usar una vista materializada que se
      refresque cada cierto tiempo.
   ===================================================================== */


/* ---------------------------------------------------------------------
   COMPARACIÓN CON LA PAUTA
   - La lógica del trigger con ON CONFLICT es correcta.
   - Usa usuariocod (es usucod).
   - La DDL no tiene FK a departamento ni NOT NULL en el contador, y no
     hace la carga inicial.
   - No incluye la explicación de integridad/concurrencia que pide la pregunta.
   --------------------------------------------------------------------- */
