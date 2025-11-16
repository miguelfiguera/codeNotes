¡Perfecto! Has completado el primer ejercicio de RSpec básico correctamente. ¡Muy bien!

Ahora, vamos a practicar la creación de una **Factory Bot factory**.

**Objetivo:** Escribir la definición de una factory para un modelo `Post`, incluyendo atributos básicos y usando Faker para generar datos.

**1. El Código del Modelo a Probar (Imagina que esto está en `app/models/post.rb`):**

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user # Asume que existe un modelo User

  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :body, presence: true
  validates :likes_count, numericality: { greater_than_or_equal_to: 0 }

  # Atributos comunes que tendrías en la base de datos:
  # - title: string
  # - body: text
  # - published_at: datetime (puede ser nil si es un borrador)
  # - likes_count: integer (con un valor por defecto de 0 en la BD sería bueno)
  # - is_featured: boolean (con un valor por defecto de false en la BD)
  # - user_id: integer (para la asociación belongs_to)
end
```

**2. El Archivo de Factory a Crear:**

Crea un archivo llamado `posts.rb` dentro de la carpeta `spec/factories/`.

```ruby
# spec/factories/posts.rb

# 1. Requiere Faker si no está cargado globalmente
require 'faker'

# 2. Define el bloque principal de FactoryBot
FactoryBot.define do

  # 3. Define la factory para el modelo Post (usa :post como nombre simbólico)
  factory :post do

    # --- TU CÓDIGO AQUÍ ---
    # Define los atributos para la factory :post
    # Usa bloques { ... } y la gema Faker para generar datos realistas.

    # title: (String) Usa Faker::Lorem.sentence, asegúrate que cumpla la longitud.
    #        Puedes usar algo como: { Faker::Lorem.sentence(word_count: 5).truncate(100) }

    # body: (Text) Usa Faker::Lorem.paragraph

    # published_at: (DateTime o nil) Puedes hacerlo nil por defecto, o usar Faker::Time.backward
    #               para una fecha pasada. O dejarlo comentado para que sea nil por defecto.

    # likes_count: (Integer) Pon 0 por defecto.

    # is_featured: (Boolean) Pon false por defecto.

    # user: (Asociación) Simplemente escribe 'user' aquí. FactoryBot buscará
    #       automáticamente una factory llamada :user para crear y asociar.
    #       (No necesitas definir la factory :user para este ejercicio, solo asume que existe).


    # --- Posibles Traits (Defínelos aquí dentro de la factory :post si quieres practicar) ---
    # trait :published do
    #   # Define published_at con una fecha/hora pasada usando Faker::Time.backward
    # end

    # trait :unpublished do
    #   # Asegura que published_at sea nil
    # end

    # trait :featured do
    #   # Define is_featured como true
    # end

    # trait :popular do
    #   # Define likes_count con un número alto (ej. Faker::Number.number(digits: 3))
    # end

  end # Fin de factory :post

end # Fin de FactoryBot.define
```

**Tu Tarea:**

1.  Rellena la sección `# --- TU CÓDIGO AQUÍ ---` dentro de `factory :post do ... end`.
2.  Define cada atributo (`title`, `body`, `likes_count`, `is_featured`, `user`) usando la sintaxis de Factory Bot (`nombre_atributo { valor_o_bloque }`).
3.  Utiliza métodos de la gema `Faker` (como `Faker::Lorem`, `Faker::Time`, `Faker::Number`) para generar datos variados y realistas donde corresponda.
4.  (Opcional, pero recomendado) Descomenta y completa uno o dos de los `trait` sugeridos para practicar su definición.

**Para verificar (mentalmente o en una consola de Rails si tienes un proyecto):**

- Si haces `build(:post)`, deberías obtener una instancia de `Post` no guardada con datos generados por Faker y los valores por defecto (likes 0, featured false, published_at nil o fecha pasada).
- Si haces `create(:post, :published, :featured)`, deberías obtener una instancia de `Post` guardada, con `published_at` establecido a una fecha pasada y `is_featured` como `true`.

Una vez que tengas la definición de la factory, me la puedes mostrar. ¡No te preocupes por la perfección, lo importante es intentarlo!
