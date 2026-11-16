-- Script de inicialización del contenedor (solo corre con un volumen nuevo).
-- Crea la BD biblioteca y carga el modelo. No hace falta ejecutarlo a mano.
CREATE DATABASE biblioteca;
\connect biblioteca
\i /biblioteca/00_reset_biblioteca.sql
