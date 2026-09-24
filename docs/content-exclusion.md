# Content exclusion: keeping files away from the agent

Some files should never reach an AI tool's context: secrets, credentials,
customer data, generated output, vendored code. Both GitHub Copilot and Claude
Code can block paths, but they work very differently, and neither is a
complete guarantee. This page covers how each mechanism works, where it stops
working, and how to combine them.

The short version:

- **Copilot** has a dedicated feature, *content exclusion*, configured in
  GitHub's settings UI (not in the repo) and enforced by the service.
- **Claude Code** has no ignore file. You block paths with `permissions.deny`
  rules in settings, and get stronger enforcement from the sandbox.
- **Neither replaces not committing secrets.** Treat exclusion as
  defence in depth.

## GitHub Copilot: content exclusion

Content exclusion is available on Copilot Business and Copilot Enterprise. It
is not a file in your repository, so it can't be reviewed in a pull request or
cloned with the template.

### What it does

For an excluded file, Copilot:

- doesn't use its contents as context for suggestions, chat answers or code
  review, in any file
- doesn't offer inline completions inside it

### Where to configure it

| Level | Who can set it | Where | Applies to |
|-------|----------------|-------|------------|
| Repository | Repository admins | Repo **Settings → Copilot → Content exclusion** | That repository |
| Organization | Organization owners | Org **Settings → Copilot → Content exclusion** | Repos in the org, plus any path patterns |
| Enterprise | Enterprise owners | Enterprise **Policies → Copilot → Content exclusion** | Every seat in the enterprise |

Rules stack. Higher-level rules can't be turned off by a lower level.

### Syntax

Rules are YAML. Patterns use fnmatch-style globs and comments start with `#`.

Repository level is a plain list of paths:

```yaml
# .env-style files and key material
- "/.env*"
- "*.pem"
- "*.key"
- "/secrets/**"
# Any file named secrets.yml anywhere
- "**/secrets.y*ml"
```

Organization and enterprise level are keyed by repository (or `"*"` for all
repositories), then a list of paths:

```yaml
"*":
  - "**/.env*"
  - "*.pem"
  - "*.key"
octo-org/payments-service:
  - "/fixtures/customers/**"
  - "/config/production/**"
```

A leading `/` anchors the pattern to the repository root. Without it the
pattern matches at any depth.

### Limitations

Check the current docs for the up-to-date list. At the time of writing:

- **Not every Copilot surface honours it.** Agent mode in Copilot Chat in IDEs,
  Copilot CLI and the Copilot cloud agent aren't covered. Content exclusion is
  therefore not enough on its own if your team uses them.
- **It can lag.** Changes can take up to around 30 minutes to reach clients,
  and IDEs may need a reload.
- **Semantic leakage.** Copilot may still see information derived from an
  excluded file, such as type information or symbol names surfaced by the IDE's
  language server.
- **Plans.** It isn't available on Copilot Free, Pro or Pro+.

## Claude Code: `permissions.deny`

Claude Code has no `.claudeignore`. The equivalent is a set of deny rules in
settings. This repo ships a starter list in
[`.claude/settings.json`](../.claude/settings.json):

```json
{
  "permissions": {
    "deny": [
      "Read(**/.env)",
      "Read(**/.env.*.local)",
      "Read(**/id_rsa)",
      "Read(**/.ssh/**)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Read(**/secrets.yaml)"
    ]
  }
}
```

Deny rules take precedence over allow and ask rules. Rules use gitignore-style
path patterns, so `**/` matches at any depth.

### Where to configure it

| Scope | File | Notes |
|-------|------|-------|
| Managed | `managed-settings.json` / MDM / admin console | Highest precedence. Users can't override it. Use for org-wide secret patterns. |
| Project | `.claude/settings.json` | Checked in and shared with the team. |
| Project (local) | `.claude/settings.local.json` | Personal, gitignored. |
| User | `~/.claude/settings.json` | Applies to every project on your machine. |

