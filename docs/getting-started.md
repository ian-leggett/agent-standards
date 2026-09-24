# Getting started: GitHub Copilot and Claude Code

This guide sets up **GitHub Copilot** and **Claude Code** in a project so both
tools follow the same standards. You write the rules once, in `AGENTS.md` and
`conventions/`. Each tool gets a thin wiring layer that points back to them.
See [Instructions](./instructions.md) for why it is split this way.

> Your team's standards stay the single source of truth. The config files here
> make agents follow those standards. They do not replace them.

## Quick start: minimum viable setup

Copy these into the root of your repo. This is enough for the tool to pick up
your standards. Follow the table for the tool you use, or both if your team
uses both. `AGENTS.md` and `conventions/` are shared, so you only copy them once.

After copying, edit the **Project overview** section at the top of `AGENTS.md`.
It ships with example values (Django, PostgreSQL, SSO), so replace the service
name, language, framework, database and authentication with your own. Also
remove the `# Agent/Root Instructions — Example` heading and the code fence
around the content, so your `AGENTS.md` contains only the rules themselves.

### Claude Code

| Step | Copy from this repo | To your repo | Purpose |
|------|---------------------|--------------|---------|
| 1 | `AGENTS.md` | `AGENTS.md` | Root instructions, always active. Edit the project overview first |
| 2 | `CLAUDE.md` | `CLAUDE.md` | One line, `@AGENTS.md`. Claude Code reads it |
| 3 | `conventions/` | `conventions/` | The actual rules. **Delete the stacks you don't use** |
| 4 | `.claude/rules/*` | `.claude/rules/*` | Scoped rule stubs for the stacks you kept |
| 5 | `.claude/settings.json` | `.claude/settings.json` | Blocks Claude from reading secret files |

### GitHub Copilot

| Step | Copy from this repo | To your repo | Purpose |
|------|---------------------|--------------|---------|
| 1 | `AGENTS.md` | `AGENTS.md` | Root instructions, always active. Edit the project overview first |
| 2 | `.github/copilot-instructions.md` | `.github/copilot-instructions.md` | One line linking to `AGENTS.md`. Copilot reads it |
| 3 | `conventions/` | `conventions/` | The actual rules. **Delete the stacks you don't use** |
| 4 | `.github/instructions/*` | `.github/instructions/*` | Scoped rule stubs for the stacks you kept |

Copilot has no equivalent of `.claude/settings.json`. Block secret files with
content exclusion instead. See the [content exclusion guide](./content-exclusion.md).

## Recommended directory structure

### Claude Code

```
your-repo/
├── AGENTS.md                        # root instructions (shared, always loaded)
├── CLAUDE.md                        # @AGENTS.md
├── conventions/                     # shared rules: the only place with real content
│   ├── python.md
│   ├── django.md
│   ├── typescript.md
│   ├── security.md
│   ├── testing.md
│   ├── git.md
│   └── ...
├── docs/                            # human-facing guides
│
├── .claude/
│   ├── settings.json                # shared permissions + hooks (committed)
│   ├── settings.local.json          # personal overrides (gitignored)
│   ├── rules/                       # one stub per convention
│   │   ├── python.md                # paths: "**/*.py" → @../../conventions/python.md
│   │   ├── django.md
│   │   ├── security.md
│   │   └── ...
│   ├── agents/                      # subagents
│   │   ├── code-reviewer.md
│   │   └── accessibility-advisor.md
│   ├── skills/                      # on-demand task instructions
│   │   ├── write-tests/SKILL.md
│   │   └── create-pr/SKILL.md
│   └── hooks/
│       └── post-tool-format.sh
│
└── .mcp.json                        # optional: MCP servers
```

### GitHub Copilot

```
your-repo/
├── AGENTS.md                        # root instructions (shared, always loaded)
├── conventions/                     # shared rules: the only place with real content
│   ├── python.md
│   ├── django.md
│   ├── typescript.md
│   ├── security.md
│   ├── testing.md
│   ├── git.md
│   └── ...
├── docs/                            # human-facing guides
│
├── .github/
│   ├── copilot-instructions.md      # link to ../AGENTS.md
│   ├── pull_request_template.md
│   ├── instructions/                # one stub per convention
│   │   ├── python.instructions.md   # applyTo: "**/*.py" → link to ../../conventions/python.md
│   │   ├── django.instructions.md
│   │   ├── security.instructions.md
│   │   └── ...
│   ├── agents/                      # custom agents
│   │   ├── code-reviewer.agent.md
│   │   └── accessibility-advisor.agent.md
│   ├── skills/
│   │   ├── write-tests/SKILL.md
│   │   └── create-pr/SKILL.md
│   └── hooks/
│       ├── formatting.json          # registers the hook (Copilot has no settings.json)
│       └── post-tool-format.sh
│
└── .vscode/mcp.json                 # optional: MCP servers for VS Code
```

## How each tool loads configuration

