# 🤖 Creating an agent: how and when to use one

A subagent is a separate context window with its own system prompt and its
own (often narrower) tool access, dispatched by a main agent to do one job
and report back. Where a [Skill](./agent-skills.md) hands the *current*
agent a procedure to follow, a subagent hands the work to a *different*
agent entirely — one whose context doesn't fill up with the main
conversation's history, and whose tool access can be locked down to just
what the job needs.

This repo includes a placeholder example at
[`.claude/agents/example-agent.md`](../.claude/agents/example-agent.md)
(mirrored for Copilot at
[`.github/agents/example-agent.agent.md`](../.github/agents/example-agent.agent.md))
showing the required shape.

## Anatomy of an agent

An agent is a single Markdown file with YAML frontmatter:

```markdown
---
name: example-agent
description: Placeholder example subagent. Replace this description with a
  specific trigger condition so Claude knows when to delegate to it (e.g.
  "Use for X task").
tools: Read, Grep, Glob
model: inherit
---

# Example agent

## Responsibilities
1. ...
```

- **`name`** — a short, kebab-case identifier, used to invoke the agent.
- **`description`** — the field the main agent matches against to decide
  whether to delegate. Same rule as a Skill's description: state plainly
  *when* to use it, not just what it does.
- **`tools`** — the allowlist of tools this agent can call. Narrower is
  better — an agent that only reads and searches can't accidentally edit
  or run destructive commands.
- **`model`** — which model runs the agent (`inherit` to match the parent,
  or pin a specific one for cost/quality tradeoffs).
- **Body** — the system prompt: the one job this agent exists to do, the
  steps it follows, and what it returns.

## Why agents exist: isolated context, not just delegation

The point of a subagent isn't just "getting another task done" — it's
keeping the *main* agent's context window small (see
[Managing the context window](./context-window.md)):

- **Exploratory or noisy work stays out of the main context.** A wide
  codebase search, a long research task, or a multi-step investigation
  produces a lot of intermediate tool output. Run it in a subagent and
  only the distilled result comes back — the raw noise never enters the
  main conversation.
- **Tool access can be scoped down.** An agent whose job is "find where X
  is defined" only needs `Read`/`Grep`/`Glob` — it doesn't need `Edit` or
  `Bash`. A narrower tool list is both safer and easier for the agent
  itself to reason about.
- **Work can run in parallel.** Independent subagents can be dispatched at
  the same time (e.g. one reviewing for correctness, one for style) rather
  than working through each concern serially in one context.

## When to use an agent (vs. a Skill or doing it inline)

| Approach          | When...                                                                 |
|--------------------|--------------------------------------------------------------------------|
| Do it inline        | The task is small, or its intermediate output is itself useful to keep in context. |
| A Skill              | The *current* agent needs a repeatable procedure or checklist — no context isolation needed. |
| A subagent           | The task is exploratory, noisy, parallelizable, or benefits from a restricted tool set — and only the final result matters to the caller. |

Good candidates for a subagent: "search the codebase for every caller of
this function," "review this diff for security issues," "research this
library's API and summarize it," "run this multi-step task in the
background while I keep working." Anything where you'd otherwise dump a
pile of tool output into the main conversation just to extract one
conclusion from it.

Poor candidates: a task so small that spinning up a subagent costs more
(in round-trip latency and re-derived context) than doing it directly, or
a task whose intermediate steps the main agent genuinely needs to see and
react to as it goes.

## Writing a good agent

- **One job, stated plainly in the description.** The description is what
  gets matched against — lead with the trigger ("use when the user asks to
  review a branch") the same way you would for a Skill.
- **Scope `tools` to the job.** Don't hand out `Edit`/`Bash`/`Write` to an
  agent whose entire purpose is read-only research.
- **Give it a self-contained brief when dispatching it.** A fresh agent has
  none of the calling conversation's context — the dispatch prompt needs to
  explain what to do and why, not just reference "the thing we discussed."
- **State what it returns.** A subagent's output is a summary handed back
  to the caller, not a live transcript — be explicit about what shape that
  summary should take.
- **Keep it narrow.** An agent that tries to cover several unrelated jobs
  is as hard to reason about as a catch-all Skill or a catch-all
  `AGENTS.md` — split it instead.

## Where agents live

- Claude Code: `.claude/agents/<name>.md`
- GitHub Copilot: `.github/agents/<name>.agent.md`

Keep both in sync the same way this repo keeps `AGENTS.md` as the single
source of truth for project instructions — write the responsibilities once,
and mirror them into whichever tool-specific file format your assistants
read from.
