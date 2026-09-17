/*1. Clientes con pedidos entre dos fechas (BETWEEN)*/

SELECT DISTINCT c.id, c.nombre, c.telefono, p.fecha_hora
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
WHERE p.fecha_hora BETWEEN '2026-01-01 00:00:00' AND '2026-12-31 23:59:59';

/*2. Pizzas más vendidas (GROUP BY y COUNT)*/
SELECT p.id, p.nombre, p.tamano, SUM(dp.cantidad) AS total_vendidas
FROM pizzas p
JOIN detalle_pedidos dp ON p.id = dp.pizza_id
GROUP BY p.id, p.nombre, p.tamano
ORDER BY total_vendidas DESC;

/*3.Pedidos por repartidor (JOIN)*/
SELECT r.id AS repartidor_id, r.nombre AS nombre_repartidor, r.zona_asignada, COUNT(p.id) AS total_pedidos
FROM repartidores r
LEFT JOIN pedidos p ON r.id = p.repartidor_id
GROUP BY r.id, r.nombre, r.zona_asignada;

/*4.Promedio de entrega por zona (AVG y JOIN)*/
SELECT r.zona_asignada, 
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 2) AS promedio_minutos_entrega
FROM repartidores r
JOIN pedidos p ON r.id = p.repartidor_id
JOIN domicilios d ON p.id = d.pedido_id
WHERE d.hora_salida IS NOT NULL AND d.hora_entrega IS NOT NULL
GROUP BY r.zona_asignada;

/*5.Clientes que gastaron más de un monto (HAVING)*/
SELECT c.id, c.nombre, SUM(p.total) AS total_gastado
FROM clientes c
JOIN pedidos p ON c.id = p.cliente_id
GROUP BY c.id, c.nombre
HAVING SUM(p.total) > 50.00;

/*6.Búsqueda por coincidencia parcial de nombre de pizza (LIKE)*/
SELECT id, nombre, tamano, precio_base, tipo
FROM pizzas
WHERE nombre LIKE '%Pepperoni%';

/*7.Subconsulta para clientes frecuentes (más de 1 pedidos mensuales)*/

SELECT c.id, c.nombre, c.telefono, c.correo_electronico
FROM clientes c
WHERE c.id IN (
    SELECT cliente_id
    FROM pedidos
    WHERE MONTH(fecha_hora) = MONTH(CURRENT_DATE()) 
      AND YEAR(fecha_hora) = YEAR(CURRENT_DATE())
    GROUP BY cliente_id
    HAVING COUNT(id) > 1
);


