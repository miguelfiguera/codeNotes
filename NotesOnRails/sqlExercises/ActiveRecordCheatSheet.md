# Active Record Cheat Sheet

# 1. Creación de Registros (INSERT)

### `new(attributes = {})`

Crea una nueva instancia del modelo en memoria, pero no la guarda en la base de datos. Los atributos se pueden pasar como un hash.
**Ejemplo:**

```ruby
user = User.new(name: "Alice", email: "alice@example.com")
```

### `create(attributes = {})`

Crea una nueva instancia y la guarda inmediatamente en la base de datos. Devuelve la instancia.
**Ejemplo:**

```ruby
user = User.create(name: "Bob", email: "bob@example.com")
```

### `create!(attributes = {})`

Igual que `create`, pero lanza una excepción (`ActiveRecord::RecordInvalid`) si las validaciones fallan.
**Ejemplo:**

```ruby
user = User.create!(name: "Charlie", email: "charlie@example.com")
```

### `save`

Guarda una instancia (nueva o modificada) en la base de datos. Devuelve `true` si tiene éxito y `false` si las validaciones fallan.
**Ejemplo (nuevo registro):**

```ruby
user = User.new(...)
user.save
```

**Ejemplo (actualizar registro):**

```ruby
user = User.find(1)
user.name = "Updated Name"
user.save
```

### `save!`

Igual que `save`, pero lanza una excepción (`ActiveRecord::RecordInvalid`) si las validaciones fallan.

# 2. Lectura / Consultas (SELECT)

### `find(id)`

Busca un registro por su clave primaria (ID). Lanza `ActiveRecord::RecordNotFound` si no lo encuentra.
**Ejemplo:**

```ruby
user = User.find(1)
```

### `find_by(attributes = {})`

Busca el primer registro que coincida con las condiciones dadas. Devuelve `nil` si no encuentra nada.
**Ejemplo:**

```ruby
user = User.find_by(email: "alice@example.com")
```

### `find_by!(attributes = {})`

Igual que `find_by`, pero lanza `ActiveRecord::RecordNotFound` si no encuentra nada.

### `where(conditions)`

Devuelve una relación (colección de registros) que cumple ciertas condiciones. Es la base para la mayoría de las consultas complejas. Permite encadenar métodos.
**Ejemplo:**

```ruby
active_users = User.where(active: true)
```

**Ejemplo:**

```ruby
recent_posts = Post.where("created_at > ?", 1.week.ago)
```

### `all`

Devuelve una relación con todos los registros de la tabla. Generalmente se usa después de otros métodos como `where` o `order`.
**Ejemplo:**

```ruby
all_users = User.all # (Aunque a menudo User.where(...) es suficiente)
```

### `first`

Devuelve el primer registro según el orden de la clave primaria (o el orden especificado con `order`).
**Ejemplo:**

```ruby
first_user = User.first
```

### `last`

Devuelve el último registro según el orden de la clave primaria (o el orden especificado con `order`).
**Ejemplo:**

```ruby
last_user = User.last
```

### `order(criteria)`

Especifica el orden de los resultados.
**Ejemplo:**

```ruby
users_by_name = User.order(name: :asc)
# o
users_by_creation = User.order("created_at DESC")
```

### `limit(number)`

Limita el número de registros devueltos.
**Ejemplo:**

```ruby
top_5_posts = Post.order(views: :desc).limit(5)
```

### `offset(number)`

Omite un número específico de registros (útil para paginación).
**Ejemplo:**

```ruby
users_page_2 = User.limit(10).offset(10)
```

### `select(columns)`

Selecciona sólo columnas específicas de la base de datos.
**Ejemplo:**

```ruby
user_emails = User.select(:id, :email)
```

### `pluck(*column_names)`

Selecciona columnas específicas y devuelve un array de valores (o arrays de valores si son múltiples columnas), saltándose la instanciación de objetos del modelo (más eficiente).
**Ejemplo:**

