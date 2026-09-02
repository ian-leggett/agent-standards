---
description: TypeScript conventions for this org — types, style, structure, errors, testing.
---

# TypeScript

## Tooling
- `tsconfig.json` `strict: true` — don't loosen it to make an error go away; fix the type.
- Formatter/linter: `eslint` + `prettier` (or `biome` if the repo uses it — check `package.json` first). Run before considering work done.
- Package manager: whatever the repo's lockfile says (`pnpm-lock.yaml` → pnpm, etc.) — never mix lockfiles.

## Types
- No `any` in new code. `unknown` + narrowing, or a real type. If you truly can't type something, `// eslint-disable-next-line` with a comment saying why, not a silent `any`.
- Prefer `type` for unions/intersections/utility types, `interface` for object shapes that might be extended. Don't fight over which for everything else — match the surrounding file.
- Discriminated unions over optional-field soup for anything with real variants (`{status: 'loading'} | {status: 'error', message: string} | {status: 'ok', data: T}`, not five optional fields on one type).
- Exported function signatures are fully typed (params + return) even when inference would work — the signature is the contract, don't make callers infer it from the implementation.

## Structure
- No default exports for anything except framework-mandated files (Next.js pages, etc.) — named exports are greppable and refactor-safe.
- Colocate a module's types with the module unless they're shared across ≥3 files, then move to a `types.ts` at the nearest common ancestor.
- No circular imports — if two modules need each other, extract the shared piece.

## Errors & async
- Never `catch (e) {}` silently. Log or rethrow with context.
- All `Promise`s are awaited or explicitly `.catch()`'d — no floating promises (enable `no-floating-promises` if not already on).
- Prefer `Result`-style returns or thrown typed errors for expected failure paths over `null`/`undefined` that callers must remember to check.

## Testing
- Vitest or Jest (match what's already in the repo). Test behavior through the public API of a module, not internals.
- Type tests (`expectTypeOf` / `tsd`) for anything whose whole job is its type signature (generic utility types, overloads).
