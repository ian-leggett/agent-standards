# Testing (example)

## How this file is activated

Each tool has its own activation file that points to these rules:

- **GitHub Copilot**: [`.github/instructions/testing.instructions.md`](../.github/instructions/testing.instructions.md)
- **Claude**: [`.claude/rules/testing.md`](../.claude/rules/testing.md)

## Example file contents

The content below goes into your conventions file:

```markdown
# Testing

Language-agnostic practices. Runner, file layout, naming, mocking-at-the-boundary, and
framework-specific patterns live in the language and framework files
(`python.md`, `django.md`, `drf.md`, `javascript.md`, `typescript.md`, `react.md`,
`nextjs.md`) — follow those for the "how". Security-specific test cases are in
`security.md`. This file covers the "what" and "why".

## What to test
- Test observable behavior through the public interface — inputs in, outputs and side effects
  out. If a refactor that preserves behavior breaks a test, the test was coupled to
  implementation; fix the test.
- Cover the boundaries and the unhappy paths, not just the happy one: empty, zero, one, many,
  max, off-by-one, null/missing, invalid, duplicate, and concurrent cases.
- Don't test the framework, the language, or a third-party library — test your use of them.
- Don't write tests for trivial code with no logic (plain getters, pass-through wrappers).
  Effort goes where the risk is: business rules, state transitions, parsing, money, dates,
  permissions, and anything that has broken before.
- A bug fix starts with a test that reproduces the bug and fails for the right reason. Then fix.

## Test shape
- Structure each test as Arrange → Act → Assert, visually separated. One Act per test.
- Assert on outcomes that matter, and be specific: check the actual value, not
  `is not None` / `toBeTruthy()` / `status < 500`. A weak assertion passes when the code is wrong.
- No conditionals, loops, or computed expected values in a test body. If you need logic to
  produce the expected result, you're re-implementing the code under test. Hardcode the
  expected value.
- Parameterise tests that differ only by data instead of copy-pasting or looping.
- Keep tests readable on their own: the reader should see inputs and expected output without
  chasing helpers. Extract setup into builders/factories; keep the *interesting* values in the
  test itself.
- Snapshot tests only for small, stable, intentional output. Review every snapshot diff as if
  it were code; never blanket-update to make a failure go away.

## Independence & determinism
- Every test runs alone, in any order, and in parallel. No shared mutable state, no
  dependence on another test having run first, and each test cleans up what it creates.
- No real time, randomness, network, or environment dependence. Inject the clock and seed the
  RNG; fake or stub external systems.
- No `sleep`/fixed delays to wait for async work — wait on the condition (poll with a timeout,
  await the event, use fake timers).
- Don't depend on iteration order of unordered collections, locale, timezone, or
  the machine's filesystem layout. Set them explicitly.

## Test doubles
- Prefer real objects, then fakes (working in-memory implementations), then stubs
  (canned answers). Reach for mocks/spies that verify interactions last — they couple tests to
  how the code works, not what it does.
- Assert on interactions only when the interaction *is* the behavior (e.g. "an email is sent",
  "the payment API is called once with this payload").
- A fake or mock must not be more permissive than the real thing. Where a double stands in for
  an external service, back it with a contract test or recorded real responses so it can't
  silently drift.
- Never mock what you don't own without wrapping it in a thin adapter you do own.

## Levels & scope
- Aim for a pyramid: many fast unit tests, fewer integration tests across real component
  boundaries (DB, queue, HTTP layer), and a small number of end-to-end tests for critical user
  journeys only.
- Push each check to the lowest level that can catch the bug. Don't use an E2E test to verify
  something a unit test could.
- Integration tests use the real dependency where practical (real DB via a test container or
  transaction rollback) rather than a mock that hides schema/query bugs.
- E2E tests cover a few critical happy paths and are isolated from each other (own data,
  own login). They select elements the way a user would, not by CSS/DOM structure.

## Test data
- Each test creates the minimum data it needs, with explicit values for anything it asserts on.
  Don't rely on a large shared seed dataset that tests silently depend on.
- Use obviously fake, generated data. Never copy production data or use real PII/credentials
  in tests or fixtures.
- Make the relevant field visible: `make_user(is_suspended=True)` beats an opaque
  `suspended_user_fixture`.

## Speed & reliability
- The unit suite runs in seconds and the whole suite in minutes. Slow tests get profiled, not
  tolerated. Fast feedback is what makes people run tests.
- A flaky test is a bug: fix the root cause (usually shared state, time, or async waiting).
  Never fix it by adding retries or re-running CI until green.
- Don't skip, disable, or delete a failing test to get a build through. If a test is
  quarantined, it needs a ticket, an owner, and a date — and a comment linking them.
- A test that has never failed proves nothing. When writing a new test, confirm it fails when
  the behavior is broken (temporarily break the code, or write the test first).

## Coverage
- Coverage shows what is *untested*, not what is *well tested*. Use it to find gaps, not as a
  target to hit; assertion-free tests written to raise the number are worse than none.
- Changed and new code is covered by meaningful tests. Don't let coverage drop on a PR
  without a stated reason.
- Consider mutation testing or property-based testing (e.g. Hypothesis, fast-check) for
  logic-heavy code such as parsers, calculations, and serialisation round-trips.

## Maintenance
- Treat test code as production code: same review standard, no duplication that hides intent,
  no dead or commented-out tests.
- When behavior intentionally changes, update the tests in the same change. Don't leave
  stale tests that pass for the wrong reason.
- Tests are documentation. If a failure message doesn't tell the reader what broke and what was
  expected, improve the assertion.
```