```ruby
user_ids = User.where(active: true).pluck(:id)
```

### `includes(*associations)`

Carga previamente las asociaciones especificadas para evitar el problema de N+1 consultas.
**Ejemplo:**

```ruby
posts_with_authors = Post.includes(:author).limit(10)
```

### `joins(*associations)`

Realiza un `INNER JOIN` con las tablas asociadas. Útil para filtrar basado en atributos de tablas relacionadas.
**Ejemplo:**

```ruby
posts_by_active_users = Post.joins(:author).where(users: { active: true })
```

### `left_outer_joins(*associations)`

Realiza un `LEFT OUTER JOIN`.
**Ejemplo:**

```ruby
users_with_or_without_posts = User.left_outer_joins(:posts)
```

### `group(*columns)`

Agrupa los registros por las columnas especificadas (para usar con funciones de agregación).
**Ejemplo:**

```ruby
posts_count_by_user = Post.group(:user_id).count
```

### `having(conditions)`

Añade condiciones a los resultados agrupados (similar a `WHERE` pero para grupos).
**Ejemplo:**

```ruby
users_with_many_posts = User.joins(:posts).group("users.id").having("COUNT(posts.id) > 10")
```

# 3. Actualización de Registros (UPDATE)

### `update(attributes = {})`

Actualiza los atributos de una instancia y la guarda inmediatamente. Devuelve `true` o `false` según el éxito de las validaciones.
**Ejemplo:**

```ruby
user = User.find(1)
user.update(name: "Alice Updated", active: false)
```

### `update!(attributes = {})`

Igual que `update`, pero lanza `ActiveRecord::RecordInvalid` si las validaciones fallan.

### `update_attribute(name, value)`

Actualiza un único atributo, **saltándose las validaciones**, y guarda el registro. (**¡Usar con precaución!**).
**Ejemplo:**

```ruby
user.update_attribute(:last_login_at, Time.current)
```

### `update_columns(attributes = {})`

Actualiza múltiples atributos **saltándose validaciones y callbacks**, y guarda el registro. (**¡Usar con mucha precaución!**).
**Ejemplo:**

```ruby
user.update_columns(login_count: 5, last_login_at: Time.current)
```

### `increment!(attribute, by = 1)`

Incrementa un atributo numérico y guarda inmediatamente (atómico).

### `decrement!(attribute, by = 1)`

Decrementa un atributo numérico y guarda inmediatamente (atómico).

### `toggle!(attribute)`

Cambia el valor de un atributo booleano y guarda inmediatamente.

# 4. Eliminación de Registros (DELETE)

### `destroy`

Elimina el registro de la base de datos. Ejecuta callbacks (`before_destroy`, `after_destroy`) y elimina/desvincula registros dependientes según las reglas de asociación (`dependent: :destroy`, `dependent: :nullify`, etc.). Devuelve el objeto congelado (frozen).
**Ejemplo:**

```ruby
user = User.find(1)
user.destroy
```

### `delete`

Elimina el registro directamente de la base de datos **sin ejecutar callbacks ni manejar dependencias**. Es más rápido pero potencialmente peligroso. Devuelve el número de filas afectadas (generalmente 1).
**Ejemplo:**

```ruby
user = User.find(1)
user.delete
```

### `destroy_all`

(Método de clase/relación) Elimina todos los registros que coinciden con la relación, **ejecutando callbacks** para cada uno. Es más lento pero más seguro que `delete_all`.
**Ejemplo:**

```ruby
User.where(active: false).destroy_all
```

### `delete_all`

(Método de clase/relación) Elimina todos los registros que coinciden con la relación directamente con SQL, **sin ejecutar callbacks**. Muy rápido pero peligroso.
**Ejemplo:**

```ruby
User.where("last_login_at < ?", 1.year.ago).delete_all
```

# 5. Validaciones

### `valid?`

