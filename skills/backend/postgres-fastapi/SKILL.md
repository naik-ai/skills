---
name: postgres-fastapi
description: PostgreSQL patterns for FastAPI/Alembic/Python backends including schema design, migrations, queries, and Supabase integration. Use when user needs "database schema", "migrations", "PostgreSQL queries", "Alembic setup", "SQLAlchemy models", "database design", "SQL optimization", or "Supabase backend". Triggers on requests for database architecture, migration workflows, query optimization, or Python ORM patterns.
---

# PostgreSQL FastAPI Skill

Production-ready PostgreSQL patterns for FastAPI applications using SQLAlchemy/SQLModel and Alembic migrations.

## When to Use

- Designing database schemas for FastAPI applications
- Creating and managing Alembic migrations
- Writing optimized PostgreSQL queries
- Setting up SQLAlchemy/SQLModel models
- Integrating with Supabase PostgreSQL

## Workflow

### Phase 1: Schema Design

**Goal**: Define models as single source of truth

**Actions**:
1. Create models in `db/models/` directory
2. Define relationships and constraints
3. Add indexes for query patterns
4. Document model purposes

**Output**: SQLModel/SQLAlchemy model files

### Phase 2: Migration Generation

**Goal**: Generate clean, single-purpose migrations

**Actions**:
1. Generate draft migration with Alembic
2. Review generated SQL
3. Consolidate if multiple drafts exist
4. Apply and verify on local DB

**Output**: Single migration file per feature

### Phase 3: Query Implementation

**Goal**: Write efficient, type-safe queries

**Actions**:
1. Implement repository pattern for data access
2. Use proper async patterns
3. Add query optimization (indexes, joins)
4. Implement pagination and filtering

**Output**: Type-safe, performant queries

## Model Patterns

### Base Model

```python
# db/models/base.py
from datetime import datetime
from sqlmodel import SQLModel, Field
from sqlalchemy import Column, DateTime, func

class TimestampMixin(SQLModel):
    created_at: datetime = Field(
        default_factory=datetime.utcnow,
        sa_column=Column(
            DateTime(timezone=True),
            server_default=func.now(),
            nullable=False,
        ),
    )
    updated_at: datetime = Field(
        default_factory=datetime.utcnow,
        sa_column=Column(
            DateTime(timezone=True),
            server_default=func.now(),
            onupdate=func.now(),
            nullable=False,
        ),
    )

class BaseModel(TimestampMixin):
    """Base model with common fields"""
    pass
```

### User Model Example

```python
# db/models/user.py
from uuid import UUID, uuid4
from typing import Optional, List
from sqlmodel import SQLModel, Field, Relationship
from sqlalchemy import Column, String, Index
from enum import Enum

class UserRole(str, Enum):
    USER = "user"
    ADMIN = "admin"
    MODERATOR = "moderator"

class User(SQLModel, table=True):
    __tablename__ = "users"
    __table_args__ = (
        Index("ix_users_email_lower", func.lower("email"), unique=True),
        Index("ix_users_created_at", "created_at"),
    )

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    email: str = Field(sa_column=Column(String(255), nullable=False))
    name: str = Field(sa_column=Column(String(100), nullable=False))
    role: UserRole = Field(default=UserRole.USER)
    is_active: bool = Field(default=True)

    # Relationships
    posts: List["Post"] = Relationship(back_populates="author")
    profile: Optional["UserProfile"] = Relationship(
        back_populates="user",
        sa_relationship_kwargs={"uselist": False},
    )

class UserProfile(SQLModel, table=True):
    __tablename__ = "user_profiles"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    user_id: UUID = Field(foreign_key="users.id", unique=True)
    bio: Optional[str] = Field(default=None, max_length=500)
    avatar_url: Optional[str] = None

    # Relationships
    user: User = Relationship(back_populates="profile")
```

### Many-to-Many Relationship

