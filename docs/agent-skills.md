# Agent Skills: what they are and when to use them

A Skill is a packaged set of instructions for a specific, recurring task —
a checklist, a workflow, a domain procedure — that an agent loads only when
that task comes up. Where `AGENTS.md` holds what an agent needs on *every*
task, a Skill holds what it needs on *one kind* of task.

This repo includes a placeholder example at
[`.claude/skills/code-reviewer/SKILL.md`](../.claude/skills/code-reviewer/SKILL.md)
(mirrored for Copilot at
[`.github/skills/code-reviewer/SKILL.md`](../.github/skills/code-reviewer/SKILL.md))
showing the required shape.

## Anatomy of a Skill

A Skill is a directory containing a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: code-reviewer
description: Reviews code changes for correctness, readability, and bugs.
  Use when the user asks to review code or a pull request.
---

# Code reviewer

## Steps
1. ...
```

- **`name`** — a short, kebab-case identifier.
- **`description`** — the single most important field. It's the only part
  of the Skill that's always in context (see below), so it has to tell the
  agent both *what the skill does* and *when to reach for it*. A vague
  description ("helps with code") means the agent won't invoke it when it
  should, or will invoke it when it shouldn't.
- **Body** — the actual instructions, steps, or reference material. This
  can be as long as the task needs, including linked reference files,
  since it only loads on invocation.

## Why Skills exist: progressive disclosure

Skills apply the same principle as this repo's `conventions/` directory
(see [What is an AGENTS.md file?](./agents-md.md)) at a finer grain:

- **Metadata-cheap, body-expensive.** Every Skill's `name` and
  `description` sit in context for every conversation, so an agent can
  decide whether it's relevant — but that's a small, fixed cost even
  across many skills. The full body only loads when the skill is actually
  invoked. See [Managing the context window](./context-window.md#skills-and-mcp-servers-change-the-baseline).
- **This means a repo can define many Skills without taxing every task.**
  Unlike `AGENTS.md`, which every conversation reads in full, Skills scale
  with the number of distinct workflows you want to codify, not with the
  size of any single one.

## When to write a Skill (vs. `AGENTS.md` or a convention doc)

| Put it in...                | When...                                                                 |
|------------------------------|--------------------------------------------------------------------------|
| `AGENTS.md`                  | It's true for *every* task in the repo (non-negotiables, build/test commands). |
| `conventions/*.md`           | It's a standing rule for a language/framework, referenced but not always loaded. |
| A Skill                      | It's a repeatable *procedure* — a sequence of steps, a checklist, a workflow — invoked for a specific kind of request. |

Good candidates for a Skill: "review this PR," "triage a bug report,"
"run the release checklist," "migrate a test file to pattern X," "do a
security review." Anything with a clear trigger ("when the user asks to
review code") and a repeatable procedure.

Poor candidates: general background knowledge an agent should just have
(that belongs in `AGENTS.md` or a convention doc), or a one-off task
that won't recur.

## Writing a good Skill

- **Lead the description with the trigger.** State plainly when to use it
  ("Use when the user asks to review a branch, a PR, or work-in-progress
  changes") — this is what the agent matches against, not the name.
- **Keep the body focused.** One skill, one job. If a skill is trying to
  cover multiple unrelated workflows, split it — a catch-all skill is as
  hard to reason about as a catch-all `AGENTS.md`.
- **Push detail into linked reference files** for material that's only
  needed in some invocations (e.g. a long checklist used only for one
  branch of the workflow), so a simple invocation doesn't pull in
  everything.
- **State what's out of scope**, if the boundary isn't obvious, so the
  agent doesn't over-apply the skill to adjacent tasks.

## Where Skills live

- Claude Code: `.claude/skills/<name>/SKILL.md`
- GitHub Copilot: `.github/skills/<name>/SKILL.md`

Keep both in sync the same way this repo keeps `AGENTS.md` as the single
source of truth for project instructions — write the procedure once, and
mirror it (or symlink it) into whichever tool-specific directories your
assistants read from.

## A good place to start

Rather than writing every Skill from scratch, look at
[Matt Pocock's `skills` repo](https://github.com/mattpocock/skills) for
well-written, real-world examples to crib from or adapt.
