**¿Qué son las Factories (con Factory Bot)?**

Las Factories son esencialmente **planos o plantillas reutilizables para crear objetos Ruby**, especialmente modelos de ActiveRecord, para tus pruebas. En lugar de escribir `User.create(first_name: 'Juan', last_name: 'Pérez', email: 'juan@ejemplo.com', ...)` en cada test donde necesites un usuario, defines una _fábrica_ para `User` una vez y luego simplemente la invocas.

**¿Por qué usar Factories en lugar de...?**

- **Creación Manual (`Model.new`/`create`):** Muy repetitivo (viola el principio DRY), difícil de mantener si el modelo cambia, y hace los tests más largos y menos legibles.
- **Fixtures (de Rails):** Son datos estáticos definidos en archivos YAML. Son difíciles de manejar para asociaciones complejas, menos flexibles para crear variaciones de datos sobre la marcha, y pueden llevar a un estado global de la base de datos difícil de razonar.

**Ventajas de Factory Bot:**

- **DRY:** Define la estructura del objeto una sola vez.
- **Legible:** `create(:user)` es mucho más claro que un bloque largo de `User.create`.
- **Flexible:** Fácil de sobreescribir atributos para casos específicos (`create(:user, admin: true)`).
- **Mantenible:** Si cambias tu modelo (añades una validación, un campo), solo actualizas la fábrica en un lugar.
- **Maneja Asociaciones:** Crea objetos asociados automáticamente.

**Integrando Faker para Datos Realistas**

**Faker** es una gema que genera datos falsos pero con apariencia realista (nombres, emails, direcciones, números de teléfono, texto lorem ipsum, etc.). Usarla con Factory Bot es una práctica estándar porque:

- Evita usar los mismos datos estáticos ("test", "foo@bar.com") en todas partes.
- Genera datos variados, lo que a veces puede ayudar a descubrir bugs sutiles.
- Ayuda a cumplir validaciones de unicidad automáticamente (cuando se usa con `sequence`).

