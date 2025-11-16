¡Entendido! Dejemos Rails a un lado por un momento y centrémonos puramente en el arte de construir consultas SQL eficientes y efectivas. Saber qué técnica SQL usar es una mezcla de entender los fundamentos, conocer las herramientas disponibles y analizar el problema específico.

Aquí te presento un desglose de las técnicas SQL más comunes, cuándo usarlas y su sintaxis básica.

**Principios Fundamentales para Decidir:**

1.  **Claridad del Requisito:** ¿Qué datos exactos quieres obtener? ¿Cómo se deben transformar, agregar o combinar?
2.  **Estructura de las Tablas:** ¿En qué tablas reside la información? ¿Cómo se relacionan estas tablas (claves primarias y foráneas)?
3.  **Empezar Simple:** Comienza con `SELECT`, `FROM`, `WHERE`. Añade complejidad solo cuando sea necesario.
4.  **Pensar en Conjuntos (Sets):** SQL opera sobre conjuntos de datos. Piensa en cómo filtrar, combinar y transformar estos conjuntos.
5.  **Optimización (Cuando sea Necesario):** Una vez que la consulta devuelve los datos correctos, puedes pensar en cómo hacerla más eficiente (índices, evitar subconsultas innecesarias, etc.).

---

**Técnicas SQL y Cuándo Usarlas:**

**1. Cláusulas Básicas: `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`**

