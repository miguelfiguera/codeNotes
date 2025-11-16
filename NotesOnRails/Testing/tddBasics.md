# Notas sobre TDD

Para ruby se puede usar RSPEC, especificamente en rails es considerablemente util.

Rspec tiene el feature de usar autorun.

Rspec es una gema de ruby usada especialmente para testing.

Combinando el uso de tests con las users stories se puede desarrollar una aplicación en buenas condiciones velozmente. Que satisfaga la funcionalidad y las necesidades del usuario de forma eficiente y segura. Aparte permite que se pueda refactorizar código sin que se rompa la aplicación.

Al definir el test primero que el codigo, construyes una expectativa clara sobre el funcionamiento del metodo, feature,integracion...etc. Estas metas tan claras y concretas hacen que escribir codigo sea sencillo.

### Para que?

Los tests son equivalentes a una documentacion automatica producida durante el desarrollo del codigo que explica la funcionalidad de cada uno de los elementos del codigo.

El testing cuenta una historia de lo que tu codigo hace.

Los test tienen 4 partes:

- Setup (Crea objetos)
- Excercises (desarrolla el metodo)
- Verification (Evalua el metodo y comprueba que haga lo que tiene que hacer.)
- Tear down (elimina efectos indeseados.)

#### Importante...

Como los test tienen el objetivo de crear una historia, si los usas para documentar tu codigo tambien, puede que en algunos casos sea mas sensato repetir codigo (si, literalmente escribir lo mismo una y otra vez) para facilitar su legibilidad y entendimiento que aplicar DRY... por que? porque DRY hace abstracciones para la reutilizacion del codigo, pero la documentacion no necesita abstracciones, necesita claridad.

Esto es recomendado por el equipo de toughbot y en lo personal pienso que tiene sentido.

## Que testear?

Segun las recomendaciones princiales que he recibido:

### El "Camino Feliz" (Happy Path):

Qué es: El flujo de ejecución normal y esperado, cuando todo funciona correctamente y se proporcionan los datos válidos.

Por qué: Es lo primero que debe funcionar. Si el caso de uso principal falla, el resto importa menos.

- Ejemplo: Para Person#full_name, el happy path es cuando se proporcionan nombre, (opcionalmente) apellido intermedio y apellido, y se devuelve la cadena concatenada correctamente. Para un login, es usuario/contraseña correctos y acceso concedido.

### Casos Límite (Edge Cases) y Condiciones de Frontera:

Qué son: Los valores o situaciones en los extremos de lo permitido o esperado. Son fuentes comunes de bugs.

Por qué: Aquí es donde la lógica a menudo se vuelve compleja o puede fallar.

Ejemplos:

- Valores Nulos o Vacíos: ¿Qué pasa si middle_name es nil (como ya probaste)? ¿Y si es un string vacío ("")? ¿Y si un campo requerido es nil?

- Cero/Números Negativos: Para cálculos, ¿funciona con 0? ¿Con negativos?

- Límites de Colecciones: ¿Funciona con listas vacías? ¿Con listas de un solo elemento? ¿Con listas muy grandes (si aplica)?

- Límites de Strings: Strings vacíos, strings muy largos, strings con caracteres especiales o unicode.

- Fechas/Horas: Fechas límite (fin de año, cambio de siglo), zonas horarias.

### Manejo de Errores y Escenarios de Fallo:

Qué es: Cómo reacciona tu código cuando algo sale mal o se proporcionan datos inválidos.

Por qué: Una aplicación robusta debe manejar los errores de forma predecible y controlada, no simplemente explotar.

Ejemplos:

- Entradas Inválidas: Si un método espera un número y recibe un string, ¿qué hace? ¿Lanza un error específico (TypeError, ArgumentError)? ¿Devuelve nil o false? Tu test debe verificar la respuesta esperada en caso de error.

- Validaciones (Muy importante en Rails): Si un modelo tiene validaciones (ej: validates :email, presence: true), debes tener tests que demuestren que un objeto sin email no es válido (expect(user).not_to be_valid) y que tiene un error específico en el campo email (expect(user.errors[:email]).to include("can't be blank")).

- Excepciones Esperadas: Si una operación puede fallar (ej: buscar un registro que no existe y usas find! que lanza ActiveRecord::RecordNotFound), testea que la excepción correcta se lanza: expect { CodigoQueFalla }.to raise_error(TipoDeErrorEsperado).

- Operaciones Externas Fallidas: Si tu código depende de una API externa, ¿qué pasa si la API no responde o devuelve un error? (Esto a menudo se prueba usando mocks/stubs con gemas como WebMock).

### Variaciones de Lógica y Ramificaciones (Branches):

Qué es: Si tu código tiene condicionales (if/else, case), asegúrate de probar cada posible rama de ejecución.

Por qué: Para garantizar que todas las partes de tu lógica se comportan como esperas.

- Ejemplo: En Person#full_name_with_middle_initial, tienes un if @middle_name. Ya probaste qué pasa cuando es true (hay middle_name) y cuando es false (no hay middle_name). ¡Perfecto!

