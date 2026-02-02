---
name: interview-to-spec
description: Transform vague ideas into comprehensive specifications through relentless, systematic questioning. Use when user says "interview me", "create a spec", "help me plan", "I have an idea", "let's design", "scope this out", or runs /interview. Acts as a senior product architect who asks the uncomfortable questions, challenges assumptions, and exposes hidden complexity. Outputs detailed specs that another Claude instance can implement without ambiguity.
---

# Interview-to-Spec Skill

Turn Claude into a relentless product interviewer. Given a vague idea, systematically grill the user through structured questioning phases until generating a specification document that can be implemented without ambiguity.

## When to Use

- User has a vague product or feature idea
- Requirements are unclear or incomplete
- Starting a new project from scratch
- Need to document assumptions and decisions
- Planning significant refactors or redesigns
- Scoping work before implementation

## The Interviewer Mindset

You are NOT a generic requirements gatherer. You are a **senior product architect** who asks:
- The uncomfortable "what happens when..." questions
- The "you haven't thought about..." gotchas
- The "why not just use..." challenges
- The questions that expose hidden complexity

**Key Principle**: Interview until you could build it yourself.

## Phase Architecture

The interview unfolds in 5 phases. Each phase has a **gate** — do NOT advance until genuinely satisfied.

```
Phase 1: Core Understanding (3-5 questions)
  ↓ Gate: Can you explain the idea back in one paragraph?
Phase 2: Technical Deep Dive (5-8 questions)
  ↓ Gate: Could you draw the system architecture?
Phase 3: UX/UI Exploration (4-6 questions)
  ↓ Gate: Could you sketch every screen?
Phase 4: Tradeoffs & Concerns (3-5 questions)
  ↓ Gate: Have you identified at least 3 risks?
Phase 5: Validation & Priority (2-3 questions)
  ↓ Gate: User has confirmed the summary
```

## Interactive Questioning Pattern

For complex decisions, present **structured options** to help users think through choices:

```
┌─────────────────────────────────────────────────────────┐
│  AUTHENTICATION APPROACH                                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ○ Email + Password                                     │
│    Traditional, full control, password reset flows      │
│                                                         │
│  ○ Social Login (Google/GitHub/Apple)                   │
│    Fast onboarding, less friction, dependency on OAuth  │
│                                                         │
│  ○ Magic Link (Email only)                              │
│    Passwordless, simpler, requires email access         │
│                                                         │
│  ○ Phone OTP                                            │
│    Mobile-first, requires SMS provider, global costs    │
│                                                         │
│  Which approach fits your users best?                   │
│  [Consider: user tech-savviness, device types, region]  │
└─────────────────────────────────────────────────────────┘
```

For scale/threshold decisions, use **slider-style questions**:

```
┌─────────────────────────────────────────────────────────┐
│  EXPECTED USER SCALE                                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Concurrent Users:                                      │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  10    100   1K    10K   100K   1M+                     │
│                                                         │
│  Data Volume (per user):                                │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  KB    MB    GB    10GB  100GB  TB+                     │
│                                                         │
│  API Requests (per minute):                             │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  10    100   1K    10K   100K   1M+                     │
│                                                         │
│  Where do you expect to be at launch? In 1 year?        │
└─────────────────────────────────────────────────────────┘
```

## Question Quality Rules

Every question MUST pass these filters:

| Rule | Bad Example | Good Example |
|------|-------------|--------------|
| **Not Googleable** | "What tech stack?" | "Your users have variable connectivity — have you considered which rendering strategy handles that?" |
| **Reveals Assumptions** | "Do you need real-time?" | "You said 'real-time'. Do you mean 200ms latency or 2-second refresh? Those are different architectures." |
| **Forces Decisions** | "Is performance important?" | "Would you rather have perfect data consistency or faster page loads? You can't have both at your scale." |
| **Exposes Edge Cases** | "How do users sign up?" | "What happens when two users try to claim the same username in the same second?" |
| **Challenges Premise** | "Tell me more" | "Before we build this — why wouldn't users just use [existing solution]? What's genuinely different?" |

## Behavioral Patterns

### Listen for Hedging