*   **`SELECT column1, column2 AS alias, COUNT(*) ...`**
    *   **Cuándo:** Siempre. Para especificar qué columnas quieres devolver. Puedes usar funciones de agregación (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`).
*   **`FROM table1`**
    *   **Cuándo:** Siempre. Para especificar la tabla principal de la que obtendrás los datos.
*   **`WHERE condition1 AND/OR condition2 ...`**
    *   **Cuándo:** Para filtrar filas *antes* de cualquier agrupación. Las condiciones aquí operan sobre datos de filas individuales.
    *   Ejemplo: `WHERE price > 100 AND category = 'Electronics'`
*   **`GROUP BY column1, column2 ...`**
    *   **Cuándo:** Cuando usas funciones de agregación (`COUNT`, `SUM`, etc.) y quieres aplicar esas funciones a grupos de filas que comparten los mismos valores en las columnas especificadas en `GROUP BY`.
    *   Ejemplo: `SELECT category, COUNT(*) FROM products GROUP BY category;` (Cuenta productos por categoría)
*   **`HAVING condition_on_aggregate_function ...`**
    *   **Cuándo:** Para filtrar grupos *después* de que `GROUP BY` y las funciones de agregación se hayan aplicado. No puedes usar funciones de agregación en `WHERE`.
    *   Ejemplo: `SELECT category, COUNT(*) FROM products GROUP BY category HAVING COUNT(*) > 10;` (Categorías con más de 10 productos)
*   **`ORDER BY column1 ASC/DESC, column2 ASC/DESC ...`**
    *   **Cuándo:** Para especificar el orden de las filas en el resultado final.
    *   Ejemplo: `ORDER BY price DESC, name ASC;`

**2. JOINs: Combinando Datos de Múltiples Tablas**

Los `JOIN`s se usan para combinar filas de dos o más tablas basándose en una columna relacionada entre ellas.

*   **`INNER JOIN` (o simplemente `JOIN`)**
    *   **Sintaxis:** `FROM table1 INNER JOIN table2 ON table1.column = table2.column`
    *   **Cuándo:** Cuando solo quieres las filas donde hay una coincidencia en *ambas* tablas según la condición del `ON`. Si una fila en `table1` no tiene una coincidencia en `table2` (o viceversa), esa fila no aparecerá.
    *   **Condiciones `AND` en el `ON`:**
        *   Se usan para añadir criterios adicionales a la condición de unión *antes* de que se determine qué filas se unen.
        *   Ejemplo: `FROM orders JOIN order_items ON orders.id = order_items.order_id AND order_items.product_type = 'book'`
        *   Esto significa: "une `orders` con `order_items` donde los IDs coincidan *Y* el `product_type` en `order_items` sea 'book'". Si un `order_item` no es 'book', no se unirá, incluso si el `order_id` coincide.

*   **`LEFT JOIN` (o `LEFT OUTER JOIN`)**
    *   **Sintaxis:** `FROM table1 LEFT JOIN table2 ON table1.column = table2.column`
    *   **Cuándo:** Cuando quieres *todas* las filas de la tabla de la izquierda (`table1`) y las filas coincidentes de la tabla de la derecha (`table2`). Si no hay coincidencia en `table2`, las columnas de `table2` tendrán valores `NULL`.
    *   **Uso común:** Encontrar ítems que *no* tienen una correspondencia. Ejemplo: Clientes que no han hecho pedidos.
        `SELECT c.name FROM customers c LEFT JOIN orders o ON c.id = o.customer_id WHERE o.id IS NULL;`
    *   **Condiciones `AND` en el `ON` vs. `WHERE` para `LEFT JOIN`:**
        *   **`ON ... AND condition_on_table2`**: La condición se aplica *antes* de decidir si hay una coincidencia para el `LEFT JOIN`. Si la condición no se cumple para una fila de `table2`, esa fila de `table2` se trata como si no existiera para la unión, pero la fila de `table1` *aún se incluirá* (con `NULLs` para las columnas de `table2`).
        *   **`WHERE condition_on_table2`**: La condición se aplica *después* de que el `LEFT JOIN` se ha realizado. Si la condición filtra filas donde las columnas de `table2` son `NULL` (porque no hubo match), entonces efectivamente puede convertir un `LEFT JOIN` en un `INNER JOIN` para esas filas. Si la condición es, por ejemplo, `table2.column = 'value'`, y no hubo match (así que `table2.column` es `NULL`), la fila de `table1` será eliminada del resultado final.

*   **`RIGHT JOIN` (o `RIGHT OUTER JOIN`)**
    *   **Sintaxis:** `FROM table1 RIGHT JOIN table2 ON table1.column = table2.column`
    *   **Cuándo:** Cuando quieres *todas* las filas de la tabla de la derecha (`table2`) y las filas coincidentes de la tabla de la izquierda (`table1`). Menos común; a menudo se puede reescribir como un `LEFT JOIN` invirtiendo el orden de las tablas.

*   **`FULL OUTER JOIN`**
    *   **Sintaxis:** `FROM table1 FULL OUTER JOIN table2 ON table1.column = table2.column`
    *   **Cuándo:** Cuando quieres *todas* las filas de *ambas* tablas. Si hay una coincidencia, las columnas se combinan. Si no, se rellenan con `NULL` donde corresponda.

**3. Subconsultas (Subqueries)**

Una subconsulta es una consulta `SELECT` anidada dentro de otra consulta SQL.

*   **En la cláusula `WHERE`:**
    *   **Sintaxis (con `IN`):** `SELECT name FROM products WHERE category_id IN (SELECT id FROM categories WHERE is_active = TRUE);`
    *   **Sintaxis (con operador de comparación y subconsulta escalar):** `SELECT name, price FROM products WHERE price > (SELECT AVG(price) FROM products);`
    *   **Cuándo:** Para filtrar resultados basados en el resultado de otra consulta. Útil cuando el criterio de filtrado es dinámico o requiere una lógica de consulta separada.
    *   `EXISTS`: Para verificar si la subconsulta devuelve *alguna* fila. `SELECT c.name FROM customers c WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id AND o.order_date > '2023-01-01');` (Clientes que tienen pedidos después de una fecha).

*   **En la cláusula `SELECT` (Subconsulta Escalar):**
    *   **Sintaxis:** `SELECT p.name, p.price, (SELECT AVG(price) FROM products) AS overall_avg_price FROM products p;`
    *   **Cuándo:** Cuando necesitas un valor calculado (que debe devolver una sola fila y una sola columna) como una columna en tu consulta principal. A menudo puede ser menos eficiente que un `JOIN` o una función de ventana si la subconsulta es correlacionada (se ejecuta para cada fila de la consulta externa).

*   **En la cláusula `FROM` (Tabla Derivada):**
    *   **Sintaxis:** `SELECT t.category_name, t.avg_price FROM (SELECT c.name AS category_name, AVG(p.price) AS avg_price FROM categories c JOIN products p ON c.id = p.category_id GROUP BY c.name) AS t WHERE t.avg_price > 50;`
    *   **Cuándo:** Cuando necesitas realizar una agregación o una transformación compleja y luego hacer un `JOIN` o filtrar sobre ese resultado intermedio como si fuera una tabla. A menudo, los CTEs son una alternativa más legible.

**4. Common Table Expressions (CTEs)**

Los CTEs te permiten definir conjuntos de resultados temporales con nombre que puedes referenciar dentro de una única sentencia `SELECT`, `INSERT`, `UPDATE` o `DELETE`.

*   **Sintaxis:**
    ```sql
    WITH sales_per_employee AS (
        SELECT employee_id, SUM(amount) AS total_sales
        FROM sales
        GROUP BY employee_id
    ),
    top_employees AS (
        SELECT employee_id, total_sales
        FROM sales_per_employee
        WHERE total_sales > 10000
    )
    SELECT e.name, te.total_sales
    FROM employees e
    JOIN top_employees te ON e.id = te.employee_id
    ORDER BY te.total_sales DESC;
    ```
*   **Cuándo Usar CTEs:**
    *   **Mejorar Legibilidad:** Para descomponer consultas largas y complejas en pasos lógicos más pequeños y manejables.
    *   **Reutilización Dentro de una Consulta:** Si necesitas referenciar el mismo conjunto de resultados intermedio varias veces en la misma consulta (aunque algunas BDs pueden materializarlo solo una vez).
    *   **Consultas Recursivas:** Para manejar datos jerárquicos o grafos (e.g., organigramas, listas de materiales).
        ```sql
        WITH RECURSIVE employee_hierarchy (id, name, manager_id, level) AS (
          SELECT id, name, manager_id, 0
          FROM employees
          WHERE manager_id IS NULL -- Raíz
          UNION ALL
          SELECT e.id, e.name, e.manager_id, eh.level + 1
          FROM employees e
          JOIN employee_hierarchy eh ON e.manager_id = eh.id
        )
        SELECT * FROM employee_hierarchy ORDER BY level, name;
        ```
*   **Diferencia con Subconsultas en `FROM`:** Los CTEs se definen al principio de la consulta y pueden ser referenciados múltiples veces por su nombre, lo que a menudo resulta en un SQL más limpio. Las subconsultas en `FROM` se anidan y pueden ser más difíciles de leer si son complejas.

**5. Window Functions (Funciones de Ventana)**

Las funciones de ventana realizan un cálculo sobre un conjunto de filas de tabla que están de alguna manera relacionadas con la fila actual. A diferencia de `GROUP BY`, no colapsan las filas en una sola fila de salida por grupo.

*   **Sintaxis General:** `FUNCTION_NAME() OVER (PARTITION BY column_to_partition ORDER BY column_to_order FRAME_CLAUSE)`
    *   `PARTITION BY`: Divide las filas en particiones. La función se calcula para cada partición de forma independiente. (Opcional)
    *   `ORDER BY`: Ordena las filas dentro de cada partición. Requerido por algunas funciones de ventana (e.g., `RANK`, `LAG`). (Opcional, pero a menudo necesario)
    *   `FRAME_CLAUSE` (e.g., `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`): Define el subconjunto de filas dentro de la partición actual (la "ventana") sobre el cual opera la función. (Más avanzado, opcional)

*   **Tipos y Cuándo Usarlas:**
    *   **Funciones de Agregación (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`) como Window Functions:**
        *   **Cuándo:** Para calcular agregados (e.g., suma total de ventas por categoría) y mostrar ese agregado en *cada fila* junto con los detalles de la fila, sin usar `GROUP BY`.
        *   **Sintaxis:** `SELECT product_name, category, price, SUM(price) OVER (PARTITION BY category) AS total_category_price FROM products;`
            (Muestra el precio de cada producto y la suma de precios de todos los productos en su categoría)

    *   **Funciones de Ranking (`ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`):**
        *   **Cuándo:** Para asignar un rango a cada fila dentro de su partición basado en un `ORDER BY`.
            *   `ROW_NUMBER()`: Número secuencial único dentro de la partición.
            *   `RANK()`: Mismo rango para empates, pero salta el siguiente rango (1, 2, 2, 4).
            *   `DENSE_RANK()`: Mismo rango para empates, sin saltos (1, 2, 2, 3).
        *   **Sintaxis:** `SELECT name, salary, department, RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank_in_department FROM employees;`

    *   **Funciones de Valor (`LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE`):**
        *   **Cuándo:** Para acceder a datos de filas anteriores (`LAG`) o posteriores (`LEAD`) dentro de la partición.
        *   **Sintaxis:** `SELECT sale_date, amount, LAG(amount, 1, 0) OVER (ORDER BY sale_date) AS previous_day_amount FROM daily_sales;`
            (Muestra la venta de hoy y la venta del día anterior)

