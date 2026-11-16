/* =====================================================================
   BIBLIOTECA UNIVERSITARIA - BASE DE DATOS (Control 3, Ejercicio 1)

   ESTE SCRIPT DEJA LA BD "biblioteca" EN SU ESTADO INICIAL.
   - Ejecútalo conectado a la BD biblioteca (NO a solemne2 ni festival).
   - Se ejecuta solo la primera vez que se levanta el contenedor.
   - Vuelve a ejecutarlo (F5) para resetear: borra también el procedimiento
     y el trigger que hayas creado.
   - Las fechas de préstamo son relativas a CURRENT_DATE, así que las multas
     esperadas valen para cualquier día en que se ejecute el reset.
   ===================================================================== */

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- ---------------------------------------------------------------------
-- DDL (según el contexto común del control)
-- ---------------------------------------------------------------------
CREATE TABLE socios (
    id        INT PRIMARY KEY,
    nombre    VARCHAR(50),
    apellido  VARCHAR(50),
    email     VARCHAR(100),
    estado    VARCHAR(10) CHECK (estado IN ('ACTIVO', 'SUSPENDIDO'))
);

CREATE TABLE autores (
    id        INT PRIMARY KEY,
    nombre    VARCHAR(50),
    apellido  VARCHAR(50),
    pais      VARCHAR(50)
);

CREATE TABLE categorias (
    id        INT PRIMARY KEY,
    nombre    VARCHAR(50)
);

CREATE TABLE libros (
    id                      INT PRIMARY KEY,
    titulo                  VARCHAR(200),
    autor_id                INT REFERENCES autores(id),
    categoria_id            INT REFERENCES categorias(id),
    ejemplares_disponibles  INT CHECK (ejemplares_disponibles >= 0)
);

CREATE TABLE prestamos (
    id                SERIAL PRIMARY KEY,
    socio_id          INT REFERENCES socios(id),
    libro_id          INT REFERENCES libros(id),
    fecha_prestamo    DATE,
    fecha_devolucion  DATE,              -- NULL = préstamo vigente
    multa             NUMERIC(8,2) DEFAULT 0
);

-- ---------------------------------------------------------------------
-- DATOS DE PRUEBA
-- ---------------------------------------------------------------------
INSERT INTO categorias VALUES
 (1, 'Bases de Datos'),
 (2, 'Programación'),
 (3, 'Matemáticas'),
 (4, 'Literatura');

INSERT INTO autores VALUES
 (1, 'Ramez',    'Elmasri',      'Estados Unidos'),
 (2, 'Abraham',  'Silberschatz', 'Estados Unidos'),
 (3, 'Donald',   'Knuth',        'Estados Unidos'),
 (4, 'Gabriela', 'Mistral',      'Chile'),
 (5, 'Isabel',   'Allende',      'Chile'),
 (6, 'Tom',      'Apostol',      'Estados Unidos');

-- El libro 41 NO existe a propósito (sirve para probar "el libro no existe").
INSERT INTO libros VALUES
 (30, 'Fundamentos de Sistemas de Bases de Datos', 1, 1, 3),
 (31, 'Fundamentos de Bases de Datos',             2, 1, 2),
 (32, 'The Art of Computer Programming',           3, 2, 1),
 (33, 'Desolación',                                4, 4, 2),
 (34, 'La Casa de los Espíritus',                  5, 4, 4),
 (35, 'Calculus',                                  6, 3, 2),
 (40, 'Diseño de Bases de Datos Relacionales',     1, 1, 2),
 (42, 'Concurrencia y Transacciones',              2, 1, 1),
 (43, 'Análisis Matemático',                       6, 3, 0);   -- sin ejemplares

INSERT INTO socios VALUES
 (10, 'Ana',      'Pérez',  'ana.perez@uni.cl',      'ACTIVO'),
 (11, 'Bruno',    'Díaz',   'bruno.diaz@uni.cl',     'ACTIVO'),
 (12, 'Carla',    'Soto',   'carla.soto@uni.cl',     'ACTIVO'),
 (13, 'Diego',    'Lagos',  'diego.lagos@uni.cl',    'ACTIVO'),
 (14, 'Elisa',    'Mora',   'elisa.mora@uni.cl',     'SUSPENDIDO'),
 (15, 'Fernanda', 'Ruiz',   'fernanda.ruiz@uni.cl',  'ACTIVO'),   -- 2 vigentes: le cabe 1 más
 (16, 'Gonzalo',  'Vera',   'gonzalo.vera@uni.cl',   'ACTIVO'),   -- 3 vigentes: en el límite
 (17, 'Héctor',   'Pino',   'hector.pino@uni.cl',    'ACTIVO');   -- sin préstamos

-- Se insertan en orden, así que los id quedan 1..9 después de cada reset.
INSERT INTO prestamos (socio_id, libro_id, fecha_prestamo, fecha_devolucion, multa) VALUES
 -- vigentes
 (15, 30, CURRENT_DATE - 3,  NULL, 0),                    -- id 1: devolver hoy -> multa 0
 (15, 33, CURRENT_DATE - 10, NULL, 0),                    -- id 2: devolver hoy -> 3 días de atraso = 1500
 (16, 31, CURRENT_DATE - 7,  NULL, 0),                    -- id 3: devolver hoy -> justo 7 días = 0 (borde)
 (16, 34, CURRENT_DATE - 12, NULL, 0),                    -- id 4: devolver hoy -> 5 días de atraso = 2500
 (16, 35, CURRENT_DATE - 1,  NULL, 0),                    -- id 5: devolver con fecha anterior -> error
 (13, 43, CURRENT_DATE - 2,  NULL, 0),                    -- id 6: único ejemplar del 43 prestado
 -- históricos (ya devueltos)
 (10, 32, CURRENT_DATE - 20, CURRENT_DATE - 11, 1000),    -- id 7: 9 días -> 2 de atraso
 (11, 30, CURRENT_DATE - 30, CURRENT_DATE - 25, 0),       -- id 8
 (15, 40, CURRENT_DATE - 40, CURRENT_DATE - 35, 0);       -- id 9: devuelto, NO cuenta como vigente
