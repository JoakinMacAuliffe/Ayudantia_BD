# Solemne 2 (2do sem. 2025): BD de práctica

PostgreSQL 16 con el modelo de control de accesos de la prueba y pgAdmin 4 en el navegador.

## Levantar / apagar

```bash
docker compose up -d      # levantar
docker compose stop       # apagar (conserva los datos)
docker compose down -v    # borrar todo (contenedores + datos)
```

- **pgAdmin:** http://localhost:5050 (sin login). El servidor "Solemne 2 (2025)" ya está configurado.
- Conexión directa (DBeaver, VS Code, etc.): `localhost:5433`, BD `solemne2`, usuario `postgres`, clave `postgres`.

## Cómo trabajar en pgAdmin

1. Servers → Solemne 2 (2025) → Databases → **solemne2** → clic derecho → **Query Tool**.
2. Abrir un archivo: ícono de carpeta (Open File) → escribir `/solemne` en la ruta.
   - `/solemne/preguntas/Pxx.sql`: solo el enunciado, para resolver.
   - `/solemne/soluciones/Pxx_solucion.sql`: la solución comentada (ábrela cuando quieras verla).
3. **F5** ejecuta todo el script, o **solo lo seleccionado** si hay texto seleccionado.

## Resetear la BD

Abre `/solemne/00_reset_bd.sql` y ejecútalo completo (F5). Borra tablas, triggers y funciones
creadas en las soluciones y vuelve a cargar los datos de prueba.

Las conexiones se generan relativas a la fecha actual, de modo que "hoy" siempre tiene datos
(P5 depende de eso). Si levantaste el contenedor otro día, ejecuta el reset antes de la P5.

## Datos de prueba pensados para cada pregunta

| Pregunta | Qué hay en los datos |
|---|---|
| P1 | 3 usuarios con 2 intentos (Felipe, Karen, Valentina); 3 bloqueados con 3 intentos |
| P2 | Tesorería y Portal Proveedores no tienen perfiles |
| P4 | Carla Soto (3) bloqueada para probar el desbloqueo |
| P5 | Comercial ya tiene 10 usuarios conectados hoy; Yerko (24) debe ser rechazado |
| P6 | Departamento Gerencia sin usuarios; Zoe sin conexiones |
| P7 | 4 usuarios con E+L en un mismo sistema; Ulises tiene 2 perfiles **ambos L** (la trampa de la pauta) |
| P9 | Sebastián tiene un perfil sin sistemas (sale 0); Zoe no tiene perfiles (no sale) |

## BD `festival` (Consultas SQL: Festival de Cine)

En el mismo servidor hay una segunda BD, **festival**, con el modelo `espectadores`, `directores`,
`peliculas`, `generos` (FK reflexiva `subgenero_id`), `entradas` y `salas`.

- pgAdmin: Servers → Solemne 2 (2025) → Databases → **festival** → Query Tool (ojo: no en `solemne2`).
- Conexión directa: igual que arriba, pero con BD `festival`.
- Resetear: abrir `/solemne/festival/00_reset_festival.sql` **conectado a festival** y ejecutarlo (F5).
- Los resultados esperados de las 5 preguntas están comentados al final de ese script.

Trampas en los datos: Camila y Diego dirigen 2 películas de terror/c. ficción (hace falta `DISTINCT` en P3).
Hay subgéneros ("terror psicológico", "ciberpunk") que solo aparecen si se recorre `subgenero_id`.
En P5 hay otra Valentina (Sepúlveda) y otro Rojas (Andrés), y 2 espectadores vieron las dos
películas de Valentina Rojas.

## BD `biblioteca` (Control 3: Ejercicio 1)

Tercera BD en el mismo servidor, con el modelo `socios`, `autores`, `categorias`, `libros` y `prestamos`
(solo lo necesario para el Ejercicio 1: procedimiento `registrar_prestamo` y trigger de devolución).

- pgAdmin: Databases → **biblioteca** → Query Tool.
- `/solemne/biblioteca/E1.sql`: enunciado, espacio para responder y pruebas con resultado esperado.
- `/solemne/biblioteca/E1_solucion.sql`: solución de la pauta.
- Resetear: `/solemne/biblioteca/00_reset_biblioteca.sql` **conectado a biblioteca** (también borra
  el procedimiento y el trigger). Las fechas son relativas a hoy, así que las multas esperadas siempre cuadran.

| Caso | Dato |
|---|---|
| Caso feliz `CALL registrar_prestamo(15, 40)` | Socio 15 tiene 2 vigentes (+1 devuelto que no cuenta) |
| Límite de 3 | Socio 16 tiene 3 vigentes; el 15 llega a 3 tras el caso feliz |
| Libro no existe / sin stock | Libro 41 no existe; libro 43 tiene 0 ejemplares |
| Multas al devolver hoy | Préstamo 1: 0 · 2: 1500 · 3: 0 (justo 7 días) · 4: 2500 |
| Devolución anterior al préstamo | Préstamo 5 con `CURRENT_DATE - 5` |
| El trigger no debe dispararse | Préstamo 7 ya devuelto (multa 1000) |

> La pauta original usa columnas que no existen en el modelo (`usuariocod`, `fechahora`,
> `idconexion`, `estado`, `tipoperfil`, etc.). Las soluciones usan los nombres del enunciado y
> cada una termina con una sección "COMPARACIÓN CON LA PAUTA".
