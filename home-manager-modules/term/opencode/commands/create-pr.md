---
description: Create a GitHub pull request with smart reviewer selection
---

## User Input

$ARGUMENTS

## Context

**Git information:**
- Current branch: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"`
- Base branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`
- Recent authors: !`git log -100 --format='%an <%ae>' | grep -oP '(?<=\+)[^@]+(?=@users\.noreply\.github\.com)' | sort -u | head -10`
- Commits on branch: !`git log origin/main..HEAD --oneline 2>/dev/null || echo "No commits"`
- Changed files: !`git diff origin/main...HEAD --name-only 2>/dev/null | head -20`
- Commit messages: !`git log origin/main..HEAD --format="%s%n%b" 2>/dev/null`

## Task

Create a GitHub pull request following these steps:

### 0. Load Reviewer Configuration
- Read `~/.claude/pr-reviewers.json` using the Read tool
- Parse the JSON to get owner info and available reviewers with their repos

### 1. Check for ClickUp Task
- Look for ClickUp task IDs in User Input (format: `MA-12345` or similar)
- Check recent conversation context for ClickUp task references
- If found, use `mcp__clickup__get_task_by_id` with `custom_task_ids: true` to get task details
- Extract task title and description for context

### 2. Parse Reviewer Input
Extract reviewer usernames from User Input.
Be flexible - accept any of these formats:
- `alice bob`
- `@alice @bob`
- `reviewers: alice, bob`
- `alice and bob please`
- (or similar)
- (not specified - auto-suggest/pick based on repo and recent authors from git log and/or git blame of most edited files)

**Auto-suggestion logic when no reviewers specified:**
1. Get current repo path: `pwd | sed "s|^$HOME|~|"`
2. Match against `repos` array in reviewer JSON to find relevant teammates
3. Filter out the owner (never suggest yourself as reviewer)
4. Supplement with recent authors from git log

Use fuzzy matching against:
1. Known reviewers from `~/.claude/pr-reviewers.json`
2. Recent authors from git log output above
3. **Never include the owner** (`.owner.username`) as a reviewer

**How to extract GitHub username from git log:**
If you need to find more usernames dynamically, use:
```bash
git log -100 --format='%an <%ae>' | grep '@users.noreply.github.com'
# The username is between + and @, e.g., Author: Name <12345+username@users.noreply.github.com> → username is username
```

### 3. Analyze Changes

- Review all commits and understand the overall goal
- If ClickUp task exists, incorporate its context
- Read any relevant `.claude/rules/*` for the repo
- Read relevant sections from CLAUDE.md if it exists
- Identify the type of change (feat/fix/refactor/chore/docs)
- Understand which parts of the codebase were modified

### 4. Generate PR Title

- Follow conventional commit format: type(scope): description
- If ClickUp task exists, include task ID at the end: feat(triggers): Add session cookie handler [MA-25396]
- Keep it concise (50-72 characters including task ID)
- Based on the primary purpose of all commits combined

### 5. Generate PR Body

It should be concise use any combination of bullet-points, paragraphs, checkboxes
depending on what makes sense.

Add the task id to the body if it's not in the title (we have an action that will find an link it).

Make the summary meaningful - explain the "why" not just the "what".

Note: Consider the user input, does it indicate you should add something specific?

### 6. Validate Before Creating

- Ensure current branch is pushed to remote (push if needed)
- Verify matched reviewers are valid GitHub usernames
- If no reviewers matched or uncertain, ask user for confirmation

### 7. Create the PR

IMPORTANT: Always use pass-env GITHUB_TOKEN=github/token/cli to inject the GitHub token:

`pass-env GITHUB_TOKEN=github/token/cli gh pr create --title "..." --body "..." --reviewer user1,user2`

If reviewer list is empty, omit the `--reviewer` flag.

Use `--draft` if specified by the user.

### 8. Output

Show the PR URL and list of reviewers added.

Important Notes

- Always check that commits are pushed before creating PR
- If unsure about reviewer names, ask for clarification rather than guessing
- Follow any project-specific PR conventions from CLAUDE.md
- The PR body should be detailed enough to review without checking commit messages
- To add new reviewers permanently, update ~/.claude/pr-reviewers.json
- ClickUp task IDs should be in the title (in brackets) or body (with "Closes" link)
