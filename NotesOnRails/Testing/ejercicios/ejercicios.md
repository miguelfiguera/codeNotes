**Ejercicios para Resolver**

Ahora, aquí tienes los ejercicios. Para cada uno, te doy el código a probar y los `it` que describen el comportamiento esperado. Tu tarea es escribir el código dentro de los bloques `it { ... }` o `it "..." do ... end`.

**(Recuerda configurar FactoryBot y Faker en tu `rails_helper.rb` o `spec/support/factory_bot.rb` si estás en un proyecto Rails real)**

---

**A. Ejercicios de Factories (FactoryBot + Faker)**

**Código a Probar (Modelos):**

```ruby
# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, length: { maximum: 500 }
  validates :is_active, inclusion: { in: [true, false] }
end

# app/models/category.rb
class Category < ApplicationRecord
  has_many :products
  validates :name, presence: true, uniqueness: true
end
```

**Factories a Crear (spec/factories/):**

```ruby
# spec/factories/categories.rb
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "#{Faker::Commerce.department(max: 1)} #{n}" }
  end
end

# spec/factories/products.rb
FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "#{Faker::Commerce.product_name} #{n}" }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 10.0..1000.0) }
    is_active { true }

    category # Asocia automáticamente

    trait :inactive do
      is_active { false }
    end

    trait :expensive do
      price { Faker::Commerce.price(range: 1001.0..5000.0) }
    end
  end
end
```

**Spec a Completar (`spec/factories_exercise_spec.rb`):**

```ruby
require 'rails_helper' # O 'spec_helper' y requerir tus clases/factories

RSpec.describe 'Factory Bot Exercises' do

  describe 'Category Factory' do
    it 'creates a valid category instance' # Usa create o build y .valid?
    it 'creates unique names for multiple categories' # Crea 2 y compara nombres
    it 'allows overriding the name attribute' # Usa create(:category, name: "Custom")
  end

  describe 'Product Factory' do
    it 'creates a valid product instance with an associated category' # Usa create o build y .valid?, verifica .category
    it 'allows overriding the price attribute' # Usa create(:product, price: 9.99)
    it 'creates an inactive product using the :inactive trait' # Usa create(:product, :inactive) y verifica is_active
    it 'creates an expensive product using the :expensive trait' # Usa create(:product, :expensive) y verifica el precio
    it 'builds a product instance without hitting the database' # Usa build y verifica que no esté persistido (.persisted?)
    it 'generates attributes hash using attributes_for' # Usa attributes_for y verifica que sea un Hash con claves esperadas
  end
end
```

---

**B. Ejercicios de RSpec Básico**

**Código a Probar:**

```ruby
# lib/string_analyzer.rb
class StringAnalyzer
  def has_vowels?(str)
    !!(str =~ /[aeiouáéíóúü]/i) # Devuelve true/false
  end

  def word_count(str)
    str.nil? ? 0 : str.split.count
  end

  def first_word(str)
    str&.split&.first # Usa safe navigation
  end
end
```

**Spec a Completar (`spec/string_analyzer_spec.rb`):**

```ruby
require_relative '../lib/string_analyzer' # Ajusta la ruta

RSpec.describe StringAnalyzer do
  let(:analyzer) { StringAnalyzer.new } # Usar let para la instancia

  describe '#has_vowels?' do
    context 'with a string containing vowels' do
      it 'returns true' # Ej: "hola"
    end
    context 'with a string containing vowels with accents' do
      it 'returns true' # Ej: "murciélago"
    end
    context 'with a string without vowels' do
      it 'returns false' # Ej: "rhythm"
    end
    context 'with an empty string' do
      it 'returns false'
    end
  end

  describe '#word_count' do
    it 'returns the correct word count for a simple sentence' # Ej: "Tres tristes tigres" -> 3
    it 'returns 0 for an empty string'
    it 'returns 0 for a nil input'
    it 'handles strings with extra spaces correctly' # Ej: "  mucho   espacio  " -> 2
  end

  describe '#first_word' do
    it 'returns the first word of a sentence' # Ej: "Primero Segundo" -> "Primero"
    it 'returns the word itself if only one word' # Ej: "Solo" -> "Solo"
    it 'returns nil for an empty string'
    it 'returns nil for a nil input'
  end
end
```

---

**C. Ejercicios de Mocks**

**Código a Probar:**

