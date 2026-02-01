# Contributing to Claude Code Skills

Guidelines for adding, modifying, and maintaining skills in this repository.

## Adding a New Skill

### 1. Create Skill Directory

```bash
# Copy template
cp -r templates/skill-template skills/[category]/[skill-name]

# Categories: core, frontend, backend, media, devops, domain
```

### 2. Structure Your Skill

```
skill-name/
├── SKILL.md              # Required - Main instructions
├── scripts/              # Optional - Executable code
├── references/           # Optional - Detailed docs
└── assets/               # Optional - Templates
```

### 3. Write SKILL.md

Follow this template:

```markdown
---
name: skill-name
description: [What + When + Triggers]. Use when user says "[phrase1]", "[phrase2]", or "[phrase3]".
---

# Skill Title

[Overview paragraph - what this skill accomplishes]

## When to Use

- [Trigger condition 1]
- [Trigger condition 2]

## Workflow

### Phase 1: [Name]

**Goal**: [What this phase accomplishes]

**Actions**:
1. [Specific action]
2. [Specific action]

**Output**: [What's produced]

## Patterns

### Pattern 1: [Name]

**When to use**: [Condition]

```language
// Code example - copy-paste ready
```

**Why**: [Brief explanation]

## References

- `references/[file].md` - [Description]
```

## Skill Design Principles

| Principle | Description |
|-----------|-------------|
| **Single Purpose** | One skill = one job done well |
| **Self-Contained** | All needed info in skill |
| **Progressive Detail** | Overview first, details on demand |
| **Copy-Paste Ready** | All code examples work immediately |
| **Under 500 Lines** | Keep SKILL.md lean, use references |

## Writing Guidelines

### DO

- Use imperative voice ("Create", "Run", "Check")
- Include concrete examples for every pattern
- Specify exact file paths and commands
- Document edge cases and error handling
- Add comprehensive trigger phrases

### DON'T

- Use vague instructions ("consider doing X")
- Assume Claude knows domain-specific terms
- Duplicate content between SKILL.md and references
- Include setup instructions (skills are for Claude)
- Put version numbers in skill names

## Naming Conventions

```
# Format: [action]-[target] or [domain]-[capability]

# Good
pwa-ui              # Domain + Capability
react-best-practices # Framework + Type
postgres-fastapi    # Tech + Framework

# Avoid
my-cool-skill       # Not descriptive
skill-v2            # Version in name
helper              # Too vague
```

## Testing Your Skill

Before submitting:

```bash
# 1. Validate structure
./scripts/validate.sh skills/[category]/[skill-name]

# 2. Test in isolation
# Add only this skill to a test project

# 3. Test trigger phrases
# Try multiple ways of asking for what the skill does

# 4. Check output quality
# Verify consistent, high-quality output
```

## Pre-Submit Checklist

- [ ] SKILL.md has name and description in frontmatter
- [ ] Description includes trigger phrases
- [ ] Workflow is clear and step-by-step
- [ ] All code examples are copy-paste ready
- [ ] Edge cases are documented
- [ ] SKILL.md is under 500 lines
- [ ] References used for detailed content
- [ ] No duplicate content between files
- [ ] Tested in isolation
- [ ] Tested with multiple trigger phrases

## Pull Request Process

1. Create feature branch: `git checkout -b add-skill-name`
2. Add skill following guidelines
3. Run validation: `./scripts/validate.sh skills/[category]/[skill-name]`
4. Update README.md skill index if needed
5. Submit PR with description of:
   - What the skill does
   - Example use cases
   - Testing performed

## Updating Existing Skills

### Minor Updates

- Fix typos, clarify wording
- Add missing edge cases
- Improve code examples

### Major Updates

- Add new patterns or workflows
- Change output format
- Update to new framework versions

For major updates:
1. Document changes in PR description
2. Test existing use cases still work
3. Update any affected references

## Questions?

Open an issue for:
- Skill ideas
- Clarification on guidelines
- Feature requests
