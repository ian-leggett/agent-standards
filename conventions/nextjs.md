# Next.js

Assumes `conventions/react.md` and `conventions/typescript.md` also apply — this file covers
App Router-specific rules (Next.js 15/16, `cacheComponents`/PPR era). Pages Router is legacy;
don't add new routes under `pages/` unless the repo hasn't migrated yet.

## Server vs Client Components
- Components are Server Components by default. Add `'use client'` only at the boundary where
  you actually need state, effect hooks, event handlers, or a browser-only API (`localStorage`,
  `window`, `Navigator.geolocation`).
- Push `'use client'` as far down the tree as possible — wrap the interactive leaf, not the page.
  A page can be a Server Component that renders static Server Component children plus one small
  Client Component island.
- Presentational/data split still holds: Server Components fetch data and pass plain, serializable
  props down; don't pass functions or class instances from server to client.
- Never fetch data in a `useEffect` inside a Client Component when a Server Component parent could
  fetch it and pass it as a prop instead.

## Routing & file conventions
- Route structure is filesystem-driven — `page.tsx` is the only file that makes a segment
  routable. `layout.tsx`, `template.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`,
  `forbidden.tsx`, `unauthorized.tsx`, and `route.ts` are all auto-discovered by name; nothing
  imports them.
- Use route groups (`(marketing)`) to organize without affecting the URL, not for arbitrary
  folder tidiness.
- Every route segment that can fail or 404 gets its own `error.tsx`/`not-found.tsx` — don't rely
  on a single global fallback for a route that has meaningfully different failure states.
- `loading.tsx` + `<Suspense>` boundaries around slow child fetches, not a single top-level
  spinner that blocks the whole page.
- Route Handlers (`route.ts`) are for things a page can't be — webhooks, non-HTML responses,
  third-party callbacks. Don't build a JSON API in `route.ts` for data your own Server Components
  could fetch directly.

## Data fetching & caching
- Default `fetch()` caching is `force-cache` (static). Use `cache: 'no-store'` for genuinely
  per-request data, and `next: { revalidate: <seconds> }` for time-based ISR — pick deliberately,
  don't leave the default un-examined for data that actually changes per request.
- For non-`fetch` data sources (ORM/DB calls), wrap the function with the `'use cache'` directive
  plus `cacheLife()`/`cacheTag()` rather than hand-rolling memoization.
- Invalidate with `revalidatePath()`/`revalidateTag()` from the Server Action or route that
  performed the mutation — don't rely on time-based revalidation alone for user-triggered writes.
- `generateStaticParams` can return a partial path list; the rest render on first request and get
  cached. Use this for large but long-tail static datasets instead of forcing full SSG or full SSR.
- Partial Prerendering (`cacheComponents: true` in `next.config.js`) lets a route serve a static
  shell instantly while dynamic pieces stream in behind `<Suspense>`. Reach for it before reaching
  for a fully dynamic route just because one section needs live data.

## Server Actions & mutations
- Every Server Action re-checks auth/authorization inside the action itself — a Server Action is
  a public HTTP endpoint (reachable by direct POST) regardless of whether any client code imports
  it. Never assume "it's not linked from the UI" is access control.
- Keep database/ORM access behind a `server-only` data-access module, not inlined in the action.
  Import `server-only` in that module so an accidental client import fails the build instead of
  leaking a DB client to the browser.
- A Server Action defined inside a component closes over outer-scope variables (e.g. a version
  snapshot at render time) — that's intentional and encrypted in transit, but don't rely on it as
  an authorization check; re-verify state server-side inside the action.
- Rate-limit expensive Server Actions the same way you would a public API route.

## Data security
- Don't pass secrets or full DB rows to Client Components — select only the public fields a
  Server Component needs before handing props to a `'use client'` child.
- Use `experimental_taintUniqueValue` (or `taintObjectReference`) on sensitive values (API keys,
  tokens) coming out of a data layer so React throws if they're ever passed toward the client,
  instead of relying on developers remembering to strip them.
- Only `NEXT_PUBLIC_`-prefixed env vars are safe to reference from client code — everything else
  is server-only by convention; a non-prefixed var used in a Client Component is a bug, not a
  style choice. `.env*` files stay in `.gitignore`.

## Rendering & performance
- Prefer `next/image` over a bare `<img>` for any content image — it needs `width`/`height`/`alt`
  and gets automatic optimization and layout-shift prevention for free.
- Use `next/font` (Google or local) instead of a `<link>` to a font CDN — it self-hosts and
  eliminates the layout-shift/flash that external font loading causes.
- Define page metadata via the exported `metadata` object or `generateMetadata()`, not manual
  `<head>`/`next/head` tags in the App Router.
- Don't add `useMemo`/`useCallback` to Server Components — memoization is a Client Component,
  re-render concept and does nothing on the server.

## Testing
- Server Components that are `async` functions can be tested by calling and awaiting them
  directly and asserting on the returned tree, or via integration tests hitting the rendered
  route — don't force a Server Component through a client-only testing shim.
- Test Server Actions as plain async functions: call with the expected `FormData`/args and assert
  on the mutation + return value; mock the data-access layer, not the framework.
