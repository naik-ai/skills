---
name: react-best-practices
description: Production React patterns from Vercel including Server Components, data fetching, performance optimization, and modern architecture. Use when user needs "React components", "Server Components", "data fetching", "React performance", "component architecture", "state management", "Next.js patterns", or "React optimization". Triggers on requests for scalable React code, production patterns, or Vercel-style development.
---

# React Best Practices Skill

Production-ready React patterns following Vercel's recommended approaches for Server Components, data fetching, state management, and performance optimization.

## When to Use

- Building React components with modern patterns
- Implementing Server Components and data fetching
- Optimizing React application performance
- Architecting component hierarchies
- Managing client/server component boundaries

## Workflow

### Phase 1: Component Design

**Goal**: Determine component architecture and data requirements

**Actions**:
1. Identify if component needs interactivity (client) or can be server-rendered
2. Map data requirements and fetching strategy
3. Plan component composition and prop drilling avoidance
4. Define error and loading boundaries

**Output**: Component architecture decision

### Phase 2: Implementation

**Goal**: Build components following best practices

**Actions**:
1. Create server components by default
2. Add 'use client' only where necessary
3. Implement proper data fetching patterns
4. Add error handling and suspense boundaries

**Output**: Production-ready component code

### Phase 3: Optimization

**Goal**: Ensure optimal performance

**Actions**:
1. Audit client/server boundaries
2. Implement proper caching strategies
3. Add streaming where beneficial
4. Verify bundle size impact

**Output**: Optimized, production-ready code

## Server vs Client Components

### Decision Matrix

| Need | Component Type | Reason |
|------|----------------|--------|
| Fetch data | Server | Direct DB/API access, no waterfalls |
| Access backend | Server | Secure, no exposure |
| Static content | Server | Zero JS shipped |
| SEO critical | Server | HTML in initial response |
| Event listeners | Client | onClick, onChange, etc. |
| useState/useEffect | Client | React hooks |
| Browser APIs | Client | localStorage, geolocation |
| Custom hooks with state | Client | Hooks need client runtime |

### Server Component (Default)

```typescript
// app/users/page.tsx
// No 'use client' directive = Server Component

import { db } from '@/lib/db';

export default async function UsersPage() {
  // Direct database access - no API layer needed
  const users = await db.user.findMany({
    orderBy: { createdAt: 'desc' },
    take: 10,
  });

  return (
    <div>
      <h1>Users</h1>
      <UserList users={users} />
    </div>
  );
}

// This component is also a Server Component
function UserList({ users }: { users: User[] }) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Client Component (Only When Needed)

```typescript
// components/SearchInput.tsx
'use client';

import { useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';

export function SearchInput() {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();
  const router = useRouter();

  function handleSearch(value: string) {
    setQuery(value);
    startTransition(() => {
      router.push(`/search?q=${encodeURIComponent(value)}`);
    });
  }

  return (
    <input
      value={query}
      onChange={(e) => handleSearch(e.target.value)}
      placeholder="Search..."
      className={isPending ? 'opacity-50' : ''}
    />
  );
}
```

### Composition Pattern (Server with Client Islands)

```typescript
// app/dashboard/page.tsx (Server Component)
import { db } from '@/lib/db';
import { InteractiveChart } from '@/components/InteractiveChart';
import { FilterDropdown } from '@/components/FilterDropdown';

export default async function Dashboard() {
  // Fetch data on server
  const metrics = await db.metrics.getLatest();

  return (
    <div>
      {/* Server-rendered header */}
      <header>
        <h1>Dashboard</h1>
        {/* Client component for interactivity */}
        <FilterDropdown />
      </header>

      {/* Server-rendered stats */}
      <div className="stats">
        <StatCard title="Revenue" value={metrics.revenue} />
        <StatCard title="Users" value={metrics.users} />
      </div>

      {/* Client component for interactive chart */}
      <InteractiveChart data={metrics.chartData} />
    </div>
  );
}
```

## Data Fetching Patterns

### Pattern 1: Parallel Data Fetching

```typescript
// app/dashboard/page.tsx
async function Dashboard() {
  // Fetch in parallel - not sequential
  const [user, posts, analytics] = await Promise.all([
    getUser(),
    getPosts(),
    getAnalytics(),
  ]);

  return (
    <>
      <UserProfile user={user} />
      <PostList posts={posts} />
      <AnalyticsChart data={analytics} />
    </>
  );
}
```

### Pattern 2: Streaming with Suspense

```typescript
// app/dashboard/page.tsx
import { Suspense } from 'react';

export default function Dashboard() {
  return (
    <div>
      {/* Renders immediately */}
      <Header />

      {/* Streams when ready */}
      <Suspense fallback={<StatsSkeleton />}>
        <Stats />
      </Suspense>

      {/* Streams independently */}
      <Suspense fallback={<ChartSkeleton />}>
        <SlowChart />
      </Suspense>
    </div>
  );
}

// Each component fetches its own data
async function Stats() {
  const stats = await getStats(); // Fast query
  return <StatsDisplay data={stats} />;
}

async function SlowChart() {
  const data = await getChartData(); // Slow query
  return <Chart data={data} />;
}
```

### Pattern 3: Server Actions

```typescript
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { db } from '@/lib/db';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  const content = formData.get('content') as string;

  // Direct database mutation
  await db.post.create({
    data: { title, content },
  });

  // Revalidate the posts page
  revalidatePath('/posts');
}

