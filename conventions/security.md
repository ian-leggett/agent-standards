# Security (example)

## How this file is activated

Each tool has its own activation file that points to these rules:

- **GitHub Copilot**: [`.github/instructions/security.instructions.md`](../.github/instructions/security.instructions.md)
- **Claude**: [`.claude/rules/security.md`](../.claude/rules/security.md)

```markdown
# Security

Baseline is the OWASP Top 10 and OWASP ASVS Level 2. Language- and framework-specific
security rules (Django, DRF, Next.js) live in their own files — this file covers the
cross-cutting rules that apply everywhere. A violation is a blocking review comment,
not a style nit.

## Secrets & credentials
- Never hardcode secrets (API keys, tokens, passwords, private keys, connection strings) in
  source, tests, fixtures, docs, or example configs. Read them from the environment or the
  project's secrets manager.
- `.env*` files, key files, and credential files stay in `.gitignore`. Commit a
  `.env.example` with placeholder values only.
- A secret that has been committed is compromised, even if the commit is later removed —
  rotate it and tell the security team. Don't just rewrite history.
- Never log, print, or include secrets in error messages, stack traces, or URLs (query strings
  end up in access logs and browser history).

## Input handling
- Treat all input as untrusted: request bodies, query params, headers, cookies, uploaded files,
  webhook payloads, data from other services, and anything read back from the database that a
  user originally wrote.
- Validate against an allow-list of expected shape, type, length, and range at the boundary,
  using the framework's schema/form/serializer layer — not ad-hoc checks scattered through
  business logic.
- Validate on the server. Client-side validation is UX, not a security control.
- Reject invalid input rather than trying to sanitise it into something valid.

## Injection
- Parameterised queries only. Never build SQL, shell commands, LDAP filters, or NoSQL queries
  by string concatenation or f-string interpolation with user input.
- Don't shell out with user-influenced arguments. If unavoidable, pass an argument list
  (no `shell=True` / `exec` of a string), and allow-list the values.
- Never `eval`, `exec`, `pickle.loads`, `yaml.load` (use `safe_load`), or deserialise
  untrusted data with a format that can construct arbitrary objects.
- Output-encode for the context it's rendered in (HTML, attribute, JS, URL, CSS). Rely on
  the template engine's auto-escaping; bypassing it (`|safe`, `mark_safe`,
  `dangerouslySetInnerHTML`, `innerHTML`) needs a comment explaining why the content is
  trusted, and sanitisation with a maintained library.

## Authentication & sessions
- Don't roll your own auth, session handling, password hashing, or crypto — use the project's
  SSO/identity integration and the framework's built-ins.
- Passwords (where unavoidable) are hashed with Argon2id, bcrypt, or scrypt — never MD5, SHA-1,
  or unsalted/fast hashes.
- Session cookies are `HttpOnly`, `Secure`, and `SameSite=Lax` or stricter. Sessions expire, and
  are invalidated on logout and on privilege change.
- Tokens (JWTs, API keys) are short-lived, scoped, and verified server-side on every request
  (signature, expiry, audience, issuer). Never store them in `localStorage`.
- Rate-limit and lock out login, password-reset, and other credential-guessing endpoints.

## Authorization
- Deny by default. Every endpoint, action, and background job checks authorization
  server-side, even if no UI links to it.
- Check access to the specific object, not just that the user is logged in — a valid session is
  not permission to read `/orders/123`. Scope queries to the requesting user/tenant.
- Never trust client-supplied identifiers, roles, prices, or flags (`isAdmin`, `user_id` in a
  body) — derive them from the authenticated session.
- Authorization logic lives in one place (policy/permission layer), not copy-pasted per view.

## Data protection
- Collect and store the minimum personal data needed. Don't add PII fields "just in case".
- Never log PII (names, addresses, emails, phone numbers, NI numbers, bank details) or
  credentials. Log opaque identifiers instead.
- TLS for all traffic in transit, including service-to-service. Encrypt sensitive data at
  rest using the platform's managed encryption/KMS.
- API responses return only the fields the caller needs — don't serialise whole DB rows or
  internal error details.
- Error messages shown to users are generic; detail goes to the logs. Never expose stack
  traces, SQL, or internal paths in production responses.

## Files & paths
- Normalise and validate file paths; reject `..` traversal and absolute paths from user input.
  Resolve against a fixed base directory and confirm the result is still inside it.
- Uploads: check size, extension **and** content type, store outside the web root with generated
  filenames, and never execute or serve them inline from an untrusted origin.
- Outbound requests to user-supplied URLs (SSRF): allow-list hosts, block private/link-local/
  metadata address ranges, and don't follow redirects blindly.

## Web-specific
- CSRF protection on every state-changing request that uses cookie auth. State changes never
  happen on `GET`.
- Set security headers: `Content-Security-Policy`, `Strict-Transport-Security`,
  `X-Content-Type-Options: nosniff`, `Referrer-Policy`, and `frame-ancestors`/`X-Frame-Options`.
- CORS: allow-list specific origins. Never `*` with credentials, and never reflect the
  `Origin` header back unchecked.
- Redirect targets taken from user input (`?next=`) are validated against an allow-list to
  prevent open redirects.

## Dependencies & supply chain
- Add dependencies deliberately: maintained, widely used, appropriately licensed. Don't add a
  package for something the standard library or an existing dependency already does.
- Commit lockfiles and install from them (`uv sync --frozen`, `npm ci`). Never mix lockfiles.
- Don't pin to unverified forks, git branches, or typosquat-prone names. Check the exact
  package name before adding it.
- Address known-vulnerable dependencies flagged by the audit tooling (`pip-audit`,
  `npm audit`, Dependabot) — don't suppress an advisory without a comment and a ticket.
- CI actions and base images are pinned to a version or digest, not `latest`.

## Logging & monitoring
- Log security-relevant events (login success/failure, permission denials, privilege changes,
  input validation failures at boundaries) with who, what, when, and where — never with secrets
  or PII.
- Sanitise user input before logging to prevent log injection (strip newlines/control characters).
- Don't swallow security exceptions. A failed auth or authorisation check fails closed.

## Testing
- Test the negative path: at least one test per endpoint proving an unauthenticated,
  unauthorised, or wrong-tenant request is rejected.
- Add a regression test for every security bug fixed.
- Test that validation rejects malformed, oversized, and hostile input (injection strings, path
  traversal, unexpected types), not only that valid input passes.
- Never use real credentials or production data in tests — use fakes generated for the purpose.

## When in doubt
- If a task requires weakening a control (disabling CSRF or TLS verification, widening CORS,
  skipping an authorization check, catching-and-ignoring an auth error), stop and ask a human.
  Document any approved deviation in a code comment with the reason and the ticket.
- Report suspected vulnerabilities to the security team rather than fixing them silently in an
  unrelated change.
```
