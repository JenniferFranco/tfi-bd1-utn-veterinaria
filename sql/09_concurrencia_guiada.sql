-- 09_concurrencia_guiada.sql
-- Trabajo Integrador - Etapa 5
-- CONCURRENCIA GUIADA (Deadlock + Niveles de Aislamiento) - requiere dos sesiones
--
-- Instrucciones: abrír dos sesiones (A = Sesión 1, B = Sesión 2) conectadas al mismo esquema.
-- Seguir los pasos en el orden indicado.
--
-- Requisitos: esquema 'gestion_veterinaria' con tabla 'mascota' (ids válidos 1 y 2).

USE gestion_veterinaria;

-- ===================================================
-- ACTIVIDAD 1: DEMO DE DEADLOCK (bloqueo mutuo)
-- Objetivo: provocar un deadlock entre dos transacciones.
-- ===================================================

-- === SESIÓN 1 (A) === PASO 1
START TRANSACTION; -- Inicia una operación
UPDATE mascota SET nombre = 'Mascota Bloqueo 1' WHERE id = 1; -- Bloquea la mascota 1


-- === SESIÓN 2 (B) === PASO 2
START TRANSACTION; -- Inicia otra operación
UPDATE mascota SET nombre = 'Mascota Bloqueo 2' WHERE id = 2; -- Bloquea la mascota 2


-- === SESIÓN 1 (A) === PASO 3
-- Intenta tocar fila de la otra sesión quedará esperando
UPDATE mascota SET fecha_nacimiento = '2020-01-01' WHERE id = 2;

-- === SESIÓN 2 (B) === PASO 4
-- Intenta tocar fila de la otra sesión  aquí MySQL detecta el ciclo y cancela una transacción con error 1213
UPDATE mascota SET fecha_nacimiento = '2020-01-01' WHERE id = 1;
-- Esperado: Error Code: 1213. Deadlock found when trying to get lock; try restarting transaction

-- === LIMPIEZA ===
-- En la sesión que NO tiró error: ROLLBACK;


-- ===================================================
-- ACTIVIDAD 3: NIVELES DE AISLAMIENTO (READ COMMITTED vs REPEATABLE READ)
-- ===================================================

-- ---------------------------
-- PARTE A: READ COMMITTED
-- ---------------------------

-- === SESIÓN 1 (A) === PASO 1
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; 
START TRANSACTION;
SELECT nombre FROM mascota WHERE id = 1; -- Anotá el valor leído

-- === SESIÓN 2 (B) === PASO 2
START TRANSACTION;
UPDATE mascota SET nombre = 'Luna Cambiado RC' WHERE id = 1;
COMMIT; -- Confirmá el cambio

-- === SESIÓN 1 (A) === PASO 3
SELECT nombre FROM mascota WHERE id = 1; -- Se deberia ver 'Luna Cambiado RC' dentro de la MISMA transacción
COMMIT;

-- ---------------------------
-- PARTE B: REPEATABLE READ
-- ---------------------------

-- === SESIÓN 1 (A) === PASO 1
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ; 
START TRANSACTION;
SELECT nombre FROM mascota WHERE id = 1; -- Debería mostrar 'Luna Cambiado RC'

-- === SESIÓN 2 (B) === PASO 2
START TRANSACTION;
UPDATE mascota SET nombre = 'Luna Cambiado RR' WHERE id = 1;
COMMIT;

-- === SESIÓN 1 (A) === PASO 3
SELECT nombre FROM mascota WHERE id = 1; -- Deberías seguir viendo el valor leído al inicio de esta transacción
COMMIT;