### Cambios de Estado (State Changes):

Qué es: Si un método modifica el estado interno de un objeto o de la base de datos.

Por qué: Para asegurar que las acciones tienen el efecto deseado sobre los datos.

- Ejemplo: Si tienes un método user.activate!, debes probar que el atributo user.status cambia de inactive a active. El matcher change de RSpec es ideal para esto: expect { user.activate! }.to change { user.status }.from('inactive').to('active'). O probar que Order.create(...) incrementa el conteo de órdenes en la base de datos: expect { Order.create(...) }.to change { Order.count }.by(1).

### Interacciones entre Objetos (Collaborations):

Qué es: Cómo un objeto interactúa con otros (sus "colaboradores").

Por qué: Para verificar que los diferentes componentes de tu sistema funcionan juntos correctamente.

- Ejemplo: Si al crear una Invoice (factura), esta debe llamar a un servicio Notifier para enviar un email, puedes testear esa intención de llamar al colaborador (a menudo usando mocks/doubles en tests unitarios para aislar la Invoice) o probar el efecto completo en un test de integración/feature.

## Qué NO testear (o testear con moderación):

- Código Trivial: Métodos que son extremadamente simples (como getters/setters básicos generados por attr_accessor sin lógica adicional) generalmente no necesitan tests dedicados. Testéalos indirectamente a través de los métodos que los usan.

- Métodos Privados: La regla general es testear la interfaz pública de tu clase. Si la lógica de un método privado es compleja, podría ser una señal de que debería extraerse a su propia clase (y entonces testear esa nueva clase). Si no, confía en que tus tests de los métodos públicos que usan el método privado lo cubrirán adecuadamente.

- Librerías Externas/Frameworks: No necesitas probar que Rails funciona o que tu gema favorita hace lo que dice su documentación. Debes probar tu código y cómo usa esas librerías. Por ejemplo, no pruebas que validates :presence funciona en general, pruebas que tu modelo lo usa correctamente para el campo deseado.

- **En resumen**: Piensa en los requisitos de tu funcionalidad. ¿Qué se supone que debe hacer? Prueba que lo hace en el caso normal. Luego, piensa en todas las formas en que podría fallar o recibir datos inesperados (nulos, vacíos, incorrectos, límites) y prueba que se comporta de manera predecible y controlada en esos casos. Finalmente, si la acción cambia datos o interactúa con otros componentes, verifica esos efectos secundarios.

## Tipos de pruebas.

### Clasificación por Nivel/Alcance (La Pirámide de Pruebas):

#### Pruebas Unitarias (Unit Tests):

- Qué prueban: La unidad más pequeña y aislada de código que tiene sentido probar, generalmente un método o una clase.
- Propósito: Verificar que la lógica interna de esa unidad funciona correctamente, independientemente de sus colaboradores (otras clases, base de datos, servicios externos).
- Cómo: Se aíslan las dependencias usando técnicas como Mocks, Stubs o Doubles. Son muy rápidas de ejecutar. Son la base de la pirámide (deberías tener muchas).
- Ejemplo RSpec: spec/models/mi_clase_spec.rb, spec/services/mi_servicio_spec.rb. Probar el método #full_name de tu clase Person es un ejemplo perfecto de test unitario.

#### Pruebas de Integración (Integration Tests):

- Qué prueban: La interacción y comunicación entre dos o más unidades/módulos que ya han sido probados unitariamente.
- Propósito: Verificar que las diferentes partes del sistema colaboran correctamente. ¿Envía la clase A los datos correctos a la clase B? ¿Se guarda correctamente en la base de datos después de llamar a un servicio?
- Cómo: Implican menos aislamiento que las unitarias. Pueden interactuar con la base de datos real (limpiada entre tests) o con stubs de servicios externos. Son más lentas que las unitarias. Están en el medio de la pirámide.
- Ejemplo RSpec (en Rails): A menudo se solapan con los Request Specs (spec/requests/) donde pruebas que una petición HTTP a un controlador desencadena las acciones correctas (llamadas a modelos, respuestas adecuadas), interactuando con varias capas pero sin pasar por la interfaz de usuario completa.

#### Pruebas de Sistema / E2E (End-to-End) / Feature Tests:

- Qué prueban: El sistema completo desde la perspectiva del usuario final, simulando flujos de trabajo reales a través de la interfaz de usuario (o API si es una aplicación sin UI).
- Propósito: Verificar que los flujos de negocio completos funcionan como se espera, atravesando todas las capas de la aplicación (UI, backend, base de datos).
- Cómo: Usan herramientas como Capybara (con drivers como Selenium o Cuprite) para automatizar un navegador web. Son las más lentas y pueden ser más frágiles (sensibles a cambios en la UI), pero dan mucha confianza sobre la funcionalidad real. Están en la cima de la pirámide (deberías tener menos que unitarias o de integración).
- Ejemplo RSpec (en Rails): spec/features/ o spec/system/. Probar el flujo completo de "iniciar sesión, añadir un producto al carrito, proceder al checkout".
