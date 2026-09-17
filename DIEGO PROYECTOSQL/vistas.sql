USE pizzeria_don_piccolo;

-- =========================================================================
-- 1. VISTA: Resumen de pedidos por cliente
-- Muestra el nombre del cliente, la cantidad total de pedidos realizados
-- y la suma acumulada de dinero gastado en ellos.
-- =========================================================================
CREATE OR REPLACE VIEW vista_resumen_pedidos_cliente AS
SELECT 
    c.id AS cliente_id,
    c.nombre AS nombre_cliente,
    COUNT(p.id) AS cantidad_pedidos,
    COALESCE(SUM(p.total), 0.00) AS total_gastado
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre;


-- =========================================================================
-- 2. VISTA: Desempeño de repartidores
-- Muestra el número de entregas realizadas, el tiempo promedio de entrega 
-- (en minutos) y la zona asignada a cada repartidor.
-- =========================================================================
CREATE OR REPLACE VIEW vista_desempeno_repartidores AS
SELECT 
    r.id AS repartidor_id,
    r.nombre AS nombre_repartidor,
    r.zona_asignada,
    COUNT(d.id) AS numero_entregas,
    ROUND(
        AVG(
            TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)
        ), 2
    ) AS tiempo_promedio_entrega_minutos
FROM repartidores r
LEFT JOIN pedidos p ON r.id = p.repartidor_id
LEFT JOIN domicilios d ON p.id = d.pedido_id AND d.hora_salida IS NOT NULL AND d.hora_entrega IS NOT NULL
GROUP BY r.id, r.nombre, r.zona_asignada;


-- =========================================================================
-- 3. VISTA: Stock de ingredientes por debajo del mínimo permitido
-- Filtra aquellos ingredientes cuyo stock actual sea menor o igual al 
-- stock mínimo estipulado, facilitando la gestión de inventario y alertas.
-- =========================================================================
CREATE OR REPLACE VIEW vista_stock_bajo_minimo AS
SELECT 
    id AS ingrediente_id,
    nombre AS nombre_ingrediente,
    stock AS stock_actual,
    stock_minimo,
    costo
FROM ingredientes
WHERE stock <= stock_minimo;