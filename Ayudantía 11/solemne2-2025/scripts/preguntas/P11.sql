/* =====================================================================
   PREGUNTA 11
   Para acelerar reportes, se decide desnormalizar y crear la tabla
   dept_connection_summary(depcod, total_conexiones BIGINT, last_update TIMESTAMP).
   Diseña la DDL para esa tabla y crea un trigger que, al insertar una nueva fila
   en conexion, incremente total_conexiones en la fila correspondiente al depcod
   del usuario que se conectó. Explica qué consideraciones de integridad y
   concurrencia se deben tener.
   ===================================================================== */

-- Tu respuesta aquí:


