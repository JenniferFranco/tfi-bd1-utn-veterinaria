/*Este script crea las "Entidades Principales" de la base de datos 'gestion_veterinaria'. 
Estas tablas incluyen:
 1. Entidades Principales:
- persona (super-entidad)
- veterinaria
- veterinario (rol de persona)
- microchip
 - mascota
2. Entidades de Eventos:
 - implantacion

 Al final del script, se incluye un bloque de PRUEBAS DE INTEGRIDAD.
 Este bloque inserta datos de prueba válidos y luego ejecuta 
 inserciones y borrados erróneos de forma intencional para 
corroborar que las constraints (UNIQUE, CHECK, FK, RESTRICT)
 funcionan como se espera, cumpliendo con los requisitos de la Etapa 1.
*/
-- Creamos la base de datos si no existe
CREATE DATABASE IF NOT EXISTS gestion_veterinaria;

USE gestion_veterinaria;

--  PERSONA: La tabla general con los datos compartidos de DUEÑO y VETERINARIO
CREATE TABLE persona (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    dni VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    telefono VARCHAR(30),
    email VARCHAR(120) UNIQUE,
    eliminado BOOLEAN NOT NULL DEFAULT FALSE,
    direccion_id BIGINT,
    
    -- RELACIONES (conexiones con otras tablas)
  CONSTRAINT fk_persona_direccion
    FOREIGN KEY (direccion_id) REFERENCES direccion(id),
   
  -- RESTRICCIONES DE DATOS (reglas para las columnas)  
  CONSTRAINT chk_email CHECK (email LIKE '%@%'), -- Formato básico de email
  CONSTRAINT chk_telefono CHECK (LENGTH(telefono) >= 7) -- Longitud mínima del teléfono  
);

-- VETERINARIA (establecimiento) con referencia a DIRECCION
CREATE TABLE veterinaria (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  nombre       VARCHAR(120) NOT NULL UNIQUE,
  telefono     VARCHAR(30),
  email        VARCHAR(120),
  pagina_web   VARCHAR(120),
  direccion_id BIGINT,
  
  -- RELACIONES (conexiones con otras tablas)
  CONSTRAINT fk_veterinaria_direccion
    FOREIGN KEY (direccion_id) REFERENCES direccion(id),
    
  -- RESTRICCIONES DE DATOS (reglas para las columnas)
  CONSTRAINT chk_veterinaria_nombre CHECK (TRIM(nombre) <> ''), -- El nombre no puede ser una cadena vacía o solo espacios.
  CONSTRAINT chk_veterinaria_telefono CHECK (telefono IS NULL OR LENGTH(telefono) >= 7),  -- El teléfono, si se ingresa, debe tener una longitud mínima.
  CONSTRAINT chk_veterinaria_email CHECK (email IS NULL OR email LIKE '%@%.%'), -- El email, si se ingresa, debe contener un '@' y un '.'
  CONSTRAINT chk_veterinaria_pagina_web CHECK (pagina_web IS NULL OR pagina_web LIKE '%.%')   -- La página web, si se ingresa, debe contener al menos un '.'
);

-- VETERINARIO 
--    Asociación unidireccional con VETERINARIA: cada veterinario pertenece a una veterinaria.
--    Incluye referencia a PERSONA.
CREATE TABLE veterinario (
  id BIGINT PRIMARY KEY,
  matricula_profesional VARCHAR(30) NOT NULL UNIQUE,
  veterinaria_id BIGINT,   -- puede ser NULL si no lo asignaron todavía
 
   -- RELACIONES (conexiones con otras tablas)
  CONSTRAINT fk_veterinario_persona
        FOREIGN KEY (id) REFERENCES persona(id)
        ON DELETE CASCADE,
  CONSTRAINT fk_veterinario_veterinaria
    FOREIGN KEY (veterinaria_id) REFERENCES veterinaria(id)
);

-- MICROCHIP (Registro de microchips independientes, con código único.)
CREATE TABLE microchip (
  id             BIGINT PRIMARY KEY AUTO_INCREMENT,
  codigo         VARCHAR(50) NOT NULL UNIQUE, 
  observaciones  TEXT, -- UsaMoS TEXT para notas largas es más flexible

-- RESTRICCIONES DE DATOS (reglas para las columnas)
 CONSTRAINT chk_microchip_codigo CHECK (TRIM(codigo) <> '') -- Asegura que el código no sea una cadena vacía o solo espacios.
);

