# Instructions

Instructions are the rules agents follow automatically: your standards for
code style, testing, security and so on. Write them once in `AGENTS.md` and
`conventions/`, and both GitHub Copilot and Claude Code load them.

## The three layers

| Layer | Lives in | Loaded | Use it for |
|-------|----------|--------|------------|
| Root instructions | `AGENTS.md` | Always | Project overview, non-negotiables, links to conventions |
| Conventions | `conventions/*.md` | When a scoped rule matches | The actual rules for one stack or topic |
| Scoped rule stubs | `.claude/rules/*.md`, `.github/instructions/*.instructions.md` | When a matching file is touched | Point a file glob at a convention |

`CLAUDE.md` is a one-line file that imports `AGENTS.md` (`@AGENTS.md`), and
`.github/copilot-instructions.md` is a one-line file that links to it, so each
tool reads the same root instructions.

## How a scoped rule loads

A stub holds a file glob and a pointer to the convention. The rule text stays in
`conventions/`. Claude Code stubs use an `@` import. Copilot has no import
syntax, so its stubs use a Markdown link.

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

When an agent works on a `.py` file, the Python convention enters its context.
Otherwise it stays out, which keeps the always-on context small.

Edit `conventions/`, not the stubs. Duplicated rules drift.

## Progressive disclosure

Every token of instructions competes with the code and the task for space in the
context window, and a long always-on file dilutes the rules that matter. So we
load instructions in stages: `AGENTS.md` carries only what every task needs, and
each convention is disclosed only when the agent is doing work it applies to.

The glob in a stub's frontmatter (`paths:` for Claude Code, `applyTo:` for
Copilot) is the trigger for that disclosure. We use a file glob because:

- **It's deterministic.** The tool loads the rule when a matching file is
  touched. It doesn't depend on the agent deciding to go and read a convention.
- **File type is a good proxy for relevance.** Touching a `.py` file means the
  Python rules apply, and touching a `.tsx` file means React and TypeScript do.
- **It keeps the cost proportional.** A docs-only change never pays for the
  Django, DRF or Next.js rules.

Keep globs as narrow as the rule allows (`**/*.py`, not `**/*`). A glob that
matches everything is just a bigger `AGENTS.md`. For topics that don't map to a
file type, such as security, list the convention in `AGENTS.md` so the agent
reads it when relevant, rather than forcing a glob that loads it every time.

## Writing good instructions

- **Keep every file short.** Each line costs context, in `AGENTS.md` and in
  conventions alike. If a rule only matters for some tasks, scope it; if it
  doesn't change what the agent does, cut it.
- **Write imperatives with a reason.** "Never use `fields = '__all__'` so new
  model fields aren't exposed by accident" beats "be careful with serializers".
- **Make rules checkable.** A reviewer should be able to tell whether a rule
  was followed. Avoid "write clean code"; prefer "functions have type hints".
- **Don't restate what tooling enforces.** If `ruff` or `eslint` catches it,
  point to the tool instead of listing the rule.
- **Fix rules from real results.** When an agent gets something wrong, ask why,
  then sharpen the rule or add an example.

## Add or remove a stack

- **Add:**
  1. Create `conventions/<stack>.md`.
  2. Add `.claude/rules/<stack>.md` with `paths:` globs and
     `@../../conventions/<stack>.md`.
  3. Add `.github/instructions/<stack>.instructions.md` with an `applyTo:` glob
     (comma-separated, no spaces) and a Markdown link to
     `../../conventions/<stack>.md`.
  4. List it under **Code standards** in `AGENTS.md`.
- **Remove:** delete the convention and both stubs, and remove its line from
  `AGENTS.md`.

## See also

- [Managing the context window](./context-window.md)
- [Config hierarchy](./config-hierarchy.md)
- [Getting started](./getting-started.md)
