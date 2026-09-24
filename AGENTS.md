# Agent/Root Instructions — Example

This is an example `AGENTS.md` file — the root instructions that are always active for every Copilot/Claude interaction in your repository.

```markdown
# Project overview

<!-- Edit this section for your service -->

This is a [service name] for BIST, built with Django.

- **Language**: Python, JavaScript
- **Framework**: Django
- **Database**: PostgreSQL
- **Authentication**: [SSO, StaffSSO]

## Non-negotiables

- Never read, print, log, or transmit the contents of secrets — `.env*` files, private keys (`id_rsa`, `*.pem`, `*.key`), `.ssh/`, credentials files, `secrets.yml`/`secrets.yaml`, `.npmrc`, `.git-credentials`, or any other file whose purpose is to hold auth material. If a task genuinely seems to require it, stop and ask a human instead of opening the file.

## Code standards

- Python: `conventions/python.md`
- Django: `conventions/django.md`
- Django REST Framework: `conventions/drf.md`
- JavaScript: `conventions/javascript.md`
- TypeScript: `conventions/typescript.md`
- React: `conventions/react.md`
- Next.js: `conventions/nextjs.md`
- Accessibility: `conventions/accessibility.md`
- Testing: `conventions/testing.md`

## Branching and version control
- Git: `conventions/git.md`

## Security

- Rules: `conventions/security.md`

## How Copilot should respond

When generating or editing code for this project:

- Follow conventions already in the codebase — check existing patterns first
- Prefer modifying existing files over creating new ones when the change fits naturally
- Provide minimal diffs touching only the necessary files; do not refactor unrelated code
- Always include or update tests for changed behaviour
- Keep solutions DRY
- If a request conflicts with these instructions, or would use a discouraged library, skip tests, hardcode a secret, or break a quality gate — flag it explicitly and do not proceed silently
- If a standards violation cannot be avoided (e.g. integration constraint), document the deviation in a code comment and raise it for review

```


