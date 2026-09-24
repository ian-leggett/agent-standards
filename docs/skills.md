# 🛠️ Skills

Skills are reusable packages of instructions for a specific task, such as
reviewing a PR, writing a migration or running a release. A skill is a folder
with a `SKILL.md` file, plus optional scripts and reference files. Both Claude
Code and GitHub Copilot support them, and they follow the open
[Agent Skills standard](https://github.com/agentskills/agentskills), so the same
skill works across tools.

Use a skill when you have a **repeatable procedure** you don't want in the
always-on instructions.

## Skills, instructions and agents

| | Instructions | Agents | Skills |
|---|---|---|---|
| Purpose | Rules to follow | A role to adopt | A procedure to run |
| Loaded | Always, or by file glob | When picked or delegated to | On demand, when relevant |
| Answers | "What are our standards?" | "Who does this job?" | "How is this task done?" |

See [Instructions](./instructions.md) and [Agents](./agents.md).

## How skills load

Skills use progressive disclosure, so many skills cost almost no context:

1. **Discovery.** The agent loads only each skill's `name` and `description`.
2. **Activation.** When a task matches a description, the full `SKILL.md` is
   loaded.
3. **Execution.** The agent follows the steps and reads bundled files or runs
   scripts only as needed.

## File format and location

| | Claude Code | GitHub Copilot |
|---|---|---|
| Project | `.claude/skills/<name>/SKILL.md` | `.github/skills/<name>/SKILL.md` |
| Personal | `~/.claude/skills/<name>/SKILL.md` | `~/.copilot/skills/<name>/SKILL.md` |

The format is identical on both tools, so keep the two copies matched.

```text
.claude/skills/code-reviewer/
├── SKILL.md        # required: frontmatter + instructions
├── references/     # optional: docs loaded when needed
├── scripts/        # optional: executable helpers
└── assets/         # optional: templates and static files
```

```markdown
---
name: code-reviewer
description: Reviews changed code against the repo's conventions. Use when the user asks to review code or a pull request.
---
```

| Field | Rule |
|---|---|
| `name` | Required. Max 64 characters. Lowercase letters, numbers and hyphens. Matches the folder name. |
| `description` | Required. Max 1024 characters. Says what the skill does **and when to use it**. |
| `license`, `metadata` | Optional. |

## Anatomy of a good skill

1. **Purpose.** One or two sentences on what the skill produces.
2. **Steps.** Numbered, concrete and in order, ending with what it returns.
3. **Out of scope.** What the skill does not do.
4. **References.** Links to `conventions/` files or bundled `references/`.
   Link them and don't restate them.

## Best practices

- **One task per skill.** Split a skill that does two jobs.
- **Write the `description` as a trigger.** Skills are picked by matching the
  description, so name the task and the situations. "Helps with code" won't
  activate reliably.
- **Keep `SKILL.md` short.** Aim for under about 500 lines. Move detail into
  `references/` and link to it.
- **Prefer scripts for deterministic work.** Formatting, scaffolding and checks
  belong in `scripts/`, not in prose.
- **Reference, don't repeat.** Point at `conventions/` so rules live in one
  place.
- **Never bundle secrets.** Follow `conventions/security.md`.
- **Iterate on real output.** When a skill gets something wrong, tighten the
  steps or add an example.

## Examples in this repo

- [`.claude/skills/write-tests/SKILL.md`](../.claude/skills/write-tests/SKILL.md): writes tests that follow `conventions/testing.md`
- [`.claude/skills/pr-description/SKILL.md`](../.claude/skills/pr-description/SKILL.md): drafts a PR description from the branch diff
- [`.github/skills/write-tests/SKILL.md`](../.github/skills/write-tests/SKILL.md) and [`.github/skills/pr-description/SKILL.md`](../.github/skills/pr-description/SKILL.md): the Copilot copies

## Further reading

- [Agent Skills open standard](https://github.com/agentskills/agentskills)
- [Claude Code skills](https://code.claude.com/docs/en/skills)
- [Awesome GitHub Copilot](https://github.com/github/awesome-copilot)
