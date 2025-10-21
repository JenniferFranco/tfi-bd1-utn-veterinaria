-- 08_transacciones.sql
-- Trabajo Integrador - Etapa 5
-- TRANSACCIONES (procedimiento con retry ante deadlock) - Standalone
--
-- Cómo usar:
-- 1) Ejecutá este archivo completo una vez (define el procedimiento).
-- 2) Probá las llamadas de ejemplo al final (una exitosa y otra que fuerza error FK para ver el ROLLBACK).
--
-- Requisitos: esquema 'gestion_veterinaria' con tabla 'mascota' y FK a 'persona' en 'duenio_id'.

USE gestion_veterinaria;

DELIMITER $$

CREATE OR REPLACE PROCEDURE sp_transferir_mascota(
    IN p_mascota_id BIGINT, 
    IN p_nuevo_duenio_id BIGINT
)
BEGIN
    -- Variables para el manejo de errores y reintentos
    DECLARE retry_count INT DEFAULT 0;
    DECLARE max_retries INT DEFAULT 2; -- Máximo de reintentos
    DECLARE deadlock_detected BOOLEAN DEFAULT FALSE;

    -- Manejador de errores específico para deadlocks (error 1213)
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @errno = MYSQL_ERRNO;
        IF @errno = 1213 THEN
            SET deadlock_detected = TRUE; -- Marcamos que ocurrió un deadlock
        ELSE
            RESIGNAL; -- Si es otro error, lo relanzamos
        END IF;
    END;

    -- Bucle para reintentar en caso de deadlock
    retry_loop: LOOP
        SET deadlock_detected = FALSE; 

        START TRANSACTION;

        -- La operación crítica: actualizar el dueño de la mascota
        UPDATE mascota 
        SET duenio_id = p_nuevo_duenio_id 
        WHERE id = p_mascota_id;

        -- Si no hubo error, confirmamos
        IF NOT deadlock_detected THEN
            COMMIT;
            SELECT CONCAT('Mascota ', p_mascota_id, ' transferida exitosamente al dueño ', p_nuevo_duenio_id) AS Resultado;
            LEAVE retry_loop; -- Salimos del bucle
        ELSE
            -- Si hubo deadlock, deshacemos y preparamos reintento
            ROLLBACK;
            SET retry_count = retry_count + 1;
            IF retry_count > max_retries THEN
                SELECT CONCAT('Error: Deadlock persistente al transferir mascota ', p_mascota_id, '. Máximo de reintentos (', max_retries, ') superado.') AS Resultado;
                LEAVE retry_loop; -- Salimos si superamos reintentos
            ELSE
                SELECT CONCAT('Advertencia: Deadlock detectado. Reintentando transferencia (intento ', retry_count, '/', max_retries, ')...') AS Estado;
                DO SLEEP(0.5); -- Espera breve (backoff)
            END IF;
        END IF;
    END LOOP retry_loop;

END$$

DELIMITER ;

-- === PRUEBAS ===
-- Ajustá IDs reales según tus datos.

-- Ejemplo exitoso (asegurate que p_nuevo_duenio_id exista en persona.id):
-- CALL sp_transferir_mascota(1, 176);

-- Ejemplo que fuerza error de FK y demuestra ROLLBACK (ID inexistente):
-- CALL sp_transferir_mascota(2, 999999);
