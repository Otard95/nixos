---
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

**First**: Load the `git-commit-practices` skill for commit conventions and staging guidance.

**Then**:
- **Analyze the actual changes** - understand what was modified and why
- **Group related changes** - stage and commit logically related modifications together
- **Separate unrelated changes** - create multiple commits when changes serve different purposes
- **Use partial staging if needed** - when a file contains unrelated changes, use `hunk` as documented in the skill

Ensure each commit is atomic (complete, testable, and reversible) while accurately reflecting the intent and scope of the changes made.