```python
# db/models/post.py
from uuid import UUID, uuid4
from typing import List, Optional
from sqlmodel import SQLModel, Field, Relationship

# Association table
class PostTag(SQLModel, table=True):
    __tablename__ = "post_tags"

    post_id: UUID = Field(foreign_key="posts.id", primary_key=True)
    tag_id: UUID = Field(foreign_key="tags.id", primary_key=True)

class Tag(SQLModel, table=True):
    __tablename__ = "tags"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    name: str = Field(unique=True, max_length=50)
    slug: str = Field(unique=True, max_length=50)

    posts: List["Post"] = Relationship(
        back_populates="tags",
        link_model=PostTag,
    )

class Post(SQLModel, table=True):
    __tablename__ = "posts"
    __table_args__ = (
        Index("ix_posts_author_created", "author_id", "created_at"),
        Index("ix_posts_published", "is_published", "published_at"),
    )

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    title: str = Field(max_length=200)
    slug: str = Field(unique=True, max_length=200)
    content: str
    author_id: UUID = Field(foreign_key="users.id")
    is_published: bool = Field(default=False)
    published_at: Optional[datetime] = None

    # Relationships
    author: User = Relationship(back_populates="posts")
    tags: List[Tag] = Relationship(
        back_populates="posts",
        link_model=PostTag,
    )
```

## Migration Workflow

### Initial Setup

```bash
# Install dependencies
pip install alembic sqlalchemy asyncpg

# Initialize Alembic
alembic init db/alembic

# Configure alembic.ini
# sqlalchemy.url = postgresql+asyncpg://user:pass@localhost/dbname
```

### Alembic Configuration

```python
# db/alembic/env.py
from logging.config import fileConfig
from sqlalchemy import pool
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import async_engine_from_config
from alembic import context

# Import all models for autogenerate
from db.models import *  # noqa

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = SQLModel.metadata

def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def do_run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()

async def run_async_migrations() -> None:
    connectable = async_engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)
    await connectable.dispose()

def run_migrations_online() -> None:
    import asyncio
    asyncio.run(run_async_migrations())

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

### Migration Commands

```bash
# Generate migration from model changes
alembic revision --autogenerate -m "add users table"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# Rollback to specific revision
alembic downgrade <revision_id>

# Show current revision
alembic current

