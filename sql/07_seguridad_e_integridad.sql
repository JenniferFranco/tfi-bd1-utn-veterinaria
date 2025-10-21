/*Este script implementa la seguridad y validación de la BBDD gestion_veterinaria.
    Crea un usuario 'usuario_consulta' con privilegios mínimos.
    Define vistas para ocultar datos sensibles (DNI, microchip).
    Contiene un Stored Procedure seguro y pruebas de integridad (PK/FK). */

USE gestion_veterinaria;

-- Creacion usuario con privilegios mínimos
DROP USER IF EXISTS 'usuario_consulta'@'localhost';
CREATE USER 'usuario_consulta'@'localhost' IDENTIFIED BY 'Segura123!';

--  SELECT solo en vistas (no sobre tablas completas)
-- No damos acceso a las tablas directamente
FLUSH PRIVILEGES;

-- Creacion de Vistas para ocultar datos sensibles
-- Vista pública de dueños (oculta DNI, email y teléfono)
DROP VIEW IF EXISTS vw_duenios_publico;
CREATE VIEW vw_duenios_publico AS
SELECT 
    p.id,
    p.nombre,
    p.apellido,
    d.calle,
    d.numero,
    c.localidad
FROM persona p
JOIN direccion d ON d.id = p.direccion_id
JOIN cod_postal c ON c.id = d.cod_postal_id
WHERE p.eliminado = FALSE;

-- Vista de mascotas y dueños (sin mostrar el codigo del microchip completo)
DROP VIEW IF EXISTS vw_mascotas_publico;
CREATE VIEW vw_mascotas_publico AS
SELECT 
    m.id AS mascota_id,
    m.nombre AS mascota,
    r.nombre AS raza,
    e.nombre AS especie,
    CONCAT(p.apellido, ', ', p.nombre) AS duenio,
    CASE 
        WHEN m.microchip_id IS NULL THEN 'SIN CHIP'
        ELSE CONCAT('CHIP-', RIGHT(mc.codigo, 4)) -- solo últimos dígitos
    END AS microchip_masked
FROM mascota m
JOIN raza r ON r.id = m.raza_id
JOIN especie e ON e.id = r.especie_id
JOIN persona p ON p.id = m.duenio_id
LEFT JOIN microchip mc ON mc.id = m.microchip_id;

-- Otorgamos permisos de lectura SOLO sobre las vistas
GRANT SELECT ON gestion_veterinaria.vw_duenios_publico TO 'usuario_consulta'@'localhost';
GRANT SELECT ON gestion_veterinaria.vw_mascotas_publico TO 'usuario_consulta'@'localhost';
FLUSH PRIVILEGES;

-- Pruebas de Integridad (violaciones PK/FK)

-- 1. Violación de PK: insertar un id ya existente en especie
-- Esperado: ERROR 1062 Duplicate entry
INSERT INTO especie (id, nombre) VALUES (1, 'Duplicado');

-- 2. Violación de FK: mascota con duenio_id inexistente
-- Esperado: ERROR 1452 Cannot add or update a child row
INSERT INTO mascota (nombre, raza_id, fecha_nacimiento, duenio_id)
VALUES ('PruebaFK', 1, '2020-01-01', 999999);

-- Procedimiento almacenado seguro (anti-inyección)
DROP PROCEDURE IF EXISTS buscar_mascota_por_nombre;
DELIMITER $$
CREATE PROCEDURE buscar_mascota_por_nombre(IN p_nombre VARCHAR(60))
BEGIN
    -- Consulta parametrizada: NO hay SQL dinámico
    SELECT m.id, m.nombre, r.nombre AS raza, e.nombre AS especie
    FROM mascota m
    JOIN raza r ON r.id = m.raza_id
    JOIN especie e ON e.id = r.especie_id
    WHERE m.nombre = p_nombre;
END $$
DELIMITER ;

-- Uso normal:
CALL buscar_mascota_por_nombre('Luna');

-- Prueba anti-inyección:
-- Intento malicioso: "' OR '1'='1"
-- Esperado: no devuelve todas las filas, solo buscará literal ese nombre
CALL buscar_mascota_por_nombre("' OR '1'='1");

-- Pruebas de acceso restringido
-- (Ejecutar en otra sesión conectando con el usuario limitado)
-- mysql -u usuario_consulta -p

-- Correcto:
-- SELECT * FROM gestion_veterinaria.vw_mascotas_publico LIMIT 5;

-- Incorrecto (debe fallar):
-- INSERT INTO persona (dni,nombre,apellido) VALUES ('1111','X','Y');
-- -> ERROR 1142 (INSERT command denied)