```ruby
# lib/weather_reporter.rb
class WeatherApiClient # Dependencia externa
  def get_temperature(city)
    # Simula llamada a API externa, puede ser lenta o fallar
    puts "API: Consultando temperatura para #{city}..."
    sleep 0.5 # Simula latencia
    case city.downcase
    when 'madrid' then 25
    when 'londres' then 18
    else raise "City not found"
    end
  end
end

class WeatherReporter
  def initialize(api_client = WeatherApiClient.new) # Permite inyección
    @api_client = api_client
  end

  def report(city)
    temp = @api_client.get_temperature(city)
    if temp > 20
      "Hace calor en #{city} (#{temp}°C)."
    else
      "Hace fresco en #{city} (#{temp}°C)."
    end
  rescue StandardError => e
    "No se pudo obtener el reporte para #{city}: #{e.message}"
  end
end
```

**Spec a Completar (`spec/weather_reporter_spec.rb`):**

```ruby
require_relative '../lib/weather_reporter'

RSpec.describe WeatherReporter do
  # Usaremos un doble para la API
  let(:mock_api_client) { instance_double(WeatherApiClient) }
  # Inyectamos el doble en el reporter
  let(:reporter) { WeatherReporter.new(mock_api_client) }

  describe '#report' do
    context 'cuando la API devuelve una temperatura cálida' do
      before do
        # Configura el mock para devolver 25 cuando se llame con 'Madrid'
        allow(mock_api_client).to receive(:get_temperature).with('Madrid').and_return(25)
      end

      it 'llama a la API con la ciudad correcta'
      it 'devuelve un mensaje indicando calor' # Espera "Hace calor..."
      it 'incluye la temperatura correcta en el mensaje' # Espera "(25°C)"
    end

    context 'cuando la API devuelve una temperatura fresca' do
       before do
         # Configura el mock para devolver 18 cuando se llame con 'Londres'
         allow(mock_api_client).to receive(:get_temperature).with('Londres').and_return(18)
       end

      it 'llama a la API con la ciudad correcta'
      it 'devuelve un mensaje indicando fresco' # Espera "Hace fresco..."
      it 'incluye la temperatura correcta en el mensaje' # Espera "(18°C)"
    end

    context 'cuando la API lanza un error (ej. ciudad no encontrada)' do
      before do
        # Configura el mock para lanzar un error cuando se llame con 'Mordor'
        allow(mock_api_client).to receive(:get_temperature).with('Mordor').and_raise("City not found")
      end

      it 'llama a la API con la ciudad correcta'
      it 'devuelve un mensaje de error' # Espera "No se pudo obtener el reporte..."
      it 'incluye el mensaje de error original' # Espera "... City not found"
    end
  end
end
```

---

**D. Ejercicios de Shoulda Matchers (Modelos Rails)**

**Código a Probar (Modelos):**

```ruby
# app/models/author.rb
class Author < ApplicationRecord
  has_many :books, dependent: :nullify # Los libros no se borran, se desasocian
  validates :name, presence: true
  validates :nationality, presence: true
  validates :email, uniqueness: true, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end

# app/models/book.rb
class Book < ApplicationRecord
  belongs_to :author
  has_and_belongs_to_many :genres # Asumiendo tabla de unión 'books_genres'
  validates :title, presence: true, uniqueness: { scope: :author_id }
  validates :isbn, presence: true, uniqueness: true, length: { is: 13 }
  validates :pages, numericality: { only_integer: true, greater_than: 0 }
end

# app/models/genre.rb
class Genre < ApplicationRecord
  has_and_belongs_to_many :books
  validates :name, presence: true, uniqueness: true
end
```

**Spec a Completar:**

```ruby
# spec/models/author_spec.rb
require 'rails_helper'
RSpec.describe Author, type: :model do
  describe 'validations' do
    subject { build(:author) } # Asume que tienes una factory :author
    it # debe validar la presencia de name
    it # debe validar la presencia de nationality
    it # debe validar la unicidad de email (ignorando mayúsculas/minúsculas, requiere BD)
    it # debe permitir un email en blanco
    it # debe validar el formato correcto del email
    it # no debe permitir un email inválido
  end
  describe 'associations' do
    it # debe tener muchos books
    it # debe especificar dependent: :nullify para la asociación de books
  end
end

# spec/models/book_spec.rb
require 'rails_helper'
RSpec.describe Book, type: :model do
  describe 'validations' do
    subject { build(:book) } # Asume factory :book con autor asociado
    it # debe validar la presencia de title
    it # debe validar la unicidad de title dentro del scope de author_id (requiere BD)
    it # debe validar la presencia de isbn
    it # debe validar la unicidad de isbn (requiere BD)
    it # debe validar que la longitud de isbn sea exactamente 13
    it # debe validar que pages sea un número entero
    it # debe validar que pages sea mayor que 0
  end
  describe 'associations' do
    it # debe pertenecer a un author
    it # debe tener y pertenecer a muchos genres (HABTM)
  end
end

# spec/models/genre_spec.rb
require 'rails_helper'
RSpec.describe Genre, type: :model do
  describe 'validations' do
     subject { build(:genre) } # Asume factory :genre
     it # debe validar la presencia de name
     it # debe validar la unicidad de name (requiere BD)
  end
  describe 'associations' do
     it # debe tener y pertenecer a muchos books (HABTM)
  end
end
```