// Usage in component
// components/CreatePostForm.tsx
'use client';

import { createPost } from '@/app/actions';

export function CreatePostForm() {
  return (
    <form action={createPost}>
      <input name="title" placeholder="Title" />
      <textarea name="content" placeholder="Content" />
      <button type="submit">Create</button>
    </form>
  );
}
```

### Pattern 4: Optimistic Updates

```typescript
// components/LikeButton.tsx
'use client';

import { useOptimistic, useTransition } from 'react';
import { likePost } from '@/app/actions';

export function LikeButton({ postId, initialLikes }: Props) {
  const [isPending, startTransition] = useTransition();
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (state) => state + 1
  );

  async function handleLike() {
    startTransition(async () => {
      addOptimisticLike(null);
      await likePost(postId);
    });
  }

  return (
    <button onClick={handleLike} disabled={isPending}>
      {optimisticLikes} likes
    </button>
  );
}
```

## Component Architecture

### Colocation Pattern

```
app/
├── dashboard/
│   ├── page.tsx           # Route component
│   ├── loading.tsx        # Loading UI
│   ├── error.tsx          # Error UI
│   ├── layout.tsx         # Shared layout
│   └── _components/       # Route-specific components
│       ├── StatsCard.tsx
│       └── RevenueChart.tsx
├── components/            # Shared components
│   ├── ui/               # Primitives (Button, Input)
│   └── features/         # Feature components
└── lib/                  # Utilities
    ├── db.ts
    └── utils.ts
```

### Component Composition

```typescript
// Compound component pattern
// components/Card.tsx
import { createContext, useContext } from 'react';

const CardContext = createContext<{ variant: string } | null>(null);

export function Card({ children, variant = 'default' }) {
  return (
    <CardContext.Provider value={{ variant }}>
      <div className={`card card-${variant}`}>
        {children}
      </div>
    </CardContext.Provider>
  );
}

Card.Header = function CardHeader({ children }) {
  return <div className="card-header">{children}</div>;
};

Card.Body = function CardBody({ children }) {
  return <div className="card-body">{children}</div>;
};

Card.Footer = function CardFooter({ children }) {
  return <div className="card-footer">{children}</div>;
};

// Usage
<Card variant="elevated">
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>Actions</Card.Footer>
</Card>
```

### Render Props for Flexibility

```typescript
// components/DataTable.tsx
interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  renderRow?: (item: T, index: number) => React.ReactNode;
  renderEmpty?: () => React.ReactNode;
}

