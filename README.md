# 🍕 Sistema Integral de Gestión de Pedidos y Domicilios - Pizzería Don Piccolo

## 📋 Descripción General del Proyecto

La **Pizzería Don Piccolo** operaba tradicionalmente mediante un registro manual de sus operaciones, lo cual generaba cuellos de botella en la atención al cliente, retrasos en la asignación de domicilios, discrepancias en el inventario de ingredientes y errores frecuentes en los registros de ventas y entregas.

Este proyecto implementa una solución de **Base de Datos Relacional robusta en MySQL**, diseñada desde cero para cubrir todo el ciclo de vida comercial del negocio: desde la captura de los requerimientos del cliente, el control estricto de recetas e inventarios, la automatización de la logística de envíos con repartidores, hasta el análisis financiero y la trazabilidad de precios.

---

## 🏗️ Arquitectura y Estructura de la Base de Datos

El diseño lógico y físico de la base de datos consta de 9 tablas interconectadas con restricciones de integridad referencial (claves foráneas, tipos `ENUM` estrictos y borrados en cascada donde corresponde):

### 1. Módulo de Clientes y Personal
* **`clientes`**: Almacena los datos de contacto principales (`nombre`, `telefono`, `direccion`, `correo_electronico` único). Permite identificar a compradores recurrentes.
* **`repartidores`**: Registra al personal de entrega, especificando su `zona_asignada` y un estado dinámico (`disponible` o `no disponible`) para la asignación de pedidos.

### 2. Módulo de Productos e Inventario
* **`ingredientes`**: Controla el stock actual, el `stock_minimo` permitido para alertas operativas y el costo unitario de cada insumo (clave para el cálculo de rentabilidad).
* **`pizzas`**: Catálogo de productos que define el nombre, `tamano` (`Personal`, `Mediana`, `Familiar`, `Gigante`), `precio_base` y el `tipo` (`vegetariana`, `especial`, `clásica`).
* **`pizza_ingredientes`**: Tabla intermedia que relaciona las pizzas con sus ingredientes, incorporando un Identificador Único (`id`) propio para un control granular de las recetas y las cantidades requeridas (`cantidad_requerida`).

### 3. Módulo de Operaciones y Transacciones
* **`pedidos`**: Tabla cabecera que agrupa la relación con el cliente, el repartidor asignado, la fecha y hora de la orden, el método de pago (`efectivo`, `tarjeta`, `aplicacion`), el estado actual (`pendiente`, `en preparación`, `entregado`, `cancelado`) y el monto total.
* **`detalle_pedidos`**: Tabla de detalle que desglosa las pizzas solicitadas por cada pedido, especificando cantidades y subtotales.
* **`domicilios`**: Administra la logística de envío asociada a un pedido, registrando la `hora_salida`, la `hora_entrega`, la `distancia_aproximada` en kilómetros y el `costo_envio`.
* **`historial_precios`**: Tabla de auditoría orientada a registrar de forma automática cualquier modificación en el precio base de las pizzas (`precio_anterior`, `precio_nuevo` y la fecha exacta).

---

## ⚙️ Lógica de Negocio Programada (Funciones y Procedimientos)

Para garantizar que el sistema automatice reglas críticas del negocio sin depender exclusivamente de la aplicación externa, se implementaron los siguientes bloques de código procedural:

### 1. Función `calcular_total_pedido(p_pedido_id)`
* **Propósito**: Automatiza el cálculo financiero de la factura de un cliente.
* **Funcionamiento**: Suma los subtotales de las pizzas asociadas en el detalle del pedido, añade el costo de envío correspondiente al domicilio y aplica automáticamente el recargo de impuesto (**IVA del 19%**) sobre las pizzas.

### 2. Función `calcular_ganancia_neta_diaria(p_fecha)`
* **Propósito**: Ofrece inteligencia de negocios (BI) para la toma de decisiones gerenciales.
* **Funcionamiento**: Evalúa los pedidos completados (`'entregado'`) en una fecha específica, calcula el total de ventas y le resta el costo real de los ingredientes consumidos (calculado en función de las recetas de las pizzas vendidas y los costos unitarios de los insumos en el inventario).

### 3. Procedimiento `registrar_entrega_domicilio(p_pedido_id, p_hora_entrega)`
* **Propósito**: Sincronizar las operaciones de logística y estatus comercial.
* **Funcionamiento**: Al recibir la hora de entrega final, actualiza simultáneamente la tabla de domicilios con la marca de tiempo y cambia de forma automática el estado del pedido principal a `'entregado'`.

---

## 🔄 Automatización Avanzada (Triggers / Desencadenantes)

El sistema hace uso de disparadores (*triggers*) para mantener la consistencia de los datos en tiempo real:

* **Actualización Automática de Stock**: Descuenta de la tabla `ingredientes` las cantidades exactas necesarias de cada insumo al registrarse un nuevo detalle de pedido, evitando sobreventa de productos.
* **Auditoría de Precios**: Captura mediante un trigger de tipo `BEFORE UPDATE` en la tabla `pizzas` cualquier cambio de precio, insertando un registro en `historial_precios` con los valores previos y nuevos.
* **Liberación de Repartidores**: Actualiza el estado del repartidor a `'disponible'` de manera automática en cuanto finaliza el proceso de un domicilio.

---

## 📊 Vistas Analíticas para Reportes

Se han creado vistas preconfiguradas que simplifican la extracción de información clave:

* **`vista_resumen_clientes`**: Agrupa a los clientes mostrando su nombre, la cantidad total de pedidos realizados y el acumulado histórico gastado.
* **`vista_desempeno_repartidores`**: Muestra las métricas operativas por repartidor, incluyendo el número total de entregas exitosas y la zona geográfica asignada.
* **`vista_stock_critico`**: Filtra y alerta de manera inmediata aquellos ingredientes cuyo stock actual se encuentra por debajo del `stock_minimo` establecido, facilitando las órdenes de compra a proveedores.

---

## 🚀 Guía de Instalación y Despliegue

Sigue estos pasos para levantar el entorno de base de datos en tu servidor MySQL local o remoto:

1. Abre tu entorno de desarrollo MySQL favorito (MySQL Workbench, DBeaver, HeidiSQL o consola).
2. Ejecuta el script de creación del esquema principal y carga de datos de prueba:
   ```sql
   SOURCE ruta/al/archivo/database.sql;
   ```
3. Implementa la capa de funciones y procedimientos almacenados:
   ```sql
   SOURCE ruta/al/archivo/funciones.sql;
   ```
4. Crea los triggers de automatización y auditoría:
   ```sql
   SOURCE ruta/al/archivo/triggers.sql;
   ```
5. Despliega las vistas analíticas:
   ```sql
   SOURCE ruta/al/archivo/vistas.sql;
   ```

---

## 🧪 Ejemplos Prácticos de Uso

* **Consultar el costo total con impuestos de un pedido:**
  ```sql
  SELECT calcular_total_pedido(1) AS total_a_pagar;
  ```

* **Obtener la ganancia neta de una jornada específica:**
  ```sql
  SELECT calcular_ganancia_neta_diaria('2026-09-15') AS ganancia_neta_dia;
  ```

* **Revisar ingredientes que necesitan reposición urgente:**
  ```sql
  SELECT * FROM vista_stock_critico;
  ```