---
description: Create a GitHub pull request with smart reviewer selection
---

## User Input

$ARGUMENTS

## Context

- Current branch: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"`
- Base branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`
- Status: !`git status`

## Task

Create a GitHub pull request.

### 1. Gather Context

- Load reviewer config from `~/.config/opencode/pr-reviewers.json`
- Check for ClickUp task IDs in user input or conversation (format: `MA-12345`)
  - If found, use clickup-cli skill to get task context
- Read project AGENTS.md if it exists for PR conventions

### 2. Determine Reviewers

If specified in user input (flexible formats accepted), match against the reviewer JSON.

If not specified, auto-select:
1. Get changed files: `git diff origin/<base>...HEAD --name-only`
2. Pick a couple of the most relevant changed files
3. Extract unique authors: `git blame --line-porcelain -- <files> | grep "^author-mail " | sort -u`
4. Cross-reference with `pr-reviewers.json` for valid reviewers on this repo
5. **Never include the owner** (`.owner.username`)

If no reviewers can be determined, ask the user.

### 3. Draft the PR

Review the commits on this branch and understand the overall goal.

**Title:** `type(scope): description` (conventional commits, 50-72 chars)
- Append ClickUp task ID if present, plain — no brackets or wrapping: `feat(triggers): add session cookie handler MA-25396`

**Body:** Concise — explain the *why* not the *what*. Use bullet points,
paragraphs, or checkboxes as fits. Include ClickUp task ID somewhere
(title or body). Incorporate any specific requests from user input.

### 4. Create the PR

- Push to remote if needed
- `pass-env ghc gh pr create --title "..." --reviewer user1,user2 --body "..."`
- `--draft` if user specified
- Omit `--reviewer` if empty

Show PR URL and reviewers added.
