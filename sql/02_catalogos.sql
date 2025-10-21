/*Este script define todas las tablas de "Catálogo", que sirven como datos de referencia para el resto del sistema. 
Estas tablas incluyen:
 1. Catálogos de Ubicación:
 - provincia
- cod_postal
- direccion
 2. Catálogos de Clasificación:
 - especie
 - raza
*/

-- Usamos la base de datos que creamos
USE gestion_veterinaria;

-- Catálogos de Ubicación
-- 1. PROVINCIAS (catálogo de provincias)
CREATE TABLE provincia (
    id      BIGINT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    
    -- RESTRICCIONES DE DATOS (reglas para las columnas) 
    CONSTRAINT chk_nombre_provincia CHECK (TRIM(nombre) <> '')
);

-- 2. COD_POSTAL (catálogo de códigos postales, incluyendo localidad)
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

-- 3. DIRECCION (calle, número y referencia al código postal)
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
-- 1. ESPECIE
CREATE TABLE especie(
	id          BIGINT PRIMARY KEY AUTO_INCREMENT,
	nombre      VARCHAR(60)  NOT NULL UNIQUE,
    
-- RESTRICCIONES DE DATOS (reglas para las columnas)
	CONSTRAINT chk_nombre_especie CHECK (TRIM(nombre) <> '') -- Asegura que el código no sea una cadena vacía o solo espacios.
);

-- 2. RAZA
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