Ejecuta las validaciones definidas en el modelo. Devuelve `true` si el objeto es válido, `false` en caso contrario. Rellena el objeto `errors`.
**Ejemplo:**

```ruby
user = User.new
user.valid? # => false (si las validaciones fallan)
```

### `invalid?`

Lo opuesto a `valid?`.

### `errors`

Devuelve un objeto `ActiveModel::Errors` que contiene los mensajes de error de validación (si los hay) después de llamar a `valid?`, `save`, `create`, etc.
**Ejemplo:**

```ruby
user.errors.full_messages # => ["Name can't be blank", "Email is invalid"]
```

# 6. Asociaciones (Relaciones)

Métodos generados por `has_many`, `belongs_to`, `has_one`, `has_and_belongs_to_many`, `has_many :through`:

- **Acceso:** `user.posts`, `post.author`, `user.profile`
- **Creación:** `user.posts.create(...)`, `user.create_profile(...)`, `post.build_author(...)`
- **Añadir/Quitar (colecciones `has_many`, `has_and_belongs_to_many`):** `user.posts << post`, `user.posts.delete(post)`

# 7. Cálculos y Agregaciones

### `count`

Cuenta el número de registros.
**Ejemplo:**

```ruby
total_users = User.count
active_users_count = User.where(active: true).count
```

### `sum(column)`

Suma los valores de una columna.

### `average(column)`

Calcula el promedio de una columna.

### `minimum(column)`

Encuentra el valor mínimo de una columna.

### `maximum(column)`

Encuentra el valor máximo de una columna.

### `calculate(operation, column)`

Método genérico para realizar cálculos (`:count`, `:sum`, `:average`, etc.).

# 8. Estado y Otros

### `new_record?`

Devuelve `true` si el objeto no ha sido guardado en la base de datos todavía.

### `persisted?`

Devuelve `true` si el objeto ha sido guardado en la base de datos y no ha sido eliminado.

### `destroyed?`

Devuelve `true` si el objeto fue eliminado usando `destroy`.

### `reload`

Recarga los atributos del objeto desde la base de datos.

### `transaction`

(Generalmente `ActiveRecord::Base.transaction do ... end`) Ejecuta un bloque de código dentro de una transacción de base de datos. Si algo falla, se hace rollback.

Esta lista cubre la gran mayoría de los métodos que usarás en el día a día con Active Record. ¡Espero que te sea útil!

---

¡Excelente pregunta! Aunque Active Record busca abstraer el SQL, hay varios métodos donde puedes (y a veces necesitas) usar fragmentos de SQL directo o incluso consultas completas.

Aquí están los métodos más comunes de la lista anterior donde puedes incorporar SQL directo:

## Métodos Comunes para Usar SQL Directo

### `where(sql_fragment, ...args)`

Este es el método más común para usar SQL en condiciones. Puedes pasar un string con tu condición SQL. Es crucial usar **placeholders** (`?` o `:named_placeholders`) para evitar inyecciones SQL.
**Ejemplo:**

```ruby
# Usando '?' como placeholder
User.where("email LIKE ? AND login_count > ?", "%@example.com", 5)

# Usando named placeholders
User.where("created_at > :start_date AND status = :status", { start_date: 1.month.ago, status: 'active' })

# SQL más complejo (¡cuidado con la inyección si no usas placeholders!)
User.where("LENGTH(name) > 10")
```

### `select(sql_fragment)`

Puedes usar SQL para seleccionar columnas específicas, calcular valores o usar funciones SQL.
**Ejemplo:**

```ruby
# Seleccionar columnas renombradas o calculadas
User.select("id, name AS user_name, email")

# Usar funciones SQL
Product.select("id, price, price * 0.8 AS discounted_price")

# Seleccionar un conteo relacionado (aunque joins/includes suele ser mejor)
User.select("users.*, (SELECT COUNT(*) FROM posts WHERE posts.user_id = users.id) AS posts_count")
```

