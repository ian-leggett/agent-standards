---
description: React conventions for this org — components, state, hooks, performance, testing.
---

# React

Assumes `conventions/typescript.md` also applies — this file only covers React-specific rules.

## Components
- Function components only. No class components in new code.
- One component per file, file named after the component (`UserCard.tsx` exports `UserCard`).
- Props are a named `interface`/`type` above the component, not inlined in the function signature, once there are more than ~2 props.
- Presentational components don't fetch data — data fetching lives in a parent/container or a hook, passed down as props.

## State
- Local state (`useState`) for anything only this component tree cares about. Don't reach for global state by default.
- Server data goes through the project's data-fetching library (React Query / SWR / RSC — check what's already in the repo) — not manually managed in `useState` + `useEffect`.
- Derived values are computed during render, not synced into state with a `useEffect`. If you're writing `useEffect(() => setX(...), [y])`, it's almost always derivable inline or with `useMemo`.

## Hooks
- Obey the Rules of Hooks — no conditional/looped hook calls. `eslint-plugin-react-hooks` errors are not suppressible without team sign-off.
- Custom hooks start with `use`, do one thing, and are named for what they return, not what they do internally.
- `useEffect` dependency arrays are complete and honest — don't silence `exhaustive-deps` by omitting a dependency; restructure instead.

## Performance
- Don't reach for `useMemo`/`useCallback`/`React.memo` preemptively — add them when profiling shows a real re-render cost, not by default on every component.
- Keys on list items are stable and unique (a real id) — never array index unless the list is static and never reordered.

## Accessibility
- Interactive elements are real `<button>`/`<a>`, not `<div onClick>`. If a div must be clickable, it needs `role`, `tabIndex`, and a keyboard handler.
- Images have `alt`; form inputs have associated `<label>`s.

## Testing
- React Testing Library — test what the user sees/does (`getByRole`, `userEvent`), not implementation details (no querying by class name or testing internal state directly).
- Don't test that a hook was called — test the resulting behavior/output.
