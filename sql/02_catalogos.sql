/*Este script tiene dos propósitos:

 1. INSERCIÓN MANUAL DE CATÁLOGOS:
 Puebla las tablas "Catálogo" (creadas en el script 01) con los 
 datos maestros iniciales. Esto incluye las inserciones (INSERT) 
 para 'provincia', 'especie' y 'raza'.

 2. PRUEBAS DE VALIDACIÓN DE CONSTRAINTS (ETAPA 1):
 Contiene el bloque de pruebas (basado en el archivo 
 '01_esquema.sql (Parte 2)' original) para validar que las 
 constraints definidas en el script 01 funcionan. 
 Se insertan datos de forma errónea (violando UNIQUE, CHECK, 
 FOREIGN KEY y ON DELETE RESTRICT) de manera intencional para 
 corroborar que la base de datos rechaza los datos inválidos.
 funcionan como se espera, cumpliendo con los requisitos de la Etapa 1.
*/

-- Usamos la base de datos que creamos
USE gestion_veterinaria;

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


