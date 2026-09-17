USE pizzeria_don_piccolo;

DELIMITER //
-- =========================================================================
-- 1. TRIGGER: Actualización automática de stock de ingredientes
-- Se ejecuta al insertar un detalle de pedido (detalle_pedidos), restando
-- la cantidad requerida de cada ingrediente según la receta de la pizza.
-- =========================================================================
CREATE TRIGGER trg_actualizar_stock_ingredientes
AFTER INSERT ON detalle_pedidos
FOR EACH ROW
BEGIN
    -- Actualizamos el stock de los ingredientes restando (cantidad de pizza * cantidad requerida por receta)
    UPDATE ingredientes i
    JOIN pizza_ingredientes pi ON i.id = pi.ingrediente_id
    SET i.stock = i.stock - (pi.cantidad_requerida * NEW.cantidad)
    WHERE pi.pizza_id = NEW.pizza_id;
END //

INSERT INTO detalle_pedidos (pedido_id, pizza_id, cantidad, subtotal)
VALUES (10, 1, 3, 105000.00);

-- =========================================================================
-- 2. TRIGGER: Auditoría de cambios de precios (historial_precios)
-- Se ejecuta antes de actualizar una pizza, guardando el precio anterior
-- y el precio nuevo si estos llegan a diferir.
-- =========================================================================
CREATE TRIGGER trg_auditoria_precio_pizza
BEFORE UPDATE ON pizzas
FOR EACH ROW
BEGIN
    -- Verificamos si realmente hubo un cambio en el precio base
    IF OLD.precio_base <> NEW.precio_base THEN
        INSERT INTO historial_precios (pizza_id, precio_anterior, precio_nuevo)
        VALUES (OLD.id, OLD.precio_base, NEW.precio_base);
    END IF;
END //

UPDATE pizzas 
SET precio_base = 38000.00 
WHERE id = 1;


-- =========================================================================
-- 3. TRIGGER: Marcar repartidor como "disponible" al terminar el domicilio
-- Se ejecuta cuando se actualiza la tabla 'domicilios' y se registra una
-- 'hora_entrega'. Libera al repartidor asignado a dicho pedido.
-- =========================================================================
CREATE TRIGGER trg_liberar_repartidor_domicilio
AFTER UPDATE ON domicilios
FOR EACH ROW
BEGIN
    -- Verificamos que antes no tuviera hora de entrega y ahora sí se le haya asignado una
    IF OLD.hora_entrega IS NULL AND NEW.hora_entrega IS NOT NULL THEN
        UPDATE repartidores r
        JOIN pedidos p ON r.id = p.repartidor_id
        SET r.estado = 'disponible'
        WHERE p.id = NEW.pedido_id;
    END IF;
END //

-- Restaurar el delimitador por defecto
DELIMITER ;

UPDATE domicilios 
SET hora_entrega = '2026-09-17 19:10:00' 
WHERE pedido_id = 15;