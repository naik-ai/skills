# React Doctor Rules Reference

## rerender-memo-with-default-value
**Category**: Performance
**Why it matters**: `function Foo({ items = [] })` creates a new array on every render, breaking `React.memo`, `useMemo`, and `useCallback` comparisons.
**Fix**: Extract to a module-level constant.

## no-array-index-as-key
**Category**: Correctness
**Why it matters**: Index keys break reconciliation when lists are reordered or filtered — React reuses the wrong DOM nodes, causing visual glitches and state bugs.
**Fix**: Use a stable unique identifier from the data.

## nextjs-no-img-element
**Category**: Next.js / Performance
**Why it matters**: Native `<img>` skips Next.js automatic WebP/AVIF conversion, lazy loading, responsive srcset, and CLS prevention.
**Fix**: `import Image from 'next/image'` with explicit `width`/`height` or `fill`.

## nextjs-missing-metadata
**Category**: Next.js / SEO
**Why it matters**: Pages without metadata get generic or empty `<title>` and `<meta description>`, hurting SEO and social sharing.
**Fix**: Export `metadata` or `generateMetadata()` from the page. Cannot be used in `'use client'` files.

## no-effect-event-handler
**Category**: State & Effects
**Why it matters**: `useEffect` that runs only when a boolean flips is almost always a disguised event handler — it runs at the wrong time, fires on remount, and is hard to reason about.
**Fix**: Move the conditional logic into the event handler that triggers the state change.

## nextjs-no-client-side-redirect
**Category**: Next.js / Performance
**Why it matters**: `router.push()` in `useEffect` causes a flash of the protected page before redirect. Server-side redirect is instant.
**Fix**: Use `redirect()` from `next/navigation` in a Server Component, or handle in middleware.

## no-giant-component
**Category**: Architecture
**Why it matters**: Components over ~300 lines are hard to test, hard to reason about, and resist code splitting.
**Fix**: Extract logical sections into focused sub-components. This requires human judgment — the rule flags, but auto-fix is not safe.
