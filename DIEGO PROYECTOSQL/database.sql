
CREATE DATABASE pizzeria_don_piccolo;
USE pizzeria_don_piccolo;


CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE ingredientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    stock DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    stock_minimo DECIMAL(10,2) NOT NULL DEFAULT 5.00,
    costo DECIMAL(10,2) NOT NULL
);

CREATE TABLE pizzas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tamano ENUM('Personal', 'Mediana', 'Familiar', 'Gigante') NOT NULL,
    precio_base DECIMAL(10,2) NOT NULL,
    tipo ENUM('vegetariana', 'especial', 'clásica') NOT NULL
);

CREATE TABLE pizza_ingredientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pizza_id INT NOT NULL,
    ingrediente_id INT NOT NULL,
    cantidad_requerida DECIMAL(10,2) NOT NULL DEFAULT 1.00,
    FOREIGN KEY (pizza_id) REFERENCES pizzas(id) ON DELETE CASCADE,
    FOREIGN KEY (ingrediente_id) REFERENCES ingredientes(id) ON DELETE CASCADE
);

CREATE TABLE repartidores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    zona_asignada VARCHAR(50) NOT NULL,
    estado ENUM('disponible', 'no disponible') DEFAULT 'disponible'
);

CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    repartidor_id INT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    metodo_pago ENUM('efectivo', 'tarjeta', 'aplicacion') NOT NULL,
    estado ENUM('pendiente', 'en preparación', 'entregado', 'cancelado') DEFAULT 'pendiente',
    total DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (repartidor_id) REFERENCES repartidores(id)
);

CREATE TABLE detalle_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    pizza_id INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    subtotal DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (pizza_id) REFERENCES pizzas(id)
);

CREATE TABLE domicilios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    hora_salida DATETIME NULL,
    hora_entrega DATETIME NULL,
    distancia_aproximada DECIMAL(6,2) NOT NULL,
    costo_envio DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE
);

CREATE TABLE historial_precios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pizza_id INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo DECIMAL(10,2) NOT NULL,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pizza_id) REFERENCES pizzas(id) ON DELETE CASCADE
);


-- 3. Inserción de Datos de Prueba (Más registros)

-- Clientes
INSERT INTO clientes (nombre, telefono, direccion, correo_electronico) VALUES
('Carlos Pérez', '3101234567', 'Calle 10 # 20-30', 'carlos.perez@email.com'),
('Ana Gómez', '3209876543', 'Carrera 15 # 80-12', 'ana.gomez@email.com'),
('Luis Rodríguez', '3154567890', 'Avenida Central # 45-55', 'luis.rodriguez@email.com'),
('María Torres', '3187890123', 'Calle 50 # 5-22', 'maria.torres@email.com'),
('Jorge Cardenas', '3001112233', 'Transversal 8 # 12-45', 'jorge.cardenas@email.com');

-- Ingredientes (Champiñones en stock bajo para pruebas futuras)
INSERT INTO ingredientes (nombre, stock, stock_minimo, costo) VALUES
('Queso Mozzarella', 80.00, 10.00, 2.50),
('Pepperoni', 50.00, 5.00, 3.00),
('Salsa de Tomate', 70.00, 8.00, 1.00),
('Champiñones', 3.00, 5.00, 2.00), 
('Masa de Pizza', 150.00, 15.00, 1.50),
('Jamón', 40.00, 10.00, 2.20),
('Piña', 35.00, 8.00, 1.80);

-- Pizzas
INSERT INTO pizzas (nombre, tamano, precio_base, tipo) VALUES
('Pizza Margarita', 'Mediana', 18.00, 'clásica'),
('Pizza Pepperoni', 'Familiar', 25.00, 'especial'),
('Pizza Vegetariana', 'Mediana', 20.00, 'vegetariana'),
('Pizza Hawaiana', 'Familiar', 23.00, 'especial'),
('Pizza Napolitana', 'Personal', 14.00, 'clásica');

-- Relación Pizza - Ingredientes
INSERT INTO pizza_ingredientes (pizza_id, ingrediente_id, cantidad_requerida) VALUES
(1, 3, 1.00), (1, 1, 2.00), (1, 5, 1.00),
(2, 3, 1.00), (2, 1, 2.50), (2, 2, 1.50), (2, 5, 1.00),
(3, 3, 1.00), (3, 1, 2.00), (3, 4, 1.00), (3, 5, 1.00),
(4, 3, 1.00), (4, 1, 2.00), (4, 6, 1.20), (4, 7, 1.20), (4, 5, 1.00),
(5, 3, 1.00), (5, 1, 1.50), (5, 5, 0.80);

-- Repartidores
INSERT INTO repartidores (nombre, zona_asignada, estado) VALUES
('Andrés Morales', 'Zona Norte', 'disponible'),
('Sofía Castro', 'Zona Sur', 'disponible'),
('Mateo Rincón', 'Zona Centro', 'no disponible');

-- Pedidos (Varios pedidos con fechas recientes y distintos métodos de pago)
INSERT INTO pedidos (cliente_id, repartidor_id, fecha_hora, metodo_pago, estado, total) VALUES
(1, 1, NOW() - INTERVAL 2 DAY, 'efectivo', 'entregado', 28.50),
(2, 2, NOW() - INTERVAL 1 DAY, 'tarjeta', 'entregado', 32.00),
(1, 1, NOW() - INTERVAL 5 HOUR, 'aplicacion', 'en preparación', 45.00),
(3, 3, NOW() - INTERVAL 3 HOUR, 'efectivo', 'pendiente', 20.00),
(4, 2, NOW() - INTERVAL 1 HOUR, 'tarjeta', 'entregado', 25.00),
(1, 1, NOW(), 'efectivo', 'pendiente', 18.00);

-- Detalle de Pedidos
INSERT INTO detalle_pedidos (pedido_id, pizza_id, cantidad, subtotal) VALUES
(1, 1, 1, 18.00),
(2, 2, 1, 25.00),
(3, 2, 1, 25.00),
(3, 4, 1, 20.00),
(4, 3, 1, 20.00),
(5, 2, 1, 25.00),
(6, 1, 1, 18.00);

-- Domicilios
INSERT INTO domicilios (pedido_id, hora_salida, hora_entrega, distancia_aproximada, costo_envio) VALUES
(1, NOW() - INTERVAL 2 DAY + INTERVAL 20 MINUTE, NOW() - INTERVAL 2 DAY + INTERVAL 50 MINUTE, 4.50, 5.00),
(2, NOW() - INTERVAL 1 DAY + INTERVAL 15 MINUTE, NOW() - INTERVAL 1 DAY + INTERVAL 45 MINUTE, 6.00, 7.00),
(3, NOW() - INTERVAL 4 HOUR, NULL, 3.20, 4.00),
(4, NULL, NULL, 5.50, 6.00),
(5, NOW() - INTERVAL 50 MINUTE, NOW() - INTERVAL 20 MINUTE, 2.80, 3.50),
(6, NULL, NULL, 4.00, 4.50);