**6. `UNION` y `UNION ALL`**

Se usan para combinar los conjuntos de resultados de dos o más sentencias `SELECT`. Las consultas deben tener el mismo número de columnas y tipos de datos compatibles en las columnas correspondientes.

*   **`UNION`**
    *   **Sintaxis:** `SELECT column1, column2 FROM table1 WHERE condition1 UNION SELECT columnA, columnB FROM table2 WHERE condition2;`
    *   **Cuándo:** Para combinar resultados y *eliminar filas duplicadas* de los conjuntos combinados.

*   **`UNION ALL`**
    *   **Sintaxis:** `SELECT column1, column2 FROM table1 WHERE condition1 UNION ALL SELECT columnA, columnB FROM table2 WHERE condition2;`
    *   **Cuándo:** Para combinar resultados e *incluir todas las filas duplicadas*. Generalmente más rápido que `UNION` porque no tiene que verificar duplicados.

**Cómo Decidir Qué Usar (Proceso Mental):**

1.  **¿Necesito datos de una sola tabla o de varias?**
    *   Una: `SELECT ... FROM ... WHERE ...`
    *   Varias: Piensa en `JOINs`.
        *   ¿Solo filas coincidentes? `INNER JOIN`.
        *   ¿Todas las filas de una tabla y las coincidentes de la otra? `LEFT JOIN` o `RIGHT JOIN`.
        *   ¿Todas las filas de ambas? `FULL OUTER JOIN`.
        *   ¿La condición de unión es más compleja que una simple igualdad o necesita filtrado *durante* la unión? Añade `AND` en la cláusula `ON`.

