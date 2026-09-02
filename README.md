# Agent standards

A starter template for AI agent documentation. Use it as the seed for a new
project's `AGENTS.md`, coding standards, and Claude Code configuration — clone
it, trim it down to the stacks you actually use, and start building.

It's built around **progressive disclosure**: every layer only enters an
agent's context when it's actually relevant, so a project's always-on
instructions stay small no matter how many stacks it ends up covering.

## Start a new project from this template

If this repo is hosted on GitHub, click **Use this template** to create a new
repo seeded from it. Otherwise, clone and re-point the remote yourself:

```bash
git clone <this-repo-url> my-new-project
cd my-new-project
rm -rf .git && git init
```

Then work through the checklist below before your first commit.

### Customization checklist

1. **Fill in `AGENTS.md`.** Replace all four `<!-- ... -->` placeholders — the
   project summary, non-negotiables, workflow, and process sections — with
   real, project-specific content. Delete a section's placeholder comment
   once it's filled in; an empty section is fine, an unfilled comment isn't.
2. **Delete the conventions you don't need.** This template ships with Python,
   Django, JavaScript, TypeScript, React, and Next.js docs under `conventions/`.
   If your project is a Python API with no frontend, delete `javascript.md`,
   `typescript.md`, `react.md`, `nextjs.md` — and remove their rows from the
   `## Conventions for languages & frameworks` table in `AGENTS.md`.
3. **Delete the matching `.claude/rules/*.md` files** for anything you removed
   in step 2 — an orphaned rule pointing at a deleted convention file will
   error when Claude Code tries to load it.
4. **Adjust the conventions you keep.** These are opinionated defaults (ruff
   for Python, Conventional Commits for git, etc.) — edit them to match how
   your team actually works before treating them as settled.
5. **Leave `skills/` empty until you need it.** Don't pre-populate workflows
   speculatively — add a skill the first time you notice an agent repeating
   the same multi-step task on this project.
6. **Commit the result** as your project's first commit, then build on top of it.

## The three layers

```
AGENTS.md              ← Layer 1: always loaded, every session. Keep this under ~50 lines.
conventions/*.md        ← Layer 2: full standards docs, loaded on demand (by reference or rule).
.claude/rules/*.md      ← Layer 3 (Claude Code only): auto-loads a Layer 2 doc, but ONLY
                           when Claude actually touches a matching file (paths: frontmatter).
```

This mirrors how Claude's own Agent Skills work (name+description always visible,
full body loaded when relevant, supporting files loaded only when needed) and how
Claude Code's own memory system is designed: `@imports` in CLAUDE.md are *always*
loaded at launch (they just help you organize one big file into several — they do
**not** save context), while `.claude/rules/` files with `paths:` frontmatter are
the mechanism that actually defers loading until it's needed. Layer 3 exists
because that distinction matters and most teams miss it.

Why not put everything in one AGENTS.md? Two independent numbers cap it:
- Frontier models hold ~150–200 *instructions* reliably before adherence drops.
- Every token in AGENTS.md is paid on every single turn, forever, whether or not
  it's relevant to what you're doing right now.

So: Layer 1 carries only what's true on every task. Everything stack-specific
moves to Layer 2, and Layer 3 gets Claude Code to fetch the right Layer 2 doc
automatically instead of relying on the model to remember to go read it.

## What's in this template

```
agent-standards/
├── AGENTS.md                  # Layer 1 — fill in the summary, trim to your stacks
├── CLAUDE.md                  # Bridges to AGENTS.md — @import, see below
├── conventions/                # Layer 2: one file per stack, plus process docs
│   ├── python.md
│   ├── django.md
│   ├── javascript.md
│   ├── typescript.md
│   ├── react.md
│   ├── nextjs.md
│   └── git.md                  # Commit/branch/PR conventions — stack-agnostic
├── skills/                      # Empty on purpose — see skills/README.md
└── .claude/
    ├── rules/                   # Layer 3: path-scoped auto-loaders for conventions/
    │   ├── python.md
    │   ├── django.md
    │   ├── javascript.md
    │   ├── typescript.md
    │   ├── react.md
    │   └── nextjs.md
    └── settings.json            # Baseline deny rules for secrets/credentials
```

## How `AGENTS.md` and `CLAUDE.md` relate

`AGENTS.md` is the source of truth — it's the file every AGENTS.md-aware tool
(Cursor, Copilot, Codex, Windsurf, Gemini CLI, Zed, Claude Code) reads natively.
`CLAUDE.md` exists only to bridge into it:

```markdown
@AGENTS.md

## Claude Code specifics
<!-- anything Claude-Code-only goes here, below the import -->
```

Never hand-edit both. If you don't need Claude-only additions, a plain symlink
works instead of the `@import`: `ln -s AGENTS.md CLAUDE.md`.

## Adding a new stack later

1. Write `conventions/<stack>.md` — the full standards doc for that stack.
2. Add a row to the `## Conventions for languages & frameworks` table in
   `AGENTS.md` pointing at it.
3. Add `.claude/rules/<stack>.md` scoped to that stack's file patterns:

   ```markdown
   ---
   paths:
     - "**/*.rb"
   ---
   @../conventions/ruby.md
   ```

That's it — Claude Code now loads `ruby.md` automatically the first time you
touch a `.rb` file, and every other tool still gets it via the `AGENTS.md` row.

## Sharing standards across many repos instead

This template is meant to be cloned once per project and then diverge — each
project's conventions drift to match how that project actually works. If you
instead want several projects to share one *versioned, centrally-updated* set
of standards, pull `conventions/` in as a git submodule rather than templating
this repo. That's a different tradeoff (updates propagate on a deliberate
version bump, but any project-specific tweaks have to happen in a fork of the
submodule rather than in place) — worth doing deliberately, not by default.

## Sources / further reading

- [agents.md — the open AGENTS.md spec](https://agents.md/)
- [Claude Code: CLAUDE.md memory docs (imports, rules, path-scoping)](https://code.claude.com/docs/en/memory)
- [AI Hero — A Complete Guide to AGENTS.md](https://www.aihero.dev/a-complete-guide-to-agents-md)
- [Ardalis — Optimizing AI Agents with Progressive Disclosure](https://ardalis.com/optimizing-ai-agents-with-progressive-disclosure/)
- [SwirlAI — Agent Skills: Progressive Disclosure as a System Design Pattern](https://www.newsletter.swirlai.com/p/agent-skills-progressive-disclosure)
- [Red Hat Developer — Standardize project context with AGENTS.md and Agent Skills](https://developers.redhat.com/articles/2026/07/27/standardize-project-context-agentsmd-and-agent-skills)
- [agentpatterns.ai — Architecting a Central Repo for Shared Agent Standards](https://agentpatterns.ai/workflows/central-repo-shared-agent-standards/)
- [aq.dev — Keep AGENTS.md and CLAUDE.md in Sync Across Agent CLIs](https://aq.dev/guides/keep-agents-md-and-claude-md-in-sync/)
