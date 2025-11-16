¡Excelente! Los dobles de prueba (Test Doubles) son herramientas fundamentales en RSpec para **aislar la unidad bajo prueba** de sus dependencias. Esto hace que tus tests sean más rápidos, más fiables (no dependen de si la base de datos o una API externa funcionan) y más enfocados en la lógica específica que quieres verificar.

Los términos `double`, `stub` y `mock` a menudo se usan de forma intercambiable, pero en RSpec tienen significados ligeramente distintos, aunque relacionados:

- **Test Double:** Es el término genérico para cualquier objeto que reemplaza a un objeto real durante una prueba. RSpec usa el método `double("nombre_opcional")` para crear un doble básico.
- **Stub :** Es un doble de prueba que **proporciona respuestas predefinidas** a llamadas de métodos específicos. Lo usas cuando tu código bajo prueba _necesita_ un valor o un comportamiento de una dependencia para poder continuar, pero _no te importa_ si ese método de la dependencia fue llamado o cómo. El foco está en controlar el **estado** o la **respuesta** de la dependencia.
- **Mock :** Es un doble de prueba que **tiene expectativas predefinidas** sobre los métodos que _deben_ ser llamados sobre él. Lo usas para verificar que tu código bajo prueba realiza las **interacciones correctas** con sus dependencias. El test fallará si el método esperado no se llama, o si se llama con argumentos incorrectos. El foco está en verificar el **comportamiento** o la **interacción**.

Veamos los usos comunes con ejemplos claros:

**1. Stubs: Controlar Respuestas de Dependencias**

- **Uso Común:** Cuando tu método necesita obtener un valor de otro objeto (una dependencia) para funcionar, pero no quieres usar el objeto real (porque es lento, complejo de configurar, o quieres forzar un escenario específico).
- **Sintaxis RSpec:** `allow(objeto_o_doble).to receive(:nombre_metodo).and_return(valor_deseado)`

**Ejemplo:** Tienes una clase `Dashboard` que muestra el nombre del usuario actual, obtenido de un objeto `Session`. Quieres probar `Dashboard` sin necesidad de simular un login real.

```ruby
# --- Código bajo prueba ---
class Session
  def current_user_name
    # ... lógica compleja para obtener el usuario de la sesión real ...
    raise "No quiero ejecutar esto en mi test unitario!"
  end
end

class Dashboard
  def initialize(session)
    @session = session
  end

  def display_greeting
    user_name = @session.current_user_name
    "Hola, #{user_name}!"
  end
end

# --- Spec ---
require_relative '../dashboard' # Asegúrate de requerir tus clases
# No necesitamos requerir Session aquí si usamos un doble

RSpec.describe Dashboard do
  it "muestra un saludo con el nombre del usuario actual" do
    # 1. Creamos un doble para la Session. No necesita ser una instancia real.
    #    El string "Session" es solo una etiqueta descriptiva.
    fake_session = double("Session")

    # 2. Creamos un STUB: Le decimos al doble que cuando reciba el mensaje
    #    :current_user_name, DEBE responder con "Carmen".
    allow(fake_session).to receive(:current_user_name).and_return("Carmen")

    # 3. Inyectamos el doble (con el stub) en nuestra clase Dashboard
    dashboard = Dashboard.new(fake_session)

    # 4. Ejecutamos el método y verificamos el resultado.
    #    El método llamará a fake_session.current_user_name, que devolverá "Carmen"
    #    gracias a nuestro stub.
    expect(dashboard.display_greeting).to eq("Hola, Carmen!")

    # Nota: El test PASA incluso si :current_user_name no se hubiera llamado nunca.
    # El stub solo define la respuesta SI SE LLAMA. No exige que se llame.
  end
end
```

**2. Mocks: Verificar Interacciones (Llamadas a Métodos)**

- **Uso Común:** Cuando la responsabilidad principal del método que estás probando es llamar a otro método en un objeto colaborador (una dependencia), posiblemente con argumentos específicos. Quieres asegurarte de que esa llamada _ocurre_.
- **Sintaxis RSpec:** `expect(objeto_o_doble).to receive(:nombre_metodo).with(argumentos_esperados)`

**Ejemplo:** Tienes una clase `OrderProcessor` que, después de procesar un pedido, _debe_ llamar a un servicio `Notifier` para enviar una notificación. Quieres probar que la notificación se intenta enviar.

