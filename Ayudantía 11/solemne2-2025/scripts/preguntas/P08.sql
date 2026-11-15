/* =====================================================================
   PREGUNTA 8
   Cuando un usuario se autentica correctamente: (a) debe registrarse la conexión
   en conexion (con usucod, fecha, hora), y (b) si existía un registro en
   intentosfallidos para ese usuario, éste debe eliminarse (resetear).
   Todo debe hacerse en una única transacción para evitar dejar intentos
   pendientes si ocurre un fallo en el registro de la conexión.
   Construya un trigger que dada una conexión proceda con el punto b de esta pregunta.
   ===================================================================== */

-- Tu respuesta aquí:


