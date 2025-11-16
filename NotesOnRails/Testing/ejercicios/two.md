¡Estupendo! Vamos a subir un poco la dificultad, introduciendo `let` para definir el objeto bajo prueba y algunos matchers más, pero todavía sin Rails.

**Ejercicio 2: Un Inventario Simple**

**Objetivo:** Practicar el uso de `let`, `context`, y matchers como `be`, `include`, y `raise_error`.

**1. El Código a Probar:**

Crea un archivo llamado `inventario.rb` (o `lib/inventario.rb`).

```ruby
# lib/inventario.rb
class Inventario
  def initialize
    @items = {} # Usaremos un Hash para guardar { nombre_item => cantidad }
  end

  # Devuelve la cantidad actual de un item. Devuelve 0 si el item no existe.
  def cantidad_de(nombre_item)
    @items.fetch(nombre_item, 0)
  end

  # Añade una cantidad específica de un item al inventario.
  def agregar(nombre_item, cantidad)
    # Validamos que la cantidad sea positiva
    raise ArgumentError, "La cantidad a agregar debe ser positiva" if cantidad <= 0

    @items[nombre_item] = cantidad_de(nombre_item) + cantidad
  end

  # Remueve una cantidad específica de un item del inventario.
  def remover(nombre_item, cantidad)
    # Validamos que la cantidad sea positiva
    raise ArgumentError, "La cantidad a remover debe ser positiva" if cantidad <= 0

    cantidad_actual = cantidad_de(nombre_item)

    # Validamos que el item exista (o que la cantidad sea 0)
    raise StandardError, "El item '#{nombre_item}' no existe en el inventario" if cantidad_actual == 0

    # Validamos que haya suficiente cantidad para remover
    raise StandardError, "No hay suficiente '#{nombre_item}' para remover #{cantidad} (solo hay #{cantidad_actual})" if cantidad > cantidad_actual

    nueva_cantidad = cantidad_actual - cantidad

    if nueva_cantidad > 0
      @items[nombre_item] = nueva_cantidad
    else
      # Si la cantidad llega a 0 o menos (por si acaso), eliminamos la clave
      @items.delete(nombre_item)
    end
  end

  # Devuelve un array con los nombres de todos los items en el inventario.
  def items_disponibles
    @items.keys
  end
end
```

**2. El Archivo de Spec a Completar (`spec/inventario_spec.rb`):**

```ruby
# spec/inventario_spec.rb
require_relative '../lib/inventario' # Ajusta la ruta

RSpec.describe Inventario do
  # Usamos 'let' para crear la instancia ANTES de cada 'it'.
  # 'inventario' estará disponible dentro de cada 'it'.
  let(:inventario) { Inventario.new }

  describe '#initialize' do
    it 'comienza con un inventario vacío' do
      # --- TU CÓDIGO AQUÍ ---
      # Verifica que al inicio, llamar a items_disponibles devuelve un array vacío.
      # Matcher útil: `be_empty`
    end
  end

  describe '#agregar' do
    context 'cuando se agrega un item nuevo' do
      before do
        # Ejecuta esta acción antes de los 'it' de este contexto
        inventario.agregar('manzanas', 5)
      end

      it 'aumenta la cantidad del item correctamente' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que cantidad_de('manzanas') ahora es 5
        # Matcher: eq
      end

      it 'añade el item a la lista de items disponibles' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que items_disponibles ahora incluye 'manzanas'
        # Matcher útil: `include`
      end
    end

    context 'cuando se agrega cantidad a un item existente' do
      before do
        inventario.agregar('manzanas', 5) # Estado inicial
        inventario.agregar('manzanas', 3) # Agregamos más
      end

      it 'actualiza la cantidad total del item' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que cantidad_de('manzanas') ahora es 8 (5 + 3)
      end
    end

    context 'cuando se intenta agregar una cantidad no positiva' do
      it 'lanza un ArgumentError si la cantidad es cero' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que llamar a agregar('peras', 0) lanza un ArgumentError.
        # Sintaxis: expect { codigo_que_lanza_error }.to raise_error(TipoDeError, /mensaje_opcional/)
        # Puedes omitir el mensaje si solo te importa el tipo de error.
      end

      it 'lanza un ArgumentError si la cantidad es negativa' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que llamar a agregar('peras', -2) lanza un ArgumentError.
      end
    end
  end # Fin de describe #agregar

  describe '#cantidad_de' do
    context 'cuando el item existe' do
       before { inventario.agregar('platanos', 7) }

       it 'devuelve la cantidad correcta' do
         # --- TU CÓDIGO AQUÍ ---
       end
    end

    context 'cuando el item NO existe' do
       it 'devuelve 0' do
         # --- TU CÓDIGO AQUÍ ---
       end
    end
  end # Fin de describe #cantidad_de

  describe '#remover' do
    before do
      # Estado inicial para las pruebas de remover
      inventario.agregar('naranjas', 10)
    end

    context 'cuando se remueve una cantidad menor a la existente' do
       before { inventario.remover('naranjas', 3) }

       it 'disminuye la cantidad del item correctamente' do
         # --- TU CÓDIGO AQUÍ ---
         # Verifica que cantidad_de('naranjas') ahora es 7 (10 - 3)
       end
    end

    context 'cuando se remueve exactamente la cantidad existente' do
       before { inventario.remover('naranjas', 10) }

       it 'la cantidad del item se vuelve 0' do
         # --- TU CÓDIGO AQUÍ ---
       end

       it 'el item es eliminado de la lista de items disponibles' do
         # --- TU CÓDIGO AQUÍ ---
         # Verifica que items_disponibles ya NO incluye 'naranjas'
         # Matcher útil: `not_to include`
       end
    end

    context 'cuando se intenta remover una cantidad mayor a la existente' do
      it 'lanza un StandardError con un mensaje específico' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que llamar a remover('naranjas', 15) lanza StandardError
        # Incluye en la verificación parte del mensaje esperado, ej: /No hay suficiente/
      end
    end

    context 'cuando se intenta remover un item que no existe' do
      it 'lanza un StandardError con un mensaje específico' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que llamar a remover('uvas', 1) lanza StandardError
        # Incluye en la verificación parte del mensaje esperado, ej: /no existe/
      end
    end

     context 'cuando se intenta remover una cantidad no positiva' do
       it 'lanza un ArgumentError si la cantidad es cero' do
         # --- TU CÓDIGO AQUÍ ---
         # Verifica que llamar a remover('naranjas', 0) lanza ArgumentError
       end

       it 'lanza un ArgumentError si la cantidad es negativa' do
         # --- TU CÓDIGO AQUÍ ---
         # Verifica que llamar a remover('naranjas', -2) lanza ArgumentError
       end
     end
  end # Fin de describe #remover

  describe '#items_disponibles' do
     before do
       inventario.agregar('kiwis', 3)
       inventario.agregar('mangos', 5)
     end

     it 'devuelve un array con los nombres de todos los items presentes' do
        # --- TU CÓDIGO AQUÍ ---
        # Verifica que el resultado incluye 'kiwis' y 'mangos'.
        # Puedes usar `include` múltiples veces o `contain_exactly` si quieres
        # verificar que *solo* esos están presentes y en cualquier orden.
        # `contain_exactly` es más estricto.
     end

     it 'devuelve un array vacío si no hay items' do
        inventario_vacio = Inventario.new
        # --- TU CÓDIGO AQUÍ ---
     end
  end

end # Fin de RSpec.describe Inventario
```

**Tu Tarea:**

1.  Rellena el código donde dice `# --- TU CÓDIGO AQUÍ ---`.
2.  Usa la instancia `inventario` creada con `let`.
3.  Aplica los matchers sugeridos (`eq`, `be_empty`, `include`, `not_to include`, `raise_error`, `contain_exactly`).
4.  Presta atención a la sintaxis para probar errores: `expect { ... }.to raise_error(TipoDeError, /mensaje_opcional/)`.

**Cómo Ejecutarlo:**

Igual que antes: `rspec inventario_spec.rb` desde la terminal, en el directorio donde está el archivo spec.

Este ejercicio te hará trabajar con el estado del objeto (`@items`) a través de los métodos, usar `let` y `context`, y aplicar una variedad mayor de matchers, incluyendo la verificación de errores. ¡Inténtalo!