-- MASCOTA (relación bidireccional con Dueño)
--    Cada mascota pertenece a un DUEÑO (relación 1..N)
--    Cada mascota tiene un MICROCHIP como máximo.
CREATE TABLE mascota (
  id               BIGINT PRIMARY KEY AUTO_INCREMENT,
  nombre           VARCHAR(60)  NOT NULL,
  raza_id         BIGINT NOT NULL,
  fecha_nacimiento DATE,
  duenio_id       BIGINT NOT NULL,
  microchip_id     BIGINT UNIQUE,  -- 1:1 flexible (puede ser NULL para mascota sin chip)
  
   -- RELACIONES 
   CONSTRAINT fk_mascota_raza
        FOREIGN KEY (raza_id) REFERENCES raza(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,  -- evita borrar razas con mascotas asociadas
    CONSTRAINT fk_mascota_duenio
        FOREIGN KEY (duenio_id) REFERENCES persona(id)
        ON DELETE RESTRICT, -- Impide borrar un dueño que tenga mascotas
    CONSTRAINT fk_mascota_microchip
        FOREIGN KEY (microchip_id) REFERENCES microchip(id)
        ON DELETE SET NULL, -- Si se borra el microchip, el campo en mascota queda nulo
  
 -- RESTRICCIONES DE DATOS
    CONSTRAINT chk_mascota_nombre CHECK (TRIM(nombre) <> '') -- Evita que el nombre sea una cadena vacía o solo espacios.
    
);

-- IMPLANTACION
--    Un registro de implantación por MICROCHIP (1:1)
--    Referencia a VETERINARIO que realiza la implantación.
CREATE TABLE implantacion (
  id                   BIGINT PRIMARY KEY AUTO_INCREMENT,
  fecha_implantacion   DATE NOT NULL,
  veterinario_id  BIGINT NOT NULL,
  microchip_id         BIGINT NOT NULL UNIQUE,  -- 1 microchip → 1 registro de implantación
  
  -- RELACIONES
  CONSTRAINT fk_implantacion_vet
    FOREIGN KEY (veterinario_id) REFERENCES veterinario(id)
    ON DELETE RESTRICT, -- Impide borrar un veterinario que tenga implantaciones registradas
  CONSTRAINT fk_implantacion_chip
    FOREIGN KEY (microchip_id)       REFERENCES microchip(id)
    ON DELETE CASCADE -- Si se borra el microchip, este registro de implantación también se borra
  
);

-- PRUEBA DE INSERCION DATOS MANUAL

-- INSERTAR DATOS EN TABLAS INDEPENDIENTES
-- Insertamos una provincia
INSERT INTO provincia (nombre) VALUES ('Buenos Aires');

-- Insertamos dos especie
INSERT INTO especie (nombre) VALUES 
('Perro'), 
('Gato');

-- Insertamos dos personas
INSERT INTO persona (dni, nombre, apellido, telefono, email) VALUES 
('30111222', 'Carlos', 'Gomez', '1155667788', 'carlos31@gmail.com'),
('35888999', 'Ana', 'Perez', '1122334455', 'ana-perez@gmail.com');

-- Insertamos la clínica veterinaria
INSERT INTO veterinaria (nombre, telefono, email) VALUES 
('Clínica Animal', '4484-1234', 'contacto@animal.vet');

-- Insertamos un microchip (aún no asignado a ninguna mascota)
INSERT INTO microchip (codigo) 
VALUES ('A1B2-C3D4-E5F6');

-- INSERTAR DATOS EN TABLAS DEPENDIENTES

-- Insertamos un código postal
INSERT INTO cod_postal (cod_postal, localidad, provincia_id) VALUES 
('1754', 'San Justo', 1),
('1425', 'Palermo', 1); 

-- Insertamos direcciones 
INSERT INTO direccion (calle, numero, cod_postal_id) VALUES 
('Av. Rivadavia', '1234', 1), -- Dirección para Carlos
('Av. Corrientes', '5678', 2); -- Dirección para la clínica

-- Asignamos el rol de veterinario a una personas que creamos
INSERT INTO veterinario (id, matricula_profesional, veterinaria_id) 
VALUES (2, 'MN-12345', 1); -- id=2 (Ana), veterinaria_id=1 (Clínica Animal)

-- Insertamos razas
INSERT INTO raza (id, nombre, especie_id) VALUES 
(1, 'Golden Retriever', 1), -- especie_id = 1 (Perro)
(2, 'Siamés', 2);           -- especie_id = 2 (Gato)

-- Registramos una mascota para el dueño Carlos
INSERT INTO mascota (nombre, raza_id, fecha_nacimiento, duenio_id, microchip_id) VALUES 
('Bruss', 1, '2022-05-10', 1, 1); -- Bruss es un Golden Retrieve (id=1) de Carlos (id=1) y le asignamos el microchip (id=1)

-- Registramos la implantación de ese microchip
INSERT INTO implantacion (fecha_implantacion, veterinario_id, microchip_id) VALUES
('2022-08-01', 2, 1); -- La implantación la hizo Ana (id=2) al microchip (id=1)


-- INSERCCIONES ERRONEAS

--  Violar UNIQUE (Clave Única): Fallará porque el DNI '30111222' (de Carlos Gomez) ya está en uso.
INSERT INTO persona (dni, nombre, apellido) VALUES 
('30111222', 'Roberto', 'Franco'); -- Error Code: 1062. Duplicate entry '30111222' for key 'dni'	

-- Violar CHECK (Verificación de Datos): Fallará porque el nombre no puede ser una cadena vacía.
INSERT INTO veterinaria (nombre) VALUES (''); -- Error Code: 4025. CONSTRAINT `chk_veterinaria_nombre` failed for `gestion_veterinaria`.`veterinaria`	

-- Violar FOREIGN KEY (Clave Foránea): Fallará porque no hay ningún dueño con id=99.
INSERT INTO mascota (nombre, raza_id, duenio_id) VALUES 
('Fito', 'Perro', 99); -- Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`gestion_veterinaria`.`mascota`, CONSTRAINT `fk_mascota_duenio` FOREIGN KEY (`duenio_id`) REFERENCES `duenio` (`id`))	

-- Violar ON DELETE RESTRICT: Fallará porque Carlos (id=1) es referenciado en la tabla 'mascota'.
DELETE FROM persona WHERE id = 1; -- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`gestion_veterinaria`.`mascota`, CONSTRAINT `fk_mascota_duenio` FOREIGN KEY (`duenio_id`) REFERENCES `persona` (`id`))




