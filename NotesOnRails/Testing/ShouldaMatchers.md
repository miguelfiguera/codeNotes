# shoulda-matchers

Se enfocan principalmente en probar:

1.  **Modelos ActiveRecord:** Validaciones, asociaciones, scopes, índices de base de datos, etc.
2.  **(Menos común hoy en día) Controladores:** Asignaciones, redirecciones, renderizado de plantillas, mensajes flash (aunque las pruebas de Request/System son ahora preferidas para gran parte de esto).

**Sintaxis Básica:**

La sintaxis fundamental de Shoulda Matchers dentro de un bloque `RSpec.describe` o `context` gira en torno al `subject` de la prueba (que, por defecto, en `RSpec.describe MiModelo`, es una instancia de `MiModelo.new`).

Hay dos formas principales de escribirlo:

1.  **Forma Clásica (`should` / `should_not`)**:

    ```ruby
    # Dentro de RSpec.describe MiModelo do ... end
    it { should matcher_de_shoulda }
    it { should_not matcher_de_shoulda_negativo }
    ```

    - **Ejemplo:** `it { should validate_presence_of(:name) }`

2.  **Forma Preferida por RSpec (`is_expected.to` / `is_expected.not_to`)**: Esta es la sintaxis más moderna y recomendada por el equipo de RSpec, ya que es más explícita y consistente con el `expect(valor).to` estándar. `is_expected` es simplemente un atajo para `expect(subject)`.
    ```ruby
    # Dentro de RSpec.describe MiModelo do ... end
    it { is_expected.to matcher_de_shoulda }
    it { is_expected.not_to matcher_de_shoulda_negativo }
    ```
    - **Ejemplo:** `it { is_expected.to validate_presence_of(:email) }`

**Matchers Comunes y Ejemplos:**

Aquí tienes ejemplos de los matchers más utilizados, agrupados por categoría:

**A. Matchers de ActiveRecord (Modelos)**

- **Validaciones:**

  ```ruby
  RSpec.describe User, type: :model do
    # Antes de las pruebas, a menudo necesitas crear un 'subject' válido
    # para que algunas validaciones (como uniqueness) puedan probarse correctamente.
    # FactoryBot es ideal para esto.
    subject { build(:user) } # O User.new con atributos válidos si no usas FactoryBot

    # Presence (Presencia)
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:email).with_message("¡El email no puede estar en blanco!") } # Mensaje custom

    # Uniqueness (Unicidad)
    # ¡IMPORTANTE! Para `validate_uniqueness_of`, necesitas un registro PERSISTIDO
    # en la BD para comparar. Por eso el `subject { create(:user) }` es común aquí.
    # O usar `build` y guardar explícitamente en un before block.
    # subject { create(:user) } # Descomentar si usas FactoryBot y necesitas persistencia
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:account_id).with_message("Ya existe en esta cuenta") } # Con scope y mensaje

    # Length (Longitud)
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
    it { is_expected.to validate_length_of(:bio).is_at_most(500) }
    it { is_expected.to validate_length_of(:zip_code).is_equal_to(5) }

    # Numericality (Numérico)
    it { is_expected.to validate_numericality_of(:age).only_integer.is_greater_than_or_equal_to(18) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:rating).is_less_than_or_equal_to(5) }
    it { is_expected.not_to validate_numericality_of(:legacy_code) } # Probar que NO valida numéricamente

    # Format (Formato con Expresión Regular)
    it { is_expected.to allow_value("nombre@dominio.com").for(:email) }
    it { is_expected.not_to allow_value("esto no es un email").for(:email) }
    it { is_expected.to validate_format_of(:subdomain).with(/^[a-z0-9]+$/).with_message("Solo letras minúsculas y números") } # Usando `validate_format_of`

    # Inclusion / Exclusion (Inclusión / Exclusión en un conjunto)
    it { is_expected.to validate_inclusion_of(:role).in_array(['admin', 'editor', 'guest']) }
    it { is_expected.to validate_exclusion_of(:username).in_array(['admin', 'root', 'superuser']) }

    # Acceptance (Aceptación - para checkboxes como "Términos y Condiciones")
    it { is_expected.to validate_acceptance_of(:terms_of_service) }

    # Confirmation (Confirmación - ej: password y password_confirmation)
    it { is_expected.to validate_confirmation_of(:password) }
  end
  ```

- **Asociaciones:**

  ```ruby
  RSpec.describe Post, type: :model do
    it { is_expected.to belong_to(:user) } # belongs_to
    it { is_expected.to belong_to(:author).class_name('User').with_foreign_key('author_id') } # Con opciones

    it { is_expected.to have_many(:comments) } # has_many
    it { is_expected.to have_many(:approved_comments).class_name('Comment').conditions(approved: true) } # Con opciones/scope
    it { is_expected.to have_many(:tags).through(:post_tags) } # has_many :through
    it { is_expected.to have_many(:subscribers).dependent(:destroy) } # Con opción dependent

    it { is_expected.to have_one(:featured_image) } # has_one
    it { is_expected.to have_one(:metadata).class_name('PostMetadata').dependent(:delete) } # Con opciones

    it { is_expected.to have_and_belong_to_many(:categories) } # has_and_belong_to_many
  end
  ```

- **Base de Datos:**

  ```ruby
  RSpec.describe User, type: :model do
    # Columnas
    it { is_expected.to have_db_column(:email).of_type(:string).with_options(null: false, limit: 255) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }

    # Índices
    it { is_expected.to have_db_index(:email).unique(true) }
    it { is_expected.to have_db_index([:account_id, :user_type]) } # Índice compuesto
  end
  ```

