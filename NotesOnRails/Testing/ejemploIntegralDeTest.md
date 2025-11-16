**Ejemplo Integrado Completo**

Imagina un sistema simple para gestionar Tareas (`Task`) que pertenecen a un Usuario (`User`). Queremos añadir una función para marcar una tarea como "urgente", lo cual notificará al usuario.

**1. El Código a Probar:**

```ruby
# --- Modelos ---
# app/models/user.rb
class User < ApplicationRecord
  has_many :tasks, dependent: :destroy
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
end

# app/models/task.rb
class Task < ApplicationRecord
  belongs_to :user
  validates :title, presence: true, length: { minimum: 5 }
  validates :description, presence: true
  validates :due_date, presence: true

  scope :pending, -> { where(completed_at: nil) }
  scope :urgent, -> { where(urgent: true) }

  def overdue?
    due_date.present? && due_date < Date.current && completed_at.nil?
  end
end

# --- Servicio ---
# app/services/task_marker.rb
class TaskMarker
  def initialize(task, notifier = UserNotifier) # Inyección de dependencia para el notificador
    @task = task
    @notifier = notifier
  end

  def mark_as_urgent!
    # Usamos una transacción por si falla la notificación (aunque en este caso simple no revertiríamos)
    ActiveRecord::Base.transaction do
      @task.update!(urgent: true)
      @notifier.notify_urgent_task(@task.user, @task)
    end
    true # Indica éxito
  rescue StandardError => e
    # Loggear el error, etc.
    Rails.logger.error "No se pudo marcar la tarea #{@task.id} como urgente: #{e.message}"
    false # Indica fallo
  end
end

# --- Notificador (Ejemplo simple, podría ser un Mailer) ---
# app/services/user_notifier.rb
class UserNotifier
  def self.notify_urgent_task(user, task)
    # En una app real: UserNotifierMailer.with(user: user, task: task).urgent_task_email.deliver_later
    puts "[NOTIFICATION] La tarea '#{task.title}' para #{user.name} (#{user.email}) ha sido marcada como URGENTE."
    # Simulamos éxito o fallo para testing
    raise "Simulated Notifier Failure!" if ENV['SIMULATE_NOTIFIER_FAILURE']
    true
  end
end

# --- Controlador (Fragmento) ---
# config/routes.rb
# resources :tasks do
#   patch :mark_urgent, on: :member
# end

# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :set_task, only: [:mark_urgent]

  def mark_urgent
    marker = TaskMarker.new(@task)
    if marker.mark_as_urgent!
      redirect_to @task, notice: 'Tarea marcada como urgente exitosamente.'
    else
      redirect_to @task, alert: 'Error al marcar la tarea como urgente.'
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
    # Aquí faltaría autorización (Pundit, CanCanCan) en una app real
  end
end
```

**2. Las Factorías (`spec/factories/`)**

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "usuario#{n}@#{Faker::Internet.domain_name}" }
  end
end

# spec/factories/tasks.rb
FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    due_date { Faker::Date.forward(days: 30) }
    urgent { false }
    completed_at { nil }

    user # Asocia automáticamente usando la factory :user

    trait :completed do
      completed_at { Time.current }
    end

    trait :overdue do
      due_date { Faker::Date.backward(days: 5) }
    end

    trait :is_urgent do
      urgent { true }
    end
  end
