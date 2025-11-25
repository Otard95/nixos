---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit with proper message
---
## User message

$ARGUMENTS

## Context

- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
- Recent commits: !`git log --oneline -5`

## Task

Create one or more atomic git commits with descriptive messages. Each commit should represent a single logical change that can stand alone.

**Critical considerations:**
- **Analyze the actual changes** - understand what was modified and why
- **Review project documentation** - consult CLAUDE.md, .claude/rules/, and any relevant project guidelines
- **Group related changes** - stage and commit logically related modifications together
- **Separate unrelated changes** - create multiple commits when changes serve different purposes
- **Follow project conventions** - adhere to the repository's commit message format and practices

Ensure each commit is atomic (complete, testable, and reversible) while accurately reflecting the intent and scope of the changes made.

**DO NOT** make the commit body to large, keep it compact, only include the absolute nessesities and don't be verbose.
