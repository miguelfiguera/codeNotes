# Rspec Basics.

## Ecosistema:

Si bien rspec es el fundamento y la piedra angular de esta suite de testing, no es la unica gema que colabora en el proceso, normalmente junto a rspec se pueden usar:

- rspec-rails (la que usamos en rails)
- factory_bot_rails (creacion de datos de prueba)
- faker (datos falsos al azar para la creacion de datos de prueba)
- database_cleaner o database_cleaner-active_record, limpieza de base de datos para evitar problemas por datos creados previamente.
- capybara, para simular la interaccion del usuario, feature specs y similares. Rspec viene ya con soporte integrado para capybara.
- selenium-webdriver junto :cuprite, colabora con capybara y permite la ejecucion de js en los tests.

### No tan comunes:

- simplecov para medir el alcance de tu test coverage.
- shoulda-matchers para validaciones en modelos, asociaciones y callbacks de activerecords. Tambien para controladores tengo entendido.
- webmock/vrc: stub para simulacion de peticiones http y definir respuestas esperadas. vcr graba las interacciones http reales y luego las ejecuta.

Tu gemfile en el area de testing podria verse de la siguiente manera:

```ruby
group :development, :test do
  gem 'rspec-rails', '~> 6.0' # O la versión que corresponda
  gem 'factory_bot_rails'
  gem 'faker' # Generalmente útil en ambos entornos
  gem 'database_cleaner-active_record' # O la gema específica para tu ORM
  # Para System/Feature tests:
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  # gem 'cuprite' # Alternativa a selenium/webdrivers
end

group :test do
  gem 'simplecov', require: false
  gem 'shoulda-matchers'
  gem 'webmock' # Si interactúas con APIs externas
  # gem 'vcr' # Alternativa/complemento a webmock
  gem 'launchy' # Para save_and_open_page
end
```

### Nota

Es requerido que hagas la configuracion correcta de cada una de estas gemas, por ahora no tengo ningun archivo que explique el proceso de forma adecuada, sin embargo puedes revisar por tu cuenta la documentacion.

Si en algun punto existe el archivo, es probable que igual te recomiende que revises la documentacion.

Por ejemplo, en algunos tests vas a usar create(factory_del_modelo) y se guardaran en la base de datos, esto hara necesario que se limpie la base de datos de tests de cualquier registro antes de correr el proximo test.

De otra forma te arriesgas a que tus tests tengan errores.

---

## Sintaxis

Rspec tiene una sintaxis especifica:

- Rspec.describe, para definir la clase.
- describe, para definir el metodo.
- context, para agrupar de acuerdo a una condicion especifica, como el numero de argumentos o tipo de data pasado al metodo.
- it, se usa para definir un test case (un escenario especifico y la funcionalidad esperada), estos bloques no deben probar más de una funcionalidad a la vez.

```ruby

Rspec.describe User do
    describe "User registration" do
        context "When user dont sent full information" do
            it "returns false when name is not present" do
            end
            it "returns true when name is present" do
            end

            it "returns false when email is not present" do
            end
        end
    end
end
```

---

### Metodos para testing:

---

#### **expect**: realiza la aserción o verificación, comprueba si un valor cumple con la condición esperada.

```ruby
expect(valor_actual).to matcher(valor_esperado)
```

- expect(...): Recibe el valor o bloque de código que quieres evaluar.

- .to o .not_to (o .to_not): Indica si esperas que la condición se cumpla o no.
- matcher: Es el método que define la condición a verificar (igualdad, verdad, nil, lanzar error, cambiar valor, etc.).

#### matchers comunes:

- eq(valor): Igualdad de valor (==).
- eql(valor): Igualdad de valor y tipo (eql?).
- be(valor): Igualdad de objeto (equal?, misma identidad).
- be_truthy: El valor es evaluado como verdadero (cualquier cosa que no sea false o nil).
- be_falsey: El valor es evaluado como falso (false o nil).
- be_nil: El valor es nil.
- include(valor): La colección (Array, String, Hash) incluye el valor.
- raise_error(ErrorType): El bloque de código (expect { ... }) lanza una excepción del tipo especificado.
- change { expresion }.from(antes).to(despues): Verifica que evaluar la expresion cambia su valor como se indica.
- be_a(Clase) / be_an_instance_of(Clase): El objeto es una instancia de esa clase.

#### let y let!

definen variables "memoizadas", cacheadas, dentro deu ngrupo describe o context. Ayudan a mantener los tests limpios.