**B. Matchers de Controladores (¡Usar con precaución!)**

- **Nota Importante:** En Rails moderno, las pruebas de _Controladores_ (`spec/controllers`) son menos comunes. Se prefiere probar la interacción completa a través de pruebas de _Request_ (`spec/requests`) o _System/Feature_ (`spec/system`, `spec/features`). Sin embargo, los matchers existen y pueden ser útiles en `Request Specs` o si aún usas `Controller Specs` para casos específicos.

```ruby
# En una Request Spec (spec/requests/posts_spec.rb)
RSpec.describe "Posts", type: :request do
  describe "GET /posts/:id" do
    let(:post) { create(:post) }

    it "asigna el post correcto a @post" do
      get post_path(post)
      # Nota: `assigns` puede requerir configuración adicional o gemas como `rails-controller-testing`
      # No es tan directo en Request Specs como lo era en Controller Specs.
      # expect(assigns(:post)).to eq(post) # Forma tradicional, puede no funcionar OOTB
    end

    it "renderiza la plantilla show" do
       get post_path(post)
       expect(response).to render_template(:show) # Este sí funciona bien en Request Specs
    end
  end

  describe "POST /posts" do
     context "con parámetros inválidos" do
       it "renderiza la plantilla new" do
         post posts_path, params: { post: { title: "" } } # Parámetros inválidos
         expect(response).to render_template(:new)
       end
     end

     context "con parámetros válidos" do
        let(:valid_attributes) { attributes_for(:post) } # De FactoryBot

        it "redirige a la página del post creado" do
          post posts_path, params: { post: valid_attributes }
          # Usar directamente los matchers de respuesta de RSpec/Rails es más común aquí
          expect(response).to redirect_to(post_path(Post.last))
        end

        it "muestra un mensaje flash de éxito" do
          post posts_path, params: { post: valid_attributes }
          # El matcher set_flash de Shoulda:
          # expect(controller).to set_flash[:notice].to("Post creado exitosamente.")
          # En Request specs, es más común verificar el contenido del flash así:
          expect(flash[:notice]).to match(/Post creado exitosamente/i)
        end
     end
  end
end
```

---

## Caso especial, asociaciones polimorficas:

Probar asociaciones polimórficas con Shoulda Matchers es bastante directo y sigue la misma filosofía de concisión. Necesitas probar ambas partes de la asociación: el lado `belongs_to` (el modelo "hijo" polimórfico) y el lado `has_many` (los modelos "padre" que pueden ser asociados).

**Recordatorio Rápido: Asociación Polimórfica en Rails**

Imaginemos que tienes `Posts` e `Images`, y ambos pueden tener `Comments`.

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  # Necesita las columnas: commentable_id (integer), commentable_type (string)
end

# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
end

# app/models/image.rb
class Image < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
end
```

**Probando con Shoulda Matchers:**

1.  **Probando el lado `belongs_to` (el modelo polimórfico):**

    - Necesitas verificar que la asociación `belongs_to` existe y que está marcada específicamente como `polymorphic: true`.
    - **Matcher:** `belong_to(:nombre_asociacion).polymorphic`

    ```ruby
    # spec/models/comment_spec.rb
    require 'rails_helper'

    RSpec.describe Comment, type: :model do
      describe 'associations' do
        # Verifica tanto la existencia del belongs_to como la opción :polymorphic => true
        it { is_expected.to belong_to(:commentable).polymorphic }
      end

      # También podrías probar las columnas de la BD si quieres ser exhaustivo
      describe 'database columns' do
        it { should have_db_column(:commentable_id).of_type(:integer) }
        it { should have_db_column(:commentable_type).of_type(:string) }
        it { should have_db_index([:commentable_type, :commentable_id]) } # El índice es crucial para el rendimiento
      end
    end
    ```

2.  **Probando el lado `has_many` (los modelos que _pueden tener_ la asociación):**

    - Necesitas verificar que la asociación `has_many` existe y, crucialmente, que usa la opción `as: :nombre_asociacion_polimorfica`.
    - **Matcher:** `have_many(:nombre_plural).as(:nombre_asociacion_polimorfica)`

    ```ruby
    # spec/models/post_spec.rb
    require 'rails_helper'

    RSpec.describe Post, type: :model do
      describe 'associations' do
        # Verifica el has_many y la opción :as => :commentable
        it { is_expected.to have_many(:comments).as(:commentable) }

        # También puedes probar opciones adicionales como dependent: :destroy
        it { is_expected.to have_many(:comments).dependent(:destroy).as(:commentable) }
      end
    end

    # spec/models/image_spec.rb
    require 'rails_helper'

    RSpec.describe Image, type: :model do
      describe 'associations' do
        # La misma prueba para el modelo Image
        it { is_expected.to have_many(:comments).as(:commentable) }
        it { is_expected.to have_many(:comments).dependent(:destroy).as(:commentable) }
      end
    end
    ```

**En Resumen:**

- Para el modelo que tiene `belongs_to :mi_cosa, polymorphic: true`, usa:
  ```ruby
  it { is_expected.to belong_to(:mi_cosa).polymorphic }
  ```
- Para los modelos que tienen `has_many :mis_cositas, as: :mi_cosa`, usa:
  ```ruby
  it { is_expected.to have_many(:mis_cositas).as(:mi_cosa) }
  ```

Shoulda Matchers hace que probar estas asociaciones sea tan sencillo como las regulares, simplemente añadiendo los calificadores `.polymorphic` o `.as(:nombre)` donde corresponda.
