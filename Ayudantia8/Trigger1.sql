CREATE OR REPLACE FUNCTION limpiar_errores_desbloqueo()
RETURNS trigger 
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM Registro_Errores 
    WHERE id_usuario = NEW.id_usuario;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_desbloqueo_usuario
AFTER UPDATE ON Usuarios
FOR EACH ROW
WHEN (OLD.estado_cuenta = 'Bloqueada' AND NEW.estado_cuenta = 'Activa')
EXECUTE FUNCTION limpiar_errores_desbloqueo();