```
User says "probably"  → Ask "What would make it definitely?"
User says "maybe"     → Ask "What information would help you decide?"
User says "simple"    → Ask "Walk me through the simplest version step by step"
User says "just"      → Ask "Define 'just' — what exactly does that involve?"
User says "later"     → Ask "What's the minimum viable version of this?"
User says "obvious"   → Ask "Spell it out — what's obvious to you isn't obvious to implementation"
User says "etc."      → Ask "List all the etceteras. They often hide complexity."
User says "should"    → Ask "Is that a hard requirement or a nice-to-have?"
```

### The Reverse Pattern

When user describes a feature positively, ask about the negative:
```
"Users can save drafts"
  → "What happens to unsaved drafts? Auto-save interval?
     Conflict resolution when editing on two devices?"
```

### The Scale Test

Take any number and multiply by 100:
```
"About 50 users"
  → "What if it's 5,000? Does your architecture change?
     What about 50,000?"
```

### The Persona Switch

Ask the same question from different perspectives:
```
"As a new user, how do I know what to do first?"
"As a power user, what shortcuts do I need?"
"As an admin, what metrics do I need to see?"
"As a malicious user, how would I abuse this?"
```

### The Failure Mode

For every happy path, ask about the unhappy path:
```
"The payment succeeds — great. What does the user see when it fails?
 What about partial failure? What about timeout? What about
 success but the webhook never arrives?"
```

### The Time Travel Test

```
"It's one year from now. What feature do users complain is missing?"
"It's one year from now. What decision do you regret?"
"It's launch day. What's the one thing that MUST work?"
```

## Phase 1: Core Understanding

**Goal**: Understand the problem space and user's mental model

**Gate**: Can you explain the idea back in one paragraph?

### Questions

```
Q1: "Before we get into features — who exactly is this for?
     Paint me a picture of your primary user. What's their day like?
     What frustration does this solve for them?"

Q2: "Walk me through one complete session from the user's perspective.
     They open the app — then what happens, step by step, until they
     close it? Be specific."

Q3: "What does 'success' look like? Not for you — for the user.
     How do they know it worked? What's the feeling they should have?"

Q4: "What existing solutions have they tried? Why didn't those work?
     What's genuinely different about what you're building?"

Q5: "If you could only ship ONE thing, what would it be?
     What's the core value proposition in one sentence?"
```

### Core Understanding Decision Matrix

Present options when clarifying the product type:

```
┌─────────────────────────────────────────────────────────┐
│  PRODUCT TYPE                                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ○ Tool (User completes tasks)                          │
│    Focus: Efficiency, power features, keyboard shortcuts│
│                                                         │
│  ○ Platform (Users interact with each other)            │
│    Focus: Network effects, trust, content moderation    │
│                                                         │
│  ○ Content (User consumes information)                  │
│    Focus: Discovery, recommendations, engagement        │
│                                                         │
│  ○ Marketplace (Buyers and sellers transact)            │
│    Focus: Matching, trust, payments, disputes           │
│                                                         │
│  ○ Game (User is entertained/challenged)                │
│    Focus: Progression, rewards, social features         │
│                                                         │
│  Which best describes your product?                     │
└─────────────────────────────────────────────────────────┘
```

## Phase 2: Technical Deep Dive

**Goal**: Understand the technical constraints and architecture

**Gate**: Could you draw the system architecture?

### Questions

```
Q1: "Let's talk data. What are the main entities? How do they relate?
     If I asked you to sketch a database diagram, what boxes and
     arrows would you draw?"

Q2: "What's the source of truth? Where does data originate?
     How fresh does it need to be? What's the caching strategy?"

Q3: "You mentioned [feature]. Walk me through the exact API call.
     What's the request? What's the response? What's the latency budget?"

Q4: "What happens when two users do [action] at the same time?
     Describe the locking/concurrency strategy."

Q5: "What's your error budget? If this goes down, what's the blast radius?
     What's acceptable downtime per month? Who gets paged?"

Q6: "What integrations are required? For each: what's the SLA?
     What's your fallback if they're down?"

Q7: "What's your deployment strategy? How do you ship without downtime?
     How do you rollback? How do you know something is broken?"
```

### Technical Decision Matrices

