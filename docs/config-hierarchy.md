# 🏛️ Config hierarchy: enterprise, org, project, and local

Both Claude Code and GitHub Copilot let instructions and settings live at
more than one scope — but the two tools don't split those scopes the same
way, and mixing up which knob lives where is a common source of "why isn't
my instruction taking effect" confusion. This page maps each tool's actual
hierarchy and what belongs at each level.

## GitHub Copilot

| Level | Set where | Holds | Format |
|-------|-----------|-------|--------|
| **Enterprise** | GitHub Enterprise admin console | Policy toggles — enable/disable Copilot features or models org-wide | Admin UI, not freeform text |
| **Organization** | Org settings → Copilot → Custom instructions (Business/Enterprise plans only) | Freeform org-wide guidance (house style, security requirements) | Plain text, any format |
| **Repository / project** | `.github/copilot-instructions.md`, plus path-scoped `.github/instructions/*.instructions.md` (`applyTo:` glob frontmatter) | Project-specific coding standards, checked into the repo | Markdown |
| **Personal** | Individual's Copilot settings on GitHub.com | Per-user preferences (tone, preferred language) | Plain text, not checked in |

Enterprise governs *whether a feature is available at all*; it doesn't
carry instruction content. Organization custom instructions are currently
scoped to Copilot Chat, code review, and the cloud agent **on GitHub.com**
— they don't yet reach IDE integrations. Repository and personal
instructions do reach the IDE. When more than one level applies, Copilot
combines them rather than letting one silently win, though the docs note
personal takes precedence over repository, which takes precedence over
organization if they genuinely conflict.

## Claude Code

| Level | Set where | Holds |
|-------|-----------|-------|
| **Managed / enterprise** | `managed-settings.json`, MDM/OS policy, or server-managed settings pushed from the claude.ai admin console | JSON settings only — permissions, hooks, allowed models, env vars. **Not** freeform instruction text. |
| **Project (shared)** | `.claude/settings.json` for settings, `CLAUDE.md`/`AGENTS.md` at repo root for instructions | Team-shared, checked into version control — this is where this repo's own `AGENTS.md` and `conventions/*.md` live |
| **Project (local)** | `.claude/settings.local.json` | Personal, per-project overrides — gitignored, not shared with the team |
| **User (global)** | `~/.claude/settings.json` for settings, `~/.claude/CLAUDE.md` for instructions | Applies across every project on your machine |

Official precedence, highest to lowest: **managed settings → CLI flags
(`--settings`) → project local → shared project → user**. A managed value
generally can't be overridden by anything lower, with a short list of
security-sensitive exceptions where Claude Code honors whichever value is
*stricter*, regardless of level.

**There's no native "organization" instructions tier.** Managed settings
are JSON policy (what's allowed/denied), not a place to write standing
prose instructions the way Copilot's organization custom instructions are.
If you want org-wide guidance for Claude Code, you distribute it by
convention instead — e.g. sync a shared snippet into every repo's
`AGENTS.md`, or provision `~/.claude/CLAUDE.md` onto every machine via
device management.

## Side by side

| Concept | Copilot | Claude Code |
|---------|---------|--------------|
| Hard policy (feature/model allow-deny) | Enterprise admin console | Managed settings (`managed-settings.json` / MDM / admin console) |
| Org-wide standing instructions | Organization custom instructions (native, freeform) | No native tier — distribute by convention (shared `AGENTS.md` snippet, provisioned `~/.claude/CLAUDE.md`) |
| Project conventions | `.github/copilot-instructions.md` + `.github/instructions/*.instructions.md` | `AGENTS.md` / `CLAUDE.md` + `.claude/settings.json` |
| Personal overrides | Personal Copilot settings (GitHub.com) | `~/.claude/settings.json`, `~/.claude/CLAUDE.md` |
| Personal, per-project overrides | — (no equivalent) | `.claude/settings.local.json` |

## What to put where

- **Hard rules that must never be bypassed** (blocked commands, model
  allowlists, compliance requirements) belong at the highest available
  tier — Enterprise policy for Copilot, managed settings for Claude Code.
  Don't rely on a project `AGENTS.md` non-negotiable to enforce something
  that actually needs to be unbypassable; a project file is a strong
  convention, not an enforcement mechanism.
- **Org-wide culture and style** (house coding style, universal security
  requirements) fits Copilot's organization instructions natively. For
  Claude Code, treat this the same way this repo treats language
  conventions — write it once somewhere shared and pull it in, rather than
  duplicating it per repo.
- **Project conventions** — the bulk of what this repo covers — belong at
  the project tier for both tools: `AGENTS.md`/`conventions/*.md`, mirrored
  into `.github/copilot-instructions.md` and `CLAUDE.md`. See
  [Folder structure: .claude/ vs .github/](./folder-structure.md) and
  [What is an AGENTS.md file?](./agents-md.md).
- **Personal preferences** (verbosity, individual workflow habits) belong
  in the local/personal tier only — `.claude/settings.local.json` or
  Copilot's personal instructions — never checked in, never imposed on
  teammates.

This repo itself only operates at the project tier — it's a template for
what a single repository's `AGENTS.md`/`.claude`/`.github` setup should
look like. Enterprise and organization tiers are configured outside any
one repo (GitHub org settings, MDM, or the claude.ai admin console), so
they're out of scope for a checked-in template, but worth knowing about
when deciding whether a rule belongs here or one level up.

## Further reading

- [GitHub Docs — Adding organization custom instructions for Copilot](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-organization-instructions)
- [GitHub Docs — Adding repository custom instructions for Copilot](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions)
- [Claude Code — Settings precedence](https://code.claude.com/docs/en/settings)
- [Claude Code — Managed settings (deployment, delivery mechanisms)](https://code.claude.com/docs/en/managed-settings)
