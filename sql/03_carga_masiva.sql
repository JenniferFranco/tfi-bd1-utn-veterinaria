USE gestion_veterinaria;

-- 1: CONFIGURACIÓN DE PARÁMETROS Y LIMPIEZA DEL ESQUEMA

-- Parámetros principales para definir el volumen de datos a generar.
SET @NUM_MASCOTAS = 35000; -- Define el número de mascotas, dueños y microchips.
SET @NUM_VETERINARIOS = 175; -- Proporción recomendada: 1 veterinario por cada 200 mascotas.

-- Desactiva temporalmente la validación de claves foráneas para permitir un borrado masivo y eficiente de las tablas sin errores de dependencia.
SET FOREIGN_KEY_CHECKS = 0;

-- Se utiliza TRUNCATE TABLE por ser la operación más rápida para vaciar tablas.
TRUNCATE TABLE implantacion;
TRUNCATE TABLE mascota;
TRUNCATE TABLE raza;
TRUNCATE TABLE especie;
TRUNCATE TABLE veterinario;
TRUNCATE TABLE persona;
TRUNCATE TABLE veterinaria;
TRUNCATE TABLE direccion;
TRUNCATE TABLE cod_postal;
TRUNCATE TABLE provincia;
TRUNCATE TABLE microchip;

-- Se reactiva la validación de claves foráneas para mantener la integridad de los datos durante el proceso de inserción.
SET FOREIGN_KEY_CHECKS = 1;

-- 2: CREACIÓN Y POBLADO DE TABLAS SEMILLA

DROP TABLE IF EXISTS seed_nombres, seed_apellidos, seed_calles;

CREATE TABLE seed_nombres (id INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(50));
CREATE TABLE seed_apellidos (id INT AUTO_INCREMENT PRIMARY KEY, apellido VARCHAR(50));
CREATE TABLE seed_calles (id INT AUTO_INCREMENT PRIMARY KEY, calle VARCHAR(50));

INSERT INTO seed_nombres (nombre) VALUES ('Juan'),('Maria'),('Carlos'),('Ana'),('Luis'),('Laura'),('Pedro'),('Sofia'),('Miguel'),('Elena'),('Diego'),('Valentina');
INSERT INTO seed_apellidos (apellido) VALUES ('Gomez'),('Perez'),('Rodriguez'),('Fernandez'),('Lopez'),('Martinez'),('Sanchez'),('Diaz'),('Torres'),('Ruiz'),('Romero'),('Alvarez');
INSERT INTO seed_calles (calle) VALUES ('San Martín'),('Rivadavia'),('Belgrano'),('Sarmiento'),('Av. de Mayo'),('Av. Corrientes'),('Av. Santa Fe'),('Florida');

-- Almacenamos los conteos en variables para usarlas en cálculos con el operador módulo (%).
SET @CANT_NOMBRES = (SELECT COUNT(*) FROM seed_nombres);
SET @CANT_APELLIDOS = (SELECT COUNT(*) FROM seed_apellidos);
SET @CANT_CALLES = (SELECT COUNT(*) FROM seed_calles);

-- 3: INSERCIÓN DE DATOS DE CATÁLOGO

-- Inserción de datos maestros que son de bajo volumen y alta referencia.
INSERT INTO provincia (nombre) VALUES ('Buenos Aires'),('Córdoba'),('Santa Fe'),('Mendoza'),('Tucumán');

INSERT INTO especie (nombre) VALUES ('Perro'),('Gato'),('Ave');

-- Bloque de inserción de razas reales
INSERT INTO raza (nombre, especie_id) VALUES
-- Razas de Perro (asociadas a especie_id = 1)
('Labrador Retriever', 1),
('Pastor Alemán', 1),
('Bulldog Francés', 1),
('Golden Retriever', 1),
('Beagle', 1),
-- Razas de Gato (asociadas a especie_id = 2)
('Siamés', 2),
('Persa', 2),
('Maine Coon', 2),
('Ragdoll', 2),
('Bengala', 2),
-- Razas de Ave (asociadas a especie_id = 3)
('Canario', 3),
('Periquito', 3),
('Cacatúa', 3);

-- Se sigue calculando la cantidad total para usarla en la generación masiva.
SET @CANT_RAZAS = (SELECT COUNT(*) FROM raza);

-- 4: GENERACIÓN MASIVA DE DATOS

-- 4.1) Direcciones, Códigos Postales y la Única Veterinaria
INSERT INTO cod_postal (cod_postal, localidad, provincia_id)
WITH RECURSIVE numbers(n) AS (
  SELECT 1 UNION ALL SELECT n + 1 FROM numbers WHERE n <= 100
)
SELECT
    LPAD(n, 4, '0'),
    CONCAT('Localidad ', n),
    1 + (n % 5)
FROM numbers;
    
-- Calculamos el total de direcciones necesarias y lo guardamos en una variable.
SET @TOTAL_DIRECCIONES = @NUM_MASCOTAS + @NUM_VETERINARIOS + 1;   
 
INSERT INTO direccion (calle, numero, cod_postal_id)
WITH RECURSIVE numbers(n) AS (
    SELECT 1 
    UNION ALL 
    SELECT n + 1 FROM numbers WHERE n < @TOTAL_DIRECCIONES
)
SELECT 
    (SELECT calle FROM seed_calles WHERE id = 1 + (n % @CANT_CALLES)), 
    100 + (n % 2500),
    -- forma egura de asignar un código postal
    (SELECT id FROM cod_postal ORDER BY RAND() LIMIT 1)
FROM 
    numbers;
    
INSERT INTO veterinaria (id, nombre, direccion_id) VALUES (1, 'Clínica Veterinaria Central', 1);

-- 4.2) Personas (Dueños y Veterinarios)
-- Capturamos el ID MÍNIMO de las direcciones disponibles para personas.
SET @MIN_DIRECCION_ID_PERSONA = 2; -- La dirección 1 es de la clínica.
-- Capturamos la cantidad de direcciones disponibles para personas.
SET @CANT_DIRECCIONES_PERSONAS = (SELECT COUNT(*) FROM direccion) - 1;

INSERT INTO persona (dni, nombre, apellido, email, direccion_id)
WITH RECURSIVE numbers(n) AS (
    SELECT 1 
    UNION ALL 
    SELECT n + 1 FROM numbers WHERE n <= (@NUM_MASCOTAS + @NUM_VETERINARIOS)
)
SELECT 
   -- No usamos RAND() para garantizar la unicidad del DNI.
    20000000 + n,
    (SELECT nombre FROM seed_nombres WHERE id = 1 + (n % @CANT_NOMBRES)),
    (SELECT apellido FROM seed_apellidos WHERE id = 1 + (n % @CANT_APELLIDOS)),
    CONCAT('user', n, '@example-mail.com'),
    -- 3. Usamos los valores reales para asignar una dirección que SIEMPRE existe.
    @MIN_DIRECCION_ID_PERSONA + (n % @CANT_DIRECCIONES_PERSONAS)
FROM numbers;

-- 4.3) Asignación de Roles: Veterinarios
INSERT INTO veterinario (id, matricula_profesional, veterinaria_id)
SELECT 
    id, 
    CONCAT('MN-', LPAD(id, 6, '0')),
    1 -- Todos se asignan a la única clínica (ID=1)
FROM 
    persona 
WHERE 
    id <= @NUM_VETERINARIOS; -- seleccionamos las personas cuyo ID está en el rango deseado

-- 4.4) Microchips y Mascotas
INSERT INTO microchip (codigo) 
WITH RECURSIVE numbers(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM numbers WHERE n <= @NUM_MASCOTAS) 
SELECT CONCAT('CHIP-2025-', LPAD(n, 8, '0')) 
FROM numbers;

-- Capturamos en variables los IDs iniciales REALES de dueños y microchips.
-- Esto hace que el script funcione siempre, sin importar cómo se reinicie el AUTO_INCREMENT.
SET @MIN_DUENIO_ID = (SELECT MIN(id) FROM persona WHERE id > @NUM_VETERINARIOS);
SET @MIN_MICROCHIP_ID = (SELECT MIN(id) FROM microchip);

-- insertamos las mascotas usando estos IDs reales como base.
INSERT INTO mascota (nombre, raza_id, fecha_nacimiento, duenio_id, microchip_id)
WITH RECURSIVE numbers(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM numbers WHERE n <= @NUM_MASCOTAS)
SELECT 
    ELT(1 + (n % 10), 'Bobby','Luna','Rocky','Lola','Max','Coco','Toby','Nala','Simba','Milo'),
    1 + (n % @CANT_RAZAS),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 4000) DAY),
    -- Asigna un 'duenio_id' que garantiza que la persona existe.
    (@MIN_DUENIO_ID + n - 1),
    -- Asigna un 'microchip_id' que garantiza que el microchip existe.
    CASE WHEN (n % 10) < 7 THEN (@MIN_MICROCHIP_ID + n - 1) ELSE NULL END