---

**E. Ejercicios de Controladores (Request Specs)**

**Código a Probar (Controlador y Rutas):**

```ruby
# config/routes.rb
# resources :articles, only: [:index, :show, :create]

# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  def index
    @articles = Article.order(created_at: :desc).limit(20)
    render :index # explícito para claridad
  end

  def show
    @article = Article.find(params[:id])
    render :show
  rescue ActiveRecord::RecordNotFound
    render plain: 'Artículo no encontrado', status: :not_found
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to @article, notice: 'Artículo creado exitosamente.'
    else
      # Re-renderizar el formulario es complejo en request specs,
      # a menudo se prefiere probar el status y el template si aplica,
      # o verificar los errores en @article si se asignara (no común aquí).
      # En este caso simple, podríamos solo verificar el status 422.
      render :new, status: :unprocessable_entity # Para indicar fallo de validación
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :content, :author_id) # Asumiendo author_id existe
  end
end

# Asume que tienes un modelo Article con factory :article y validaciones
```

**Spec a Completar (`spec/requests/articles_controller_spec.rb`):**

```ruby
require 'rails_helper'

RSpec.describe "ArticlesController", type: :request do
  # Asume factories :article y :author existen
  let!(:author) { create(:author) }
  let!(:article1) { create(:article, author: author, created_at: 1.day.ago) }
  let!(:article2) { create(:article, author: author, created_at: 2.days.ago) }

  describe "GET /articles" do
    before { get articles_path } # Realiza la petición antes de cada 'it'

    it 'responde con status OK (200)'
    it 'renderiza la plantilla index'
    it 'incluye el título del artículo más reciente en el cuerpo de la respuesta' # expect(response.body).to include(article1.title)
    it 'no incluye artículos más allá del límite (si hubiera más)' # Requeriría crear >20 artículos
  end

  describe "GET /articles/:id" do
    context 'cuando el artículo existe' do
       before { get article_path(article1) }

       it 'responde con status OK (200)'
       it 'renderiza la plantilla show'
       it 'incluye el contenido del artículo en el cuerpo de la respuesta'
    end

    context 'cuando el artículo NO existe' do
       before { get article_path(id: 'id-invalido') }

       it 'responde con status Not Found (404)'
       it 'muestra un mensaje de "Artículo no encontrado"'
    end
  end

  describe "POST /articles" do
    context 'con parámetros válidos' do
      let(:valid_attributes) { attributes_for(:article, author_id: author.id, title: "Nuevo Artículo") }

      it 'crea un nuevo Artículo en la base de datos' # Usa change { Article.count }.by(1)
      it 'redirige al artículo recién creado' # Verifica redirect_to(article_path(Article.last))
      it 'muestra un mensaje flash de éxito'
    end

    context 'con parámetros inválidos (ej. sin título)' do
      let(:invalid_attributes) { attributes_for(:article, author_id: author.id, title: "") }

      it 'NO crea un nuevo Artículo en la base de datos' # Usa not_to change { Article.count }
      it 'responde con status Unprocessable Entity (422)'
      it 'renderiza la plantilla :new (o verifica que el cuerpo contenga errores)' # Verificar `render_template(:new)` puede ser más directo
    end
  end
end
```

---

**F. Ejercicios de Modelos (Lógica Custom)**

**Código a Probar (Modelo):**

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :customer # Asume modelo Customer
  has_many :order_items, dependent: :destroy

  enum status: { pending: 0, processing: 1, shipped: 2, cancelled: -1 }

  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { where('created_at >= ?', 1.week.ago) }
  scope :high_value, -> { where('total_amount > ?', 1000) }

  # Método para calcular el total basado en los items
  def calculate_total!
    calculated_total = order_items.joins(:product) # Asume OrderItem tiene product
                       .sum('order_items.quantity * products.price') # Asume Product tiene price
    update!(total_amount: calculated_total)
  end

  # Método para avanzar el estado
  def ship!
    if processing? # Solo se puede enviar si está procesando
      update!(status: :shipped, shipped_at: Time.current)
    else
      errors.add(:base, "La orden no puede ser enviada desde el estado #{status}")
      false # Indica fallo
    end
  end

  def status_description
    I18n.t("order.statuses.#{status}", default: status.humanize)
  end
