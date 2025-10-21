-- Medir tiempos con y sin índices en al menos 3 consultas representativas:
-- Consulta de igualdad (WHERE codigo = ...)
-- (a) Plan de ejecución con índice

EXPLAIN SELECT * 
FROM microchip FORCE INDEX (idx_microchip_codigo)
WHERE codigo = 'CHIP-009091';




-- (b) Medir tiempo de ejecución con índice:
SET @start = NOW(6);
SELECT * 
FROM microchip FORCE INDEX (idx_microchip_codigo)
WHERE codigo = 'CHIP-009091';

SET @end = NOW(6);
SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000,3) AS elapsed_ms;

-- (c) Plan sin índice
EXPLAIN SELECT * 
FROM microchip IGNORE INDEX (idx_microchip_codigo)
WHERE codigo = 'CHIP-009091';

-- (d) Medir tiempo sin índice:
SET @start = NOW(6);
SELECT * 
FROM microchip IGNORE INDEX (idx_microchip_codigo)
WHERE codigo = 'CHIP-009091';

SET @end = NOW(6);
SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000,3) AS elapsed_ms;




-- Consulta de rango (BETWEEN fechas)
-- (a) Plan con índice
EXPLAIN SELECT i.id, i.fecha_implantacion, v.id AS veterinario_id
FROM implantacion i FORCE INDEX (idx_implantacion_fecha)
JOIN veterinario v ON v.id = i.veterinario_id
WHERE i.fecha_implantacion BETWEEN '2024-01-01' AND '2025-12-31';

-- (b) Medición con índice
SET @start = NOW(6);

SELECT i.id, i.fecha_implantacion, v.id AS veterinario_id
FROM implantacion i FORCE INDEX (idx_implantacion_fecha)
JOIN veterinario v ON v.id = i.veterinario_id
WHERE i.fecha_implantacion BETWEEN '2024-01-01' AND '2025-12-31';

SET @end = NOW(6);

SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000,3) AS elapsed_ms;

-- (c) Plan sin índice

EXPLAIN SELECT i.id, i.fecha_implantacion, v.id AS veterinario_id
FROM implantacion i IGNORE INDEX (idx_implantacion_fecha)
JOIN veterinario v ON v.id = i.veterinario_id
WHERE i.fecha_implantacion BETWEEN '2024-01-01' AND '2025-12-31';

-- (d) Medición sin índice
SET @start = NOW(6);

SELECT i.id, i.fecha_implantacion, v.id AS veterinario_id
FROM implantacion i IGNORE INDEX (idx_implantacion_fecha)
JOIN veterinario v ON v.id = i.veterinario_id
WHERE i.fecha_implantacion BETWEEN '2024-01-01' AND '2025-12-31';

SET @end = NOW(6);

SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000,3) AS elapsed_ms;

-- Consulta de JOIN (implantación ↔ veterinario ↔ microchip)
(a) Plan con índice
EXPLAIN SELECT v.id AS veterinario_id, COUNT(i.id) AS cantidad_implantes
FROM veterinario v
JOIN implantacion i FORCE INDEX (idx_implantacion_veterinario)
    ON i.veterinario_id = v.id
JOIN microchip m ON m.id = i.microchip_id
GROUP BY v.id;






-- (b) Medición con índice
SET @start = NOW(6);

SELECT v.id AS veterinario_id, COUNT(i.id) AS cantidad_implantes
FROM veterinario v
JOIN implantacion i FORCE INDEX (idx_implantacion_veterinario)
    ON i.veterinario_id = v.id
JOIN microchip m ON m.id = i.microchip_id
GROUP BY v.id;

SET @end = NOW(6);

SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000,3) AS elapsed_ms;

-- (c) Plan sin índice
EXPLAIN SELECT v.id AS veterinario_id, COUNT(i.id) AS cantidad_implantes
FROM veterinario v
JOIN implantacion i IGNORE INDEX (idx_implantacion_veterinario)
    ON i.veterinario_id = v.id
JOIN microchip m ON m.id = i.microchip_id
GROUP BY v.id;





-- (d) Medición sin índice

SET @start = NOW(6);

SELECT v.id AS veterinario_id, COUNT(i.id) AS cantidad_implantes
FROM veterinario v
JOIN implantacion i IGNORE INDEX (idx_implantacion_veterinario)
    ON i.veterinario_id = v.id
JOIN microchip m ON m.id = i.microchip_id
GROUP BY v.id;

SET @end = NOW(6);

SELECT ROUND(TIMESTAMPDIFF(MICROSECOND, @start, @end)/1000,3) AS elapsed_ms;
