/* =====================================================================
   FESTIVAL DE CINE - BASE DE DATOS (Consultas SQL, pregunta 2)

   ESTE SCRIPT DEJA LA BD "festival" EN SU ESTADO INICIAL.
   - Ejecútalo conectado a la BD festival (NO a solemne2).
   - Se ejecuta solo la primera vez que se levanta el contenedor.
   - Puedes volver a ejecutarlo completo (F5) cuando quieras resetear.
   ===================================================================== */

DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

-- ---------------------------------------------------------------------
-- DDL (tal como lo define el enunciado)
-- ---------------------------------------------------------------------
CREATE TABLE espectadores (
    id        INT PRIMARY KEY,
    nombre    VARCHAR(50),
    apellido  VARCHAR(50),
    email     VARCHAR(100),
    telefono  VARCHAR(20)
);

CREATE TABLE directores (
    id        INT PRIMARY KEY,
    nombre    VARCHAR(50),
    apellido  VARCHAR(50),
    pais      VARCHAR(50)
);

CREATE TABLE salas (
    id        INT PRIMARY KEY,
    nombre    VARCHAR(50),
    capacidad INT
);

-- subgenero_id referencia a otro registro de la misma tabla (FK reflexiva)
CREATE TABLE generos (
    id           INT PRIMARY KEY,
    nombre       VARCHAR(50),
    subgenero_id INT REFERENCES generos(id)
);

CREATE TABLE peliculas (
    id          INT PRIMARY KEY,
    titulo      VARCHAR(100),
    genero_id   INT REFERENCES generos(id),
    director_id INT REFERENCES directores(id),
    sala_id     INT REFERENCES salas(id)
);

CREATE TABLE entradas (
    espectador_id INT REFERENCES espectadores(id),
    pelicula_id   INT REFERENCES peliculas(id),
    fecha_compra  DATE,
    PRIMARY KEY (espectador_id, pelicula_id)
);

-- ---------------------------------------------------------------------
-- DATOS DE PRUEBA
-- ---------------------------------------------------------------------
INSERT INTO salas VALUES
 (1, 'Sala Lumière',  120),
 (2, 'Sala Méliès',    80),
 (3, 'Sala Varda',     60),
 (4, 'Sala Kurosawa',  40);

INSERT INTO directores VALUES
 (1, 'Valentina', 'Rojas',      'Chile'),
 (2, 'Tomás',     'Herrera',    'Argentina'),
 (3, 'Camila',    'Fuentes',    'Chile'),
 (4, 'Diego',     'Morales',    'México'),
 (5, 'Valentina', 'Sepúlveda',  'Chile'),     -- otra Valentina (trampa P5)
 (6, 'Andrés',    'Rojas',      'Perú'),      -- otro Rojas (trampa P5)
 (7, 'Lucía',     'Navarro',    'España'),
 (8, 'Martín',    'Ibarra',     'Uruguay');   -- sin películas

-- Géneros "padre" con subgenero_id NULL; los subgéneros apuntan a su género padre
INSERT INTO generos VALUES
 (1, 'drama',              NULL),
 (2, 'comedia',            NULL),
 (3, 'terror',             NULL),
 (4, 'ciencia ficción',    NULL),
 (5, 'documental',         NULL),
 (6, 'terror psicológico', 3),
 (7, 'ciberpunk',          4),
 (8, 'comedia romántica',  2);

INSERT INTO peliculas VALUES
 ( 1, 'Noche en el Observatorio', 4, 3, 1),  -- ciencia ficción, Camila Fuentes
 ( 2, 'La Casa del Silencio',     3, 2, 2),  -- terror, Tomás Herrera
 ( 3, 'Marea Roja',               1, 1, 1),  -- drama, Valentina Rojas
 ( 4, 'Órbita Cero',              4, 4, 3),  -- ciencia ficción, Diego Morales
 ( 5, 'El Último Verano',         1, 5, 2),  -- drama, Valentina Sepúlveda
 ( 6, 'Ecos del Desierto',        5, 1, 4),  -- documental, Valentina Rojas
 ( 7, 'Neón Austral',             7, 6, 3),  -- ciberpunk (subgénero de c. ficción), Andrés Rojas
 ( 8, 'Susurros',                 6, 7, 4),  -- terror psicológico (subgénero de terror), Lucía Navarro
 ( 9, 'Risas en Valparaíso',      2, 2, 2),  -- comedia, Tomás Herrera
 (10, 'Amor en Tránsito',         8, 4, 3),  -- comedia romántica, Diego Morales
 (11, 'Planeta Errante',          4, 4, 1),  -- ciencia ficción, Diego Morales (sin entradas)
 (12, 'Cielo de Plomo',           3, 3, 4);  -- terror, Camila Fuentes (sin entradas)

