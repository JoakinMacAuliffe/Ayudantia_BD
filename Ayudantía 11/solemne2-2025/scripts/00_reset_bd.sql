/* =====================================================================
   SOLEMNE 2 - BASE DE DATOS (2do semestre 2025)
   Modelo: control de accesos de usuarios a los sistemas de una empresa

   ESTE SCRIPT DEJA LA BD EN SU ESTADO INICIAL.
   - Se ejecuta solo la primera vez que se levanta el contenedor.
   - Puedes volver a ejecutarlo completo (F5) en pgAdmin cuando quieras
     "resetear": borra TODO (tablas, triggers, funciones creadas en las
     soluciones) y vuelve a cargar los datos de prueba.
   - Las conexiones se generan relativas a CURRENT_DATE, así que el
     día de hoy siempre tiene conexiones (necesario para la pregunta 5).
   ===================================================================== */

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- ---------------------------------------------------------------------
-- DDL (tal como lo define el enunciado)
-- ---------------------------------------------------------------------
CREATE TABLE departamento (
    depcod  INT PRIMARY KEY,
    depnom  VARCHAR(50)
);

CREATE TABLE usuario (
    usucod  INT PRIMARY KEY,
    usunom  VARCHAR(30),
    usucla  VARCHAR(20),
    depcod  INT REFERENCES departamento(depcod),
    usuest  CHAR(1) CHECK (usuest IN ('S', 'N'))   -- S = activo, N = bloqueado
);

CREATE TABLE perfil (
    percod  INT PRIMARY KEY,
    pernom  VARCHAR(30)
);

CREATE TABLE usuper (
    percod  INT REFERENCES perfil(percod),
    usucod  INT REFERENCES usuario(usucod),
    PRIMARY KEY (percod, usucod)
);

CREATE TABLE sistema (
    siscod  INT PRIMARY KEY,
    sisnom  VARCHAR(30)
);

CREATE TABLE persis (
    siscod  INT REFERENCES sistema(siscod),
    percod  INT REFERENCES perfil(percod),
    modo    CHAR(1) CHECK (modo IN ('E', 'L')),     -- E = escritura, L = lectura
    PRIMARY KEY (siscod, percod)
);

CREATE TABLE conexion (
    usucod  INT REFERENCES usuario(usucod),
    fecha   DATE,
    hora    SMALLINT,                               -- hora del día (0-23)
    PRIMARY KEY (usucod, fecha, hora)
);

-- El enunciado no le define PK: solo usucod (FK) e intentos.
CREATE TABLE intentosfallidos (
    usucod   INT REFERENCES usuario(usucod),
    intentos INT
);

-- ---------------------------------------------------------------------
-- DATOS DE PRUEBA
-- ---------------------------------------------------------------------
INSERT INTO departamento VALUES
 (1, 'Contabilidad'),
 (2, 'Recursos Humanos'),
 (3, 'Comercial'),
 (4, 'Informática'),
 (5, 'Logística'),
 (6, 'Gerencia');                -- departamento SIN usuarios

INSERT INTO sistema VALUES
 (1, 'Contabilidad'),
 (2, 'RRHH'),
 (3, 'Comercial'),
 (4, 'Inventario'),
 (5, 'Mesa de Ayuda'),
 (6, 'Business Intelligence'),
 (7, 'Tesorería'),               -- sin perfiles asociados
 (8, 'Portal Proveedores');      -- sin perfiles asociados

INSERT INTO perfil VALUES
 (1,  'Contador'),
 (2,  'Auditor'),
 (3,  'Analista RRHH'),
 (4,  'Vendedor'),
 (5,  'Consulta Comercial'),
 (6,  'Bodeguero'),
 (7,  'Soporte TI'),
 (8,  'Analista BI'),
 (9,  'Practicante'),            -- perfil SIN sistemas
 (10, 'Lector Inventario');

INSERT INTO persis (percod, siscod, modo) VALUES
 (1, 1, 'E'), (1, 6, 'L'),                 -- Contador
 (2, 1, 'L'), (2, 2, 'L'), (2, 3, 'L'),    -- Auditor
 (3, 2, 'E'),                              -- Analista RRHH
 (4, 3, 'E'), (4, 4, 'L'),                 -- Vendedor
 (5, 3, 'L'), (5, 5, 'L'),                 -- Consulta Comercial
 (6, 4, 'E'),                              -- Bodeguero
 (7, 5, 'E'), (7, 4, 'L'),                 -- Soporte TI
 (8, 6, 'E'), (8, 3, 'L'),                 -- Analista BI
 (10, 4, 'L');                             -- Lector Inventario