2.  **¿Necesito filtrar filas?**
    *   Filtro simple sobre columnas individuales: `WHERE`.
    *   Filtro basado en el resultado de otra consulta: Subconsulta en `WHERE` (con `IN`, `EXISTS`, etc.).

3.  **¿Necesito agregar datos (contar, sumar, promediar)?**
    *   Sí: Usa funciones de agregación (`COUNT`, `SUM`, etc.).
    *   ¿Agregación por grupos? Añade `GROUP BY`.
    *   ¿Filtrar *después* de la agregación? Usa `HAVING`.

4.  **¿La consulta se está volviendo muy larga o necesito un resultado intermedio para pasos posteriores *dentro de la misma consulta*?**
    *   Considera los **CTEs** para mejorar la legibilidad y estructura.

5.  **¿Necesito realizar cálculos que comparen la fila actual con otras filas relacionadas (e.g., ranking, suma acumulada, valor anterior/siguiente) *sin colapsar las filas*?**
    *   Esta es la señal para usar **Window Functions**. Identifica la `PARTITION BY` (cómo agrupar lógicamente) y `ORDER BY` (cómo ordenar dentro de esas particiones para el cálculo).

6.  **¿Tengo dos o más conjuntos de resultados (de diferentes `SELECTs`) con la misma estructura que quiero apilar verticalmente?**
    *   Usa `UNION` (para eliminar duplicados) o `UNION ALL` (para mantenerlos).

7.  **¿La lógica de un filtro o una columna calculada es condicional?**
    *   Usa `CASE WHEN ... THEN ... ELSE ... END`.

**Ejemplo de Proceso de Pensamiento para una Consulta:**

"Quiero encontrar los 3 empleados mejor pagados en cada departamento, mostrando su nombre, departamento, salario y su rango salarial dentro de ese departamento."

1.  **Datos de:** `employees` (name, department, salary).
2.  **Tarea principal:** Ranking dentro de grupos (departamentos). Esto grita **Window Functions**.
3.  **Ranking:** `RANK()` o `DENSE_RANK()` sobre el salario, descendente.
4.  **Grupos:** "en cada departamento" -> `PARTITION BY department`.
5.  **Filtrar por rango:** Una vez que tengo el rango, quiero solo los rangos 1, 2, 3. Esto se hace *después* de que la función de ventana asigna los rangos. No puedo poner `WHERE rank <= 3` directamente en la misma consulta donde defino el `rank` con la función de ventana. Necesito una subconsulta o CTE.

    ```sql
    WITH RankedEmployees AS (
        SELECT
            name,
            department,
            salary,
            RANK() OVER (PARTITION BY department ORDER BY salary DESC) as salary_rank
        FROM
            employees
    )
    SELECT
        name,
        department,
        salary,
        salary_rank
    FROM
        RankedEmployees
    WHERE
        salary_rank <= 3;
    ```

Este es un proceso iterativo. A veces pruebas algo, ves el resultado (o el error) y refinas. La práctica constante y el análisis de cómo otros escriben SQL complejo son claves para volverse un experto. ¡Espero que esto te dé una base mucho más sólida!