end

# Asume modelos Customer, OrderItem, Product con factories y asociaciones básicas
```

**Spec a Completar (`spec/models/order_spec.rb`):**

```ruby
require 'rails_helper'

RSpec.describe Order, type: :model do
  # Asume factories :order, :customer, :order_item, :product
  let(:customer) { create(:customer) }

  describe 'enums' do
     it # define el enum status correctamente (con los valores esperados)
     # Usar: expect(Order.statuses).to eq({"pending"=>0, "processing"=>1, "shipped"=>2, "cancelled"=>-1})
     # O probar los métodos helper: build(:order, status: :processing).processing? => true
  end

  describe 'scopes' do
    let!(:recent_order) { create(:order, customer: customer, created_at: 3.days.ago, total_amount: 50) }
    let!(:old_order) { create(:order, customer: customer, created_at: 2.weeks.ago, total_amount: 60) }
    let!(:high_value_order) { create(:order, customer: customer, total_amount: 1500) }
    let!(:low_value_order) { create(:order, customer: customer, total_amount: 100) }

    it '.recent devuelve solo ordenes de la última semana'
    it '.high_value devuelve solo ordenes con total > 1000'
  end

  describe '#calculate_total!' do
    let(:order) { create(:order, customer: customer, total_amount: 0) }
    let(:product1) { create(:product, price: 10.0) }
    let(:product2) { create(:product, price: 25.5) }
    let!(:item1) { create(:order_item, order: order, product: product1, quantity: 2) } # 2 * 10 = 20
    let!(:item2) { create(:order_item, order: order, product: product2, quantity: 1) } # 1 * 25.5 = 25.5
                                                                                     # Total = 45.5
    it 'actualiza el total_amount de la orden con la suma correcta de los items' # Llama a calculate_total! y usa change y reload
  end

  describe '#ship!' do
    context 'cuando la orden está en estado processing' do
      let(:order) { create(:order, customer: customer, status: :processing) }

      it 'cambia el estado a shipped' # Usa change { order.status }
      it 'establece la fecha shipped_at' # Usa change { order.shipped_at }.from(nil) y verifica que no sea nil
      it 'devuelve true'
    end

    context 'cuando la orden está en estado pending' do
      let(:order) { create(:order, customer: customer, status: :pending) }

      it 'no cambia el estado' # Usa not_to change { order.status }
      it 'no establece la fecha shipped_at' # Usa not_to change { order.shipped_at }
      it 'devuelve false'
      it 'añade un error a la orden' # Verifica order.errors[:base]
    end
  end

  describe '#status_description' do
     # Asume que tienes traducciones en config/locales/en.yml o es.yml
     # en:
     #   order:
     #     statuses:
     #       pending: "Pendiente de Pago"
     #       processing: "En Proceso"
     #       shipped: "Enviado"
     #       cancelled: "Cancelado"
     it 'devuelve la descripción traducida para el estado pending'
     it 'devuelve la descripción traducida para el estado shipped'
     it 'devuelve el nombre humanizado si no hay traducción' # Podrías probar un estado sin traducción
  end
end
```

---

**G. Ejercicios de Service Objects**

**Código a Probar:**

```ruby
# app/services/user_registration.rb
class UserRegistration
  attr_reader :user, :error_message

  # Colaboradores (podrían ser clases reales o módulos)
  module AccountCreator
    def self.create!(email:, name:, password:)
      puts "ACCOUNT_CREATOR: Creando cuenta para #{email}..."
      sleep 0.1 # Simula trabajo
      # En la vida real, crearía el User y tal vez otros registros asociados
      user = User.create(email: email, name: name, password: password) # Usar create! para que falle en validación
      raise "Simulated DB failure during account creation" if ENV['SIMULATE_DB_FAILURE']
      user # Devuelve el usuario si tiene éxito
    end
  end

  module WelcomeMailer
    def self.send_welcome_email(user)
      puts "MAILER: Enviando email de bienvenida a #{user.email}..."
      sleep 0.2 # Simula envío
      raise "Simulated Mailer Failure!" if ENV['SIMULATE_MAILER_FAILURE']
      true
    end
  end

  def initialize(params, creator = AccountCreator, mailer = WelcomeMailer)
    @params = params
    @creator = creator
    @mailer = mailer
    @user = nil
    @error_message = nil
  end

  def register
    ActiveRecord::Base.transaction do # Envuelve todo en una transacción
      @user = @creator.create!(email: @params[:email], name: @params[:name], password: @params[:password])
      @mailer.send_welcome_email(@user)
    end
    true # Éxito
  rescue ActiveRecord::RecordInvalid => e
    # Error de validación al crear usuario
    @error_message = "Error de validación: #{e.record.errors.full_messages.join(', ')}"
    @user = e.record # Podríamos querer devolver el usuario inválido
    false
  rescue StandardError => e
    # Cualquier otro error (DB, Mailer, etc.)
    @error_message = "Error inesperado durante el registro: #{e.message}"
    # @user ya podría estar creado si el mailer falló, pero la transacción lo revertirá
    @user = nil # Aseguramos que no se devuelve user si algo falla
    false
  end
