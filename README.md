# Claude Code Skills Repository

A curated collection of modular instruction packages that extend Claude Code's capabilities with domain expertise, workflows, and tool integrations.

## Quick Start

```bash
# Clone into your project
git clone https://github.com/naik-ai/skills .claude/skills

# Or add as submodule
git submodule add https://github.com/naik-ai/skills .claude/skills

# Or install specific skills
./scripts/install.sh --skill pwa-ui
```

## What Are Skills?

Skills are modular instruction packages that transform Claude from a general-purpose assistant into a specialized agent:

| Component | Purpose |
|-----------|---------|
| **Domain Expertise** | Specialized knowledge Claude doesn't have |
| **Workflows** | Multi-step procedures for specific tasks |
| **Tool Integrations** | Instructions for specific frameworks, APIs, or patterns |
| **Bundled Resources** | Scripts, templates, and reference documentation |

## Repository Structure

```
skills/
├── skills/                    # All skills live here
│   ├── core/                  # Foundational skills
│   ├── frontend/              # Frontend-specific skills
│   ├── backend/               # Backend-specific skills
│   ├── media/                 # Media creation skills
│   ├── devops/                # DevOps skills
│   └── domain/                # Domain-specific skills
├── commands/                  # Reusable slash commands
├── templates/                 # Starter templates
└── scripts/                   # Utility scripts
```

## Available Skills

### Frontend Skills

| Skill | Description | Status |
|-------|-------------|--------|
| [pwa-ui](skills/frontend/pwa-ui/) | Apple-inspired PWA UI/UX patterns for React/Next.js with animations, typography, and design tokens | Ready |
| [react-best-practices](skills/frontend/react-best-practices/) | Production React patterns from Vercel including Server Components, data fetching, and performance | Ready |

### Backend Skills

| Skill | Description | Status |
|-------|-------------|--------|
| [postgres-fastapi](skills/backend/postgres-fastapi/) | PostgreSQL patterns for FastAPI/Alembic with migrations, queries, and Supabase integration | Ready |

### Core Skills (Roadmap)

| Skill | Description | Priority |
|-------|-------------|----------|
| interview-to-spec | Deep user interviews into comprehensive specs | P0 |
| code-review | Systematic code review with actionable feedback | P0 |
| documentation | Generate docs from code | P0 |

## Usage

Skills are automatically available when placed in `.claude/skills/`. Just describe your task and relevant skills will be used.

```bash
# PWA UI patterns
"Create a mobile-first dashboard with Apple-style animations"

# React best practices
"Build a data table with server-side pagination"

# Postgres patterns
"Design a schema for user subscriptions with proper migrations"
```

## Skill Architecture

Every skill follows this structure:

```
skill-name/
├── SKILL.md              # Required - Main instructions
├── scripts/              # Optional - Executable code
├── references/           # Optional - Detailed documentation
└── assets/               # Optional - Templates, files
```

### Progressive Disclosure

Skills use three-level loading to manage context:

| Level | Content | When Loaded | Size Target |
|-------|---------|-------------|-------------|
| 1 | Name + Description | Always | ~100 words |
| 2 | SKILL.md body | When triggered | < 500 lines |
| 3 | References/Assets | When needed | Unlimited |

---

## Roadmap

### Phase 1: Foundation (Current)

| Skill | Purpose | Status |
|-------|---------|--------|
| pwa-ui | Apple-inspired PWA patterns | Ready |
| react-best-practices | Vercel React patterns | Ready |
| postgres-fastapi | FastAPI/Alembic patterns | Ready |

### Phase 2: Development Core

| Skill | Purpose | Priority |
|-------|---------|----------|
| interview-to-spec | Requirements gathering | P0 |
| code-review | Systematic review | P0 |
| api-design | RESTful/GraphQL APIs | P0 |
| database-schema | Schema design | P0 |

### Phase 3: Extended

| Skill | Purpose | Priority |
|-------|---------|----------|
| auth-patterns | Authentication/authorization | P1 |
| docker-compose | Container orchestration | P1 |
| github-actions | CI/CD pipelines | P1 |

### Priority Matrix

```
                    High Value
                        │
         P0             │             P1
    ┌───────────────────┼───────────────────┐
    │ • pwa-ui          │ • auth-patterns   │
    │ • react-practices │ • github-actions  │
    │ • postgres-fastapi│ • docker-compose  │
Low │ • interview-spec  │                   │ High
Effort──────────────────┼──────────────────── Effort
    │ • code-review     │ • infrastructure  │
    │ • documentation   │ • domain-specific │
    └───────────────────┼───────────────────┘
         P2             │             P3
                        │
                    Low Value
```

---

## Improvement Loop

### Continuous Skill Enhancement

```
┌─────────────────────────────────────────────────────────────┐
│                  IMPROVEMENT WORKFLOW                        │
└─────────────────────────────────────────────────────────────┘

Step 1: Use Skill
┌─────────────────┐
│  Apply skill    │ ──── Note friction points
│  to real task   │
└────────┬────────┘
         │
         ▼
Step 2: Capture Feedback
┌─────────────────┐
│ Document issues │ ──── Missing patterns, unclear steps
│ and successes   │
└────────┬────────┘
         │
         ▼
Step 3: Refine Skill
┌─────────────────┐
│ Update SKILL.md │ ──── Add patterns, fix workflows
│ Add references  │
└────────┬────────┘
         │
         ▼
Step 4: Validate
┌─────────────────┐
│ Test on new     │ ──── Verify improvements work
│ similar task    │
└────────┬────────┘
         │
         ▼
    ┌────┴────┐
    │  Loop   │
    └─────────┘
```

### Feedback Categories

| Category | Action |
|----------|--------|
| Missing Pattern | Add to Patterns section |
| Unclear Step | Rewrite with more detail |
| Common Error | Add to References with fix |
| New Use Case | Expand trigger phrases |

### Quality Checklist

Before updating a skill:

- [ ] SKILL.md under 500 lines
- [ ] All code examples copy-paste ready
- [ ] Trigger phrases comprehensive
- [ ] Edge cases documented
- [ ] Tested on real task

---

## Skill Synergies

```
pwa-ui
    │
    └──→ react-best-practices
              │
              ├──→ postgres-fastapi (for full-stack)
              │
              └──→ api-design (for backend)
                        │
                        ▼
                   documentation
```

When building a full-stack app:
1. Use `pwa-ui` for mobile-first design patterns
2. Apply `react-best-practices` for component architecture
3. Use `postgres-fastapi` for backend data layer
4. Reference `api-design` for endpoint design

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding or modifying skills.

### Quick Add

```bash
# Copy template
cp -r templates/skill-template skills/[category]/[skill-name]

# Edit SKILL.md
# Test skill
# Submit PR
```

---

## Scripts

| Script | Purpose |
|--------|---------|
| `install.sh` | Install skills to project |
| `validate.sh` | Validate skill structure |

```bash
# Install all skills
./scripts/install.sh --all

# Install specific skill
./scripts/install.sh --skill pwa-ui

# Validate a skill
./scripts/validate.sh skills/frontend/pwa-ui
```

---

*Repository Version: 1.0.0*
