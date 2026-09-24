# Write Tests Skill — Example

This is an example skill file for writing tests. It applies the rules in this repo's `conventions/testing.md` and the matching language file, and links to them rather than restating them. Copy the folder into your repository as `.claude/skills/write-tests/SKILL.md` (Claude Code) or `.github/skills/write-tests/SKILL.md` (GitHub Copilot). The format is identical on both tools.

## Example file contents

The content below goes into your `SKILL.md` file:

```markdown
---
name: write-tests
description: Writes or updates tests for changed code. Use when adding a feature, fixing a bug, or when asked to add test coverage.
---

# Write tests

## Purpose

Produce focused tests for changed behaviour that follow this repo's testing
conventions and fail when the behaviour is broken.

## Steps

1. Find the change: run `git diff main...HEAD` and `git status`. List the
   behaviours that were added or changed.
2. Read `conventions/testing.md`, then the convention file for the language and
   framework under test.
3. Find the nearest existing tests and copy their runner, layout, naming and
   fixtures. Don't introduce a new pattern.
4. For a bug fix, write the reproducing test first and confirm it fails for the
   right reason.
5. Write one test per behaviour, covering the happy path and the unhappy paths:
   empty, boundary, invalid and unauthorised inputs.
6. Run only the new tests. Then break the code temporarily to confirm each new
   test fails, and restore it.
7. Return the list of tests added, the behaviour each covers, and any gap you
   chose not to cover.

## Rules

- Test behaviour through the public interface, not internals.
- Assert specific values, not just that something exists or is truthy.
- Hardcode expected values. No logic or loops in a test body.
- Mock only at the boundary (network, filesystem, clock).
- Use obviously fake data. Never copy production data or real credentials.
- Never skip, disable or delete an existing test to get a build through.

## References

- `conventions/testing.md`
- `conventions/security.md` (negative-path tests)
- The convention file(s) for the language and framework under test

## Out of scope

- Changing production code to make it testable without asking first.
- Running the full test suite or CI.
- Chasing a coverage percentage.
```