end

# Asume que User tiene validaciones y factory :user
```

**Spec a Completar (`spec/services/user_registration_spec.rb`):**

```ruby
require 'rails_helper'

RSpec.describe UserRegistration do
  # Parámetros válidos para el registro
  let(:valid_params) { attributes_for(:user) } # Usar factory para generar params válidos
  # Parámetros inválidos (ej. email faltante)
  let(:invalid_params) { attributes_for(:user, email: '') }

  # Mocks/Doubles para los colaboradores
  let(:mock_creator) { class_double(UserRegistration::AccountCreator).as_stubbed_const }
  let(:mock_mailer) { class_double(UserRegistration::WelcomeMailer).as_stubbed_const }

  # Instancia del servicio bajo prueba, inyectando los mocks
  let(:service) { UserRegistration.new(params, mock_creator, mock_mailer) }
  # Necesitamos definir `params` en cada contexto

  describe '#register' do
    context 'con parámetros válidos y colaboradores exitosos' do
      let(:params) { valid_params }
      let(:created_user) { build_stubbed(:user, valid_params) } # Simula el usuario que DEVOLVERÁ el creator

      before do
        # Espera que el creador sea llamado con los datos correctos y devuelva el usuario simulado
        expect(mock_creator).to receive(:create!)
                              .with(email: valid_params[:email], name: valid_params[:name], password: valid_params[:password])
                              .and_return(created_user)
        # Espera que el mailer sea llamado con el usuario devuelto por el creador
        expect(mock_mailer).to receive(:send_welcome_email).with(created_user).and_return(true)
      end

      it 'llama al AccountCreator con los parámetros correctos'
      it 'llama al WelcomeMailer con el usuario creado'
      it 'devuelve true'
      it 'asigna el usuario creado al atributo user del servicio' # expect(service.user).to eq(created_user)
      it 'no asigna mensaje de error' # expect(service.error_message).to be_nil
    end

    context 'con parámetros inválidos (falla de validación del creador)' do
      let(:params) { invalid_params }
      let(:invalid_user) { build(:user, params) } # Usuario que NO es válido

      before do
         # Simula que create! falla con RecordInvalid
         invalid_user.valid? # Fuerza la carga de errores
         expect(mock_creator).to receive(:create!)
                               .with(email: invalid_params[:email], name: invalid_params[:name], password: invalid_params[:password])
                               .and_raise(ActiveRecord::RecordInvalid.new(invalid_user))
         # Espera que el mailer NO sea llamado
         expect(mock_mailer).not_to receive(:send_welcome_email)
      end

      it 'llama al AccountCreator pero este falla'
      it 'NO llama al WelcomeMailer'
      it 'devuelve false'
      it 'asigna el mensaje de error de validación' # expect(service.error_message).to include("Email can't be blank")
      it 'asigna el usuario inválido al atributo user' # expect(service.user).to eq(invalid_user)
    end

    context 'cuando el Mailer falla después de crear el usuario' do
      let(:params) { valid_params }
      let(:created_user) { build_stubbed(:user, valid_params) }

      before do
        # El creador tiene éxito y devuelve el usuario
        expect(mock_creator).to receive(:create!).and_return(created_user)
        # El mailer es llamado pero lanza un error
        expect(mock_mailer).to receive(:send_welcome_email).with(created_user).and_raise("Simulated Mailer Failure!")
      end

      it 'llama al AccountCreator (y tiene éxito)'
      it 'llama al WelcomeMailer (pero falla)'
      it 'devuelve false'
      it 'asigna un mensaje de error genérico incluyendo el del mailer' # expect(service.error_message).to include("Simulated Mailer Failure!")
      it 'NO asigna el usuario (debido al rollback de la transacción o la lógica de rescate)' # expect(service.user).to be_nil
    end
  end
end
```
