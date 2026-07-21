/*Objetivo: Evaluar la comprensión de los triggers y su aplicación en la lógica del sistema.
Enunciado:
Crea un trigger SQL que, al insertar una nueva membresía, calcule y complete 
automáticamente la fecha de vencimiento sumando 30 días a la fecha de inicio.
El trigger debe ejecutarse después de insertar (AFTER INSERT) una membresía.
La fecha de vencimiento debe guardarse en el mismo registro de la membresía.
Incluye un comentario explicando brevemente cómo funciona el trigger.*/

USE coworking;

DROP TRIGGER IF EXISTS trg_mem_calc_vencimiento1;

-- Trigger de auditoría detallada al modificar membresías (Historial Completo).

DROP TRIGGER IF EXISTS trg_mem_audit_update;

DELIMITER //
CREATE TRIGGER trg_mem_audit_update -- CREA EL TRIGGER
AFTER UPDATE ON membresia_usuario -- DESPUES DE ACTUALIZAR LA TABLA QUE YA ESTA CREADA
FOR EACH ROW -- PARA CADA UNA
BEGIN
    IF OLD.estado != NEW.estado OR OLD.tipo_membresia_id != NEW.tipo_membresia_id AND v_nombre_tipo = 'Mensual' THEN
        INSERT INTO log_membresias (id, membresia_usuario_id, usuario_id, tipo_anterior_id, tipo_nuevo_id, accion, estado_anterior, estado_nuevo, precio_anterior, precio_nuevo, fecha_inicio_anterior, fecha_inicio_nueva, fecha_fin_anterior, fecha_fin_nueva)
        VALUES (UUID(), NEW.id, NEW.usuario_id, OLD.tipo_membresia_id, NEW.tipo_membresia_id, 'CAMBIO_ESTADO', OLD.estado, NEW.estado, OLD.precio_pagado, NEW.precio_pagado, OLD.fecha_inicio, NEW.fecha_inicio, OLD.fecha_fin, NEW.fecha_fin);
    END IF;
END;


DELIMITER //
CREATE TRIGGER trg_mem_calc_vencimiento1 
AFTER UPDATE ON membresia_usuario
FOR EACH ROW	
BEGIN
	
	IF OLD.estado != NEW.estado THEN
		INSERT INTO membresia_usuario (id, usuario_id, tipo_memebresia_id,fecha_inicio,fecha_fin,fecha_contratacion,estado,renovaciones,precio_pagado)
    	VALUES (NEW.id, NEW.usuario_id, NEW.tipo_membresia_id, NEW.fecha_inicio,NEW.fecha_fin,NEW.fecha_contratacion, 'ACTIVA', NEW.renovaciones,NEW.precio_pagado);    
	SET NEW.fecha_fin = DATE_ADD(NEW.fecha_inicio, INTERVAL 1 MONTH);
END IF;
END;


-- OTRO CAMBIO POR UPDATE ESTE SI ES.
-- DEJO LOS OTROS PARA QUE VEA EL SUFRIMIENTO

CREATE TRIGGER trg_mem_calc_vencimiento1 -- SE CREA EL TRIGGET
AFTER UPDATE ON membresia_usuario -- SE DA LA CONDICION DE ANTES DE ... 
FOR EACH ROW -- PARA CADA FILA
BEGIN -- INICIA LA LOGICA DE LAS CONDICIONES	
	IF OLD.estado != NEW.estado THEN -- COMO ES NUEVA ME ENFOCO EN EL ESTADO DE LA MEMBRESIA
		INSERT INTO membresia_usuario (id, usuario_id, tipo_memebresia_id,fecha_inicio,fecha_fin,fecha_contratacion,estado,renovaciones,precio_pagado) -- DONDE SE VA A  MODIFICAR LA INFO
    	VALUES (NEW.id, NEW.usuario_id, NEW.tipo_membresia_id, NEW.fecha_inicio,NEW.fecha_fin,NEW.fecha_contratacion, 'ACTIVA', NEW.renovaciones,NEW.precio_pagado);  -- LOS VALORES QUE SE VAN A INSERTAR
    	UPDATE membresia_usuario -- SE ACTUALIZA LA INFO EN LA TABLA
	SET NEW.fecha_fin = DATE_ADD(NEW.fecha_inicio, INTERVAL 1 MONTH); -- SE CONFIGURA EL MES
END IF; -- TERMINA EL IF
END;-- TERMINA EL TRIGGER