### `order(sql_fragment)`

Permite definir el orden usando expresiones SQL.
**Ejemplo:**

```ruby
# Ordenar por una función SQL
User.order("RANDOM()") # Ejemplo en SQLite/PostgreSQL para orden aleatorio
User.order("created_at DESC") # Esto es SQL válido también

# Ordenar por múltiples columnas con direcciones específicas
Product.order("category ASC, price DESC")
```

### `joins(sql_fragment)`

Aunque normalmente usas nombres de asociaciones, puedes escribir la cláusula `JOIN` completa en SQL.
**Ejemplo:**

```ruby
# JOIN explícito (menos común que usar asociaciones)
Order.joins("INNER JOIN users ON users.id = orders.user_id AND users.active = TRUE")
```

### `group(sql_fragment)`

Puedes agrupar por columnas o expresiones SQL.
**Ejemplo:**

```ruby
# Agrupar por una función SQL sobre una columna
Order.group("DATE(created_at)").count # Agrupa por día
```

### `having(sql_fragment, ...args)`

Similar a `where`, pero para filtrar resultados después de agruparlos (`GROUP BY`). También acepta placeholders.
**Ejemplo:**

```ruby
User.joins(:posts)
  .group("users.id")
  .having("COUNT(posts.id) > ?", 10) # Usuarios con más de 10 posts
```

### `pluck(sql_fragment)`

Aunque principalmente usado con nombres de columna, técnicamente puede aceptar expresiones SQL simples que devuelven una columna.
**Ejemplo:**

```ruby
User.pluck("CONCAT(first_name, ' ', last_name)")
```

### `update_all(sql_fragment)` / `delete_all(sql_fragment)` / `destroy_all(sql_fragment)`

Las versiones de clase/relación de estos métodos pueden aceptar fragmentos SQL para las condiciones (`WHERE`) y `update_all` también para la asignación (`SET`).
**Ejemplo:**

```ruby
# Actualizar usando una expresión SQL
Product.where("stock < ?", 10).update_all("price = price * 1.1")

# Eliminar usando una condición SQL
LogEntry.where("created_at < '2023-01-01'").delete_all
```

## Métodos Específicos para SQL Directo

(No siempre en la lista "común" pero importantes):

### `find_by_sql(sql, binds = [])`

Ejecuta una consulta `SELECT` SQL completa y devuelve instancias de los modelos correspondientes. Usa placeholders (`?` o `:name`) en el array `binds`.
**Ejemplo:**

```ruby
sql = "SELECT * FROM users WHERE email LIKE ? ORDER BY created_at DESC LIMIT ?"
users = User.find_by_sql(sql, ["%@example.com", 10])
```

### `connection.execute(sql)`

Ejecuta SQL arbitrario (incluyendo `INSERT`, `UPDATE`, `DELETE`, DDL) directamente en la base de datos a través de la conexión. No devuelve instancias de modelos, sino un resultado dependiente del adaptador de base de datos. No ejecuta callbacks de Active Record.
**Ejemplo:**

```ruby
sql = "UPDATE posts SET view_count = view_count + 1 WHERE id = 123"
ActiveRecord::Base.connection.execute(sql)
```

### `connection.select_all(sql)` / `select_one` / `select_rows` / `select_value` / `select_values`

Métodos de la conexión para ejecutar consultas `SELECT` y obtener resultados en formatos más crudos (hashes, arrays, valores individuales) sin instanciar modelos Active Record.

> **¡Advertencia Importante!**
> Cuando uses SQL directo, especialmente si incorporas datos proporcionados por el usuario, **SIEMPRE** utiliza **placeholders** (`?` o `:named`) para pasar los valores. Construir strings SQL concatenando directamente valores externos te expone a graves vulnerabilidades de **inyección SQL**. Los métodos como `where`, `having`, `find_by_sql` y otros que aceptan argumentos adicionales están diseñados para manejar estos placeholders de forma segura.
