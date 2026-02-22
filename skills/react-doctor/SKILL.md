---
name: react-doctor
description: Scan a React/Next.js codebase for anti-patterns and fix them automatically. Use when user says "/react-doctor", "run react doctor", "fix react issues", "scan for react anti-patterns", "useEffect issues", or "react accessibility". Runs npx react-doctor@latest, reads the diagnostics JSON, fixes every warning in the affected files, then re-runs until the codebase passes (no warnings remaining). Handles: unnecessary useEffects used as event handlers, default prop values causing re-renders, array index as key, missing Next.js metadata, <img> instead of next/image, accessibility issues, and giant components.
---

# React Doctor Skill

Automated fix loop for React anti-patterns powered by `react-doctor`.

## Workflow

### Phase 1: Run Diagnostics

Run react-doctor and capture the diagnostics output path:

```bash
npx -y react-doctor@latest 2>&1
```

When react-doctor runs it prints a line like:
```
Full diagnostics written to /tmp/react-doctor-<uuid>
```

Capture that path. Then read `<path>/diagnostics.json` — it is an array of objects:

```json
[
  {
    "filePath": "src/components/Foo.tsx",
    "rule": "no-effect-event-handler",
    "severity": "warning",
    "message": "useEffect simulating an event handler...",
    "help": "Move the conditional logic into onClick...",
    "line": 42,
    "column": 3,
    "category": "State & Effects"
  }
]
```

Also read each `react-doctor--<rule>.txt` file in the same directory for the per-rule file+line list.

If there are **no warnings**, print the score and stop — the codebase is passing.

### Phase 2: Group and Prioritise

Group diagnostics by `filePath`. For each file, collect all warnings sorted by line number descending (fix from bottom to top so line numbers stay valid).

Skip warnings where the fix would require large architectural changes that are out of scope (e.g. `no-giant-component` when the component is > 500 lines — note it but don't attempt to split automatically unless specifically asked).

**Priority order** (fix easiest wins first):
1. `rerender-memo-with-default-value` — extract default value to module scope constant
2. `no-array-index-as-key` — replace `key={index}` with a stable id
3. `nextjs-no-img-element` — replace `<img>` with `<Image>` from `next/image`
4. `nextjs-missing-metadata` — add metadata export to page files
5. `no-effect-event-handler` — move effect body to the actual event handler
6. `nextjs-no-client-side-redirect` — move redirect to server component or middleware
7. `no-giant-component` — note the issue, suggest extraction strategy, skip auto-fix

### Phase 3: Fix Each File

For each file with warnings:

1. **Read the file** with the Read tool
2. **Apply fixes** using the Edit tool, working from the bottom of the file upward (so earlier line numbers remain accurate):

#### Rule: `rerender-memo-with-default-value`
```typescript
// BEFORE — default value inside function signature
function MyComponent({ items = [] }: Props) { ... }

// AFTER — extract to module-level constant above the component
const EMPTY_ITEMS: SomeType[] = [];
function MyComponent({ items = EMPTY_ITEMS }: Props) { ... }
```
The constant name should follow the pattern `EMPTY_<PROP_NAME_UPPER>` or `DEFAULT_<PROP_NAME_UPPER>`.

#### Rule: `no-array-index-as-key`
```typescript
// BEFORE
{items.map((item, index) => <Row key={index} {...item} />)}

// AFTER — use a stable unique field
{items.map((item) => <Row key={item.id} {...item} />)}
```
Inspect the item type to find a stable unique field (`id`, `slug`, `name`, etc.). If none exists, use `${item.field1}-${item.field2}` as a composite key.

#### Rule: `nextjs-no-img-element`
```typescript
// BEFORE
import Image from 'next/image'; // may already be imported
<img src={src} alt={alt} className="..." />

// AFTER
import Image from 'next/image';
<Image src={src} alt={alt} width={X} height={Y} className="..." />
```
Infer width/height from context (CSS classes like `w-8 h-8` → `width={32} height={32}`). If unknown, use `fill` with a positioned wrapper or reasonable defaults. Always keep the `alt` prop.

#### Rule: `nextjs-missing-metadata`
Add at the top of the page file (after imports, before the default export), only if the file has `'use client'` at the top — skip it (client components can't export metadata, note this). For server components:
```typescript
export const metadata = {
  title: '<Derived from component name or route>',
  description: '<Brief description of the page>',
};
```

#### Rule: `no-effect-event-handler`
```typescript
// BEFORE — useEffect that fires only on a specific state change
useEffect(() => {
  if (someCondition) {
    doSomething();
  }
}, [someCondition]);

// AFTER — move to the event handler that sets someCondition
const handleClick = () => {
  setSomeCondition(true);
  doSomething(); // moved here
};
```
Read the effect carefully. If it truly needs to run as a side effect (e.g. fetching data, subscribing), leave it and explain why it's appropriate. Only move logic that is clearly triggered by a user action.

#### Rule: `nextjs-no-client-side-redirect`
```typescript
// BEFORE — redirect inside useEffect
useEffect(() => {
  if (!user) router.push('/login');
}, [user]);

// AFTER (if page can be a server component)
// In a Server Component:
import { redirect } from 'next/navigation';
if (!user) redirect('/login');

// OR — if must stay client: keep the useEffect but note it's intentional
// Add a comment: // intentional: auth redirect in client component
```
Only convert to server-side redirect if the component doesn't use other client-side APIs. Otherwise, add a `// intentional:` comment to suppress future warnings.

#### Rule: `no-giant-component`
Do not auto-refactor giant components. Instead, output a suggested extraction plan:
```
⚠ ComponentName (line X) is N lines. Suggested extractions:
  - <SectionHeader /> — lines A–B (props: title, subtitle)
  - <ItemList /> — lines C–D (props: items, onSelect)
  ...
Ask me to extract a specific section and I will do it.
```

### Phase 4: Verify and Re-run

After applying all fixes to all files:

1. Run the linter to confirm no TypeScript errors were introduced:
   ```bash
   cd frontend && npm run type-check 2>&1 | tail -20
   ```
   If there are type errors, fix them before proceeding.

2. Re-run react-doctor:
   ```bash
   npx -y react-doctor@latest 2>&1
   ```

3. Read the new `diagnostics.json`.

4. If warnings remain that weren't there before, fix them.

5. If the same warnings remain (couldn't be auto-fixed), report them clearly.

6. **Repeat Phase 3–4** until:
   - No warnings remain, OR
   - All remaining warnings are `no-giant-component` (architectural, require human decision), OR
   - 3 consecutive runs produce identical warning counts (stuck — report and stop)

### Phase 5: Summary Report

```
## React Doctor Report

Score: X / 100

### Fixed
- ✅ rerender-memo-with-default-value × N (gully-nav.tsx, ...)
- ✅ no-array-index-as-key × N (...)
- ✅ nextjs-no-img-element × N (auction/page.tsx)

### Needs Human Review
- ⚠ no-giant-component: AuctionRoomPage (1021 lines) — extraction plan above
- ⚠ nextjs-missing-metadata: auction/page.tsx is 'use client' — metadata must be in a parent layout

### Not Fixed
- [list any that couldn't be resolved and why]
```

## Key Principles

- Always fix from **bottom to top** within a file so line numbers stay valid
- Never change logic when fixing — only restructure
- If a fix would break type safety, skip it and note it
- `'use client'` pages cannot export `metadata` — don't add it there; check the nearest `layout.tsx` instead
- Preserve all existing imports; only add new ones at the end of the import block
- Run `type-check` after each file batch to catch breakage early

## References

- `references/rules.md` — Full rule descriptions and examples
