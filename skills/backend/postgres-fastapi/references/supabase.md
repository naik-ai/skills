# Supabase PostgreSQL Patterns

## Connection Setup

### Direct Connection (Transactions)

```python
# For migrations and transactions
DATABASE_URL = "postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:5432/postgres"
```

### Pooled Connection (Application)

```python
# For application queries - use pooler
DATABASE_URL = "postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres"

# With transaction mode (recommended)
DATABASE_URL = "postgresql://postgres.[ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres?pgbouncer=true"
```

### FastAPI Configuration

```python
# db/session.py
import os
from sqlalchemy.ext.asyncio import create_async_engine

# Use asyncpg for async support
DATABASE_URL = os.getenv("DATABASE_URL").replace(
    "postgresql://",
    "postgresql+asyncpg://"
)

engine = create_async_engine(
    DATABASE_URL,
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,
    # Required for Supabase pooler
    connect_args={
        "statement_cache_size": 0,  # Disable for pgbouncer
        "prepared_statement_cache_size": 0,
    },
)
```

## Row Level Security (RLS)

### Enable RLS on Tables

```sql
-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Force RLS for table owner too
ALTER TABLE posts FORCE ROW LEVEL SECURITY;
```

### Policy Patterns

```sql
-- Users can read their own data
CREATE POLICY "users_read_own"
ON users FOR SELECT
USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "users_update_own"
ON users FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Public read for published posts
CREATE POLICY "posts_public_read"
ON posts FOR SELECT
USING (is_published = true);

-- Authors can CRUD their own posts
CREATE POLICY "posts_author_all"
ON posts FOR ALL
USING (auth.uid() = author_id)
WITH CHECK (auth.uid() = author_id);
```

### Bypassing RLS (Service Role)

```python
# Use service role key for admin operations
from supabase import create_client

supabase = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_SERVICE_KEY"),  # Bypasses RLS
)
```

## Auth Integration

### Get Current User in FastAPI

```python
# dependencies/auth.py
from fastapi import Depends, HTTPException, Header
from supabase import create_client
import os

supabase = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_ANON_KEY"),
)

async def get_current_user(
    authorization: str = Header(...),
) -> dict:
    token = authorization.replace("Bearer ", "")

    try:
        user = supabase.auth.get_user(token)
        return user.user
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

# Usage in route
@router.get("/me")
async def get_me(user: dict = Depends(get_current_user)):
    return user
```

### Set Auth Context for RLS

```python
# Set user context for RLS policies
async def with_auth_context(session: AsyncSession, user_id: str):
    await session.execute(
        text("SET LOCAL request.jwt.claim.sub = :user_id"),
        {"user_id": user_id},
    )
```

## Storage Integration

```python
from supabase import create_client

supabase = create_client(url, key)

# Upload file
with open("file.pdf", "rb") as f:
    supabase.storage.from_("documents").upload(
        "folder/file.pdf",
        f,
        {"content-type": "application/pdf"},
    )

# Get public URL
url = supabase.storage.from_("documents").get_public_url("folder/file.pdf")

# Get signed URL (private bucket)
url = supabase.storage.from_("private").create_signed_url(
    "folder/file.pdf",
    expires_in=3600,  # 1 hour
)
```

## Realtime Subscriptions

```python
# Listen to database changes
def handle_insert(payload):
    print("New record:", payload["new"])

supabase.table("posts").on("INSERT", handle_insert).subscribe()

# With filter
supabase.table("posts").on(
    "INSERT",
    handle_insert,
    filter="author_id=eq.123",
).subscribe()
```

## Edge Functions Integration

```python
# Call Supabase Edge Function from FastAPI
import httpx

async def call_edge_function(function_name: str, payload: dict):
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{os.getenv('SUPABASE_URL')}/functions/v1/{function_name}",
            json=payload,
            headers={
                "Authorization": f"Bearer {os.getenv('SUPABASE_ANON_KEY')}",
                "Content-Type": "application/json",
            },
        )
        return response.json()
```

## Best Practices

### Connection Management

```python
# Use connection pooling
# Supabase has built-in pgbouncer on port 6543

# For serverless (Vercel, AWS Lambda)
# Use transaction mode pooler
DATABASE_URL = "...pooler.supabase.com:6543/postgres?pgbouncer=true"
```

### Security

```python
# Never expose service key to client
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")  # Safe for client
SUPABASE_SERVICE_KEY = os.getenv("SUPABASE_SERVICE_KEY")  # Server only

# Always enable RLS on user-facing tables
# Use service key only for admin operations
```

### Performance

```sql
-- Create indexes for RLS policy columns
CREATE INDEX ix_posts_author_id ON posts (author_id);

-- Use auth.uid() efficiently
-- It's a function call, so index the column it compares against
```
