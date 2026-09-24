# PR Description Skill — Example

This is an example skill file that drafts a pull request description from the branch's changes. It uses this repo's `.github/pull_request_template.md` and links to the conventions rather than restating them. Copy the folder into your repository as `.claude/skills/pr-description/SKILL.md` (Claude Code) or `.github/skills/pr-description/SKILL.md` (GitHub Copilot). The format is identical on both tools.

## Example file contents

The content below goes into your `SKILL.md` file:

```markdown
---
name: pr-description
description: Drafts a pull request title and description from the branch diff. Use when the user asks for a PR description or is about to open a PR.
---

# PR description

## Purpose

Produce a clear, accurate PR title and description that a reviewer can act on
without reading the whole diff first.

## Steps

1. Find the change: run `git log main..HEAD --oneline` and
   `git diff main...HEAD --stat`, then read the diff for anything non-trivial.
2. Read `.github/pull_request_template.md` and fill in its sections in order. If
   there is no template, use: Summary, Changes, Testing, Notes for reviewers.
3. Write a title under 72 characters that says what changed, in the imperative
   mood.
4. In the summary, explain why the change is needed before what it does. Link the
   issue or ticket if one is known.
5. List the notable changes as short bullets, grouped by area. Don't list every
   file.
6. Under testing, state only what was actually run and its result. If tests were
   not run, say so.
7. Flag anything a reviewer should look at closely: security-relevant changes,
   migrations, new dependencies, and deviations from `conventions/`.
8. Return the title and description as Markdown. Don't open the PR.

## Rules

- Describe the diff as it is. Don't claim tests, fixes or behaviour you haven't
  verified.
- Keep it concise. No filler and no restating of the code.
- Never include secrets, tokens or personal data.
- Follow `conventions/git.md` for title and commit wording.

## References

- `.github/pull_request_template.md`
- `conventions/git.md`
- `conventions/security.md`
- `conventions/testing.md`

## Out of scope

- Creating, pushing or merging the PR.
- Reviewing the code. Use the `code-reviewer` agent for that.
- Editing code or commit history.
```
