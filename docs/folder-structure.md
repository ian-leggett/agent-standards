# 🗂️ Folder structure: `.claude/` vs `.github/`

This repo configures two AI coding assistants side by side — Claude Code and
GitHub Copilot — and keeps their tool-specific configuration mirrored under
`.claude/` and `.github/`. Neither folder holds the actual content: they're
thin, tool-specific wiring that points back to one shared source of truth
(`AGENTS.md` and `conventions/`), so a rule, agent, or skill is written once
and read by both tools. See [What is an AGENTS.md file?](./agents-md.md) for
why that split exists.

## `.claude/` (Claude Code)

```
.claude/
├── settings.json          # permissions (secret-file deny list) + hooks registration
├── settings.local.json    # personal, machine-local overrides (not for shared rules)
├── agents/
│   └── example-agent.md   # subagent definitions — docs/agents.md
├── hooks/
│   └── post-tool-format.sh
├── rules/
│   └── python.md, ...     # per-language stubs, "paths:" frontmatter + @-import
└── skills/
    └── code-reviewer/
        └── SKILL.md       # docs/agent-skills.md
```

## `.github/` (GitHub Copilot)

```
.github/
├── copilot-instructions.md   # @../AGENTS.md — docs/agents-md.md
├── pull_request_template.md
├── agents/
│   └── example-agent.agent.md
├── hooks/
│   ├── post-tool-format.sh
│   └── formatting.json       # registers the hook (Copilot has no settings.json)
├── instructions/
│   └── python.instructions.md, ...  # per-language stubs, "applyTo:" frontmatter + @-import
└── skills/
    └── code-reviewer/
        └── SKILL.md
```

## Concept map

Same concept, different filename/frontmatter convention per tool — both
ultimately point back to the shared files at the repo root.

| Concept                        | Claude Code                                                        | GitHub Copilot                                                          | Shared source                | Docs |
|---------------------------------|----------------------------------------------------------------------|----------------------------------------------------------------------------|-------------------------------|------|
| Project-wide instructions       | `CLAUDE.md` → `@AGENTS.md`                                            | `.github/copilot-instructions.md` → `@../AGENTS.md`                         | `AGENTS.md`                    | [agents-md.md](./agents-md.md) |
| Language/framework conventions  | `.claude/rules/<name>.md` (`paths:` frontmatter) → `@../../conventions/<name>.md` | `.github/instructions/<name>.instructions.md` (`applyTo:` frontmatter) → `@../../conventions/<name>.md` | `conventions/<name>.md`        | [agents-md.md](./agents-md.md) |
| Subagents                       | `.claude/agents/<name>.md`                                            | `.github/agents/<name>.agent.md`                                            | —, written per-tool            | [agents.md](./agents.md) |
| Skills                          | `.claude/skills/<name>/SKILL.md`                                      | `.github/skills/<name>/SKILL.md`                                            | —, written per-tool (or mirrored by hand) | [agent-skills.md](./agent-skills.md) |
| Hooks                           | `.claude/hooks/*.sh`, registered under `"hooks"` in `.claude/settings.json` | `.github/hooks/*.sh`, registered in a config like `.github/hooks/formatting.json` | —, written per-tool            | [hooks.md](./hooks.md) |
| Secret/permission guardrails    | `"permissions.deny"` in `.claude/settings.json`                       | no direct equivalent — rely on repo access controls and hook-based gating   | —                               | [hooks.md](./hooks.md) |
| PR checklist                    | —                                                                      | `.github/pull_request_template.md`                                          | —                               | — |

Two things worth noticing in that table:

- **Rules and instructions are import stubs, not copies.** Both
  `.claude/rules/python.md` and `.github/instructions/python.instructions.md`
  are one line — `@../../conventions/python.md` — plus frontmatter that tells
  the tool which files to auto-attach the rule to (`paths:` for Claude Code,
  `applyTo:` for Copilot, both taking a glob). The actual convention text
  lives once, in `conventions/python.md`.
- **Agents, skills, and hooks are written per-tool**, because their
  frontmatter/runtime shapes genuinely differ (e.g. Copilot agent frontmatter
  uses `tools: ["search"]` and a `model` string; Claude Code uses
  `tools: Read, Grep, Glob` and `model: inherit`). Keep the *body* — the
  responsibilities, the steps, the checks — logically identical across the
  pair even though the file has to be duplicated; see each concept's doc for
  the exact frontmatter shape.

## Adding a new stack

To add support for a new language or framework (say, Go), touch four files:

1. `conventions/go.md` — the actual rules. This is the only file with real
   content.
2. `.claude/rules/go.md`:
   ```markdown
   ---
   paths:
     - "**/*.go"
   ---
   @../../conventions/go.md
   ```
3. `.github/instructions/go.instructions.md`:
   ```markdown
   ---
   applyTo: "**/*.go"
   ---
   @../../conventions/go.md
   ```
4. Add a line for it under **Conventions for languages & frameworks** in
   `AGENTS.md`, so it's discoverable even outside the glob-triggered path.

Adding a new subagent or Skill follows the same "write once per tool" pattern
described in [agents.md](./agents.md) and [agent-skills.md](./agent-skills.md)
— there's no shared-source shortcut for those two, since their content is
tool-specific by nature.