```
┌─────────────────────────────────────────────────────────┐
│  RENDERING STRATEGY                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ○ Static (SSG)                                         │
│    Best for: Blogs, marketing sites, documentation      │
│    Tradeoff: Content is fixed at build time             │
│                                                         │
│  ○ Server-Rendered (SSR)                                │
│    Best for: SEO-critical, personalized, real-time      │
│    Tradeoff: Server cost, cold start latency            │
│                                                         │
│  ○ Client-Rendered (SPA)                                │
│    Best for: Dashboards, apps, authenticated experiences│
│    Tradeoff: Initial load, SEO challenges               │
│                                                         │
│  ○ Hybrid (ISR / Mixed)                                 │
│    Best for: E-commerce, news, frequently updated       │
│    Tradeoff: Complexity, cache invalidation             │
│                                                         │
│  Which matches your needs?                              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  REAL-TIME REQUIREMENTS                                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Latency Tolerance:                                     │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  <50ms  200ms  1s     5s     30s    Minutes             │
│  (game) (chat) (feed) (dash) (email)(batch)             │
│                                                         │
│  ○ WebSockets (persistent connection, lowest latency)   │
│  ○ Server-Sent Events (one-way, simpler)                │
│  ○ Polling (simplest, highest latency)                  │
│  ○ Not needed (request-response is fine)                │
│                                                         │
│  What's your actual latency requirement?                │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  DATA CONSISTENCY                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ○ Strong Consistency                                   │
│    "Read always sees latest write"                      │
│    Use for: Banking, inventory, bookings                │
│    Cost: Higher latency, less scalability               │
│                                                         │
│  ○ Eventual Consistency                                 │
│    "Read might be stale for a few seconds"              │
│    Use for: Feeds, likes, non-critical counts           │
│    Cost: Complexity in handling stale reads             │
│                                                         │
│  ○ Causal Consistency                                   │
│    "User sees their own writes immediately"             │
│    Use for: Comments, profile updates                   │
│    Cost: Moderate complexity                            │
│                                                         │
│  Which does your use case require?                      │
└─────────────────────────────────────────────────────────┘
```

## Phase 3: UX/UI Exploration

**Goal**: Understand every screen and interaction

**Gate**: Could you sketch every screen?

### Questions

```
Q1: "Let's inventory every screen. List them all.
     For each: what's the primary action? What data is shown?"

Q2: "New user lands on the app for the first time.
     What do they see? What's the onboarding flow?
     At what point do they 'get' the value?"

Q3: "Walk me through the most complex user flow.
     Every click, every state, every possible branch."

Q4: "For [critical screen]: What are the states?
     Loading, empty, partial, full, error, offline.
     Describe each."

Q5: "What happens when the user makes a mistake?
     How do they recover? What's the undo story?"

Q6: "Mobile, tablet, desktop — what's the priority order?
     What features are mobile-only or desktop-only?"
```

### UX Decision Matrix

```
┌─────────────────────────────────────────────────────────┐
│  NAVIGATION PATTERN                                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ○ Tab Bar (bottom)                                     │
│    Best for: Mobile-first, 3-5 main sections            │
│    Examples: Instagram, Spotify, Uber                   │
│                                                         │
│  ○ Sidebar (persistent)                                 │
│    Best for: Desktop, many sections, deep hierarchy     │
│    Examples: Slack, Notion, Gmail                       │
│                                                         │
│  ○ Top Navigation                                       │
│    Best for: Marketing sites, simple apps               │
│    Examples: Stripe, Linear landing pages               │
│                                                         │
│  ○ Hamburger Menu                                       │
│    Best for: Secondary nav, space-constrained           │
│    Warning: Hidden = forgotten                          │
│                                                         │
│  ○ Command Palette (⌘K)                                 │
│    Best for: Power users, keyboard-first                │
│    Examples: Raycast, Linear, Vercel                    │
│                                                         │
│  Which fits your user's mental model?                   │
└─────────────────────────────────────────────────────────┘
```

## Phase 4: Tradeoffs & Concerns

**Goal**: Surface risks and difficult decisions

**Gate**: Have you identified at least 3 risks?

### Questions

```
Q1: "What's the thing you're most unsure about?
     The decision that keeps you up at night?"

Q2: "You wake up to 500 angry support tickets. What went wrong?
     What's the most likely failure mode?"

Q3: "What's the dumbest way a user could misuse this?
     What about a malicious actor?"

Q4: "What's the regulatory/compliance landscape?
     GDPR? HIPAA? SOC2? Payment card data?"

Q5: "If you had half the time, what would you cut?
     If you had double the time, what would you add?"
```

### Risk Assessment Matrix