Para mas informacion puedes visitar el link con la documentacion de faker: [aqui.](https://github.com/faker-ruby/faker/tree/main/doc/default)

**Sintaxis Básica y Ejemplos (con Faker)**

1.  **Definición de Fábricas:**

    - Convencionalmente, las fábricas se definen en archivos dentro del directorio `spec/factories/`. Por ejemplo, `spec/factories/users.rb`, `spec/factories/posts.rb`.
    - Se usa `FactoryBot.define do ... end` y dentro `factory :nombre_simbolico do ... end`. El nombre simbólico suele ser el nombre de la clase en minúsculas (`:user` para la clase `User`).

    ```ruby
    # spec/factories/users.rb
    require 'faker' # Asegúrate de que Faker esté disponible

    FactoryBot.define do
      factory :user do
        # Atributos básicos con Faker
        first_name { Faker::Name.first_name }
        last_name  { Faker::Name.last_name }

        # Para emails, es común usar 'sequence' para garantizar unicidad
        # El bloque recibe un número 'n' que se incrementa cada vez.
        sequence(:email) { |n| "persona#{n}@#{Faker::Internet.domain_name}" }
        # Alternativa simple con Faker (puede colisionar si creas muchos):
        # email { Faker::Internet.unique.email }

        password { "contraseña_segura" } # A menudo una contraseña fija para tests es suficiente
        # O si tienes validaciones de formato más complejas:
        # password { Faker::Internet.password(min_length: 10, max_length: 20, mix_case: true, special_characters: true) }

        # Atributo booleano (ejemplo)
        admin { false } # Valor por defecto

        # Si tuvieras una columna 'username' con validación de unicidad:
        sequence(:username) { |n| "#{Faker::Internet.username(specifier: 5..8)}#{n}" }

        # --- Traits (para variaciones comunes) ---
        trait :admin do
          admin { true }
        end

        trait :with_profile do
          # after(:create) es un callback de FactoryBot
          # Se ejecuta después de que el usuario ha sido CREADO y guardado
          after(:create) do |user_instance, evaluator|
            # Crea un perfil asociado a este usuario recién creado
            # 'evaluator' permite pasar datos si es necesario
            create(:profile, user: user_instance) # Asumiendo que tienes una factory :profile
          end
        end
      end
    end
    ```

2.  **Fábricas con Asociaciones:**

    - Factory Bot es inteligente: si tienes `belongs_to :user` en un modelo `Post`, y en la factory de `Post` no especificas el usuario, Factory Bot _automáticamente_ buscará y usará la factory llamada `:user`.

    ```ruby
    # spec/factories/posts.rb
    require 'faker'

    FactoryBot.define do
      factory :post do
        title { Faker::Lorem.sentence(word_count: 3) }
        body  { Faker::Lorem.paragraphs(number: 2).join("\n\n") }
        published_at { Faker::Time.backward(days: 14) } # Fecha pasada aleatoria

        # ¡Asociación! Factory Bot buscará la factory :user por defecto
        user # Esto es suficiente para crear un usuario asociado usando la factory :user

        # Alternativamente, podrías especificar una factory diferente o pasar una instancia:
        # association :author, factory: :admin_user # Si tuvieras una factory :admin_user
        # user { association :user, admin: true } # Crear un usuario específico para este post
      end
    end
    ```

3.  **Uso en Specs (Estrategias de Creación):**

    - **`build(:nombre_factory, atributos_a_sobreescribir)`:**

      - Crea una instancia del objeto en memoria (`Model.new`).
      - **NO** guarda en la base de datos.
      - Es rápido. Útil para probar validaciones, métodos que no dependen de la persistencia o el ID.
      - Ejemplo: `let(:user) { build(:user) }`

    - **`create(:nombre_factory, atributos_a_sobreescribir)`:**

      - Crea Y **GUARDA** el objeto en la base de datos (`Model.create`).
      - Es más lento porque interactúa con la BD.
      - **Es la estrategia más común**, necesaria cuando pruebas cosas que requieren un ID, asociaciones que se cargan desde la BD, scopes, o validaciones de unicidad.
      - Ejemplo: `let(:user) { create(:user, admin: true) }`

    - **`attributes_for(:nombre_factory, atributos_a_sobreescribir)`:**

      - Devuelve un **Hash** con los atributos que _se usarían_ para crear el objeto.
      - No crea el objeto ni toca la BD.
      - Útil para probar acciones de controlador, pasando los atributos como `params`.
      - Ejemplo: `let(:valid_attributes) { attributes_for(:post, title: "Título Específico") }`

    - **`build_stubbed(:nombre_factory, atributos_a_sobreescribir)`:**
      - Crea un objeto que _parece_ persistido (tiene un ID, `persisted?` devuelve `true`), pero **NO** toca la base de datos.
      - Más rápido que `create`. Bueno para tests unitarios donde necesitas simular un objeto existente sin el coste de la BD. Menos común que `build` o `create`.
      - Ejemplo: `let(:stubbed_user) { build_stubbed(:user) }`

    **Ejemplo en una Spec:**

    ```ruby
    # spec/models/post_spec.rb
    require 'rails_helper'

    RSpec.describe Post, type: :model do
      # Usando create para probar validaciones que pueden depender de la BD (como uniqueness del user)
      # o simplemente porque es la forma más robusta.
      let(:user) { create(:user) } # Crea y guarda un usuario usando la factory :user
      let(:post) { create(:post, user: user, title: "Mi Título de Prueba") } # Crea y guarda un post asociado

      it "es válido con atributos válidos y un usuario" do
        expect(post).to be_valid
      end

      it "requiere un título" do
        # Usa build aquí, no necesita guardar para probar la validación de presencia
        post_sin_titulo = build(:post, user: user, title: nil)
        expect(post_sin_titulo).not_to be_valid
        expect(post_sin_titulo.errors[:title]).to include("can't be blank")
      end

      it "pertenece a un usuario" do
        # Usando shoulda-matchers y un post creado
        expect(post).to belong_to(:user)
        # O verificando directamente la instancia
        expect(post.user).to eq(user)
      end

      context "con traits" do
         # Asumiendo que la factory :user tiene un trait :admin
         let(:admin) { create(:user, :admin) } # Aplica el trait :admin
         let(:admin_post) { create(:post, user: admin) }

         it "puede ser creado por un admin" do
           expect(admin_post).to be_valid
           expect(admin_post.user.admin).to be true
         end
      end

      context "para params de controlador" do
        it "genera un hash de atributos válidos" do
          attrs = attributes_for(:post)
          expect(attrs).to include(:title, :body)
          expect(attrs[:title]).to be_a(String)
        end
      end
    end
    ```

**Configuración (Importante):**

Para poder usar `build`, `create`, etc., directamente sin `FactoryBot.` delante, necesitas incluir la configuración en tu `rails_helper.rb` o en un archivo de soporte como `spec/support/factory_bot.rb`:

```ruby
# spec/support/factory_bot.rb (o dentro de RSpec.configure en rails_helper.rb)
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# Asegúrate de requerir este archivo en tu rails_helper.rb si lo creas aparte:
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }
```

Factory Bot y Faker son herramientas esenciales en el arsenal de pruebas de Rails. Te permiten generar los datos necesarios para tus tests de forma limpia, flexible y mantenible.
