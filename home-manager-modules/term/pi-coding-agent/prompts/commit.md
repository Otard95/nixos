---
description: Create atomic git commits with conventional messages
---

$ARGUMENTS

## Context

Review the current state before committing:
- Run `git status` to see what's changed
- Run `git diff HEAD` to see the actual changes
- Run `git log --oneline -5` to see recent commit style

## Git Commit Conventions

**Format:** `type(scope): Description in sentence case`

**Types:** `feat`, `fix`, `chore`, `ci`, `refactor`, `docs`

- **Sentence case**: `feat(auth): Add user authentication` — not title case, not lowercase
- **No empty scopes**: Use `chore: Update dependencies` not `chore(): Update dependencies`
- **Scope** should logically encapsulate the staged changes (service, feature, domain, module). Omit for cross-cutting changes.
- **BREAKING CHANGE** in body = major release (avoid when possible)

**Always:** Use relevant skills, when available.

## Task

Create one or more atomic git commits. Each commit should represent a single logical change that can stand alone.

1. **Analyze the changes** — understand what was modified and why
2. **Group related changes** — stage logically related modifications together
3. **Separate unrelated changes** — create multiple commits when changes serve different purposes
4. **Never blindly `git add .`** — stage specific files for each logical commit
5. **Verify before committing** — run `git diff --cached` to confirm what's staged

Each commit should be atomic: complete, testable, and reversible.
