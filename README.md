# 🤖 AI engineering Hub

A starter template for AI agent documentation. Use it as the seed for a new
project's `AGENTS.md`, coding standards, and configuration for Claude Code and
GitHub Copilot — clone it, trim it down to the stacks you actually use, and
start building.

It's built around **progressive disclosure**: every layer only enters an
agent's context when it's actually relevant, so a project's always-on
instructions stay small no matter how many stacks it ends up covering.

## 📚 Guides

### [Getting Started](docs/getting-started.md)

The main setup guide — explains GitHub Copilot's and Claude's configuration system and how to set up your repository with instructions, agents, skills, and hooks. Includes a quick start with the three essential files to get you running.

### [Instructions](docs/instructions.md)

Project-specific rules and standards that Copilot and Claude follow automatically.

- [Python](conventions/python.md) - tooling, typing, style, error handling and pytest practices
- [Django](conventions/django.md) - app structure, models, migrations, admin and query correctness
- [Django REST Framework](conventions/drf.md) - serializers, viewsets, permissions, pagination and API errors
- [JavaScript](conventions/javascript.md) - JSDoc typing, ESM modules, async handling and coercion rules for non-TypeScript projects
- [TypeScript](conventions/typescript.md) - strict typing, module structure and error handling
- [React](conventions/react.md) - components, state, hooks, performance and Testing Library practices
- [Next.js](conventions/nextjs.md) - App Router server/client components, caching, Server Actions and data security
- [Accessibility](conventions/accessibility.md) - WCAG 2.2 AA rules for semantics, keyboard, forms, colour, media and ARIA
- [Testing](conventions/testing.md) - language-agnostic guidance on what to test, test shape, doubles and coverage
- [Security](conventions/security.md) - OWASP-based rules for secrets, input, auth, data protection and dependencies
- [Git](conventions/git.md) - Conventional Commits, branch naming and pull request expectations

### [Agents](docs/agents.md)

Specialised AI personas you invoke in Copilot and Claude. Each agent has a defined role, expertise, and workflow.

- [Code reviewer agent](.claude/agents/code-reviewer.md) - systematic code review using BIST quality criteria
- [Accessibility advisor agent](.claude/agents/accessibility-advisor.md) - WCAG 2.2 AA checks for frontend changes

### [Skills](docs/skills.md)

Reusable procedures that load on demand when a task matches, following the open Agent Skills standard.

- [Write tests skill](.claude/skills/write-tests/SKILL.md) - writes tests that follow the testing conventions
- [PR description skill](.claude/skills/pr-description/SKILL.md) - drafts a PR title and description from the branch diff

### [Config hierarchy](docs/config-hierarchy.md)

How Claude Code and GitHub Copilot split instructions and settings across enterprise, organisation, project and local scopes, and what belongs at each level.

### [Context window](docs/context-window.md)

Why a smaller context window matters and how to keep an agent's working memory lean.

## How to use the examples

1. Browse the [Getting Started](docs/getting-started.md) guide to understand the configuration structure
2. Navigate to the example files that match your project's needs
3. Copy the raw markdown content into the matching directory in your repository
4. Edit the examples to fit your specific project context

## 🔗 Sources / further reading

- [AI Hero — A Complete Guide to AGENTS.md](https://www.aihero.dev/a-complete-guide-to-agents-md)
- [agents.md — the open AGENTS.md spec](https://agents.md/)
- [Claude Code: CLAUDE.md memory docs (imports, rules, path-scoping)](https://code.claude.com/docs/en/memory)
- [Ardalis — Optimizing AI Agents with Progressive Disclosure](https://ardalis.com/optimizing-ai-agents-with-progressive-disclosure/)
- [SwirlAI — Agent Skills: Progressive Disclosure as a System Design Pattern](https://www.newsletter.swirlai.com/p/agent-skills-progressive-disclosure)
- [Red Hat Developer — Standardize project context with AGENTS.md and Agent Skills](https://developers.redhat.com/articles/2026/07/27/standardize-project-context-agentsmd-and-agent-skills)
- [agentpatterns.ai — Architecting a Central Repo for Shared Agent Standards](https://agentpatterns.ai/workflows/central-repo-shared-agent-standards/)
- [aq.dev — Keep AGENTS.md and CLAUDE.md in Sync Across Agent CLIs](https://aq.dev/guides/keep-agents-md-and-claude-md-in-sync/)