# Show migration history
alembic history --verbose
```

### Migration Best Practices

```python
# db/alembic/versions/001_add_users.py
"""add users table

Revision ID: 001
Create Date: 2024-01-15 10:00:00
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision: str = '001'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    op.create_table(
        'users',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('role', sa.String(20), nullable=False, server_default='user'),
        sa.Column('is_active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
    )

    # Create indexes
    op.create_index(
        'ix_users_email_lower',
        'users',
        [sa.func.lower(sa.column('email'))],
        unique=True,
    )

def downgrade() -> None:
    op.drop_index('ix_users_email_lower')
    op.drop_table('users')
```

## Query Patterns

### Repository Pattern

```python
# db/repositories/user.py
from uuid import UUID
from typing import Optional, List
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from db.models.user import User, UserProfile

class UserRepository:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, user_id: UUID) -> Optional[User]:
        result = await self.session.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.session.execute(
            select(User).where(User.email.ilike(email))
        )
        return result.scalar_one_or_none()

    async def get_with_profile(self, user_id: UUID) -> Optional[User]:
        result = await self.session.execute(
            select(User)
            .options(selectinload(User.profile))
            .where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    async def list_paginated(
        self,
        offset: int = 0,
        limit: int = 20,
        is_active: Optional[bool] = None,
    ) -> List[User]:
        query = select(User).offset(offset).limit(limit)

        if is_active is not None:
            query = query.where(User.is_active == is_active)

        query = query.order_by(User.created_at.desc())

        result = await self.session.execute(query)
        return list(result.scalars().all())

    async def create(self, user: User) -> User:
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
        return user

    async def update(self, user: User) -> User:
        await self.session.commit()
        await self.session.refresh(user)
        return user

    async def delete(self, user: User) -> None:
        await self.session.delete(user)
        await self.session.commit()
```

### Complex Queries

```python
# Aggregation with group by
async def get_posts_per_author(session: AsyncSession) -> List[dict]:
    result = await session.execute(
        select(
            User.id,
            User.name,
            func.count(Post.id).label('post_count'),
        )
        .join(Post, User.id == Post.author_id, isouter=True)
        .group_by(User.id)
        .order_by(func.count(Post.id).desc())
    )
    return [
        {"id": row.id, "name": row.name, "post_count": row.post_count}
        for row in result.all()
    ]

# Filtering with multiple conditions
async def search_posts(
    session: AsyncSession,
    query: str,
    tags: Optional[List[str]] = None,
    author_id: Optional[UUID] = None,
) -> List[Post]:
    stmt = (
        select(Post)
        .options(selectinload(Post.author), selectinload(Post.tags))
        .where(Post.is_published == True)
    )

    if query:
        stmt = stmt.where(
            or_(
                Post.title.ilike(f'%{query}%'),
                Post.content.ilike(f'%{query}%'),
            )
        )

    if tags:
        stmt = stmt.join(Post.tags).where(Tag.slug.in_(tags))

    if author_id:
        stmt = stmt.where(Post.author_id == author_id)

    result = await session.execute(stmt)
    return list(result.scalars().unique().all())
```

### Bulk Operations

```python
# Bulk insert
async def bulk_create_users(session: AsyncSession, users: List[User]) -> None:
    session.add_all(users)
    await session.commit()

# Bulk update with raw SQL for performance
async def deactivate_inactive_users(session: AsyncSession, days: int = 90) -> int:
    result = await session.execute(
        text("""
            UPDATE users
            SET is_active = false, updated_at = now()
            WHERE last_login_at < now() - interval ':days days'
            AND is_active = true
        """),
        {"days": days},
    )
    await session.commit()
    return result.rowcount

# Upsert (insert or update)
async def upsert_user(session: AsyncSession, user_data: dict) -> User:
    stmt = postgresql.insert(User).values(**user_data)
    stmt = stmt.on_conflict_do_update(
        index_elements=['email'],
        set_={
            'name': stmt.excluded.name,
            'updated_at': func.now(),
        },
    )
    await session.execute(stmt)
    await session.commit()
```

## FastAPI Integration

### Database Session

```python
# db/session.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql+asyncpg://user:pass@localhost/db"

engine = create_async_engine(
    DATABASE_URL,
    echo=False,  # Set True for SQL logging
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,  # Verify connections
)

AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_session() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
```

### Dependency Injection

```python
# api/routes/users.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from uuid import UUID

from db.session import get_session
from db.repositories.user import UserRepository
from api.schemas.user import UserCreate, UserResponse

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: UUID,
    session: AsyncSession = Depends(get_session),
):
    repo = UserRepository(session)
    user = await repo.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/", response_model=UserResponse, status_code=201)
async def create_user(
    data: UserCreate,
    session: AsyncSession = Depends(get_session),
):
    repo = UserRepository(session)

    # Check if email exists
    existing = await repo.get_by_email(data.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user = User(**data.dict())
    return await repo.create(user)
```

## Index Strategies

### Index Types

```python
# B-tree (default) - equality and range queries
Index("ix_users_created", "created_at")

# Hash - equality only, faster for exact matches
Index("ix_users_email_hash", "email", postgresql_using="hash")

# GIN - full-text search, arrays, JSONB
Index("ix_posts_tags", "tags", postgresql_using="gin")

# Partial index - only index subset of rows
Index(
    "ix_posts_published",
    "published_at",
    postgresql_where=text("is_published = true"),
)

# Expression index - index computed values
Index("ix_users_email_lower", func.lower(User.email), unique=True)

# Composite index - multiple columns
Index("ix_posts_author_date", "author_id", "created_at")
```

### When to Add Indexes

| Query Pattern | Index Type |
|---------------|------------|
| WHERE col = value | B-tree on col |
| WHERE col IN (...) | B-tree on col |
| WHERE col > value | B-tree on col |
| ORDER BY col | B-tree on col |
| WHERE a = x AND b = y | Composite (a, b) |
| WHERE LOWER(col) = value | Expression index |
| Full-text search | GIN with tsvector |
| JSONB containment | GIN on JSONB col |

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| N+1 queries | Slow, many DB calls | Use selectinload/joinedload |
| No indexes on FK | Slow joins | Add index on foreign keys |
| SELECT * everywhere | Excess data transfer | Select only needed columns |
| String concatenation in SQL | SQL injection | Use parameterized queries |
| Committing in loops | Slow, many transactions | Batch operations |
| Missing connection pooling | Connection exhaustion | Configure pool_size |

## Key Principles

1. **Models are truth**: Always update models first, migrations follow
2. **One migration per feature**: Consolidate drafts before committing
3. **Index for queries**: Add indexes based on actual query patterns
4. **Async everywhere**: Use async sessions and queries consistently
5. **Repository pattern**: Abstract data access from business logic
6. **Type safety**: Use SQLModel for runtime validation

## References

- `references/migrations.md` - Migration workflow deep dive
- `references/optimization.md` - Query optimization patterns
- `references/supabase.md` - Supabase-specific patterns
