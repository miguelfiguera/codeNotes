# Funciones Comunes en SQL (Agrupadas por Tipo)

Estas funciones realizan operaciones sobre los datos. Su disponibilidad y sintaxis exacta pueden variar entre RDBMS (Sistemas de Gestión de Bases de Datos Relacionales).

## Funciones de Agregación (Operan sobre conjuntos de filas)

- `COUNT()`: Cuenta el número de filas (o valores no nulos de una columna).
- `SUM()`: Suma los valores de una columna numérica.
- `AVG()`: Calcula el promedio de los valores de una columna numérica.
- `MIN()`: Encuentra el valor mínimo en una columna.
- `MAX()`: Encuentra el valor máximo en una columna.
- `GROUP_CONCAT()` (MySQL) / `STRING_AGG()` (PostgreSQL, SQL Server): Concatena cadenas de un grupo.

## Funciones de Cadena

- `CONCAT()` o `||`: Concatena (une) cadenas.
- `SUBSTRING()` o `SUBSTR()`: Extrae una parte de una cadena.
- `LENGTH()` o `LEN()`: Devuelve la longitud de una cadena.
- `LOWER()` o `LCASE()`: Convierte una cadena a minúsculas.
- `UPPER()` o `UCASE()`: Convierte una cadena a mayúsculas.
- `REPLACE()`: Reemplaza ocurrencias de una subcadena.
- `TRIM()`, `LTRIM()`, `RTRIM()`: Elimina espacios en blanco (u otros caracteres) del inicio, fin o ambos lados.
- `POSITION()` o `INSTR()` o `CHARINDEX()`: Encuentra la posición de una subcadena.

## Funciones Numéricas

- `ABS()`: Devuelve el valor absoluto.
- `ROUND()`: Redondea un número a una cantidad específica de decimales.
- `CEILING()` o `CEIL()`: Redondea hacia arriba al entero más cercano.
- `FLOOR()`: Redondea hacia abajo al entero más cercano.
- `MOD()` o `%`: Devuelve el resto de una división.
- `POWER()` o `POW()`: Eleva un número a una potencia.
- `SQRT()`: Calcula la raíz cuadrada.

## Funciones de Fecha y Hora

- `CURRENT_DATE`, `CURDATE()`, `GETDATE()` (parte fecha): Obtiene la fecha actual.
- `CURRENT_TIME`, `CURTIME()`, `GETDATE()` (parte hora): Obtiene la hora actual.
- `CURRENT_TIMESTAMP`, `NOW()`, `GETDATE()`: Obtiene la fecha y hora actual.
- `DATE()`: Extrae la parte de fecha de un valor de fecha/hora.
- `TIME()`: Extrae la parte de hora.
- `YEAR()`, `MONTH()`, `DAY()`, `HOUR()`, `MINUTE()`, `SECOND()`: Extraen partes específicas de una fecha/hora (a menudo vía `EXTRACT`).
- `EXTRACT(part FROM source)`: Función estándar para extraer partes de fechas (ej. `EXTRACT(YEAR FROM order_date)`).
- `DATE_ADD()`, `DATE_SUB()` o aritmética con `INTERVAL`: Añaden o restan intervalos de tiempo a una fecha.
- `DATEDIFF()`: Calcula la diferencia entre dos fechas.

## Funciones Condicionales

- `CASE WHEN condition THEN result [WHEN...] [ELSE result] END`: Estructura condicional similar a if-then-else.
- `COALESCE(value1, value2, ...)`: Devuelve el primer argumento no nulo de la lista. Muy útil para manejar `NULL`s.
- `NULLIF(expr1, expr2)`: Devuelve `NULL` si `expr1` es igual a `expr2`, de lo contrario devuelve `expr1`.
- `IFNULL()` (MySQL) / `ISNULL()` (SQL Server): Devuelve un valor alternativo si el primer argumento es `NULL`.

## Funciones de Conversión de Tipo

- `CAST(expression AS datatype)`: Convierte un valor a un tipo de dato específico (estándar SQL).
- `CONVERT()`: Similar a `CAST`, con sintaxis diferente y a veces más opciones (común en SQL Server).

## Funciones de Ventana (Window Functions - Más Avanzadas)

Realizan cálculos sobre un conjunto de filas relacionadas con la fila actual (la "ventana"). Se usan con la cláusula `OVER()`.

- `ROW_NUMBER()`: Asigna un número secuencial único a cada fila dentro de su partición.
- `RANK()`: Asigna un rango a cada fila; puede haber empates (saltos en la secuencia).
- `DENSE_RANK()`: Asigna un rango sin saltos en la secuencia para los empates.
- `LAG()`, `LEAD()`: Acceden a datos de filas anteriores o posteriores dentro de la partición.
- Funciones de agregación usadas como funciones de ventana (ej. `SUM(...) OVER (...)`, `AVG(...) OVER (...)`).
