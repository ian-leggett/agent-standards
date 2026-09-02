---
description: Python conventions for this org — style, typing, structure, errors, testing, deps.
---

# Python

## Tooling
- Formatter/linter: `ruff` (format + check). Don't hand-format; run `ruff format` before committing.
- Type checker: `mypy --strict` on new code. Existing untyped modules get `# type: ignore` sparingly, not blanket ignores.
- Dependency manager: `uv`. Don't use bare `pip install` in a repo that has a `uv.lock`.
- Python version: match `.python-version` / `pyproject.toml` `requires-python` exactly — don't assume latest.

## Style
- Follow PEP 8 via ruff defaults; don't argue with the formatter, don't hand-tune spacing.
- Type-hint all new function signatures, including return types. `Any` requires a comment saying why.
- Prefer `dataclasses` or `pydantic` models over untyped dicts for anything crossing a function boundary.
- f-strings only — no `%` or `.format()` in new code.
- No mutable default arguments (`def f(x=[])`). Use `None` + assign inside.

## Structure
- Business logic does not import from `web`/`api`/`cli` layers — dependencies point inward.
- One module = one responsibility. If a file needs a table of contents comment, split it.
- `__init__.py` re-exports the public surface only; nothing does real work in `__init__.py`.

## Errors
- Never bare `except:`. Catch specific exceptions.
- Raise custom exception classes for domain errors, not `ValueError`/`Exception` for anything a caller needs to branch on.
- Don't swallow exceptions silently — log with context or re-raise.

## Testing
- `pytest`, not `unittest`, for new tests.
- Test file mirrors source path: `src/foo/bar.py` → `tests/foo/test_bar.py`.
- One assertion concept per test; name tests for the behavior, not the method (`test_returns_empty_list_when_no_matches`, not `test_search_2`).
- Mock at the boundary (network, filesystem, clock) — don't mock your own business logic.
