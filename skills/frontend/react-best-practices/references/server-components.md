# Server Components Deep Dive

## Mental Model

```
Server Components          Client Components
─────────────────          ─────────────────
• Run on server            • Run in browser
• Zero JS to client        • JS shipped to client
• Direct backend access    • Need API calls
• No hooks                 • Full React hooks
• Can be async             • Cannot be async
• Render once              • Re-render on state
```

## Boundary Rules

### What Can Cross the Boundary

| Direction | Allowed | Not Allowed |
|-----------|---------|-------------|
| Server → Client | Serializable props (JSON) | Functions, Classes, Symbols |
| Client → Server | Server Actions only | Direct function calls |

### Serializable Props

```typescript
// These can pass from Server to Client
type SerializableProps = {
  // Primitives
  string: string;
  number: number;
  boolean: boolean;
  null: null;
  undefined: undefined;

  // Containers
  array: string[];
  object: { key: string };
  date: Date; // Serialized to string

  // React
  children: React.ReactNode;
  element: JSX.Element;
};

// These CANNOT pass
type NonSerializable = {
  function: () => void;      // ❌
  class: new () => object;   // ❌
  symbol: symbol;            // ❌
  map: Map<string, string>;  // ❌
  set: Set<string>;          // ❌
};
```

## Patterns

### Passing Server Data to Client

```typescript
// app/posts/page.tsx (Server)
import { ClientEditor } from './ClientEditor';

export default async function Page() {
  const post = await db.post.findFirst();

  // ✅ Passing serializable data
  return <ClientEditor initialContent={post.content} />;
}

// ClientEditor.tsx
'use client';
export function ClientEditor({ initialContent }: { initialContent: string }) {
  const [content, setContent] = useState(initialContent);
  return <textarea value={content} onChange={e => setContent(e.target.value)} />;
}
```

### Server Components as Children

```typescript
// ClientWrapper.tsx
'use client';
export function ClientWrapper({ children }: { children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && children} {/* Server component rendered here */}
    </div>
  );
}

// page.tsx (Server)
export default async function Page() {
  const data = await fetchData(); // Server-side fetch

  return (
    <ClientWrapper>
      {/* This Server Component is passed as children */}
      <ServerDataDisplay data={data} />
    </ClientWrapper>
  );
}
```

### Lifting State Up (Avoid Client Creep)

```typescript
// ❌ Bad: Making parent client just for child state
'use client';
export function ProductPage() {
  const [selectedId, setSelectedId] = useState(null);
  // Now ENTIRE page is client-rendered
  return (
    <div>
      <ProductList onSelect={setSelectedId} />
      <ProductDetail id={selectedId} />
    </div>
  );
}

// ✅ Good: Isolate client state
// page.tsx (Server)
export default async function ProductPage() {
  const products = await getProducts();

  return (
    <div>
      <ProductList products={products} />
      {/* Client component handles its own selection */}
      <ProductSelector products={products} />
    </div>
  );
}

// ProductSelector.tsx
'use client';
export function ProductSelector({ products }) {
  const [selectedId, setSelectedId] = useState(products[0]?.id);
  const selected = products.find(p => p.id === selectedId);

  return (
    <div>
      <select value={selectedId} onChange={e => setSelectedId(e.target.value)}>
        {products.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
      </select>
      <ProductDetail product={selected} />
    </div>
  );
}
```

## Common Mistakes

### Mistake 1: Fetching in Client Components

```typescript
// ❌ Bad
'use client';
export function UserList() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    fetch('/api/users').then(r => r.json()).then(setUsers);
  }, []);

  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}

// ✅ Good
// Server Component - no 'use client'
export async function UserList() {
  const users = await db.user.findMany();
  return <ul>{users.map(u => <li key={u.id}>{u.name}</li>)}</ul>;
}
```

### Mistake 2: Adding 'use client' Too High

```typescript
// ❌ Bad: Entire tree becomes client
'use client';
export function Dashboard() {
  return (
    <div>
      <Header />      {/* Now client */}
      <Sidebar />     {/* Now client */}
      <MainContent /> {/* Now client */}
    </div>
  );
}

// ✅ Good: Only interactive parts are client
// Dashboard.tsx (Server)
export function Dashboard() {
  return (
    <div>
      <Header />
      <Sidebar />
      <MainContent />
      <InteractiveWidget /> {/* Only this is 'use client' */}
    </div>
  );
}
```

### Mistake 3: Trying to Pass Functions

```typescript
// ❌ Bad: Functions can't cross boundary
// page.tsx (Server)
export default function Page() {
  function handleClick() {
    console.log('clicked');
  }

  return <ClientButton onClick={handleClick} />; // Error!
}

// ✅ Good: Use Server Actions
// page.tsx (Server)
import { handleAction } from './actions';

export default function Page() {
  return <ClientButton action={handleAction} />;
}

// actions.ts
'use server';
export async function handleAction() {
  // Server-side logic
}

// ClientButton.tsx
'use client';
export function ClientButton({ action }) {
  return <button onClick={() => action()}>Click</button>;
}
```

## Performance Implications

| Aspect | Server Component | Client Component |
|--------|-----------------|------------------|
| Initial HTML | Full content | Placeholder + loading |
| JS Bundle | 0 KB | Component + deps |
| Data Fetching | Server, no waterfall | Client, waterfall possible |
| Interactivity | None | Full |
| Re-renders | Never | On state change |
