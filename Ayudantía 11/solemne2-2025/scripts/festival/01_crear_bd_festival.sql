-- Script de inicialización del contenedor (solo corre con un volumen nuevo).
-- Crea la BD festival y carga el modelo. No hace falta ejecutarlo a mano.
CREATE DATABASE festival;
\connect festival
\i /festival/00_reset_festival.sql
