---
name: code-review
description: Perform systematic code reviews with actionable feedback. Use when user says "review this code", "check my implementation", "/review", "find bugs", "code quality check", or "PR review". Analyzes code for bugs, security issues, performance problems, and style consistency. Outputs structured feedback with severity levels and specific fix suggestions.
---

# Code Review Skill

Systematic code review methodology that produces actionable, prioritized feedback.

## When to Use

- Reviewing pull requests or code changes
- Checking implementation before merge
- Auditing existing code for issues
- Learning best practices from code examples
- Pre-commit quality checks

## Workflow

### Phase 1: Context Understanding

**Goal**: Understand what the code is supposed to do

**Actions**:
1. Read any PR description or commit messages
2. Identify the feature/fix being implemented
3. Note the affected areas (files, functions, modules)
4. Check for related tests

**Output**: Mental model of intended behavior

### Phase 2: Systematic Review

**Goal**: Analyze code across multiple dimensions

**Review Checklist**:

```markdown
## Correctness
- [ ] Logic implements requirements correctly
- [ ] Edge cases handled
- [ ] Error conditions handled
- [ ] No off-by-one errors
- [ ] Null/undefined checks where needed

## Security
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Input validation present
- [ ] Authentication/authorization correct
- [ ] Secrets not hardcoded
- [ ] No sensitive data in logs

## Performance
- [ ] No N+1 queries
- [ ] Appropriate data structures used
- [ ] No unnecessary re-renders (React)
- [ ] Database queries optimized
- [ ] No memory leaks

## Maintainability
- [ ] Code is readable and self-documenting
- [ ] Functions have single responsibility
- [ ] No code duplication
- [ ] Appropriate abstraction level
- [ ] Follows project conventions

## Testing
- [ ] Tests cover happy path
- [ ] Tests cover edge cases
- [ ] Tests cover error cases
- [ ] Tests are deterministic
- [ ] Mocks are appropriate
```

**Output**: List of findings

### Phase 3: Feedback Formatting

**Goal**: Present findings in actionable format

**Actions**:
1. Categorize by severity
2. Provide specific fix suggestions
3. Include code examples where helpful
4. Prioritize critical issues first

**Output**: Structured review feedback

## Feedback Format

```markdown
## Code Review: [File/PR Name]

### Summary
[1-2 sentence overview of the changes and overall assessment]

### Critical Issues 🔴
[Must fix before merge]

#### Issue 1: [Title]
**Location**: `path/to/file.ts:42`
**Problem**: [What's wrong]
**Impact**: [Why it matters]
**Fix**:
```typescript
// Instead of this:
[current code]

// Do this:
[suggested fix]
```

### Warnings ⚠️
[Should fix, but not blocking]

#### Issue 2: [Title]
**Location**: `path/to/file.ts:87`
**Problem**: [What's wrong]
**Suggestion**: [How to improve]

### Suggestions 💡
[Nice to have improvements]

### Positive Notes ✅
[What was done well - important for morale]

- Good use of [pattern] in [location]
- Clear naming in [function]
- Thorough error handling in [area]
```

## Review Patterns

### Security Review

```typescript
// 🔴 SQL Injection
const query = `SELECT * FROM users WHERE id = ${userId}`; // BAD
const query = 'SELECT * FROM users WHERE id = $1'; // GOOD

// 🔴 XSS Vulnerability
element.innerHTML = userInput; // BAD
element.textContent = userInput; // GOOD

// 🔴 Hardcoded Secrets
const apiKey = 'sk-1234567890'; // BAD
const apiKey = process.env.API_KEY; // GOOD

// 🔴 Missing Auth Check
app.get('/admin/users', (req, res) => { ... }); // BAD
app.get('/admin/users', requireAdmin, (req, res) => { ... }); // GOOD
```

### Performance Review

```typescript
// 🔴 N+1 Query
const users = await User.findAll();
for (const user of users) {
  user.posts = await Post.findAll({ where: { userId: user.id } }); // BAD
}

// ✅ Eager Loading
const users = await User.findAll({
  include: [{ model: Post }], // GOOD
});

// 🔴 Unnecessary Re-renders (React)
function Component({ items }) {
  const sorted = items.sort(); // BAD - mutates and triggers re-render
  return <List items={sorted} />;
}

// ✅ Memoized
function Component({ items }) {
  const sorted = useMemo(() => [...items].sort(), [items]); // GOOD
  return <List items={sorted} />;
}
```

### Logic Review

```typescript
// 🔴 Off-by-one Error
for (let i = 0; i <= array.length; i++) { } // BAD - goes past end

// ✅ Correct Bounds
for (let i = 0; i < array.length; i++) { } // GOOD

// 🔴 Missing Null Check
function getName(user) {
  return user.profile.name; // BAD - crashes if profile is null
}

// ✅ Safe Access
function getName(user) {
  return user?.profile?.name ?? 'Unknown'; // GOOD
}

// 🔴 Type Coercion Bug
if (value == null) { } // BAD - catches both null and undefined unexpectedly

// ✅ Explicit Check
if (value === null || value === undefined) { } // GOOD - explicit intent
```

### Style Review

```typescript
// ⚠️ Inconsistent Naming
const getUserData = () => { };  // camelCase
const fetch_posts = () => { };  // snake_case - inconsistent

// ⚠️ Magic Numbers
if (retryCount > 3) { } // BAD - what's 3?
const MAX_RETRIES = 3;
if (retryCount > MAX_RETRIES) { } // GOOD

// ⚠️ Long Function
function doEverything() {
  // 200 lines of code
}

// ✅ Single Responsibility
function validateInput() { }
function processData() { }
function saveResult() { }
```

## Severity Guidelines

| Severity | Criteria | Action |
|----------|----------|--------|
| 🔴 Critical | Security vulnerability, data loss risk, crash | Block merge |
| 🔴 Critical | Incorrect business logic | Block merge |
| ⚠️ Warning | Performance issue, code smell | Request fix |
| ⚠️ Warning | Missing error handling | Request fix |
| 💡 Suggestion | Style improvement, refactoring | Optional |
| 💡 Suggestion | Documentation improvement | Optional |

## Review Communication

### Constructive Phrasing

| Instead of | Say |
|------------|-----|
| "This is wrong" | "This might cause [issue] because..." |
| "Why did you do this?" | "I'm curious about the reasoning for..." |
| "This is bad code" | "Consider [alternative] for better [benefit]" |
| "You should know..." | "One pattern that helps here is..." |

### Asking Questions

```markdown
// Good review question format
"What happens if [edge case]? I want to make sure we handle..."

"I see this pattern - was this intentional for [reason], or would
[alternative] work better here?"

"Could you help me understand the tradeoff between [A] and [B] here?"
```

## Common Mistakes (Reviewer)

| Mistake | Problem | Fix |
|---------|---------|-----|
| Nitpicking style | Frustrates author | Use linters for style |
| No positive feedback | Demoralizing | Always note what's good |
| Vague feedback | Can't be actioned | Be specific with fixes |
| Reviewing too much at once | Misses issues | Review in chunks |
| Blocking on opinions | Delays delivery | Distinguish must-fix from preferences |

## Key Principles

1. **Be kind**: There's a human on the other side
2. **Be specific**: Point to exact lines, provide exact fixes
3. **Be timely**: Review promptly to unblock others
4. **Prioritize**: Focus on what matters most
5. **Learn**: Every review is a chance to learn something

## References

- `references/security-checklist.md` - Detailed security review checklist
- `references/language-patterns.md` - Language-specific anti-patterns
