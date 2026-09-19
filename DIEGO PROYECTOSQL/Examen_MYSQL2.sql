use pizzeria_don_piccolo;

/** Consulta de pedidos por cliente
Consulta SQL que muestre el nombre del cliente, el ID del pedido, el total y el estado del pedido. **/

SELECT 
    c.nombre AS nombre_cliente,
    p.id,
    p.total,
    p.estado
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id;


/** 
Consulta de pedidos entregados en un rango de fechas
Mostrar los pedidos con estado entregado cuya fecha esté entre dos fechas dadas (usa BETWEEN).
**/
SELECT 
    p.id AS id_pedido,
    p.cliente_id,
    p.fecha_hora,
    p.metodo_pago,
    p.estado,
    p.total
FROM pedidos p
WHERE p.estado = 'entregado'
  AND DATE(p.fecha_hora) BETWEEN '2026-09-01' AND '2026-09-30';
  
 /**
 Consulta de resumen de pedidos por método de pago
Mostrar cuántos pedidos se hicieron por cada método de pago y el total acumulado (GROUP BY).
 **/ 
SELECT 
    metodo_pago,
    COUNT(*) AS cantidad_pedidos,
    SUM(total) AS total_acumulado
FROM pedidos
GROUP BY metodo_pago;

/**
Consulta de clientes frecuentes
Mostrar los clientes que tengan más de 5 pedidos en total (usa HAVING COUNT(*) > 5).
**/
SELECT 
    c.id AS id_cliente,
    c.nombre AS nombre_cliente,
    COUNT(p.id) AS total_pedidos
FROM clientes c
INNER JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
HAVING COUNT(p.id) > 2;

/**
Puse en el filtro  que se mayor a 2 y no mayor que 5 porque mi base de datos no tiene compras mayores de 5
**/