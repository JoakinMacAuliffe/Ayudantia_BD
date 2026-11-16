/* =====================================================================
   CONTROL 3 - EJERCICIO 1 (50 pts)        BD: biblioteca

   (a) Procedimiento registrar_prestamo (25 pts)
       Cree el procedimiento almacenado
       registrar_prestamo(p_socio_id INT, p_libro_id INT) que:
         - valide que el libro existe y tiene ejemplares_disponibles > 0;
         - valide que el socio tiene MENOS DE 3 préstamos vigentes;
         - si todo es correcto, inserte el préstamo con
           fecha_prestamo = CURRENT_DATE y descuente en 1 los
           ejemplares_disponibles del libro.
       Muestre además cómo se invoca para el socio 15 y el libro 40.

   (b) Trigger de devolución y multa (25 pts)
       El plazo de un préstamo es de 7 días y cada día de atraso se multa
       con $500. Cree un trigger que se ejecute SOLO cuando se registra una
       devolución, es decir, cuando fecha_devolucion pasa de NULL a una
       fecha. El trigger debe:
         - abortar si la fecha de devolución es anterior a fecha_prestamo;
         - calcular la multa según el atraso y dejarla guardada en la
           columna multa del mismo préstamo;
         - reponer en 1 los ejemplares_disponibles del libro.

   Notas: un préstamo está vigente mientras fecha_devolucion sea NULL.
          prestamos.id es SERIAL; multa es NUMERIC(8,2) DEFAULT 0.
   ===================================================================== */

-- Tu respuesta aquí:

-- (a)


-- (b)


/* ---------------------------------------------------------------------
   PRUEBAS: ejecútalas de a una (selecciona + F5) después de crear tus
   objetos. Para repetirlas, ejecuta antes 00_reset_biblioteca.sql.
   --------------------------------------------------------------------- */

-- (a) Caso feliz: socio 15 tiene 2 vigentes, libro 40 tiene 2 ejemplares.
-- CALL registrar_prestamo(15, 40);
-- SELECT * FROM prestamos WHERE socio_id = 15 ORDER BY id;       -- aparece uno nuevo con fecha de hoy
-- SELECT ejemplares_disponibles FROM libros WHERE id = 40;       -- 1

-- (a) Socio 15 ahora tiene 3 vigentes -> debe fallar por el límite.
-- CALL registrar_prestamo(15, 42);

-- (a) Socio 16 ya tiene 3 vigentes -> debe fallar por el límite.
-- CALL registrar_prestamo(16, 30);

-- (a) Libro 41 no existe -> debe fallar.
-- CALL registrar_prestamo(17, 41);

-- (a) Libro 43 sin ejemplares -> debe fallar.
-- CALL registrar_prestamo(17, 43);

-- (b) Devoluciones de hoy:
-- UPDATE prestamos SET fecha_devolucion = CURRENT_DATE WHERE id = 1;   -- multa 0     (3 días)
-- UPDATE prestamos SET fecha_devolucion = CURRENT_DATE WHERE id = 2;   -- multa 1500  (10 días)
-- UPDATE prestamos SET fecha_devolucion = CURRENT_DATE WHERE id = 3;   -- multa 0     (justo 7)
-- UPDATE prestamos SET fecha_devolucion = CURRENT_DATE WHERE id = 4;   -- multa 2500  (12 días)
-- SELECT id, fecha_prestamo, fecha_devolucion, multa FROM prestamos WHERE id <= 4 ORDER BY id;
-- SELECT id, ejemplares_disponibles FROM libros WHERE id IN (30, 31, 33, 34);  -- 4, 3, 3, 5

-- (b) Devolución anterior al préstamo -> debe fallar.
-- UPDATE prestamos SET fecha_devolucion = CURRENT_DATE - 5 WHERE id = 5;

-- (b) Préstamo ya devuelto: el trigger NO debe dispararse (multa sigue en 1000, stock del 32 sigue en 1).
-- UPDATE prestamos SET fecha_devolucion = CURRENT_DATE WHERE id = 7;
-- SELECT multa FROM prestamos WHERE id = 7;
-- SELECT ejemplares_disponibles FROM libros WHERE id = 32;

-- (b) Cambiar otra columna de un vigente: el trigger NO debe dispararse.
-- UPDATE prestamos SET multa = 0 WHERE id = 6;
-- SELECT ejemplares_disponibles FROM libros WHERE id = 43;            -- sigue en 0
