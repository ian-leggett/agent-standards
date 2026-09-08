# 📄 What is an AGENTS.md file?

`AGENTS.md` is an open, tool-agnostic convention for giving AI coding
assistants the context they need to work in your repository: how to build and
test it, the conventions to follow, and anything else a new contributor
(human or AI) would need to be told up front.

It's a plain Markdown file, checked into version control at the root of a
project (or repeated closer to the code in a monorepo — see below). Think of
it as a `README.md`, but written for an agent instead of a human: no badges,
no marketing copy, just the operating instructions an assistant needs before
it starts making changes.

**Both Claude Code and GitHub Copilot read `AGENTS.md`.** That's the point of
the convention — write your project instructions once, in one file, and any
supporting assistant picks them up:

- **Claude Code** reads `AGENTS.md` directly, or you can `@AGENTS.md`-import
  it from a `CLAUDE.md` file (this repo does exactly that — see
  [`CLAUDE.md`](../CLAUDE.md)) if you also need Claude-specific instructions.
- **GitHub Copilot** reads `AGENTS.md` as part of its custom instructions
  support.

Because both tools converge on the same file, you don't have to maintain
parallel, drifting copies of your project's conventions for each assistant.

## Where it lives

- A single `AGENTS.md` at the repo root covers the whole project.
- In a monorepo, place an additional `AGENTS.md` inside a package/app
  directory to add or override instructions for just that subtree — closer
  files take precedence for the code under them.

## What to put in it

Keep it short and scannable. An agent reads this file on every task, so
every line should earn its place. Good sections to include:

- **Project overview** — a sentence or two on what the project is and how
  it's laid out, enough for an agent to orient itself.
- **Non-negotiables** — hard rules that should never be broken (e.g. "never
  read or print secrets", "never force-push to main"). Keep this list short
  and genuinely non-negotiable, not a dumping ground for preferences.
- **Setup / build / test commands** — the exact commands to install
  dependencies, run the app, run the test suite, and lint/format. Agents
  will run these verbatim, so keep them accurate and current.
- **Conventions** — coding style, architectural rules, naming, and structure
  expectations. If these are long or vary by language/framework, don't
  inline them all — link out to dedicated convention docs instead (see
  [Progressive disclosure](#progressive-disclosure) below).
- **Workflow expectations** — how you want changes made: commit message
  style, whether to open a PR vs. push directly, branch naming, when to ask
  before proceeding.
- **Security** — hard boundaries an agent must respect: files and directories
  it should never read or modify (secrets, credentials, `.env*`), commands it
  should never run unprompted (destructive git operations, deploys), and any
  data it must never transmit outside the project.

What to leave out: anything already obvious from reading the code, and
anything that changes often enough to go stale fast (that belongs in
memory, a ticket, or a comment, not in a file every task loads).

## Pointing to it from CLAUDE.md and copilot-instructions.md

If you need tool-specific instructions on top of the shared ones — say,
something only relevant to Claude Code or only to Copilot — don't duplicate
`AGENTS.md`'s content into each tool's own file. Import it instead, and add
the tool-specific bits alongside the import.

Both tools support the same `@`-followed-by-relative-path import syntax, so a
one-line file is enough in each case:

**Claude Code** (`CLAUDE.md`, repo root):

```markdown
@AGENTS.md
```

**GitHub Copilot** (`.github/copilot-instructions.md`, path is relative to
that file's own directory):

```markdown
@../AGENTS.md
```

This repo's own [`CLAUDE.md`](../CLAUDE.md) and
[`.github/copilot-instructions.md`](../.github/copilot-instructions.md) use
exactly these one-liners. Add any tool-specific instructions below the
import line in either file — `AGENTS.md` stays the single source of truth,
and each tool's own file only carries what's genuinely tool-specific.

## Progressive disclosure

`AGENTS.md` doesn't need to contain everything. If your project supports many
stacks or has deep conventions for a particular language or framework, keep
`AGENTS.md` itself small and link out to detail files (for example, this
repo's [`conventions/`](../conventions/) directory) that only get pulled in
when relevant. This keeps the always-on context an agent has to read on
every task small, no matter how much documentation the project accumulates
overall.

## Further reading

- [agents.md — the open AGENTS.md spec](https://agents.md/)
- [Claude Code: CLAUDE.md memory docs (imports, rules, path-scoping)](https://code.claude.com/docs/en/memory)