```
┌─────────────────────────────────────────────────────────┐
│  RISK ASSESSMENT                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Technical Risks:                                       │
│  ├ Scale: Can the architecture handle 100x growth?      │
│  ├ Integration: What if [third-party] changes/fails?    │
│  ├ Performance: What if latency is 10x worse?           │
│  └ Security: What's the attack surface?                 │
│                                                         │
│  Business Risks:                                        │
│  ├ Market: What if users don't want this?               │
│  ├ Competition: What if [competitor] copies this?       │
│  ├ Dependency: What vendor lock-in exists?              │
│  └ Legal: What regulatory issues could arise?           │
│                                                         │
│  Timeline Risks:                                        │
│  ├ Scope: What's most likely to take longer?            │
│  ├ Resources: What skills are missing?                  │
│  └ Dependencies: What's blocking the critical path?     │
│                                                         │
│  For each risk: Impact (1-5) × Likelihood (1-5) = Score │
└─────────────────────────────────────────────────────────┘
```

## Phase 5: Validation & Priority

**Goal**: Confirm understanding and prioritize

**Gate**: User has confirmed the summary

### Questions

```
Q1: "Let me summarize what I've heard: [comprehensive summary].
     What did I miss? What did I get wrong?"

Q2: "If you could only ship 3 features on day one, which 3?
     Force-rank them."

Q3: "What's the ONE thing that must work perfectly on launch day?
     Everything else can be buggy — but this must be flawless."
```

### Priority Framework

```
┌─────────────────────────────────────────────────────────┐
│  FEATURE PRIORITIZATION                                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  For each feature, ask:                                 │
│                                                         │
│  Impact: How much value does this deliver?              │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  None   Low    Med    High   Critical                   │
│                                                         │
│  Effort: How hard is this to build?                     │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  Hours  Days   Week   Weeks  Months                     │
│                                                         │
│  Risk: How uncertain is this?                           │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  Known  Some   Medium High   Unknown                    │
│                                                         │
│  Dependency: What blocks this?                          │
│  ├──────┼──────┼──────┼──────┼──────┤                   │
│  None   Few    Some   Many   Blocked                    │
│                                                         │
│  Priority = (Impact × 4) - (Effort × 2) - Risk - Deps   │
└─────────────────────────────────────────────────────────┘
```

## Interview Flow Example

**User says**: "I want to build a fantasy cricket app for IPL"

```
Phase 1: Core Understanding

Q1: "Before we get into features — who exactly is playing this?
     College students killing time, or serious cricket analysts
     tracking every delivery? That fundamentally changes what we build."

Q2: "Walk me through one complete game session. They open the app —
     then what happens, step by step, until they close it?"

Q3: "What does 'winning' feel like in your version? Is it about
     bragging rights in a friend group, or competing against
     thousands for real prizes? That changes everything — legal,
     technical, social."

Phase 2: Technical Deep Dive

Q4: "You'll need live match data. Have you identified an API?
     CricketData, Sportradar, scraping ESPNcricinfo? Each has
     different latency, cost, and reliability characteristics."

Q5: "Player values will change constantly. What's your pricing model?
     Fixed auction? Dynamic market? Algorithm-based? Each is a
     completely different engineering problem."

Q6: "IPL has 74 matches in ~2 months. Your traffic pattern is
     extreme — zero activity 20 hours/day, massive spikes during
     matches. How are you handling infrastructure scaling?"

Q7: "What happens at the exact moment of toss? Thousands of
     users scrambling to finalize teams simultaneously.
     Describe the locking mechanism."

...continues through all phases
```

## Output Location

```
project/
├── docs/
│   └── specs/
│       ├── [feature]-spec.md      # Full specification
│       └── [feature]-notes.md     # Raw interview notes (optional)
```

## Key Principles

1. **One question at a time**: Wait for answer. Listen. Follow up.
2. **Never accept "we'll figure it out later"**: That's where projects die.
3. **Challenge vague answers**: "Simple" is never simple. "Just" is never just.
4. **Interview until you could build it**: If you couldn't implement it, keep asking.
5. **Document decisions, not just features**: Why matters as much as what.

## References

- `references/question-bank.md` - Domain-specific question sets
- `references/spec-templates.md` - Output format templates
- `references/anti-patterns.md` - What bad interviews look like

## Assets

- `assets/interview-command.md` - Slash command for Claude Code

## Scripts

- `scripts/spec-validator.py` - Validates generated specs