export function DataTable<T>({
  data,
  columns,
  renderRow,
  renderEmpty,
}: DataTableProps<T>) {
  if (data.length === 0) {
    return renderEmpty?.() ?? <div>No data</div>;
  }

  return (
    <table>
      <thead>
        <tr>
          {columns.map(col => (
            <th key={col.key}>{col.header}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.map((item, index) =>
          renderRow ? (
            renderRow(item, index)
          ) : (
            <tr key={index}>
              {columns.map(col => (
                <td key={col.key}>{col.render(item)}</td>
              ))}
            </tr>
          )
        )}
      </tbody>
    </table>
  );
}
```

## State Management

### Server State (Recommended)

```typescript
// Prefer server components with direct data access
// app/products/page.tsx
export default async function Products({ searchParams }) {
  const { category, sort } = searchParams;

  // State is in the URL, not React
  const products = await db.product.findMany({
    where: category ? { category } : undefined,
    orderBy: sort ? { [sort]: 'asc' } : undefined,
  });

  return <ProductList products={products} />;
}
```

### URL State for Shareable UI

```typescript
// components/Filters.tsx
'use client';

import { useRouter, useSearchParams } from 'next/navigation';

export function Filters() {
  const router = useRouter();
  const searchParams = useSearchParams();

  function updateFilter(key: string, value: string) {
    const params = new URLSearchParams(searchParams);
    if (value) {
      params.set(key, value);
    } else {
      params.delete(key);
    }
    router.push(`?${params.toString()}`);
  }

  return (
    <select
      value={searchParams.get('category') ?? ''}
      onChange={(e) => updateFilter('category', e.target.value)}
    >
      <option value="">All</option>
      <option value="electronics">Electronics</option>
      <option value="clothing">Clothing</option>
    </select>
  );
}
```

### Local UI State

```typescript
// components/Accordion.tsx
'use client';

import { useState } from 'react';

export function Accordion({ items }) {
  // Local state for UI-only concerns
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <div>
      {items.map((item, index) => (
        <div key={index}>
          <button onClick={() => setOpenIndex(
            openIndex === index ? null : index
          )}>
            {item.title}
          </button>
          {openIndex === index && (
            <div>{item.content}</div>
          )}
        </div>
      ))}
    </div>
  );
}
```

## Performance Patterns

### React.memo for Expensive Renders

```typescript
// Only use when profiling shows it's needed
const ExpensiveList = memo(function ExpensiveList({ items }: Props) {
  return (
    <ul>
      {items.map(item => (
        <ExpensiveItem key={item.id} item={item} />
      ))}
    </ul>
  );
});

// With custom comparison
const UserCard = memo(
  function UserCard({ user }: Props) {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
);
```

### useMemo/useCallback (Use Sparingly)

```typescript
// Only when passing to memoized children or expensive computations
function Dashboard({ data }) {
  // Expensive computation - memoize
  const processedData = useMemo(
    () => data.map(item => expensiveTransform(item)),
    [data]
  );

  // Callback passed to memoized child - memoize
  const handleSelect = useCallback(
    (id: string) => {
      // handle selection
    },
    []
  );

  return <MemoizedChart data={processedData} onSelect={handleSelect} />;
}
```

### Dynamic Imports for Code Splitting

```typescript
// components/HeavyChart.tsx
'use client';

import dynamic from 'next/dynamic';

const Chart = dynamic(() => import('@/components/Chart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // Only if chart uses browser APIs
});

export function HeavyChart({ data }) {
  return <Chart data={data} />;
}
```

### Image Optimization

```typescript
import Image from 'next/image';

// Always use next/image for optimization
export function ProductCard({ product }) {
  return (
    <div>
      <Image
        src={product.image}
        alt={product.name}
        width={300}
        height={200}
        placeholder="blur"
        blurDataURL={product.blurHash}
        priority={false} // Only true for above-fold images
      />
    </div>
  );
}
```

## Error Handling

### Error Boundaries

```typescript
// app/dashboard/error.tsx
'use client';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="error-container">
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

### Granular Error Handling

```typescript
// Wrap specific sections
export default function Dashboard() {
  return (
    <div>
      <Header /> {/* If this errors, whole page fails */}

      <ErrorBoundary fallback={<StatsFallback />}>
        <Suspense fallback={<StatsSkeleton />}>
          <Stats />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<ChartFallback />}>
        <Suspense fallback={<ChartSkeleton />}>
          <Chart />
        </Suspense>
      </ErrorBoundary>
    </div>
  );
}
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| 'use client' everywhere | Bloated JS bundle | Default to server, add client only when needed |
| Fetching in useEffect | Waterfalls, no SSR | Fetch in server components |
| Prop drilling | Unmaintainable code | Composition, context, or server components |
| Over-memoizing | Complexity, no benefit | Profile first, memoize only bottlenecks |
| Client state for URL data | Not shareable | Use searchParams for filterable UI |

## Key Principles

1. **Server by default**: Only add 'use client' when you need interactivity
2. **Fetch where you render**: Colocate data fetching with components
3. **Parallel over sequential**: Use Promise.all, not await chains
4. **URL as state**: Use searchParams for shareable, bookmarkable UI
5. **Composition over props**: Build flexible components with children
6. **Profile before optimizing**: Don't guess, measure

## References

- `references/server-components.md` - Deep dive on Server Components
- `references/caching.md` - Next.js caching strategies
- `references/patterns.md` - Advanced component patterns
