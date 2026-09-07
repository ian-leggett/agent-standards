---
name: example-agent
description: Placeholder example subagent. Replace this description with a specific trigger condition so Claude knows when to delegate to it (e.g. "Use for X task").
tools: Read, Grep, Glob
model: inherit
---

# Example agent (placeholder)

This is an example Claude Code subagent showing the shape of a project-level
agent definition — replace this system prompt with real, specific
instructions for what this agent should do.

## Responsibilities

1. State the one job this agent exists to do.
2. List the steps it follows to do that job.
3. State what it returns to the main agent when it's done.

## Out of scope

- Anything outside this agent's one job — keep a subagent narrow rather than
  a second general-purpose agent.
