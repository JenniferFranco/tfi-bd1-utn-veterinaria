-- Igualdad: búsqueda por código de microchip
CREATE INDEX idx_microchip_codigo ON microchip (codigo);
-- Rango: búsqueda por fecha de implantación
CREATE INDEX idx_implantacion_fecha ON implantacion (fecha_implantacion);
-- JOIN: FK entre implantacion y veterinario
CREATE INDEX idx_implantacion_vet ON implantacion (veterinario_id);

-- --- VERSION FINAL
