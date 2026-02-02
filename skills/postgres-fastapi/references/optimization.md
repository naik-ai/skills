# Query Optimization Reference

## EXPLAIN ANALYZE

Always analyze slow queries:

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM users WHERE email = 'test@example.com';
```

### Reading EXPLAIN Output

```
Seq Scan on users  (cost=0.00..12.50 rows=1 width=100) (actual time=0.015..0.016 rows=1 loops=1)
  Filter: (email = 'test@example.com'::text)
  Rows Removed by Filter: 499
Planning Time: 0.080 ms
Execution Time: 0.035 ms
```

| Term | Meaning |
|------|---------|
| Seq Scan | Full table scan (usually bad) |
| Index Scan | Using index (good) |
| cost | Estimated cost (first=startup, second=total) |
| rows | Estimated row count |
| actual time | Real execution time (ms) |
| Rows Removed | Rows filtered out |

### What to Look For

```
❌ Bad: Seq Scan on large table
✅ Good: Index Scan using ix_users_email

❌ Bad: Rows Removed by Filter: 1000000
✅ Good: Rows Removed by Filter: 0

❌ Bad: Hash Join (large tables)
✅ Good: Nested Loop (small result sets with index)
```

## Index Optimization

### Create Index Concurrently (Production)

```sql
-- Won't block writes
CREATE INDEX CONCURRENTLY ix_users_email ON users (email);
```

### Covering Index

```sql
-- Include columns to avoid table lookup
CREATE INDEX ix_users_email_name ON users (email) INCLUDE (name);

-- Query satisfied entirely from index
SELECT name FROM users WHERE email = 'test@example.com';
```

### Partial Index

```sql
-- Only index active users
CREATE INDEX ix_users_active ON users (email)
WHERE is_active = true;

-- Much smaller index, faster queries for common case
SELECT * FROM users WHERE email = 'x' AND is_active = true;
```

### Expression Index

```sql
-- Index lowercase email for case-insensitive search
CREATE INDEX ix_users_email_lower ON users (LOWER(email));

-- Query must match expression exactly
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';
```

## N+1 Query Prevention

### The Problem

```python
# ❌ Bad: N+1 queries
users = await session.execute(select(User))
for user in users.scalars():
    # Each access triggers a query!
    print(user.profile.bio)
```

### The Solution

```python
# ✅ Good: Eager loading
from sqlalchemy.orm import selectinload, joinedload

# selectinload - separate query, good for collections
users = await session.execute(
    select(User).options(selectinload(User.posts))
)

# joinedload - single query with JOIN, good for single relations
users = await session.execute(
    select(User).options(joinedload(User.profile))
)

# Nested eager loading
users = await session.execute(
    select(User).options(
        selectinload(User.posts).selectinload(Post.tags)
    )
)
```

## Pagination Strategies

### Offset Pagination (Simple, Not Scalable)

```python
# Page 1000 still scans first 999 pages
async def get_page(page: int, size: int = 20):
    return await session.execute(
        select(Post)
        .order_by(Post.created_at.desc())
        .offset((page - 1) * size)
        .limit(size)
    )
```

### Cursor Pagination (Scalable)

```python
# Always fast regardless of "page number"
async def get_after_cursor(cursor: datetime, size: int = 20):
    return await session.execute(
        select(Post)
        .where(Post.created_at < cursor)
        .order_by(Post.created_at.desc())
        .limit(size)
    )
```

### Keyset Pagination (Best)

```python
# Handles ties in sort column
async def get_page(
    last_created: Optional[datetime],
    last_id: Optional[UUID],
    size: int = 20,
):
    query = select(Post).order_by(
        Post.created_at.desc(),
        Post.id.desc(),
    ).limit(size)

    if last_created and last_id:
        query = query.where(
            or_(
                Post.created_at < last_created,
                and_(
                    Post.created_at == last_created,
                    Post.id < last_id,
                ),
            )
        )

    return await session.execute(query)
```

## Batch Operations

### Bulk Insert

```python
# ✅ Good: Single statement
from sqlalchemy.dialects.postgresql import insert

stmt = insert(User).values([
    {"email": "a@x.com", "name": "A"},
    {"email": "b@x.com", "name": "B"},
    {"email": "c@x.com", "name": "C"},
])
await session.execute(stmt)
```

### Bulk Update

```python
# ✅ Good: Single statement with CASE
from sqlalchemy import case

stmt = (
    update(User)
    .where(User.id.in_([id1, id2, id3]))
    .values(
        name=case(
            (User.id == id1, "Name 1"),
            (User.id == id2, "Name 2"),
            (User.id == id3, "Name 3"),
        )
    )
)
await session.execute(stmt)
```

## Connection Pooling

```python
engine = create_async_engine(
    DATABASE_URL,
    pool_size=5,          # Maintained connections
    max_overflow=10,      # Extra connections when needed
    pool_timeout=30,      # Wait time for connection
    pool_recycle=1800,    # Recycle connections after 30min
    pool_pre_ping=True,   # Verify connection before use
)
```

### Pool Sizing Formula

```
pool_size = (core_count * 2) + effective_spindle_count

For SSD:
pool_size ≈ core_count * 2

Example (4 cores, SSD):
pool_size = 8
max_overflow = 4
```

## Query Caching

### Statement Cache

```python
# Reuse prepared statements
engine = create_async_engine(
    DATABASE_URL,
    connect_args={
        "prepared_statement_cache_size": 500,
    },
)
```

### Application-Level Cache

```python
from functools import lru_cache
import redis.asyncio as redis

redis_client = redis.from_url("redis://localhost")

async def get_user_cached(user_id: UUID) -> Optional[User]:
    # Try cache first
    cached = await redis_client.get(f"user:{user_id}")
    if cached:
        return User.parse_raw(cached)

    # Fetch from DB
    user = await repo.get_by_id(user_id)
    if user:
        await redis_client.setex(
            f"user:{user_id}",
            300,  # 5 minute TTL
            user.json(),
        )
    return user
```