INSERT INTO usuario VALUES
 ( 1, 'Ana Rojas',          'ana2025',   1, 'S'),
 ( 2, 'Bruno Díaz',         'bruno*1',   1, 'S'),
 ( 3, 'Carla Soto',         'carla.s',   1, 'N'),
 ( 4, 'Diego Muñoz',        'dmunoz',    2, 'S'),
 ( 5, 'Elena Fuentes',      'elena99',   2, 'S'),
 ( 6, 'Felipe Araya',       'faraya',    2, 'S'),
 ( 7, 'Gabriela Pino',      'gpino',     3, 'S'),
 ( 8, 'Hugo Vera',          'hvera',     3, 'S'),
 ( 9, 'Isabel Castro',      'icastro',   3, 'S'),
 (10, 'Javier Morales',     'jmorales',  3, 'S'),
 (11, 'Karen Silva',        'ksilva',    3, 'S'),
 (12, 'Luis Herrera',       'lherrera',  3, 'N'),
 (13, 'Marcela Reyes',      'mreyes',    3, 'S'),
 (14, 'Nicolás Torres',     'ntorres',   3, 'S'),
 (15, 'Olga Navarro',       'onavarro',  4, 'S'),
 (16, 'Pablo Gómez',        'pgomez',    4, 'S'),
 (17, 'Rocío Campos',       'rcampos',   4, 'S'),
 (18, 'Sebastián Vargas',   'svargas',   4, 'S'),
 (19, 'Tamara Lagos',       'tlagos',    5, 'S'),
 (20, 'Ulises Bravo',       'ubravo',    5, 'S'),
 (21, 'Valentina Ortiz',    'vortiz',    5, 'S'),
 (22, 'Walter Cáceres',     'wcaceres',  5, 'N'),
 (23, 'Ximena Peña',        'xpena',     3, 'S'),
 (24, 'Yerko Sepúlveda',    'ysepulveda',3, 'S'),
 (25, 'Zoe Alarcón',        'zalarcon',  4, 'S');   -- sin perfiles

INSERT INTO usuper (usucod, percod) VALUES
 (1, 1),
 (2, 1), (2, 2),
 (3, 2),
 (4, 3),
 (5, 3), (5, 2),
 (6, 3),
 (7, 4),
 (8, 4), (8, 5),
 (9, 4),
 (10, 5),
 (11, 4),
 (12, 4),
 (13, 5),
 (14, 4),
 (15, 7),
 (16, 7), (16, 8),
 (17, 8), (17, 1),
 (18, 9),
 (19, 6),
 (20, 4), (20, 10),
 (21, 6),
 (22, 6),
 (23, 5),
 (24, 4);

INSERT INTO intentosfallidos VALUES
 ( 3, 3),     -- bloqueada
 ( 6, 2),
 ( 9, 1),
 (11, 2),
 (12, 3),     -- bloqueado
 (18, 1),
 (21, 2),
 (22, 3);     -- bloqueado

-- Conexiones históricas: últimos 13 días (pseudo-aleatorias pero reproducibles)
INSERT INTO conexion (usucod, fecha, hora)
SELECT u.usucod, CURRENT_DATE - d, 8 + (u.usucod + d) % 6
FROM usuario u
CROSS JOIN generate_series(1, 13) AS d
WHERE u.usucod <> 25
  AND (u.usucod * 7 + d * 3) % 5 < 3;

-- Segunda conexión (tarde) algunos días
INSERT INTO conexion (usucod, fecha, hora)
SELECT u.usucod, CURRENT_DATE - d, 14 + (u.usucod * d) % 5
FROM usuario u
CROSS JOIN generate_series(1, 13) AS d
WHERE u.usucod <> 25
  AND (u.usucod + d) % 4 = 0;

-- Conexiones de HOY.
-- 10 usuarios distintos con acceso al sistema 3 (Comercial) ya conectados hoy
-- (2, 5, 7, 8, 9, 10, 13, 14, 16, 23), más otros que no usan Comercial (1, 4, 15, 19).
INSERT INTO conexion (usucod, fecha, hora) VALUES
 ( 2, CURRENT_DATE, 8), ( 5, CURRENT_DATE, 8), ( 7, CURRENT_DATE, 8),
 ( 7, CURRENT_DATE, 9), ( 8, CURRENT_DATE, 8), ( 9, CURRENT_DATE, 9),
 (10, CURRENT_DATE, 8), (13, CURRENT_DATE, 9), (14, CURRENT_DATE, 9),
 (16, CURRENT_DATE, 8), (23, CURRENT_DATE, 8), (23, CURRENT_DATE, 10),
 ( 1, CURRENT_DATE, 8), ( 4, CURRENT_DATE, 9), (15, CURRENT_DATE, 8),
 (19, CURRENT_DATE, 9);

-- Resumen rápido de lo cargado
SELECT 'departamento' AS tabla, COUNT(*) AS filas FROM departamento
UNION ALL SELECT 'usuario',          COUNT(*) FROM usuario
UNION ALL SELECT 'perfil',           COUNT(*) FROM perfil
UNION ALL SELECT 'usuper',           COUNT(*) FROM usuper
UNION ALL SELECT 'sistema',          COUNT(*) FROM sistema
UNION ALL SELECT 'persis',           COUNT(*) FROM persis
UNION ALL SELECT 'conexion',         COUNT(*) FROM conexion
UNION ALL SELECT 'intentosfallidos', COUNT(*) FROM intentosfallidos;
