/* =====================================================================
   PREGUNTA 10 - SOLUCIÓN
   Login correcto: (a) registrar la conexión y (b) borrar intentosfallidos,
   todo en UNA ÚNICA TRANSACCIÓN.
   ===================================================================== */

-- IDEA: BEGIN ... COMMIT agrupa las dos operaciones. Si cualquiera falla,
--       ROLLBACK deshace ambas: nunca queda la conexión sin el reseteo,
--       ni el reseteo sin la conexión (atomicidad, la "A" de ACID).
--
-- NOTA: la pauta reutiliza el trigger de la P8, pero esta pregunta pide la
-- transacción explícita (sin trigger). Si ya creaste el trigger de la P8,
-- el DELETE de abajo simplemente no encontrará nada que borrar.


/* ---------------------------------------------------------------------
   SOLUCIÓN 1: transacción explícita (ejemplo con Valentina Ortiz, 21)
   --------------------------------------------------------------------- */
BEGIN;

    INSERT INTO conexion (usucod, fecha, hora)
    VALUES (21, CURRENT_DATE, EXTRACT(HOUR FROM now())::smallint);   -- (a)

    DELETE FROM intentosfallidos
    WHERE usucod = 21;                                                -- (b)

    -- Verificación dentro de la transacción
    SELECT 'conexion' AS tabla, COUNT(*) FROM conexion WHERE usucod = 21 AND fecha = CURRENT_DATE
    UNION ALL
    SELECT 'intentosfallidos', COUNT(*) FROM intentosfallidos WHERE usucod = 21;

ROLLBACK;   -- en la vida real va COMMIT; acá ROLLBACK para no alterar los datos


/* ---------------------------------------------------------------------
   SOLUCIÓN 2: encapsularlo en un procedimiento.
   Un CALL en modo autocommit se ejecuta como una sola transacción:
   si el INSERT falla, el DELETE tampoco queda hecho.
   --------------------------------------------------------------------- */
CREATE OR REPLACE PROCEDURE registrar_login(p_usucod INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO conexion (usucod, fecha, hora)
    VALUES (p_usucod, CURRENT_DATE, EXTRACT(HOUR FROM now())::smallint);

    DELETE FROM intentosfallidos
    WHERE usucod = p_usucod;
END;
$$;


/* ---------------------------------------------------------------------
   DEMOSTRACIÓN DE ATOMICIDAD (paso a paso: selecciona cada bloque y F5)

   PASO 1: Valentina (21) tiene 2 intentos
       SELECT * FROM intentosfallidos WHERE usucod = 21;

   PASO 2: forzamos que el INSERT vaya a fallar, creando antes una conexión
           en la misma fecha y hora (violará la PK usucod+fecha+hora).
           Lo hacemos SIN borrar intentos, a propósito:
       ALTER TABLE conexion DISABLE TRIGGER USER;   -- por si existe el trigger de la P8
       INSERT INTO conexion VALUES (21, CURRENT_DATE, EXTRACT(HOUR FROM now())::smallint);
       ALTER TABLE conexion ENABLE TRIGGER USER;

   PASO 3: llamamos al procedimiento -> ERROR duplicate key
       CALL registrar_login(21);

   PASO 4: los intentos siguen ahí (2): el DELETE no quedó a medias
       SELECT * FROM intentosfallidos WHERE usucod = 21;

   PASO 5 (limpieza): borra la conexión de prueba
       DELETE FROM conexion WHERE usucod = 21 AND fecha = CURRENT_DATE;
   --------------------------------------------------------------------- */


/* ---------------------------------------------------------------------
   PARA DISCUTIR
   - ¿Importa el orden INSERT / DELETE? Dentro de una transacción no: si
     algo falla, se revierte todo. Pero hacer primero el INSERT permite
     fallar antes de tocar intentosfallidos.
   - Sin BEGIN/COMMIT (autocommit) cada sentencia es su propia transacción:
     si el INSERT falla después de un DELETE ya hecho, el DELETE queda.
   --------------------------------------------------------------------- */
