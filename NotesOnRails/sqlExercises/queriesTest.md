# Este es un test de queries en sql y active record:

## schema

Esquema Asumido (Recordatorio):

- vendors (id, name, created_at)
- products (id, vendor_id, category_id, name, price, stock_quantity)
- categories (id, name)
- discounts (id, vendor_id, product_id, description, percentage, active, start_date, end_date)
- customers (id, name, email, signup_date)
- orders (id, customer_id, order_date, total_amount)
- order_items (id, order_id, product_id, quantity, price_at_order)
- employees (id, name, manager_id)

1. Ranking de Productos por Precio:

- Para cada categoría, lista los nombres de los productos ordenados del más caro al más barato dentro de esa categoría. Incluye una columna que muestre el ranking de precio de cada producto dentro de su categoría (ej. 1 para el más caro, 2 para el segundo, etc., manejando empates si los hubiera).

```sql
SELECT p.name, c.name,RANK() OVER(PARTITION BY c.id ORDER BY p.price DESC) AS ranking FROM products AS p
JOIN categories AS c ON p.category_id=c.id
```

**ActiveRecord**

```ruby
Product.joins(:categories).select('products.name,categories.name,RANK() OVER(PARTITION BY categories.id ORDER BY products.price DESC)')
```

2. Clientes con Gasto Promedio Superior:

- Encuentra los nombres de los clientes cuyo valor promedio de orden (orders.total_amount) es mayor que el valor promedio de todas las órdenes en la base de datos.

```sql
SELECT c.name FROM customers AS c
JOIN orders AS o ON c.id = o.customer_id
HAVING AVG(o.total_amount) > (SELECT AVG(orders.total_amount) FROM orders)
GROUP BY c.id

```

**ActiveRecord**

```ruby
Customer.joins(:orders).having("AVG(orders.total_amount)> (SELECT AVG(orders.total_amount) FROM orders)").group(:id).pluck(:name)
```

3. Productos de Vendedores Recientes:

- Obtén una lista con los nombres de los productos (products.name) que son vendidos por vendedores (vendors) que se registraron (created_at) en los últimos 365 días.

```sql
SELECT DISTINCT p.name FROM products AS p
JOIN vendors AS v ON p.vendor_id = v.id
WHERE v.created_at >= CURRENT_DATE - INTERVAL '365 day'
GROUP BY p.id
```

**ActiveRecord**

```ruby
Product.joins(:vendor).where('vendors.created_at >= CURRENT_DATE - ?',365.days.ago).group(:id).distinct.pluck(:name)
```

4. Compañeros de Equipo por Gerente:
   Para cada empleado que tiene un gerente, muestra su nombre y cuántos otros empleados comparten el mismo gerente directo (es decir, el número de "compañeros" que le reportan al mismo jefe, sin contarse a sí mismo).

```sql
SELECT e.name, (SELECT COUNT(*) FROM employees AS peers WHERE peers.manager_id = e.manager_id AND peers.id != e.id) AS PeersCount FROM employees AS e
WHERE e.manager_id IS NOT NULL
ORDER BY e.id

```

```sql
SELECT
    e.name AS EmployeeName,
    COUNT(peers.id) AS PeersCount -- Contar los compañeros encontrados
FROM
    employees AS e
INNER JOIN -- Asegura que e tiene manager
    employees AS peers ON e.manager_id = peers.manager_id AND e.id != peers.id -- Encuentra compañeros con el mismo manager
WHERE
     e.manager_id IS NOT NULL -- Redundante por INNER JOIN pero explícito
GROUP BY
    e.id -- Agrupar por empleado 'e' para contar sus compañeros
ORDER BY
    EmployeeName ASC;
```

```ruby
Employee
  .joins("INNER JOIN employees AS peers ON employees.manager_id = peers.manager_id AND employees.id != peers.id")
  .where.not(manager_id: nil) # Asegurar que el empleado tiene manager
  .group("employees.id")
  .select("employees.name, COUNT(peers.id) AS peers_count")
  .order("employees.name ASC")

```

5. Listado Unificado de Descuentos Relevantes:

- Genera una única lista que contenga las descripciones (discounts.description) de todos los descuentos que están activos actualmente O aquellos cuya fecha de fin (end_date) es dentro de los próximos 7 días. Asegúrate de que cada descripción aparezca solo una vez si cumple ambas condiciones.

```sql
SELECT DISTINCT d.description FROM discounts AS d
WHERE d.active IS TRUE OR
d.end_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 day'
ORDER BY d.id
```

```ruby

Discount.where(
          "discounts.active = ? OR discounts.end_date BETWEEN ? AND ?",
          true,
          Date.today,
          Date.today + 7.days
        )
        .distinct
        .order(:id)
        .pluck(:description)
```

6. Vendedores Sin Productos Electrónicos:

- Identifica los nombres de los vendedores (vendors.name) que no tienen listado ningún producto perteneciente a la categoría 'Electrónicos'.

```sql
SELECT v.name
FROM vendors AS v
LEFT JOIN products AS p ON v.id = p.vendor_id
LEFT JOIN categories AS c ON c.id=p.category_id AND c.name = 'Electrónicos'
GROUP BY v.id
HAVING COUNT(c.id) = 0
ORDER BY v.name ASC

-- Another way
WITH electronicos AS (
    SELECT DISTINCT vendor_id
    FROM products
    JOIN categories ON products.category_id = categories.id
    WHERE categories.name = 'Electrónicos'
      AND vendor_id IS NOT NULL
)
SELECT v.name FROM vendors AS v
WHERE v.id NOT IN (SELECT vendor_id FROM electronicos)
ORDER BY v.name

```

```ruby
Vendor
  .left_outer_joins(products: :category)
  .group("vendors.id")
  .having(
    "COUNT(CASE WHEN categories.name = 'Electrónicos' THEN categories.id ELSE NULL END) = 0"
  )
  .pluck(:name)

  # segunda opcion

 electronic_products = Product.joins(:category).where(categories: { name: 'Electrónicos' })
Vendor.where.not(id: electronic_products.select(:vendor_id).distinct)
      .order(:name)
      .pluck(:name)


```

7. Variación Mensual del Valor de Órdenes:
   Calcula el valor total (SUM(total_amount)) de las órdenes para cada mes del año pasado (últimos 12 meses completos). Adicionalmente, muestra el cambio porcentual en el valor total comparado con el mes anterior.

8. Ruta Jerárquica de Empleados:

- Para cada empleado, muestra su nombre y una cadena de texto que represente su línea de reporte ascendente hasta el nivel superior (ej. "Empleado C -> Gerente B -> CEO A"). Considera cómo manejar empleados sin gerente.

9. Clientes Inactivos Recientemente:

- Encuentra los nombres y correos electrónicos de los clientes que existen en la tabla customers pero que no han realizado ninguna orden (orders) en los últimos 6 meses.

10. Comparación de Precio de Producto con Promedio de Categoría:

- Lista el nombre y precio de cada producto. Añade una columna que indique si el precio de ese producto es 'Mayor', 'Menor' o 'Igual' al precio promedio de todos los productos dentro de su misma categoría.
