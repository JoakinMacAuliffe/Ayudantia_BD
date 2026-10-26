CREATE OR REPLACE FUNCTION limpiar_errores_post_login()
RETURNS trigger 
LANGUAGE plpgsql
AS $$
BEGIN
    -- NEW representa el nuevo registro que se acaba de insertar en Historial_Conexiones.
    DELETE FROM Registro_Errores 
    WHERE id_usuario = NEW.id_usuario;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_limpiar_errores
AFTER INSERT ON Historial_Conexiones
FOR EACH ROW
EXECUTE FUNCTION limpiar_errores_post_login();