- let(:nombre_variable) { ... }:
  Evaluación perezosa (Lazy evaluation): El bloque {...} solo se ejecuta la primera vez que se llama a nombre_variable dentro de un it específico.
- Memoización: El resultado se guarda y se reutiliza si se vuelve a llamar a nombre_variable dentro del mismo it. Se recalcula para cada it.
- let!(:nombre_variable) { ... }:
  Igual que let, pero el bloque se ejecuta antes de cada it en el grupo, incluso si la variable no se usa explícitamente en ese it. Útil para setup que debe ocurrir (ej: crear registros en la BD).

```ruby
let(:usuario) { Usuario.new(nombre: "Juan", apellido: "Pérez") }
let!(:post) { create(:post, autor: usuario) } # Usando FactoryBot, por ejemplo

it "tiene un nombre completo" do
  expect(usuario.nombre_completo).to eq("Juan Pérez")
end
```

#### before y after:

Ejecutan código antes o después de los ejemplos. before(:each) { ... } o before(:all) { ... } (y lo mismo para after).

- :each (o :example): Se ejecuta antes/después de cada it en el grupo. Es lo más común.
- :all (o :context): Se ejecuta una sola vez antes/después de todos los it en el grupo. Úsalo con precaución, ya que el estado puede persistir entre ejemplos, lo cual generalmente se quiere evitar.

Se suelen usar para setup/teardown que no encaja bien en let o let!, como limpiar una base de datos, iniciar/detener servicios externos, etc.

#### subject:

Define el objeto principal bajo prueba en el contexto actual. Puede ser explícito o implícito.

- Implícito: Como mencioné, RSpec.describe MiClase crea un subject que es MiClase.new.
- Explícito: Puedes definirlo tú mismo, a menudo usando let o directamente.

```ruby
RSpec.describe Calculadora do
  subject(:calculadora) { Calculadora.new(precision: 2) } # Subject explícito con nombre

  describe "#sumar" do
    # Se puede usar 'subject' directamente o el nombre 'calculadora'
    it "suma dos números" do
      expect(subject.sumar(2, 3)).to eq(5)
      expect(calculadora.sumar(1, 1)).to eq(2)
    end

    # Sintaxis corta usando 'is_expected' (funciona con el subject)
    it { is_expected.to respond_to(:sumar) }
  end
end
```

- is_expected: Es una sintaxis corta que equivale a expect(subject).

### Ejemplo completo:

---

```ruby
# spec/calculadora_spec.rb

require 'rails_helper' # O solo 'spec_helper' si no es Rails, o requiere tu archivo de clase
require_relative '../app/models/calculadora' # Asegúrate de cargar tu clase

RSpec.describe Calculadora do
  # Usamos let para crear la instancia que se usará en los tests
  let(:calculadora) { Calculadora.new }

  describe "#sumar" do
    it "suma correctamente dos números positivos" do
      resultado = calculadora.sumar(5, 3)
      expect(resultado).to eq(8)
    end

    it "suma correctamente un número positivo y cero" do
      expect(calculadora.sumar(7, 0)).to eq(7)
    end

    it "suma correctamente dos números negativos" do
      expect(calculadora.sumar(-5, -2)).to eq(-7)
    end
  end

  describe "#restar" do
    context "cuando el primer número es mayor" do
      it "devuelve un resultado positivo" do
        expect(calculadora.restar(10, 4)).to eq(6)
      end
    end

    context "cuando el segundo número es mayor" do
      it "devuelve un resultado negativo" do
        expect(calculadora.restar(3, 8)).to eq(-5)
      end
    end
  end

  # Ejemplo con subject explícito y 'is_expected'
  describe "precisión por defecto" do
     subject { Calculadora.new } # Subject implícito funciona igual aquí
     it { is_expected.to have_attributes(precision: 0) } # Asumiendo que Calculadora tiene attr_reader :precision
  end
end
```

### Raising Errors

Cuando tu codigo de Rspec requiere verificar un "efecto secundario" o un evento que sucede durante la ejecucion del codigo requiere que en la sintaxis uses {} en vez de (). La diferencia entre usar un bloque `{ ... }` (o `do ... end`) y pasar un valor directamente entre paréntesis `( ... )` a `expect` se reduce a **lo que RSpec necesita evaluar para realizar la aserción.**

**1. `expect(valor_actual).to matcher(valor_esperado)` (Con paréntesis)**

