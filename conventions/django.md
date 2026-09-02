---
description: Django conventions for this org — models, views, migrations, admin, security.
---

# Django

Assumes `conventions/python.md` also applies — this file only covers Django-specific rules.

## Apps & structure
- One app per bounded domain concept, not one giant `core` app. If you're not sure it deserves its own app, it probably belongs in an existing one — don't create speculative apps.
- Business logic lives in `services.py` or a `domain/` module, not in views or model methods that do I/O.
- Views stay thin: parse request → call service → shape response. No queryset construction inline in a view if it's reused anywhere else — put it on a model manager.

## Models
- Every model gets an explicit `Meta.ordering` unless order truly doesn't matter — undefined ordering causes flaky tests and pagination bugs.
- `related_name` is explicit on every ForeignKey/ManyToMany — never rely on the default.
- Prefer `TextChoices`/`IntegerChoices` over bare string/int constants for enumerated fields.
- No business logic in `save()` overrides beyond simple field derivation — use signals sparingly, services preferentially.

## Migrations
- One logical change per migration. Don't squash unrelated model changes into one migration file.
- Data migrations are separate from schema migrations, and are reversible (`RunPython` with a real `reverse_code`, not `migrations.RunPython.noop` unless truly irreversible).
- Never edit a migration that's already been merged to main and might be applied elsewhere — write a new one.
- Run `manage.py makemigrations --check --dry-run` before considering model changes done; an uncommitted migration is a broken PR.

## Admin
- Register a `ModelAdmin` with explicit `list_display`, `list_filter`, and `search_fields` for anything a human will actually browse — the bare `admin.site.register(Model)` is a debugging tool, not a deliverable.
- Never expose write access to PII-bearing fields in admin without checking with the team.

## Security / correctness
- All user input goes through a `Form` or DRF `Serializer` — no manual `request.POST.get()` parsing that skips validation.
- Raw SQL / `.extra()` requires a comment justifying why the ORM couldn't express it, and confirmation it's parameterized.
- New endpoints default to authenticated + permission-checked; anonymous access is an explicit, reviewed decision, not a default.
- N+1 queries: use `select_related`/`prefetch_related` for anything iterating a relation in a loop, especially in serializers and templates.

## Testing
- `pytest-django` + factory objects (`factory_boy`), not fixtures full of hand-built model instances.
- Test migrations that alter data, not just schema, with a real before/after assertion.
