-- ------VERSION FINAL

CREATE OR REPLACE VIEW vw_implantaciones_activas AS
SELECT 
  i.id AS implantacion_id,
  i.fecha_implantacion,
  v.id AS veterinario_id,
  CONCAT(pv.nombre, ' ', pv.apellido) AS veterinario,
  mc.id AS microchip_id,
  mc.codigo AS microchip_codigo,
  m.id AS mascota_id,
  m.nombre AS mascota,
  CONCAT(pd.nombre, ' ', pd.apellido) AS duenio,
  pd.dni AS duenio_dni
FROM implantacion i
JOIN microchip mc ON mc.id = i.microchip_id
LEFT JOIN mascota m ON m.microchip_id = mc.id
LEFT JOIN persona pd ON pd.id = m.duenio_id
LEFT JOIN veterinario v ON v.id = i.veterinario_id
LEFT JOIN persona pv ON pv.id = v.id
WHERE COALESCE(mc.eliminado, FALSE) = FALSE;

---------------------------

-- Ver la vista
SELECT * FROM vw_implantaciones_activas;