end
```

**3. Las Specs:**

```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  # Shoulda Matchers para validaciones y asociaciones
  describe 'validations' do
    subject { build(:user) } # build es suficiente para la mayoría de validaciones
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive } # Necesita BD, subject debe ser create o usar save
    it { is_expected.to allow_value('test@example.com').for(:email) }
    it { is_expected.not_to allow_value('test@example').for(:email) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
  end
end

# spec/models/task_spec.rb
require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_least(5) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:due_date) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  # Basic RSpec + Factories para lógica custom y scopes
  describe 'scopes' do
    let!(:pending_task) { create(:task) }
    let!(:completed_task) { create(:task, :completed) }
    let!(:urgent_task) { create(:task, :is_urgent) }

    it '.pending returns only tasks without completed_at' do
      expect(Task.pending).to contain_exactly(pending_task, urgent_task) # contain_exactly es bueno para scopes
      expect(Task.pending).not_to include(completed_task)
    end

    it '.urgent returns only tasks marked as urgent' do
      expect(Task.urgent).to contain_exactly(urgent_task)
      expect(Task.urgent).not_to include(pending_task, completed_task)
    end
  end

  describe '#overdue?' do
    let(:user) { create(:user) }

    it 'returns true if due_date is in the past and task is not completed' do
      overdue_task = build(:task, user: user, due_date: 2.days.ago, completed_at: nil)
      expect(overdue_task).to be_overdue # o expect(overdue_task.overdue?).to be true
    end

    it 'returns false if due_date is in the future' do
      future_task = build(:task, user: user, due_date: 2.days.from_now, completed_at: nil)
      expect(future_task).not_to be_overdue
    end

    it 'returns false if task is completed, even if due_date is past' do
      completed_overdue = build(:task, user: user, due_date: 2.days.ago, completed_at: 1.day.ago)
      expect(completed_overdue).not_to be_overdue
    end

    it 'returns false if due_date is nil' do
      no_due_date = build(:task, user: user, due_date: nil)
      expect(no_due_date).not_to be_overdue
    end
  end
end

# spec/services/task_marker_spec.rb
require 'rails_helper'

RSpec.describe TaskMarker do
  # Mocks + Basic RSpec para Service Objects
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user, urgent: false) }
  # Creamos un doble verificador para el Notificador
  let(:mock_notifier) { class_double(UserNotifier).as_stubbed_const }
  # Instancia del servicio bajo prueba
  let(:service) { TaskMarker.new(task, mock_notifier) }

  describe '#mark_as_urgent!' do
    context 'cuando todo funciona correctamente' do
      before do
        # Configuramos la expectativa del mock ANTES de llamar al método
        expect(mock_notifier).to receive(:notify_urgent_task).with(user, task).and_return(true)
      end

      it 'actualiza el atributo urgent de la tarea a true' do
        # Usamos el matcher `change` para verificar el cambio de estado
        expect { service.mark_as_urgent! }.to change { task.reload.urgent }.from(false).to(true)
      end

      it 'llama al notificador con el usuario y la tarea correctos' do
        service.mark_as_urgent!
        # La verificación del mock se hace automáticamente al final del 'it'
        # gracias al 'expect(...).to receive' en el before block.
      end

      it 'devuelve true' do
        expect(service.mark_as_urgent!).to be true
      end
    end

    context 'cuando la actualización de la tarea falla (ej. validación)' do
      before do
        # Hacemos que task.update! falle (simulado)
        allow(task).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
        # Importante: Esperamos que el notificador NO sea llamado en este caso
        expect(mock_notifier).not_to receive(:notify_urgent_task)
      end

      it 'no cambia el atributo urgent de la tarea' do
         expect { service.mark_as_urgent! rescue ActiveRecord::RecordInvalid }.not_to change { task.reload.urgent }
         # Nota: Se rescata el error esperado fuera del bloque change
      end


      it 'no llama al notificador' do
        begin
          service.mark_as_urgent!
        rescue ActiveRecord::RecordInvalid
          # No hacer nada, la expectativa está en el before
        end
      end

      it 'devuelve false' do
        expect(service.mark_as_urgent!).to be false
      end
    end

    context 'cuando el notificador falla' do
      before do
        # Hacemos que el mock del notificador lance un error
        expect(mock_notifier).to receive(:notify_urgent_task).with(user, task).and_raise("Simulated Notifier Failure!")
      end

      it 'no deshace la actualización de urgent (en este diseño simple)' do
         # La transacción de Rails por defecto no revierte en StandardError, solo en Exception/SignalException
         # Si quisiéramos rollback, necesitaríamos `raise ActiveRecord::Rollback` o configurar la transacción
         expect { service.mark_as_urgent! }.to change { task.reload.urgent }.from(false).to(true)
      end

      it 'devuelve false' do
        expect(service.mark_as_urgent!).to be false
      end

      it 'loggea un error (opcional, difícil de probar sin más)' do
        # Probar logs puede ser complejo, a menudo se omite o requiere stubs de Rails.logger
        # allow(Rails.logger).to receive(:error)
        # service.mark_as_urgent!
        # expect(Rails.logger).to have_received(:error).with(/No se pudo marcar la tarea/)
      end
    end
  end
