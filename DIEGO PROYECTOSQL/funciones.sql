USE pizzeria_don_piccolo;

DELIMITER //
-- =========================================================================
-- 1. FUNCIÓN: Calcular el total de un pedido 
-- (Suma el subtotal de las pizzas + costo de envío + IVA del 19%)
-- =========================================================================
CREATE FUNCTION calcular_total_pedido(p_pedido_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_subtotal_pizzas DECIMAL(10,2) DEFAULT 0;
    DECLARE v_costo_envio DECIMAL(10,2) DEFAULT 0;
    DECLARE v_iva DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;

    -- Obtener la suma de los subtotales de las pizzas del pedido
    SELECT COALESCE(SUM(subtotal), 0) INTO v_subtotal_pizzas
    FROM detalle_pedidos
    WHERE pedido_id = p_pedido_id;

    -- Obtener el costo de envío del domicilio asociado
    SELECT COALESCE(costo_envio, 0) INTO v_costo_envio
    FROM domicilios
    WHERE pedido_id = p_pedido_id;

    -- Calcular el IVA (19% sobre las pizzas)
    SET v_iva = v_subtotal_pizzas * 0.19;

    -- Calcular el total final
    SET v_total = v_subtotal_pizzas + v_costo_envio + v_iva;

    RETURN v_total;
END //
DELIMITER ;

SELECT calcular_total_pedido(1) AS total_calculado;





DELIMITER //
-- =========================================================================
-- 2. FUNCIÓN: Calcular la ganancia neta diaria 
-- (Ventas totales de pedidos entregados - Costo de los ingredientes usados)
-- =========================================================================
CREATE FUNCTION calcular_ganancia_neta_diaria(p_fecha DATE) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_ventas DECIMAL(10,2) DEFAULT 0;
    DECLARE v_costo_ingredientes DECIMAL(10,2) DEFAULT 0;
    DECLARE v_ganancia_neta DECIMAL(10,2) DEFAULT 0;

    -- Sumar las ventas de los pedidos entregados en la fecha indicada
    SELECT COALESCE(SUM(dp.subtotal), 0) INTO v_total_ventas
    FROM pedidos p
    JOIN detalle_pedidos dp ON p.id = dp.pedido_id
    WHERE DATE(p.fecha_hora) = p_fecha AND p.estado = 'entregado';

    -- Calcular el costo de los ingredientes consumidos en esas pizzas vendidas
    SELECT COALESCE(SUM(pi.cantidad_requerida * i.costo * dp.cantidad), 0) INTO v_costo_ingredientes
    FROM pedidos p
    JOIN detalle_pedidos dp ON p.id = dp.pedido_id
    JOIN pizza_ingredientes pi ON dp.pizza_id = pi.pizza_id
    JOIN ingredientes i ON pi.ingrediente_id = i.id
    WHERE DATE(p.fecha_hora) = p_fecha AND p.estado = 'entregado';

    -- Ganancia neta = Ventas - Costos
    SET v_ganancia_neta = v_total_ventas - v_costo_ingredientes;

    RETURN v_ganancia_neta;
END //
DELIMITER ;

desc pedidos;
SELECT calcular_ganancia_neta_diaria('2026-09-17') AS ganancia_hoy;


DELIMITER //
-- =========================================================================
-- 3. PROCEDIMIENTO: Cambiar automáticamente el estado del pedido a “entregado” 
-- cuando se registra la hora de entrega en el domicilio.
-- =========================================================================
CREATE PROCEDURE registrar_entrega_domicilio(
    IN p_pedido_id INT, 
    IN p_hora_entrega DATETIME
)
BEGIN
    -- Actualizar la hora de entrega en la tabla domicilios
    UPDATE domicilios
    SET hora_entrega = p_hora_entrega
    WHERE pedido_id = p_pedido_id;

    -- Cambiar automáticamente el estado del pedido a 'entregado'
    UPDATE pedidos
    SET estado = 'entregado'
    WHERE id = p_pedido_id;
END //

-- Restaurar el delimitador por defecto
DELIMITER ;

CALL registrar_entrega_domicilio(5, NOW());
select * from domicilios;
