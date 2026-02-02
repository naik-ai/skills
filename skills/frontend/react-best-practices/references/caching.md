# Next.js Caching Strategies

## Caching Layers

```
Request → Router Cache → Full Route Cache → Data Cache → Origin
         (client)        (server)           (server)
```

## Data Cache (fetch)

### Default Caching

```typescript
// Cached indefinitely by default
const data = await fetch('https://api.example.com/data');

// Force fresh data
const data = await fetch('https://api.example.com/data', {
  cache: 'no-store',
});

// Revalidate after time
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 3600 }, // 1 hour
});

// Revalidate on demand with tags
const data = await fetch('https://api.example.com/data', {
  next: { tags: ['posts'] },
});
```

### Revalidation Patterns

```typescript
// Time-based revalidation
// page.tsx
export const revalidate = 3600; // Revalidate every hour

// On-demand revalidation
// app/actions.ts
'use server';
import { revalidateTag, revalidatePath } from 'next/cache';

export async function createPost() {
  await db.post.create(...);

  // Revalidate by tag
  revalidateTag('posts');

  // Or by path
  revalidatePath('/posts');
}
```

## unstable_cache for Non-Fetch

```typescript
import { unstable_cache } from 'next/cache';

// Cache database queries
const getCachedUser = unstable_cache(
  async (id: string) => {
    return await db.user.findUnique({ where: { id } });
  },
  ['user'], // Cache key prefix
  {
    tags: ['user'],
    revalidate: 3600,
  }
);

// Usage
const user = await getCachedUser(userId);
```

## Route Segment Config

```typescript
// Force dynamic rendering
export const dynamic = 'force-dynamic';

// Force static rendering
export const dynamic = 'force-static';

// Revalidation interval
export const revalidate = 60; // seconds

// Runtime
export const runtime = 'nodejs'; // or 'edge'
```

## Cache Invalidation Strategy

```
┌─────────────────┐
│   User Action   │
│  (create post)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Server Action  │
│  revalidateTag  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Data Cache     │
│  invalidated    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Next request   │
│  fetches fresh  │
└─────────────────┘
```

## Common Patterns

### Blog with ISR

```typescript
// app/posts/[slug]/page.tsx
export const revalidate = 3600; // Rebuild every hour

export async function generateStaticParams() {
  const posts = await db.post.findMany({ select: { slug: true } });
  return posts.map(post => ({ slug: post.slug }));
}

export default async function Post({ params }) {
  const post = await db.post.findUnique({
    where: { slug: params.slug },
  });
  return <article>{post.content}</article>;
}
```

### Dashboard with Real-time

```typescript
// app/dashboard/page.tsx
export const dynamic = 'force-dynamic'; // Always fresh

export default async function Dashboard() {
  const stats = await db.stats.getCurrent();
  return <StatsDisplay stats={stats} />;
}
```

### E-commerce Product

```typescript
// Cache product data, revalidate on update
const getProduct = unstable_cache(
  async (id: string) => db.product.findUnique({ where: { id } }),
  ['product'],
  { tags: ['products'], revalidate: 300 }
);

// Invalidate when product updated
'use server';
export async function updateProduct(id: string, data: ProductData) {
  await db.product.update({ where: { id }, data });
  revalidateTag('products');
}
```
