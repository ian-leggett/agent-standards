# JavaScript

For projects without TypeScript. If the repo has a `tsconfig.json`, use
`conventions/typescript.md` instead — don't hand-roll type discipline in JS
when the compiler is already available.

## Tooling
- Formatter/linter: `eslint` + `prettier` (or `biome` if the repo uses it — check
  `package.json` first). Run before considering work done.
- Package manager: whatever the repo's lockfile says (`pnpm-lock.yaml` → pnpm,
  `package-lock.json` → npm, `yarn.lock` → yarn) — never mix lockfiles.
- Enable `"type": "module"` (ESM) for new projects unless the repo is already
  committed to CommonJS — don't introduce a second module system into an
  existing CJS codebase.
- Turn on `eslint-plugin-jsdoc` + `checkJs` (via `// @ts-check` at the top of a
  file or `jsconfig.json`) on files where correctness matters — it catches
  whole classes of bugs a linter alone can't, without requiring a TS migration.

## Types (without a type checker)
- JSDoc on every exported function: `@param`/`@returns` with concrete types
  (`{string}`, `{number[]}`, `{Promise<User>}`), not just prose. This is the
  contract callers read — treat it as seriously as a TS signature.
- Don't invent ad-hoc "duck typed" objects for anything crossing a module
  boundary — define the expected shape in a JSDoc `@typedef` and reference it.
- No implicit `undefined` in object shapes — if a field is optional, say so in
  the `@typedef` (`{string} [name]`) rather than leaving callers to guess.

## Style
- `const` by default, `let` when reassignment is real, never `var`.
- `===`/`!==` always — no `==`/`!=` (the only exception is `x == null` to check
  both `null` and `undefined` in one branch, and even then prefer being explicit).
- Arrow functions for callbacks and anything without its own `this`; `function`
  declarations for top-level named functions (better stack traces, hoisting is
  visible in intent, not relied on).
- Template literals over string concatenation. No `%s`-style formatting.
- Destructure function parameters for anything with more than ~2 named inputs
  instead of an untyped options blob the reader has to trace to its call sites.
- No mutable default arguments (`function f(x = [])` creates one shared array
  under some transpile targets — verify, or just default to `null` and assign
  inside).

## Modules & structure
- One module = one responsibility. Named exports only — no default exports,
  they're harder to grep and rename-refactor safely.
- No circular imports — if two modules need each other, extract the shared piece.
- Business logic doesn't import from `web`/`api`/`cli` entry-point layers —
  dependencies point inward, entry points wire things together.
- Colocate a module's JSDoc `@typedef`s with the module unless they're shared
  across ≥3 files, then move to a `types.js` at the nearest common ancestor.

## Async & errors
- `async`/`await` over raw `.then()` chains — reserve `.then()` for genuinely
  fire-and-forget cases, and even then prefer an explicit `void` + `.catch()`.
- Every `Promise` is awaited or explicitly `.catch()`'d — no floating promises.
  If the repo's ESLint config supports it, turn on a floating-promises rule
  (`eslint-plugin-promise` or the `no-floating-promises`-equivalent check).
- Never bare `catch {}` — log with context or rethrow. Catch specific error
  types/conditions where the runtime allows it; don't swallow everything with
  one blanket handler.
- Raise/reject with `Error` subclasses for domain errors a caller needs to
  branch on, not a bare string or a generic `Error` with no discriminating field.

## Equality & coercion
- Never rely on implicit coercion (`if (someArray)`, `+someString`) — check the
  actual condition (`someArray.length > 0`, `Number(someString)`).
- `Array.isArray()` to check for arrays, never `typeof`.
- `Number.isNaN`/`Number.isFinite`, not the global `isNaN`/`isFinite` — the
  global versions coerce first and produce surprising results on non-numbers.

## Testing
- Vitest or Jest (match what's already in the repo). Test behavior through the
  public API of a module, not internals.
- Test file mirrors source path: `src/foo/bar.js` → `tests/foo/bar.test.js`.
- One assertion concept per test; name tests for the behavior, not the method
  (`test('returns empty array when no matches')`, not `test('search 2')`).
- Mock at the boundary (network, filesystem, clock) — don't mock your own
  business logic.