Deny rules from different scopes are merged, so a project can add to a
managed list but not remove from it. See [Config hierarchy](./config-hierarchy.md).

### Limitations

- **Bash coverage is partial.** `Read` deny rules apply to Claude's built-in
  file tools, to the file commands Claude Code recognises in Bash (`cat`,
  `head`, `tail`, `sed`, `tee`), and to redirect targets such as `< .env`. They
  don't apply to a command that reads files without naming them, such as
  `grep -r pattern .` run from the directory that holds the file. Close that
  gap with the sandbox (below).
- **Search tools are best-effort.** Grep and Glob honour Read deny rules on a
  best-effort basis. Test that a denied file's contents don't appear in search
  results.
- **Patterns are literal.** A file called `.env.prod` isn't covered by
  `Read(**/.env)`. List the variants you use, or use a wildcard.
- **It only guards this tool.** Deny rules don't stop a process Claude starts
  (a test runner, a build script) from reading the file itself.
- **`claudeMdExcludes` is not content exclusion.** It only stops other teams'
  `CLAUDE.md` files loading as instructions.
- **`respectGitignore` is not content exclusion either.** It affects the
  `@` file picker, not what Claude can read.

### Stronger enforcement: the sandbox

Claude Code's sandbox restricts what Bash commands and their child processes
can read at the OS level. Configure filesystem read denials in the sandbox
settings so the block applies to `cat`, `grep`, scripts and anything else run
from Bash. Use it together with `permissions.deny`, not instead of it.

## Side by side

| | Copilot content exclusion | Claude Code `permissions.deny` |
|---|---|---|
| Configured in | GitHub settings UI (YAML) | `settings.json` (JSON) |
| Lives in the repo | No | Yes (project scope) |
| Reviewed via pull request | No | Yes |
| Enforced by | GitHub service | Claude Code client |
| Org/enterprise policy | Yes, native | Yes, via managed settings |
| Pattern syntax | fnmatch | gitignore-style, per tool (`Read(...)`) |
| Blocks shell access | n/a | Recognised file commands only; full coverage needs the sandbox |
| Known gaps | Agent mode in IDEs, CLI, cloud agent | Scripts and unnamed-file reads (`grep -r .`) without sandbox |
| Plans | Business, Enterprise | All |

## Recommended setup

1. **Keep secrets out of the repo.** `.env*` stays in `.gitignore`, and only
   `.env.example` is committed. See [Security](../conventions/security.md#secrets--credentials).
2. **Copilot:** set organization-level content exclusion for universal secret
   patterns, and repository-level rules for repo-specific paths (fixtures,
   production config, customer data).
3. **Claude Code:** commit project deny rules in `.claude/settings.json`, and
   push the universal list through managed settings.
4. **Enable the Claude Code sandbox** for anything that handles real
   credentials.
5. **Keep the non-negotiable in `AGENTS.md`.** The
   [root instructions](../AGENTS.md) already tell agents never to open secret
   files. That is a convention the model follows, not enforcement, but it
   covers the surfaces the technical controls miss.
6. **Keep the two lists in sync.** There is no shared format, so when you add
   a pattern to one tool, add it to the other.
7. **Test it.** Ask each tool to read a dummy excluded file (with fake
   contents) and confirm it can't. Re-test after changing tools or versions.

## Further reading

- [GitHub Docs: Excluding content from GitHub Copilot](https://docs.github.com/en/copilot/how-tos/configure-content-exclusion/exclude-content-from-copilot)
- [GitHub Docs: Content exclusion limitations](https://docs.github.com/en/copilot/concepts/context/content-exclusion)
- [Claude Code: Permissions](https://code.claude.com/docs/en/permissions)
- [Claude Code: Sandboxing](https://code.claude.com/docs/en/sandboxing)
- [Claude Code: Settings](https://code.claude.com/docs/en/settings)