FROM numbers;

-- 4.5) Implantaciones
INSERT INTO implantacion (fecha_implantacion, veterinario_id, microchip_id)
SELECT 
    DATE_ADD(m.fecha_nacimiento, INTERVAL FLOOR(30 + RAND() * 500) DAY),
    v.id,
    m.microchip_id
FROM mascota m
JOIN veterinario v ON v.id = 1 + (m.id % @NUM_VETERINARIOS)
WHERE m.microchip_id IS NOT NULL;

-- 5: CHEQUEOS DE VALIDACIÓN

-- CHEQUEO 1: CONTEO GENERAL DE REGISTROS - Realizar un recuento rápido de todas las tablas principales.
SELECT 'veterinaria', COUNT(*) FROM veterinaria 
UNION ALL SELECT 'provincia', COUNT(*) FROM provincia 
UNION ALL SELECT 'cod_postal', COUNT(*) FROM cod_postal 
UNION ALL SELECT 'direccion', COUNT(*) FROM direccion 
UNION ALL SELECT 'persona', COUNT(*) FROM persona 
UNION ALL SELECT 'veterinario', COUNT(*) FROM veterinario
UNION ALL SELECT 'especie', COUNT(*) FROM especie 
UNION ALL SELECT 'raza', COUNT(*) FROM raza UNION ALL SELECT 'microchip', COUNT(*) FROM microchip
UNION ALL SELECT 'mascota', COUNT(*) FROM mascota 
UNION ALL SELECT 'implantacion', COUNT(*) FROM implantacion; 

-- CHEQUEO 2: VALIDACIÓN DE INTEGRIDAD DE DATOS (1 a 1) - Auditar la regla de negocio que establece que un microchip solo puede ser asignado a una única mascota.
-- Resultado esperado: 0 filas. Si devuelve alguna fila, indica un error grave en los datos, ya que habría microchips duplicados.
SELECT microchip_id, COUNT(*) AS num_asignaciones 
FROM mascota 
	WHERE microchip_id IS NOT NULL 
    GROUP BY microchip_id 
    HAVING num_asignaciones > 1;

-- CHEQUEO 3: MUESTRA DE DATOS INTEGRADOS (SANITY CHECK)
-- Sirve para confirmar visualmente que las relaciones (JOINs) funcionan como se espera y que los datos combinados son coherentes.
SELECT m.id, m.nombre AS mascota, r.nombre AS raza, e.nombre AS especie, p.apellido AS duenio_apellido, p.nombre AS duenio_nombre
FROM mascota m 
JOIN raza r ON r.id = m.raza_id 
JOIN especie e ON e.id = r.especie_id 
JOIN persona p ON p.id = m.duenio_id
LIMIT 10;

-- CHEQUEO 4: VALIDACIÓN DE REGLA DE NEGOCIO (DISTRIBUCIÓN DE DATOS) - Verificar que la proporción de mascotas con y sin microchip
-- coincida con la lógica definida en el script de carga (70% con chip).
SELECT
    COUNT(*) AS total_mascotas,
    SUM(CASE WHEN microchip_id IS NOT NULL THEN 1 ELSE 0 END) AS con_chip,
    SUM(CASE WHEN microchip_id IS NULL THEN 1 ELSE 0 END) AS sin_chip,
    ROUND((SUM(CASE WHEN microchip_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS pct_con_chip,
    ROUND((SUM(CASE WHEN microchip_id IS NULL THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS pct_sin_chip
FROM
    mascota;

-- CHEQUEO 5: VERIFICACIÓN DE REGISTROS HUÉRFANOS - Busca mascotas que tengan un duenio_id que no exista en la tabla persona.
-- El resultado debe ser 0 para confirmar la integridad referencial.
SELECT m.id AS mascota_id, m.duenio_id
FROM mascota m
LEFT JOIN persona p ON m.duenio_id = p.id
WHERE p.id IS NULL;    
    
-- CHEQUEO 6: VALIDACIÓN DE COHERENCIA TEMPORAL- Cuenta si hay implantaciones registradas antes de la fecha de nacimiento de la mascota.
-- El resultado debe ser 0.
SELECT COUNT(*) AS implantaciones_incoherentes
FROM mascota m
JOIN implantacion i ON m.microchip_id = i.microchip_id
WHERE i.fecha_implantacion < m.fecha_nacimiento;


-- 6: LIMPIEZA DE OBJETOS TEMPORALES

DROP TABLE IF EXISTS seed_nombres, seed_apellidos, seed_calles;