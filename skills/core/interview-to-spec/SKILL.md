---
name: interview-to-spec
description: Interview users in-depth to create comprehensive specification documents. Use when user says "interview me", "create a spec", "help me plan", "I have an idea", "let's design", or runs /interview. Transforms vague ideas into detailed, actionable specifications through systematic questioning. Outputs structured spec files for implementation planning.
---

# Interview-to-Spec Skill

Transform vague ideas into comprehensive, actionable specifications through systematic deep questioning.

## When to Use

- User has a new feature or product idea
- Requirements are unclear or incomplete
- Starting a new project from scratch
- Need to document existing mental models
- Planning a significant refactor or redesign

## Workflow

### Phase 1: Context Gathering

**Goal**: Understand the problem space and user's mental model

**Questions to Ask**:
1. "What problem are you trying to solve?"
2. "Who is this for? Describe your target user."
3. "What does success look like?"
4. "What existing solutions have you tried or seen?"
5. "What constraints do you have? (time, budget, tech stack)"

**Output**: Problem statement and context summary

### Phase 2: Deep Dive

**Goal**: Extract detailed requirements through iterative questioning

**Techniques**:
- **5 Whys**: Keep asking "why" to uncover root needs
- **Edge Cases**: "What happens when X fails/is empty/exceeds limits?"
- **User Journeys**: "Walk me through how a user would..."
- **Negative Space**: "What should this NOT do?"

**Question Patterns**:
```
"You mentioned [X]. Can you elaborate on..."
"What happens if [edge case]?"
"How would [user type] use this differently?"
"What's the most important thing to get right?"
"What would make this a failure?"
```

**Output**: Detailed requirements list

### Phase 3: Specification Writing

**Goal**: Produce structured, actionable spec document

**Actions**:
1. Synthesize answers into structured sections
2. Identify ambiguities and resolve with follow-ups
3. Define acceptance criteria for each requirement
4. Prioritize features (must-have, should-have, nice-to-have)

**Output**: `docs/specs/[feature-name]-spec.md`

## Spec Document Template

```markdown
# [Feature Name] Specification

## Overview
[One paragraph summary of what this feature does and why]

## Problem Statement
[What problem does this solve? Who has this problem?]

## Goals
- [ ] Primary goal 1
- [ ] Primary goal 2

## Non-Goals
- [What this feature explicitly will NOT do]

## User Stories

### Story 1: [User Type] [Action]
**As a** [user type]
**I want to** [action]
**So that** [benefit]

**Acceptance Criteria**:
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Requirements

### Data Model
[Describe entities, relationships, key fields]

### API Endpoints
[List endpoints if applicable]

### UI Components
[List key screens/components if applicable]

## Edge Cases
| Scenario | Expected Behavior |
|----------|-------------------|
| [Edge case 1] | [How to handle] |

## Security Considerations
[Authentication, authorization, data privacy concerns]

## Dependencies
[External services, libraries, other features]

## Open Questions
- [ ] [Unresolved question 1]
- [ ] [Unresolved question 2]

## Priority
| Feature | Priority | Effort |
|---------|----------|--------|
| [Feature 1] | Must-have | Medium |
| [Feature 2] | Should-have | Low |
```

## Interview Patterns

### Opening the Interview

```
"I'd like to understand your idea deeply so we can build exactly
what you need. I'll ask a series of questions - some might seem
obvious, but they help ensure we don't miss anything. Ready?"
```

### Clarifying Vague Statements

| User Says | Ask |
|-----------|-----|
| "It should be fast" | "What response time would feel fast? Under 100ms? 1 second?" |
| "Users need to see their data" | "Which specific data? In what format? How often updated?" |
| "It should be secure" | "What's the sensitivity level? Who should/shouldn't access it?" |
| "Make it simple" | "Simple to use, simple to build, or both? Show me an example of 'simple' you like." |

### Uncovering Hidden Requirements

```
"Who else will interact with this besides the main user?"
"What reports or analytics will you need from this?"
"How will you know if this is working well?"
"What's your plan if this feature is wildly successful?"
"What happens to existing data/users when we launch this?"
```

### Closing the Interview

```
"Let me summarize what I've heard: [summary].
Did I miss anything important?
What's the ONE thing that must work perfectly on day one?"
```

## Question Bank by Domain

### For User-Facing Features
- "What's the first thing a user should see?"
- "What actions can they take? In what order?"
- "What feedback do they need after each action?"
- "How do they recover from mistakes?"
- "What's the mobile experience like?"

### For Data/Backend Features
- "What's the source of truth for this data?"
- "How fresh does the data need to be?"
- "What's the expected data volume?"
- "Who can read/write/delete this data?"
- "What happens if the data source is unavailable?"

### For Integrations
- "What systems does this need to talk to?"
- "What's the authentication method?"
- "What's the SLA/uptime requirement?"
- "How do we handle partial failures?"
- "Who maintains the integration long-term?"

## Output Locations

```
project/
├── docs/
│   └── specs/
│       ├── feature-name-spec.md    # Full specification
│       └── feature-name-notes.md   # Raw interview notes
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Accepting first answer | Surface-level requirements | Ask "why" 3+ times |
| Technical solutioning early | Constrains options | Focus on "what" before "how" |
| Skipping edge cases | Surprises during implementation | Explicitly ask about failures |
| Not prioritizing | Everything seems critical | Force-rank with "if you could only have one..." |
| Assuming shared vocabulary | Misunderstandings | Define terms explicitly |

## Key Principles

1. **Listen more than talk**: Your job is to extract, not to suggest
2. **No stupid questions**: Obvious questions often reveal assumptions
3. **Document everything**: Capture exact words, not interpretations
4. **Embrace ambiguity**: Unresolved questions are better than wrong assumptions
5. **Iterate**: Good specs emerge from multiple passes

## References

- `references/question-bank.md` - Extended question library by domain
- `references/spec-examples.md` - Example specifications
