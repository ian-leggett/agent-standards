# Hooks

A hook is a command the tool runs itself at a set point in the agent's
lifecycle, such as before or after a tool call. Instructions are read by the
model and may be skipped. A hook always runs, so use one when something **must**
happen, for example formatting a file after every edit or blocking a dangerous
command.

## Hooks, instructions and skills

| | Instructions | Skills | Hooks |
|---|---|---|---|
| Purpose | Rules to follow | A procedure to run | An action the tool runs |
| Run by | The model | The model | The tool, every time |
| Use for | Judgement calls | Multi-step tasks | Anything that must be deterministic |

See [Instructions](./instructions.md) and [Skills](./skills.md).

## File format and location

| | Claude Code | GitHub Copilot |
|---|---|---|
| Script | `.claude/hooks/<name>.sh` | `.github/hooks/<name>.sh` |
| Registered in | `hooks` key of `.claude/settings.json` | `.github/hooks/<name>.json` |
| Event names | `PreToolUse`, `PostToolUse`, `Stop` | `preToolUse`, `postToolUse`, `agentStop` |
| Command field | `command` | `bash` (and `powershell`) |
| Timeout field | `timeout`, in seconds | `timeoutSec`, default 30 |
| Narrow by tool | `matcher`, for example `Write\|Edit` | `matcher`, an optional regex |
| Runs in | Claude Code | Copilot CLI and the Copilot cloud agent |

Copilot has no `settings.json`, so the JSON file is what registers the hook.
Its `version: 1` format is documented for the CLI and cloud agent. Check
VS Code's docs before relying on it in the editor.

```json
// .claude/settings.json
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

```json
// .github/hooks/formatting.json
{
  "version": 1,
  "hooks": {
    "postToolUse": [
      {
        "type": "command",
        "bash": ".github/hooks/post-tool-format.sh",
        "timeoutSec": 30
      }
    ]
  }
}
```

Both tools send the event as JSON on the script's stdin.

## Report or gate

- **Report.** Runs after the action and never fails it. Formatting is the
  example: the script always exits `0`. A `PostToolUse` hook can't block, because
  the tool has already run.
- **Gate.** Runs before the action and can stop it. In Claude Code use a
  `PreToolUse` hook that exits `2`. Any other non-zero exit, including `1`, is a
  non-blocking error and the action still runs.

## Best practices

- **Keep it fast and idempotent.** Hooks run inline and hold up the agent.
- **Scope the matcher.** Match only the tools that need it. The Claude example
  matches `Write|Edit`. The Copilot example has no `matcher`, so it runs after
  every tool call. Add one when you copy it.
- **Never read or log secrets.** A hook runs unconditionally, so a leak repeats
  every time. See `AGENTS.md` non-negotiables.
- **Keep the two configs independent.** Each tool has its own config, so either
  can change or be removed without touching the other.

## Examples in this repo

Both are placeholders that print a line and exit `0`. Replace the body with your
formatter or linter (`ruff format`, `prettier`, `eslint --fix`).

- [`.claude/hooks/post-tool-format.sh`](../.claude/hooks/post-tool-format.sh),
  registered in [`.claude/settings.json`](../.claude/settings.json)
- [`.github/hooks/post-tool-format.sh`](../.github/hooks/post-tool-format.sh),
  registered in [`.github/hooks/formatting.json`](../.github/hooks/formatting.json)

## Further reading

- [Claude Code hooks reference](https://code.claude.com/docs/en/hooks)
- [GitHub Docs: Copilot hooks configuration](https://docs.github.com/en/copilot/reference/hooks-configuration)
