# Hooks: how and when to use them

A hook is a shell command the harness runs deterministically at a defined
lifecycle event (before a tool runs, after a tool runs, on user input, on
session stop, etc.). Where `AGENTS.md`, a convention doc, or a Skill are
*instructions* the agent reads and may or may not follow precisely, a hook
is *code the harness executes itself* — it always runs, in the same way,
every time its event fires. Use hooks for anything that must happen, not
just should happen.

This repo includes a placeholder example at
[`.claude/hooks/post-tool-format.sh`](../.claude/hooks/post-tool-format.sh),
wired up in [`.claude/settings.json`](../.claude/settings.json) (mirrored
for Copilot at
[`.github/hooks/post-tool-format.sh`](../.github/hooks/post-tool-format.sh)
and [`.github/hooks/formatting.json`](../.github/hooks/formatting.json))
showing the required shape.

## Anatomy of a hook

A hook is two pieces: a script, and a config entry that says which event
triggers it.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/post-tool-format.sh\"",
            "timeout": 30,
            "statusMessage": "Formatting changed file..."
          }
        ]
      }
    ]
  }
}
```

- **Event** (`PostToolUse`, `PreToolUse`, `UserPromptSubmit`, `Stop`, etc.)
  — when the hook fires.
- **`matcher`** — narrows which tool calls trigger it (e.g. only
  `Write`/`Edit`, not every tool). Omit it to match every event of that
  type.
- **`command`** — the script or command to run. Receives the event's JSON
  payload on stdin.
- **`timeout`** — hooks block the agent loop while they run; keep them
  fast, and set a timeout that fails safe.
- **Exit code / output** — controls whether the hook merely reports
  (formatting) or actually blocks the action (a gate). See below.

## Why hooks exist: deterministic vs. probabilistic

An agent *reading* "format the file after you edit it" in `AGENTS.md` will
usually do it — but "usually" is the operative word. It can forget,
skip it under time pressure, or paraphrase the instruction into something
looser. A hook removes that uncertainty: the harness runs the command
itself, outside the model's discretion, every single time the matching
event occurs.

That makes hooks the right tool specifically for **deterministic
outputs** — results that must be byte-identical regardless of which model
ran the session, how the conversation went, or whether the agent
"remembered":

- **Formatting/linting after a write.** `post-tool-format.sh` in this repo
  is the canonical example: run `ruff format`, `prettier`, `eslint --fix`,
  or `gofmt` after every `Write`/`Edit`, so code style never depends on the
  model choosing to run it.
- **Gating dangerous actions.** A `PreToolUse` hook that blocks
  `git push --force` or `rm -rf` outright, rather than hoping the agent's
  training data makes it cautious.
- **Injecting fixed context.** A `UserPromptSubmit` hook that appends the
  current git branch or ticket number to every prompt.
- **Enforcing a check before stopping.** A `Stop` hook that runs the test
  suite and reopens the loop if it fails.

## When to use a hook (vs. an instruction)

| Approach                     | When...                                                                 |
|-------------------------------|--------------------------------------------------------------------------|
| `AGENTS.md` / a convention doc | The rule requires judgment, varies by context, or is fine to be "usually" followed. |
| A Skill                       | It's a multi-step procedure the agent should reason through, not a fixed transformation. |
| A hook                        | The outcome must be deterministic and unconditional — the same action, every time, regardless of what the model decides. |

Good candidates for a hook: formatting/linting on save, secret-pattern
scanning before a commit, blocking specific commands outright, injecting
fixed context into every prompt, running tests before the session ends.

Poor candidates: anything requiring judgment about *when* it applies (that
needs the model in the loop, so it belongs in `AGENTS.md` or a Skill), or
a one-off check that doesn't recur across sessions.

## Writing a good hook

- **Make it fast and idempotent.** Hooks run inline and block the agent
  loop — a slow or flaky hook is a tax on every matching event.
- **Decide: report or gate.** A formatting hook should never fail the tool
  call (exit `0` always) — formatting is a nice-to-have. A safety hook
  (blocking a destructive command) should exit non-zero / return
  `"continue": false` to actually stop the action. Don't accidentally
  write a gate that silently no-ops, or a reporter that blocks work.
- **Scope the matcher tightly.** Don't run a formatter on every tool call
  when it only needs to fire on `Write`/`Edit`; don't run it on every file
  type when it only handles one.
- **Never let a hook read or leak secrets.** Same rule as the agent itself
  (see `AGENTS.md`'s non-negotiables) — a hook that shells out and logs
  file contents is a bigger blast radius than the agent making the same
  mistake, since it runs unconditionally.
- **Keep tool-specific hook configs separate.** This repo keeps the Claude
  Code hook (`.claude/hooks/` + `.claude/settings.json`) and the Copilot
  hook (`.github/hooks/`) as independent configs pointing at logically
  equivalent scripts, so either can be edited or removed without touching
  the other.

## Where hooks live

- Claude Code: script in `.claude/hooks/`, registered under `"hooks"` in
  `.claude/settings.json`.
- GitHub Copilot (VS Code agent mode): script in `.github/hooks/`,
  registered in a config file such as `.github/hooks/formatting.json`.

Keep both in sync the same way this repo keeps `AGENTS.md` as the single
source of truth for project instructions — write the behavior once, and
mirror it into whichever tool-specific hook config your assistants read
from.
