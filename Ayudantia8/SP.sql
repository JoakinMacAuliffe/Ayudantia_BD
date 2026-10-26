CREATE OR REPLACE PROCEDURE iniciar_sesion(
    p_id_usuario IN INT,
    p_contrasena_ingresada IN VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
-- Declaración de variables
    v_contrasena_bd VARCHAR(50);
    v_estado_cuenta VARCHAR(20);
    v_errores_acumulados INT;
BEGIN

    -- Ingresar datos hacia variables (INTO)
    SELECT contrasena, estado_cuenta INTO v_contrasena_bd, v_estado_cuenta
    FROM Usuarios
    WHERE id_usuario = p_id_usuario;

    -- Si el SELECT no encuentra nada, aborta la operación
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El usuario con ID % no está registrado.', p_id_usuario;
    END IF;

    -- Valida si la cuenta estaba bloqueada previamente
    IF v_estado_cuenta = 'Bloqueada' THEN
        RAISE EXCEPTION 'Acceso denegado: Tu cuenta se encuentra bloqueada por seguridad.';
    END IF;

    -- 3. Lógica de validación de contraseña
    IF v_contrasena_bd = p_contrasena_ingresada THEN
        
        -- Login correcto: Se registra hora de ingreso y se borra registro de errores
        INSERT INTO Historial_Conexiones (id_usuario, fecha_conexion, hora_conexion)
        VALUES (p_id_usuario, CURRENT_DATE, EXTRACT(HOUR FROM CURRENT_TIME));
        DELETE FROM Registro_Errores WHERE id_usuario = p_id_usuario;
        
        RAISE NOTICE '¡Login exitoso! Bienvenido al sistema.';

    ELSE

        -- Login incorrecto

        INSERT INTO Registro_Errores (id_usuario, cantidad_errores)
        VALUES (p_id_usuario, 1)
        ON CONFLICT (id_usuario) 
        DO UPDATE SET cantidad_errores = Registro_Errores.cantidad_errores + 1;

        -- Ingresar cantidad de errores en la variable v_errores_acumulados
        SELECT cantidad_errores INTO v_errores_acumulados 
        FROM Registro_Errores 
        WHERE id_usuario = p_id_usuario;

        -- Se bloquea el usuario al tener 3 errores
        IF v_errores_acumulados >= 3 THEN
            UPDATE Usuarios 
            SET estado_cuenta = 'Bloqueada' 
            WHERE id_usuario = p_id_usuario;
            
            RAISE EXCEPTION 'Cuenta bloqueada automáticamente tras 3 intentos fallidos.';
        ELSE
            RAISE EXCEPTION 'Contraseña incorrecta. Llevas % de 3 intentos.', v_errores_acumulados;
        END IF;

    END IF;

    COMMIT;

END;
$$;