# Create PR Skill — Example

This is an example skill file that drafts a pull request title and description from the branch's changes, then opens the PR after the user confirms. It uses this repo's `.github/pull_request_template.md` and links to the conventions rather than restating them. Copy the folder into your repository as `.claude/skills/create-pr/SKILL.md` (Claude Code) or `.github/skills/create-pr/SKILL.md` (GitHub Copilot). The format is identical on both tools.

## Example file contents

The content below goes into your `SKILL.md` file:

```markdown
---
name: create-pr
description: Drafts a pull request title and description from the branch diff, then opens the PR once the user confirms. Use when the user asks to create, open or raise a PR, or asks for a PR description.
---

# Create PR

## Purpose

Open a pull request with a clear, accurate title and description that a reviewer
can act on without reading the whole diff first.

## Steps

1. Check the branch: run `git branch --show-current` and `git status`. Stop and
   ask if you are on `main` or the default branch, or if the working tree has
   uncommitted changes. The branch name should follow `conventions/git.md`.
2. Check for an existing PR for this branch (for example `gh pr view`). If one
   exists, update its title and description instead of creating another.
3. Find the change: run `git log main..HEAD --oneline` and
   `git diff main...HEAD --stat`, then read the diff for anything non-trivial.
4. Read `.github/pull_request_template.md` and fill in its sections in order. If
   there is no template, use: Summary, Changes, Testing, Notes for reviewers.
5. Write a title under 72 characters that says what changed, in the imperative
   mood.
6. In the summary, explain why the change is needed before what it does. Link the
   issue or ticket if one is known.
7. List the notable changes as short bullets, grouped by area. Don't list every
   file.
8. Under testing, state only what was actually run and its result. If tests were
   not run, say so.
9. Flag anything a reviewer should look at closely: security-relevant changes,
   migrations, new dependencies, and deviations from `conventions/`.
10. Show the title, description, base branch and draft status to the user and
    wait for an explicit yes. Don't push or create anything before that.
11. On confirmation, push the branch with upstream tracking, then open the PR as
    a draft using the GitHub CLI (`gh pr create --draft`) or the platform's PR
    tool. Return the PR URL.

## Rules

- Never push or create the PR without explicit confirmation of the exact title
  and description.
- Open PRs as drafts unless the user says otherwise.
- Never force-push, push to `main`, or merge.
- Describe the diff as it is. Don't claim tests, fixes or behaviour you haven't
  verified.
- Keep it concise. No filler and no restating of the code.
- Never include secrets, tokens or personal data.
- Follow `conventions/git.md` for branch, title and commit wording.

## References

- `.github/pull_request_template.md`
- `conventions/git.md`
- `conventions/security.md`
- `conventions/testing.md`

## Out of scope

- Merging the PR.
- Reviewing the code. Use the `code-reviewer` agent for that.
- Editing code or commit history.
- Committing uncommitted changes. Ask the user to do that first.
```
