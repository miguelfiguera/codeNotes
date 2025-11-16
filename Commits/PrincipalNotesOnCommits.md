¡Claro que sí! Aquí tienes toda la información organizada en español, manteniendo los tipos de commit y el ejemplo final en inglés, como solicitaste.

---

### Guía Organizada sobre Conventional Commits

Los _Conventional Commits_ proporcionan un estándar para crear un historial de commits claro y descriptivo, facilitando la revisión de cambios y la automatización de procesos como la generación de _changelogs_.

### Tipos de Commit

Los tipos se agrupan en dos categorías: **Tipos Principales** para cambios significativos de cara al usuario, y **Tipos Suplementarios** para tareas de mantenimiento interno y desarrollo.

#### Tipos Principales

| Tipo           | Descripción                                               | Ejemplo                                      |
| :------------- | :-------------------------------------------------------- | :------------------------------------------- |
| **`feat`**     | Una nueva característica o funcionalidad.                 | `feat(payment): add PayPal integration`      |
| **`fix`**      | Una corrección de un bug o error.                         | `fix(login): handle null tokens`             |
| **`refactor`** | Reestructuración de código (sin romper la funcionalidad). | `refactor(database): simplify query builder` |
| **`docs`**     | Únicamente actualizaciones en la documentación.           | `docs(README): update installation steps`    |
| **`test`**     | Añadir o mejorar tests.                                   | `test(auth): add password strength tests`    |

#### Tipos Suplementarios

| Tipo         | Descripción                                           | Ejemplo                                  |
| :----------- | :---------------------------------------------------- | :--------------------------------------- |
| **`perf`**   | Un cambio en el código que mejora el rendimiento.     | `perf(images): compress thumbnails`      |
| **`chore`**  | Tareas de mantenimiento (ej: dependencias, configs).  | `chore(deps): upgrade lodash to v4.17`   |
| **`build`**  | Cambios en el sistema de compilación o configuración. | `build(webpack): add source-map support` |
| **`ci`**     | Cambios en el pipeline de CI/CD.                      | `ci(github): add automated e2e tests`    |
| **`revert`** | Revertir un commit anterior.                          | `revert: "feat(chat): message threads"`  |

---

### Estructura del Mensaje de Commit

Un mensaje de commit convencional sigue un formato específico:

```
<type>(<scope>): <subject>
<LÍNEA EN BLANCO>
<body>
<LÍNEA EN BLANCO>
<footer>
```

- **type**: (Requerido) El tipo de cambio (ej: `feat`, `fix`, `chore`).
- **scope**: (Opcional) Un sustantivo que describe la sección del código afectada.
  - Mantén los scopes cortos y consistentes (ej: `auth`, `ui`, `api`, `config`).
- **subject**: (Requerido) Un resumen corto en modo imperativo sobre el cambio.
  - **Regla:** Mantén la línea del asunto por debajo de 72 caracteres.
- **body**: (Opcional) Una explicación más larga y detallada. Usa este espacio para explicar el "qué" y el "porqué" del cambio.
  - **Regla:** Separa el cuerpo del asunto con una línea en blanco.
  - **Buena práctica:** Usa listas con viñetas para un resumen claro de los cambios.
- **footer**: (Opcional) Para referenciar IDs de seguimiento de incidencias (ej: `Closes #123`) o declarar cambios que rompen la compatibilidad (`BREAKING CHANGE:`).

---

### Ejemplo de un Commit Completo

Aquí tienes un ejemplo completo que sigue todas las reglas (dejado en inglés según tu petición):

```
fix(api): prevent timeout on large exports

The previous implementation buffered the entire export response in memory,
causing timeouts and memory leaks for large datasets. This new solution
streams data in chunks to the client using the Node.js Transform API.

- Increased payload chunk size from 1MB to 10MB.
- Added a streaming response handler to the export service.
- Fixed a related memory leak in the data aggregation step.
```
