---
description: Create a GitHub pull request
---

$ARGUMENTS

## Context

- Current branch: run `git rev-parse --abbrev-ref HEAD`
- Base branch: run `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` (fallback: `main`)
- Status: run `git status`
- Changes: run `git log --oneline origin/<base>..HEAD`

## Task

Create a GitHub pull request.

### 1. Gather Context

- Review the commits on this branch to understand the overall goal
- Check for task/issue IDs mentioned in user input or commit messages

### 2. Draft the PR

**Title:** `type(scope): description` (conventional commits style, 50-72 chars)
- Append task/issue ID if present: `feat(triggers): add session cookie handler #123`

**Body:** Concise — explain the *why* not the *what*. Use bullet points, paragraphs, or checkboxes as appropriate. Include issue references if available.

### 3. Create the PR

- Push to remote if needed: `git push -u origin <branch>`
- Create: `gh pr create --title "..." --body "..."`
- Add `--draft` if the user specified draft
- Add `--reviewer user1,user2` if reviewers specified

Show the PR URL when done.