INSERT INTO espectadores VALUES
 ( 1, 'Ana',       'Pérez',     'ana.perez@mail.cl',       '+56911111111'),
 ( 2, 'Benjamín',  'Soto',      'benjamin.soto@mail.cl',   '+56922222222'),
 ( 3, 'Catalina',  'Muñoz',     'catalina.munoz@mail.cl',  '+56933333333'),
 ( 4, 'Daniel',    'Reyes',     'daniel.reyes@mail.cl',    '+56944444444'),
 ( 5, 'Elena',     'Castro',    'elena.castro@mail.cl',    '+56955555555'),
 ( 6, 'Felipe',    'Vargas',    'felipe.vargas@mail.cl',   '+56966666666'),
 ( 7, 'Gabriela',  'Díaz',      'gabriela.diaz@mail.cl',   '+56977777777'),
 ( 8, 'Hugo',      'Torres',    'hugo.torres@mail.cl',     '+56988888888'),
 ( 9, 'Isidora',   'Rojas',     'isidora.rojas@mail.cl',   '+56999999999'),
 (10, 'Joaquín',   'Silva',     'joaquin.silva@mail.cl',   '+56910101010'),
 (11, 'Karina',    'López',     'karina.lopez@mail.cl',    '+56911011011'),
 (12, 'Luis',      'Contreras', 'luis.contreras@mail.cl',  '+56912121212'),
 (13, 'Martina',   'Flores',    'martina.flores@mail.cl',  '+56913131313'),
 (14, 'Nicolás',   'Araya',     'nicolas.araya@mail.cl',   '+56914141414'),
 (15, 'Olivia',    'Espinoza',  'olivia.espinoza@mail.cl', '+56915151515');  -- sin entradas

-- (espectador, película); la fecha se reparte entre el 3 y el 9 de noviembre de 2025
INSERT INTO entradas (espectador_id, pelicula_id, fecha_compra)
SELECT e, p, DATE '2025-11-03' + ((e + p) % 7)
FROM (VALUES
  (1,1),(1,2),(1,3),(1,4),(1,6),
  (2,1),(2,3),(2,4),
  (3,1),(3,3),
  (4,3),(4,6),
  (5,1),(5,4),(5,5),(5,7),
  (6,2),
  (7,2),(7,3),(7,4),
  (8,1),(8,5),
  (9,7),(9,8),
  (10,1),(10,3),(10,4),(10,9),(10,10),
  (11,3),(11,9),
  (12,2),(12,4),(12,5),(12,7),
  (13,1),(13,3),(13,4),
  (14,1),(14,2),(14,3),(14,5),(14,7),(14,8),(14,9)
) AS t(e, p);

/* ---------------------------------------------------------------------
   RESULTADOS ESPERADOS
   P1: Camila Fuentes.
   P2: Marea Roja (9, Valentina Rojas), Noche en el Observatorio (8, Camila
       Fuentes), Órbita Cero (7, Diego Morales). La 4ª (La Casa del Silencio)
       tiene 5, así que no hay empates en el corte.
   P3: Solo 'terror' y 'ciencia ficción': Camila Fuentes, Tomás Herrera, Diego
       Morales (Camila y Diego aparecen 2 veces sin DISTINCT).
       Si se incluyen los subgéneros (subgenero_id = 3 o 4): + Andrés Rojas
       (ciberpunk) y Lucía Navarro (terror psicológico).
   P4: 8 espectadores (1, 2, 5, 7, 10, 12, 13, 14).
   P5: 9 espectadores distintos (11 filas sin DISTINCT: Ana y Daniel vieron
       las dos películas de Valentina Rojas). Filtrar solo por nombre o solo
       por apellido trae películas de Valentina Sepúlveda o Andrés Rojas.
   --------------------------------------------------------------------- */
