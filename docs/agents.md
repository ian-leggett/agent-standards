# 🧑‍💻 Agents

Agents are specialised AI personas with a defined role, a limited set of tools
and a fixed workflow. GitHub Copilot calls them **custom agents** and you pick
one from the agent picker in Copilot Chat. Claude Code calls them
**subagents**. Claude delegates to one when the task matches its description,
and the subagent works in its own context window and returns a summary.

Use an agent when a task has a clear role and you want the same behaviour every
time, such as reviewing code, writing tests or triaging bugs.

## Agents, instructions and skills

| | Instructions | Agents | Skills |
|---|---|---|---|
| Purpose | Rules to follow | A role to adopt | A procedure to run |
| Loaded | Always, or by file glob | When picked or delegated to | On demand, when relevant |
| Answers | "What are our standards?" | "Who does this job?" | "How is this task done?" |

Agents don't replace your standards. They point at them. See
[Instructions](./instructions.md) and [Skills](./skills.md).

## File format and location

| | Claude Code | GitHub Copilot |
|---|---|---|
| Location | `.claude/agents/<name>.md` | `.github/agents/<name>.agent.md` |
| Picked by | Claude, from the `description` | You, from the agent picker |
| Tools | `tools:` comma-separated list | `tools:` list of tool sets |

The body is the same on both tools. Only the frontmatter differs.

```markdown
<!-- .claude/agents/code-reviewer.md -->
---
name: code-reviewer
description: Reviews changed code against the repo's conventions. Use after finishing a change and before opening a PR.
tools: Read, Grep, Glob
model: inherit
---
```

```markdown
<!-- .github/agents/code-reviewer.agent.md -->
---
name: code-reviewer
description: "Reviews changed code against the repo's conventions before a PR."
tools: ["read", "search", "execute"]
---
```

## Anatomy of a good agent

Give the body four sections:

1. **Role.** One sentence on who the agent is and what it is expert in.
2. **Workflow.** Numbered steps it follows, ending with what it returns.
3. **Rules.** Hard dos and don'ts for this role.
4. **References.** Links to the conventions it applies, for example
   `conventions/security.md`. Link them and don't restate them.

Also list what is **out of scope**, so the agent stays narrow.

```markdown
# Code reviewer

## Role
You review changes against this repo's standards. You do not edit code.

## Workflow
1. Run `git diff main...HEAD` to find the changed files.
2. Read the conventions that match each file type.
3. Report each violation with `file:line`, the rule broken and a suggested fix.

## Rules
- Report only violations of a written convention, not personal preference.
- Flag security issues first.

## References
- `conventions/security.md`
- `conventions/testing.md`

## Out of scope
- Making changes. Report findings only.
```

## Best practices

- **One job per agent.** A narrow agent is predictable. A broad one is a second
  general-purpose assistant.
- **Write the `description` as a trigger.** Say when to use it. Claude uses it
  to decide whether to delegate, and Copilot shows it in the picker, so keep it
  short.
- **Grant least privilege.** A read-only reviewer gets `Read, Grep, Glob` and no
  edit tools. Add `Bash` only if it needs read-only commands such as `git diff`,
  and say so in its rules.
- **Prefer tool sets on Copilot.** Use `read`, `search`, `edit`, `execute` and
  `web` over long lists of individual tools.
- **Reference, don't repeat.** Point at `conventions/` so rules live in one
  place.
- **Keep the two copies matched.** Agents are written per tool, so review the
  Claude and Copilot versions together.
- **Iterate on real output.** When an agent gets something wrong, tighten the
  workflow or add an example.

## Examples in this repo

- [`.claude/agents/code-reviewer.md`](../.claude/agents/code-reviewer.md): a worked example
- [`.github/agents/example-agent.agent.md`](../.github/agents/example-agent.agent.md): a placeholder

Replace the placeholder description and body with a real role before use.

## Further reading

- [Agent Skills open standard](https://github.com/agentskills/agentskills)
- [Awesome GitHub Copilot: community agents, skills and instructions](https://github.com/github/awesome-copilot)
- [DEFRA AI config examples: agents](https://github.com/DEFRA/defra-ai-config-examples/blob/main/pages/agents/index.md)
- [Claude Code subagents](https://code.claude.com/docs/en/sub-agents)