```ruby
# --- Código bajo prueba ---
class Notifier
  def send_order_confirmation(customer_email, order_id)
    # ... lógica real para enviar un email (lenta, depende de servicios externos) ...
    puts "Enviando email a #{customer_email} para pedido #{order_id}"
  end
end

class OrderProcessor
  def initialize(notifier)
    @notifier = notifier
  end

  def process(customer_email, order_id)
    puts "Procesando pedido #{order_id}..."
    # Lógica de procesamiento...
    @processed = true
    # ¡La interacción crucial que queremos probar!
    @notifier.send_order_confirmation(customer_email, order_id)
    puts "Pedido #{order_id} procesado."
    true
  end
end

# --- Spec ---
require_relative '../order_processor'

RSpec.describe OrderProcessor do
  it "envía una notificación después de procesar un pedido" do
    # 1. Creamos un doble para el Notifier.
    mock_notifier = double("Notifier")

    # 2. Creamos un MOCK (una EXPECTATIVA): Esperamos que el mock_notifier
    #    RECIBA el mensaje :send_order_confirmation EXACTAMENTE UNA VEZ,
    #    y CON los argumentos 'cliente@ejemplo.com' y 999.
    expect(mock_notifier).to receive(:send_order_confirmation)
                          .with('cliente@ejemplo.com', 999)
                          .once # '.once' es opcional si solo esperas una llamada

    # 3. Inyectamos el mock en nuestra clase OrderProcessor
    order_processor = OrderProcessor.new(mock_notifier)

    # 4. Ejecutamos el método que DEBERÍA disparar la llamada esperada.
    order_processor.process('cliente@ejemplo.com', 999)

    # 5. ¡VERIFICACIÓN IMPLÍCITA! Al final del bloque `it`, RSpec
    #    automáticamente verifica si todas las expectativas (`expect(...).to receive`)
    #    se cumplieron. Si `send_order_confirmation` no fue llamado, o fue
    #    llamado con otros argumentos, el test FALLARÁ.
  end
end
```

**3. Doubles (Simples y Verificadores): Creación de los Reemplazos**

- **`double("Nombre")`:** Crea el doble más básico. Es útil pero "tonto", puedes decirle que reciba cualquier método, exista o no en la clase real.
- **`instance_double(ClassName, stubs_opcionales)` y `class_double(ClassName, stubs_opcionales)`:** Son **dobles verificadores**. Son mucho más seguros.
  - Solo te permiten hacer stub o mock de métodos que _realmente existen_ en la clase `ClassName` (o sus ancestros).
  - Verifican que la _aridad_ (número de argumentos) de los métodos que stubeas/mockeas coincida con la del método real.
  - `instance_double` simula una instancia de la clase.
  - `class_double` simula la propia clase (para hacer stub/mock de métodos de clase).
- **Uso Común:** Siempre que sepas la clase real que estás reemplazando, es **altamente recomendable** usar `instance_double` o `class_double` en lugar de `double` para evitar que tus tests pasen incluso si refactorizas la clase real y cambias el nombre o los argumentos de un método.

**Ejemplo (Usando `instance_double` en los ejemplos anteriores):**

```ruby
# --- Spec del Dashboard (mejorado) ---
# Asumiendo que existe la clase `Session` en algún lugar
# require_relative '../session' # Podrías necesitar requerirla para instance_double

RSpec.describe Dashboard do
  it "muestra un saludo con el nombre del usuario actual (con instance_double)" do
    # Usamos instance_double. RSpec verificará que Session responde a :current_user_name
    fake_session = instance_double(Session)
    # Si Session no tiene .current_user_name, instance_double dará error aquí mismo.

    allow(fake_session).to receive(:current_user_name).and_return("Carmen")
    # Si .current_user_name esperara argumentos, RSpec también lo verificaría.

    dashboard = Dashboard.new(fake_session)
    expect(dashboard.display_greeting).to eq("Hola, Carmen!")
  end
end

# --- Spec del OrderProcessor (mejorado) ---
# Asumiendo que existe la clase `Notifier`
# require_relative '../notifier'

RSpec.describe OrderProcessor do
  it "envía una notificación después de procesar un pedido (con instance_double)" do
    # Usamos instance_double. RSpec verificará que Notifier responde a :send_order_confirmation
    mock_notifier = instance_double(Notifier)
    # Si el método real no existe o tiene diferente aridad, instance_double fallará.

    expect(mock_notifier).to receive(:send_order_confirmation)
                          .with('cliente@ejemplo.com', 999)

    order_processor = OrderProcessor.new(mock_notifier)
    order_processor.process('cliente@ejemplo.com', 999)
  end
end
```

**En Resumen:**

| Característica            | Stub (`allow(...).to receive(...)`)                | Mock (`expect(...).to receive(...)`)             |
| :------------------------ | :------------------------------------------------- | :----------------------------------------------- |
| **Propósito**             | Controlar **respuestas/estado** de una dependencia | Verificar **interacciones/comportamiento**       |
| **Foco**                  | Qué **devuelve** la dependencia si se le llama     | Que la dependencia **sea llamada** correctamente |
| **Fallo si no se llama?** | No                                                 | **Sí** (es una expectativa)                      |
| **Ideal para...**         | Proporcionar datos de entrada para tu SUT\*        | Verificar efectos secundarios en colaboradores   |
| **Verificación**          | No hay verificación explícita de llamada           | RSpec verifica al final del test                 |

_\*SUT = System Under Test (Sistema Bajo Prueba)_

Usa **stubs** cuando necesites que una dependencia se comporte de cierta manera para que tu test pueda continuar. Usa **mocks** cuando la _propia llamada_ a la dependencia sea el comportamiento importante que quieres verificar. Y siempre que puedas, ¡usa **dobles verificadores** (`instance_double`, `class_double`) para mayor seguridad!
