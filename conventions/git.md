# Git

## Commit messages — Conventional Commits

Every commit message follows the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<optional scope>): <description>

<optional body>

<optional footer(s)>
```

- `type` is one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- `scope` is the area of the codebase affected (e.g. `api`, `auth`, `parser`) — omit it only when the change is truly repo-wide.
- `description` is imperative, present tense, lowercase, no trailing period (`add`, not `added`/`adds`).
- Breaking changes are marked with a `!` after the type/scope (`feat(api)!: ...`) and/or a `BREAKING CHANGE:` footer explaining the migration.
- The body explains *why*, not *what* — the diff already shows what changed.
- Reference issues/tickets in the footer (`Refs: #123`, `Closes: #123`), not the subject line.

Examples:

```
fix(auth): reject expired refresh tokens before session lookup

feat(billing)!: require currency on invoice creation

BREAKING CHANGE: `Invoice.create` now requires a `currency` field;
callers relying on the USD default must pass it explicitly.
Refs: #482
```

## Branch naming — Conventional Branch

Branch names follow `<type>/<short-description>`, mirroring the commit `type` vocabulary:

- `feat/`, `fix/`, `docs/`, `style/`, `refactor/`, `perf/`, `test/`, `build/`, `ci/`, `chore/`, `revert/`
- `<short-description>` is lowercase, hyphen-separated, no ticket-only names (`fix/login-redirect-loop`, not `fix/bug`).
- Include a ticket/issue id when one exists, appended after the description: `feat/short-description-123`.
- No personal-name or date-based prefixes (`ian/`, `2024-01-fix`) — the type prefix and description are enough to identify purpose; git blame/authorship already tracks who.

## Pull requests

- Every PR description is filled out using `.github/pull_request_template.md` — populate its sections, don't delete them or replace the template with freeform text.
- If the template doesn't exist yet in the repo, create it at `.github/pull_request_template.md` before opening the PR rather than skipping it.

## General

- Don't mix an unrelated `type` of change into one commit — a refactor and a feature addition are two commits, even on the same branch.
- Squash-merge or keep history linear per the repo's existing convention (check recent `git log` before assuming) — don't introduce a new merge strategy unilaterally.