end

# spec/requests/tasks_controller_spec.rb
require 'rails_helper'

RSpec.describe "TasksController", type: :request do
  # Controllers (Request Specs) + Factories
  let(:user) { create(:user) } # Asumimos un sistema de autenticación simple o no implementado aquí
  let(:task) { create(:task, user: user, urgent: false) }

  # Necesitaríamos simular el login del usuario en una app real
  # before { sign_in user } # Usando helpers de Devise, por ejemplo

  describe "PATCH /tasks/:id/mark_urgent" do
    context "cuando la marcación como urgente tiene éxito" do
      # Usamos un spy (un doble que registra llamadas) en el servicio real
      # para verificar que fue llamado, en lugar de mockear todo el servicio.
      # Esto es bueno para tests de controlador/request, probando la integración.
      let(:marker_spy) { instance_spy(TaskMarker) }

      before do
        # Permitimos que se cree una nueva instancia de TaskMarker, pero
        # queremos interceptarla para poder espiarla.
        allow(TaskMarker).to receive(:new).with(task).and_return(marker_spy)
        # Hacemos que el spy devuelva 'true' cuando se llame a mark_as_urgent!
        allow(marker_spy).to receive(:mark_as_urgent!).and_return(true)

        # Realizamos la petición HTTP
        patch mark_urgent_task_path(task)
      end

      it "llama al servicio TaskMarker" do
        expect(TaskMarker).to have_received(:new).with(task)
        expect(marker_spy).to have_received(:mark_as_urgent!)
      end

      it "redirige a la página de la tarea (show)" do
        expect(response).to redirect_to(task_path(task))
      end

      it "muestra un mensaje flash de éxito" do
        expect(flash[:notice]).to eq('Tarea marcada como urgente exitosamente.')
      end
    end

    context "cuando la marcación como urgente falla" do
      let(:marker_spy) { instance_spy(TaskMarker) }

      before do
        allow(TaskMarker).to receive(:new).with(task).and_return(marker_spy)
        # Hacemos que el spy devuelva 'false'
        allow(marker_spy).to receive(:mark_as_urgent!).and_return(false)
        patch mark_urgent_task_path(task)
      end

      it "llama al servicio TaskMarker" do
         expect(TaskMarker).to have_received(:new).with(task)
         expect(marker_spy).to have_received(:mark_as_urgent!)
      end

      it "redirige a la página de la tarea (show)" do
        expect(response).to redirect_to(task_path(task))
      end

      it "muestra un mensaje flash de alerta/error" do
        expect(flash[:alert]).to eq('Error al marcar la tarea como urgente.')
      end
    end

    context "cuando la tarea no se encuentra" do
       it "levanta un error ActiveRecord::RecordNotFound (manejado por Rails)" do
         # Rails por defecto convierte RecordNotFound en un 404 Not Found
         expect {
           patch mark_urgent_task_path(id: 'id-no-existente')
         }.not_to raise_error # No debe explotar sin control

         # Verificar la respuesta 404
         # Esta parte depende de cómo tu aplicación maneje los 404
         # expect(response).to have_http_status(:not_found)
       end
    end
  end
end
```
