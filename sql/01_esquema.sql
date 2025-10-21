/* 
Este script construye el "esqueleto" completo de la base de datos 
'gestion_veterinaria'.

Su función es crear TODAS las tablas en el orden de dependencia correcto,
asegurando que las claves foráneas (FOREIGN KEY) se establezcan sin errores.

 1. Primero, crea las tablas de Catálogo (ej. 'provincia', 'especie') 
que no dependen de ninguna otra.
2. Segundo, crea las tablas de Entidades Principales (ej. 'mascota', 
'persona', 'implantacion') que SÍ dependen de los catálogos.

También define TODAS las constraints (PK, UNIQUE, CHECK) para
asegurar la integridad. Al terminar, la base de datos queda lista 
(pero vacía) para ser poblada por los siguientes scripts.

*/
-- Creamos la base de datos si no existe
CREATE DATABASE IF NOT EXISTS gestion_veterinaria;

USE gestion_veterinaria;

-- INICIO: BLOQUE DE IDEMPOTENCIA (Permite re-ejecutar el script)
-- Desactiva temporalmente la validación de claves foráneas para permitir borrar las tablas.
SET FOREIGN_KEY_CHECKS = 0;

-- Borramos las tablas si ya existen.
DROP TABLE IF EXISTS implantacion;
DROP TABLE IF EXISTS mascota;
DROP TABLE IF EXISTS veterinario;
DROP TABLE IF EXISTS persona;
DROP TABLE IF EXISTS veterinaria;
DROP TABLE IF EXISTS direccion;
DROP TABLE IF EXISTS cod_postal;
DROP TABLE IF EXISTS raza;
DROP TABLE IF EXISTS especie;
DROP TABLE IF EXISTS provincia;
DROP TABLE IF EXISTS microchip;

-- Reactiva la validación de claves foráneas para el resto de la sesión.
SET FOREIGN_KEY_CHECKS = 1;

-- FIN: BLOQUE DE IDEMPOTENCIA

-- Catálogos de Ubicación
-- PROVINCIAS (catálogo de provincias)
CREATE TABLE provincia (
    id      BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    
    -- RESTRICCIONES DE DATOS (reglas para las columnas) 
    CONSTRAINT chk_nombre_provincia CHECK (TRIM(nombre) <> '')
);

--  COD_POSTAL (catálogo de códigos postales, incluyendo localidad)
CREATE TABLE cod_postal (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  cod_postal   VARCHAR(10) NOT NULL,
  localidad    VARCHAR(80)  NOT NULL,
  provincia_id BIGINT NOT NULL,
  
  -- RELACIONES (conexiones con otras tablas)
  CONSTRAINT fk_provincia
    FOREIGN KEY (provincia_id) REFERENCES provincia(id)
        ON UPDATE CASCADE    -- Si cambia el id_provincia, se actualiza aquí
        ON DELETE RESTRICT,  -- No permite borrar provincias con códigos postales
    
   -- RESTRICCIONES DE DATOS (reglas para las columnas) 
    CONSTRAINT chk_localidad CHECK (TRIM(localidad) <> '') -- Evita que la localidad sea una cadena vacía o solo espacios en blanco.
);

-- DIRECCION (calle, número y referencia al código postal)
--    Tabla reutilizable por Persona y Veterinaria
CREATE TABLE direccion (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
  calle        VARCHAR(120) NOT NULL,
  numero       VARCHAR(10),
  cod_postal_id   BIGINT  NOT NULL,
  
  -- RELACIONES (conexiones con otras tablas)
  CONSTRAINT fk_direccion_cod_postal
    FOREIGN KEY (cod_postal_id) REFERENCES cod_postal(id),
    
  -- RESTRICCIONES ADICIONALES
  CONSTRAINT chk_calle CHECK (TRIM(calle) <> '') -- Evita que la calle sea una cadena vacía o solo espacios en blanco.
);

-- Catálogos de Clasificación:
-- ESPECIE
CREATE TABLE especie(
	id          BIGINT PRIMARY KEY AUTO_INCREMENT,
	nombre      VARCHAR(60)  NOT NULL UNIQUE,
    
-- RESTRICCIONES DE DATOS (reglas para las columnas)
	CONSTRAINT chk_nombre_especie CHECK (TRIM(nombre) <> '') -- Asegura que el código no sea una cadena vacía o solo espacios.
);

-- RAZA
CREATE TABLE raza(
	id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre      VARCHAR(60)  NOT NULL,
    especie_id  BIGINT NOT NULL,
    
    -- RELACIONES 
     CONSTRAINT fk_raza_especie
        FOREIGN KEY (especie_id) REFERENCES especie(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,  -- no permite borrar una especie si tiene razas asociadas
    
    -- RESTRICCIONES DE DATOS
    CONSTRAINT uq_raza_nombre_especie
        UNIQUE (nombre, especie_id), -- evita duplicar razas dentro de la misma especie  
    CONSTRAINT chk_nombre_raza CHECK (TRIM(nombre) <> '')  -- Asegura que el código no sea una cadena vacía o solo espacios.  
);

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