| Concept | Claude Code | GitHub Copilot |
|---------|-------------|----------------|
| Root instructions | `CLAUDE.md` (imports `@AGENTS.md`) | `.github/copilot-instructions.md` (links to `../AGENTS.md`) |
| Scoped rules | `.claude/rules/<name>.md`, frontmatter `paths:` | `.github/instructions/<name>.instructions.md`, frontmatter `applyTo:` |
| Agents | `.claude/agents/<name>.md` | `.github/agents/<name>.agent.md` |
| Skills | `.claude/skills/<name>/SKILL.md` | `.github/skills/<name>/SKILL.md` |
| Prompts | Skills, or `.claude/commands/<name>.md` | `.github/prompts/<name>.prompt.md` |
| Hooks | `.claude/hooks/*.sh`, registered in `.claude/settings.json` | `.github/hooks/*.sh`, registered in `.github/hooks/*.json` |
| MCP servers | `.mcp.json` | `.vscode/mcp.json` |
| Secret guardrails | `permissions.deny` in `.claude/settings.json` | Copilot content exclusion (set in GitHub repo or org settings) |

Scoped rules are the stubs mentioned in the quick start. Each is a few lines of
frontmatter plus a pointer, so the rule text lives only in `conventions/`.
Claude Code supports `@` imports. Copilot does not, so its stubs use a
Markdown link, which Copilot follows in VS Code:

```markdown
<!-- .claude/rules/python.md -->
---
paths:
  - "**/*.py"
---
@../../conventions/python.md
```

```markdown
<!-- .github/instructions/python.instructions.md -->
---
applyTo: "**/*.py"
---
Follow the [Python conventions](../../conventions/python.md).
```

For adding or removing a stack, see [Instructions](./instructions.md#add-or-remove-a-stack).

## Set up GitHub Copilot

1. **Enable Copilot** in your editor (VS Code, JetBrains, or another supported
   IDE) and sign in with your GitHub account.
2. **Check the repo files** from the quick start are in place. Copilot reads
   `.github/copilot-instructions.md` automatically, and
   `.github/instructions/*.instructions.md` when a file matches the `applyTo`
   glob.
3. **Turn on `AGENTS.md` support** if your editor needs it. In VS Code, enable
   the `chat.useAgentsMdFile` setting so Copilot reads `AGENTS.md` in the local
   agent.
4. **Add agents and skills** (optional). Copy `.github/agents/` and
   `.github/skills/`, rename the agent files to `<name>.agent.md`, and edit
   them to match your workflow.
5. **Verify.** Open Copilot Chat, ask *"What coding standards apply to this
   repo?"*, and check the reply cites your conventions. The **References**
   list on a reply shows which instruction files were loaded.

## Set up Claude Code

1. **Install** Claude Code. See the
   [official install docs](https://code.claude.com/docs/en/overview) for your
   platform.
2. **Start it in your repo:** `cd your-repo && claude`.
3. **Check the repo files** from the quick start are in place. Claude reads
   `CLAUDE.md` at session start (which imports `AGENTS.md`), and loads
   `.claude/rules/*` when it touches a matching file.
4. **Review `.claude/settings.json`.** The `permissions.deny` list blocks reads
   of `.env*`, private keys and credential files. Add to it if your project has
   other secret files. Put personal preferences in `.claude/settings.local.json`
   so they stay out of version control. `Read` deny rules also cover Grep, Glob
   and Bash file commands such as `cat`, but not a script that opens the file
   itself. Enable the [sandbox](https://code.claude.com/docs/en/sandboxing) for
   a hard guarantee.
5. **Add agents, skills and hooks** (optional). Copy `.claude/agents/`,
   `.claude/skills/` and `.claude/hooks/`, then edit the placeholders.
6. **Verify.** Run `/memory` to list the instruction files loaded, and
   `/permissions` to confirm the deny rules are active.

## Trim it down to your stack

Everything is opt-in per stack. To drop Django and DRF, for example:

1. Delete `conventions/django.md` and `conventions/drf.md`.
2. Delete `.claude/rules/django.md`, `.claude/rules/drf.md`,
   `.github/instructions/django.instructions.md` and
   `.github/instructions/drf.instructions.md`.
3. Remove their lines from the **Code standards** list in `AGENTS.md`.

To add a stack that isn't covered, follow
[Add or remove a stack](./instructions.md#add-or-remove-a-stack).


## Tips

- **Keep `AGENTS.md` short.** Anything only some tasks need belongs in a
  convention, a scoped rule, or a skill. See
  [Managing the context window](./context-window.md).
- **Write rules as imperatives with a reason.** "Never use `fields = '__all__'`
  so new model fields aren't exposed by accident" works better than "be careful
  with serializers".
- **Edit `conventions/`, not the stubs.** If a rule is duplicated in
  `.claude/` or `.github/`, the two will drift.
- **Keep agent and skill bodies matched across tools.** They have to be
  written per tool, so review both copies together.
- **Iterate on real results.** When an agent gets something wrong, ask why, then
  fix the rule or add an example.
- **Keep a human in the loop.** Agents follow the config but can still make
  mistakes. Review generated code as you would a colleague's.

## Going further

- [Config hierarchy: enterprise, org, project, and local](./config-hierarchy.md)
- [Agents](./agents.md), [Skills](./skills.md), [Hooks](./hooks.md)
- [Claude Code memory docs](https://code.claude.com/docs/en/memory)
- [GitHub Copilot: custom instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions)
- [agents.md: the open AGENTS.md spec](https://agents.md/)
