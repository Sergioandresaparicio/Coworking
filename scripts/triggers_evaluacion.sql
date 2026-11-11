-- =====================================================================
-- SISTEMA DE GESTIÓN DE COWORKING - TRIGGER DE VENCIMIENTO Y AUDITORÍA
-- =====================================================================
-- Objetivo: Automatizar el cálculo de fechas de vencimiento y auditar cambios 
-- de estado en la tabla de membresías de usuarios.
-- =====================================================================

USE coworking;

DROP TRIGGER IF EXISTS trg_mem_audit_update;
DROP TRIGGER IF EXISTS trg_mem_calc_vencimiento;

-- 1. Trigger de auditoría detallada al modificar membresías
DELIMITER //
CREATE TRIGGER trg_mem_audit_update
AFTER UPDATE ON membresia_usuario
FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado OR OLD.tipo_membresia_id != NEW.tipo_membresia_id THEN
        INSERT INTO log_membresias (
            id, membresia_usuario_id, usuario_id, tipo_anterior_id, tipo_nuevo_id, 
            accion, estado_anterior, estado_nuevo, precio_anterior, precio_nuevo, 
            fecha_inicio_anterior, fecha_inicio_nueva, fecha_fin_anterior, fecha_fin_nueva
        )
        VALUES (
            UUID(), NEW.id, NEW.usuario_id, OLD.tipo_membresia_id, NEW.tipo_membresia_id, 
            'CAMBIO_ESTADO', OLD.estado, NEW.estado, OLD.precio_pagado, NEW.precio_pagado, 
            OLD.fecha_inicio, NEW.fecha_inicio, OLD.fecha_fin, NEW.fecha_fin
        );
    END IF;
END //
DELIMITER ;

-- 2. Trigger para calcular automáticamente la fecha de vencimiento (30 días de vigencia)
DELIMITER //
CREATE TRIGGER trg_mem_calc_vencimiento
BEFORE INSERT ON membresia_usuario
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin IS NULL THEN
        SET NEW.fecha_fin = DATE_ADD(NEW.fecha_inicio, INTERVAL 30 DAY);
    END IF;
END //
DELIMITER ;
