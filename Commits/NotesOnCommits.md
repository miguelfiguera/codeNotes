Here's the complete guide in a markdown-formatted file:

````markdown
# Git Commit Workflow Guide

## Workflow Steps

### 1. Stage Changes

```bash
git add .
```
````

- Stages all modified/new files
- Run from **workspace root** (where `.git` is located)

### 2. Review Changes

```bash
git diff --staged  # Detailed changes
git status         # File summary
```

- Verify staged changes before committing

### 3. Create Commit

```bash
git commit -m "type(scope): title" -m " " -m "• Change 1" -m "• Change 2" -m " " -m "-bmadAi"
```

### 4. Push Changes

```bash
git push origin HEAD
```

- Pushes to current branch's remote

---

## Commit Message Format

```text
type(scope): brief description (max 72 chars)

[EMPTY LINE]
[EMPTY LINE]
• Bulleted change summary
• Additional technical details

Signature: -bmadAi
```

### Example:

```text
fix(auth): prevent token expiration

• Extended session duration to 24h
• Added refresh token rotation
• Updated security tests

JWT tokens now use RS256 encryption instead of HS256.
Added token validation middleware.

-bmadAi
```

---

## Commit Types

| Type       | Description                  | Example                           |
| ---------- | ---------------------------- | --------------------------------- |
| `feat`     | New feature                  | `feat(payment): add Apple Pay`    |
| `fix`      | Bug fix                      | `fix(login): password validation` |
| `refactor` | Code restructuring           | `refactor(api): simplify routes`  |
| `docs`     | Documentation changes        | `docs(README): update examples`   |
| `test`     | Test additions/modifications | `test(ui): add button tests`      |
| `perf`     | Performance improvements     | `perf(db): optimize queries`      |
| `chore`    | Maintenance tasks            | `chore(deps): update lodash`      |
| `build`    | Build system changes         | `build(webpack): add plugins`     |
| `ci`       | CI/CD configurations         | `ci(github): add e2e workflow`    |
| `revert`   | Undo previous commit         | `revert: "feat(chat): threads"`   |

---

## Scope Guidelines

- Use parentheses after type: `type(scope)`
- Keep concise (2-12 characters)
- Examples:
  - `(auth)`, `(ui)`, `(api)`
  - `(database)`, `(config)`, `(tests)`
- Match existing project conventions

---

## Key Requirements

1. Title format: `type(scope): description`
2. Title length: ≤ 72 characters
3. Two empty lines after title
4. Bullet-pointed change summary
5. Technical details in body (optional)
6. Final line: `-bmadAi`
7. No newline characters in title

---

## Full Workflow Example

```bash
# From workspace root:
git add .
git status

git commit -m "docs(guide): add commit standards" -m " " \
-m "• Added type reference table" \
-m "• Included scope examples" \
-m "• Added validation rules" \
-m " " \
-m "-bmadAi"

git push origin HEAD
```

Save this content as `git_workflow.md` for future reference.

```

```
