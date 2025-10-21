-- CONSULTA 1: Ranking de veterinarios por cantidad de implantaciones en 2023–2025
SELECT 
  v.id AS veterinario_id,
  CONCAT(p.nombre, ' ', p.apellido) AS veterinario,
  COUNT(i.id) AS total_implantaciones,
  SUM(CASE 
      WHEN i.fecha_implantacion BETWEEN '2023-01-01' AND '2025-12-31' 
      THEN 1 ELSE 0 END) AS implantaciones_en_periodo,
  ROW_NUMBER() OVER (
      ORDER BY SUM(CASE 
          WHEN i.fecha_implantacion BETWEEN '2023-01-01' AND '2025-12-31' 
          THEN 1 ELSE 0 END) DESC
  ) AS ranking
FROM veterinario v
JOIN persona p ON v.id = p.id
LEFT JOIN implantacion i ON i.veterinario_id = v.id
GROUP BY v.id, p.nombre, p.apellido
ORDER BY implantaciones_en_periodo DESC;



-- ---------------------------------

-- CONSULTA 2: Microchips activos con información de mascota y dueño

SELECT 
  mc.id AS microchip_id,
  mc.codigo,
  mc.observaciones,
  mc.eliminado,
  m.id AS mascota_id,
  m.nombre AS nombre_mascota,
  r.nombre AS raza,
  e.nombre AS especie,
  CONCAT(p.nombre, ' ', p.apellido) AS duenio,
  i.fecha_implantacion
FROM microchip mc
LEFT JOIN mascota m ON m.microchip_id = mc.id
LEFT JOIN raza r ON r.id = m.raza_id
LEFT JOIN especie e ON e.id = r.especie_id
LEFT JOIN persona p ON p.id = m.duenio_id
LEFT JOIN implantacion i ON i.microchip_id = mc.id
WHERE mc.eliminado = FALSE;

-- -------------------------------------
-- CONSULTA 3: Dueños con 2 o más mascotas registradas
SELECT 
  p.id AS duenio_id,
  CONCAT(p.nombre, ' ', p.apellido) AS duenio,
  COUNT(m.id) AS num_mascotas,
  GROUP_CONCAT(m.nombre SEPARATOR '; ') AS mascotas_list
FROM persona p
JOIN mascota m ON m.duenio_id = p.id
GROUP BY p.id, p.nombre, p.apellido
HAVING COUNT(m.id) >= 2
ORDER BY num_mascotas DESC;


-- --------------------------------

-- CONSULTA 4: Dueños con todas sus mascotas microchipeadas
SELECT
 p.id AS duenio_id,
 CONCAT(p.nombre, ' ', p.apellido) AS duenio,
 (SELECT COUNT(*) FROM mascota m2 WHERE m2.duenio_id = p.id) AS total_mascotas
FROM persona p
WHERE NOT EXISTS (
 SELECT 1
 FROM mascota m
 WHERE m.duenio_id = p.id
 AND m.microchip_id IS NULL
)
ORDER BY total_mascotas DESC;