- **Cuándo se usa:** Cuando el **valor actual** que quieres probar es el _resultado directo_ de una expresión o una llamada a un método. RSpec toma ese resultado y lo compara con lo que espera el `matcher`.
- **Cómo funciona:**
  1.  Primero se evalúa la expresión dentro de `expect(...)`. Por ejemplo, `calculador.sumar(1, 1)` se ejecuta y devuelve `2`.
  2.  Luego, ese resultado (`2`) se pasa al matcher. `eq(2)` compara `2 == 2`.
- **Ejemplos:**

  ```ruby
  expect(calculador.sumar(1, 1)).to eq(2)
  # RSpec evalúa calculador.sumar(1,1) -> obtiene 2
  # Luego compara: 2 es igual a 2?

  expect(inventario.items_disponibles).to include('manzanas')
  # RSpec evalúa inventario.items_disponibles -> obtiene ['manzanas'] (o lo que sea)
  # Luego pregunta: el array ['manzanas'] incluye 'manzanas'?
  ```

**2. `expect { codigo_que_lanza_el_error }.to raise_error(TipoDeError)` (Con bloque `{...}`)**

- **Cuándo se usa:** Cuando lo que quieres probar es un **efecto secundario** o un **evento** que ocurre durante la ejecución de un bloque de código. El matcher `raise_error` no está interesado en el _valor de retorno_ del bloque (que, si se lanza un error, no existe o es el propio error). En su lugar, está interesado en si _se lanza_ un error específico _mientras_ se ejecuta ese bloque.
- **Cómo funciona:**
  1.  RSpec toma el bloque de código `{ inventario.agregar('peras', 0) }` **sin ejecutarlo inmediatamente**.
  2.  El matcher `raise_error` es especial: se prepara para "atrapar" errores.
  3.  Luego, RSpec **ejecuta el código dentro del bloque** en un entorno controlado.
  4.  Si durante esa ejecución se lanza un error, `raise_error` lo "atrapa".
  5.  El matcher verifica si el error atrapado es del tipo esperado (y opcionalmente, si el mensaje coincide).
  6.  Si no se lanza ningún error, o se lanza un tipo de error diferente, la aserción falla.
- **Ejemplos:**
  ```ruby
  expect { inventario.agregar('peras', 0) }.to raise_error(ArgumentError)
  # RSpec ejecuta el código `inventario.agregar('peras', 0)`.
  # Si ese código lanza un ArgumentError, el test pasa.
  # Si no lanza ningún error, o lanza un TypeError, el test falla.
  ```
- **Otros matchers que usan bloques:**
  - **`change`**: También espera un bloque porque necesita evaluar una expresión _antes_ y _después_ de que se ejecute el código dentro del `expect { ... }`.
    ```ruby
    expect { inventario.agregar('manzanas', 5) }.to change { inventario.cantidad_de('manzanas') }.by(5)
    # 1. RSpec evalúa `inventario.cantidad_de('manzanas')` (antes) -> digamos 0
    # 2. RSpec ejecuta el bloque `inventario.agregar('manzanas', 5)`
    # 3. RSpec evalúa `inventario.cantidad_de('manzanas')` (después) -> digamos 5
    # 4. El matcher `change` verifica si el cambio fue de 5.
    ```
  - Muchos matchers relacionados con el rendimiento o el tiempo también usarían bloques para medir la ejecución del código.

**Analogía:**

Imagina que estás probando una tostadora:

- **`expect(tostadora.color).to eq('rojo')` (paréntesis):** Estás mirando el _estado_ o _atributo_ actual de la tostadora (su color) y comparándolo.
- **`expect { tostadora.tostar_pan }.to raise_error(CortoCircuitoError)` (bloque):** Estás observando una _acción_ (`tostar_pan`). No te importa si `tostar_pan` devuelve algo (probablemente `nil` o `true`), te importa si _durante_ esa acción ocurre un evento específico (un cortocircuito).

**En resumen:**

- Usa **paréntesis `()`** con `expect` cuando te interesa el **valor de retorno** de una expresión y quieres compararlo.
- Usa un **bloque `{}`** (o `do...end`) con `expect` cuando te interesa un **evento que sucede durante la ejecución** de ese bloque (como lanzar un error o cambiar un estado). RSpec necesita controlar la ejecución del bloque para observar estos eventos.

Es una distinción sutil pero crucial para usar los matchers de RSpec correctamente, especialmente `raise_error` y `change`.
