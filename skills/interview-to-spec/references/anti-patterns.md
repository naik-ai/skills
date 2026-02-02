# Interview Anti-Patterns

What BAD interviews look like and how to fix them.

## Question Anti-Patterns

### Too Generic

```
❌ BAD: "What features do you want?"
✅ GOOD: "Walk me through your user's worst day. What goes wrong?
         What would make it better?"

❌ BAD: "Do you need authentication?"
✅ GOOD: "Who should NOT be able to access this? What happens
         if they try?"

❌ BAD: "What database do you want to use?"
✅ GOOD: "Your data has [these relationships]. Walk me through
         a query you'll run 1000 times per second."

❌ BAD: "What's your tech stack?"
✅ GOOD: "Your users are on mobile with spotty connectivity.
         Walk me through how they use this offline."
```

### Too Leading

```
❌ BAD: "You probably want React for this, right?"
✅ GOOD: "What frontend experience does your team have?
         What are the rendering requirements?"

❌ BAD: "Should we use PostgreSQL since it's the best choice?"
✅ GOOD: "What are your query patterns? What's the data volume?
         What consistency guarantees do you need?"

❌ BAD: "We should probably use WebSockets for this"
✅ GOOD: "What's the actual latency requirement? 100ms? 1 second?
         That determines the architecture."
```

### Too Many at Once

```
❌ BAD: "What's the auth flow, and how do you handle roles, and
        what about password reset, and do you need SSO?"

✅ GOOD: "Let's start with authentication. Who needs access?"
        [wait for answer]
        "How do they prove their identity?"
        [wait for answer]
        "What happens when they forget their password?"
        [wait for answer]
```

### Too Shallow

```
❌ BAD:
User: "We need real-time updates"
Claude: "Okay, noted. What else?"

✅ GOOD:
User: "We need real-time updates"
Claude: "When you say 'real-time', what latency is acceptable?
         Under 100ms like a game? Under 1 second like chat?
         Under 5 seconds like a dashboard?"
```

## Behavioral Anti-Patterns

### Accepting Vague Answers

```
❌ BAD:
User: "The UI should be simple"
Claude: "Great, keeping it simple. Moving on..."

✅ GOOD:
User: "The UI should be simple"
Claude: "Define 'simple' for me. Show me an example of
         an app you consider simple. What specifically
         makes it simple — fewer features, cleaner design,
         faster flow?"
```

### Not Challenging Assumptions

```
❌ BAD:
User: "We need to store everything in one database"
Claude: "Okay, single database it is."

✅ GOOD:
User: "We need to store everything in one database"
Claude: "What's driving that constraint? Different data
         might have different query patterns. Walk me through
         your most frequent reads and writes."
```

### Stopping Too Early

```
❌ BAD:
[After 5 questions]
Claude: "I think I have enough. Let me write the spec."

✅ GOOD:
[After 20+ questions, covering all 5 phases]
Claude: "Let me summarize what I've understood...
         [comprehensive summary]
         What did I miss? What did I get wrong?"
```

### Being Too Polite

```
❌ BAD:
User: "We'll figure out the edge cases later"
Claude: "That sounds reasonable. Let's move on."

✅ GOOD:
User: "We'll figure out the edge cases later"
Claude: "That's exactly where projects die. Let me ask about
         just three critical edge cases now: What happens when
         [scenario 1]? What about [scenario 2]? And [scenario 3]?"
```

### Solutioning Too Early

```
❌ BAD:
User: "I need user authentication"
Claude: "Great, we'll use NextAuth with JWT tokens stored in..."

✅ GOOD:
User: "I need user authentication"
Claude: "Before we pick a solution — who are your users?
         Are they technical? What devices do they use?
         What's your team's experience with auth systems?"
```

## Spec Output Anti-Patterns

### Too Brief

```
❌ BAD:
## Authentication
- Users can log in
- Users can log out

✅ GOOD:
## Authentication

### Login Flow
1. User enters email on /login
2. System sends magic link to email
3. Link expires after 15 minutes
4. Clicking link creates session (7 day expiry)
5. Session stored in httpOnly cookie

### Logout Flow
1. User clicks logout button
2. Session invalidated server-side
3. Cookie cleared
4. Redirect to /login

### Edge Cases
| Scenario | Behavior |
|----------|----------|
| Expired link | Show "Link expired, request new one" |
| Already logged in | Skip login, redirect to /dashboard |
| Multiple tabs | All tabs logged out on logout |
```

### Missing Edge Cases

```
❌ BAD:
## File Upload
Users can upload files to their account.

✅ GOOD:
## File Upload

### Happy Path
User selects file → progress bar → upload complete → file appears in list

### Edge Cases
| Scenario | Behavior |
|----------|----------|
| File too large (>100MB) | Block upload, show error before starting |
| Connection lost mid-upload | Pause, show retry button |
| Unsupported type | Block upload, list supported types |
| Storage quota exceeded | Show upgrade prompt |
| Duplicate filename | Append (1), (2), etc. |
| Special characters in name | Sanitize, keep alphanumeric only |
| Zero-byte file | Accept but flag as potentially corrupt |
| Upload cancelled | Clean up partial file immediately |
```

### Missing Technical Details

```
❌ BAD:
## API
The API will handle all requests.

✅ GOOD:
## API Specification

### Endpoint: POST /api/v1/uploads

**Request**
- Method: POST
- Content-Type: multipart/form-data
- Auth: Bearer token required
- Rate limit: 10 uploads/minute

**Request Body**
| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| file | binary | yes | max 100MB |
| folder_id | UUID | no | must exist |

**Response 201**
```json
{
  "data": {
    "id": "uuid",
    "name": "string",
    "size": 12345,
    "mime_type": "image/png",
    "url": "string",
    "created_at": "ISO8601"
  }
}
```

**Errors**
| Status | Code | When |
|--------|------|------|
| 400 | FILE_TOO_LARGE | >100MB |
| 400 | UNSUPPORTED_TYPE | Not in allowed list |
| 401 | AUTH_REQUIRED | No/invalid token |
| 413 | QUOTA_EXCEEDED | User storage full |
```

### No Prioritization

```
❌ BAD:
## Features
- User profiles
- Search
- Notifications
- Analytics dashboard
- Dark mode
- Export to PDF
- Integrations

✅ GOOD:
## Feature Priority

### Phase 1: MVP (Must Have)
| Feature | Why Critical |
|---------|--------------|
| User profiles | Core identity |
| Search | Primary action |

### Phase 2: Enhancement (Should Have)
| Feature | Why Important |
|---------|---------------|
| Notifications | Engagement |
| Dark mode | Accessibility |

### Phase 3: Future (Nice to Have)
| Feature | Why Deferred |
|---------|--------------|
| Analytics | Not core to MVP |
| PDF export | Low usage expected |
| Integrations | Needs partner setup |
```

## Interview Flow Anti-Patterns

### No Structure

```
❌ BAD:
"Tell me about your app"
"What else?"
"And then what?"
"Okay, anything else?"
"I think I have enough."

✅ GOOD:
"Let's start with Phase 1: Core Understanding. Who is this for?"
[complete phase 1]
"Good, I can explain this back now. Moving to Phase 2: Technical Deep Dive..."
[complete phase 2]
"I could draw the architecture now. Phase 3: UX/UI Exploration..."
[and so on through all 5 phases]
```

### Not Summarizing

```
❌ BAD:
[After 30 minutes of questions]
Claude: "Okay, let me write the spec now."

✅ GOOD:
[After completing all phases]
Claude: "Let me summarize what I've understood:

You're building [X] for [audience].
The core flow is: [step by step].
The key technical decisions are: [list].
The main risks are: [list].
The MVP includes: [list].
Deferred to later: [list].

What did I miss? What did I get wrong?"
```

### No Follow-Up

```
❌ BAD:
User: "Users can create documents"
Claude: "Noted. What else?"

✅ GOOD:
User: "Users can create documents"
Claude: "Walk me through document creation step by step.
         What fields are required? Optional?
         Can they save drafts? Auto-save?
         What formats? Rich text? Markdown? Plain text?
         Collaborative editing or single-user?
         Version history? How many versions?
         Templates? Who creates them?"
```

## Recovery Patterns

When you realize you've fallen into an anti-pattern:

### Went Too Fast

```
"I realize I moved on too quickly. Let me back up.
When you said [X], I should have asked: [deeper question].
Can we explore that more?"
```

### Got Too Technical

```
"I've been asking a lot of technical questions.
Let me step back to the user experience.
Forget the implementation — what does the user see and do?"
```

### Missing Context

```
"I've been asking about features, but I don't fully understand
the problem. Can we go back to basics?
What's the pain point this solves?"
```

### Unclear Requirement

```
"I wrote down [X], but I'm not sure I understand it.
Can you give me a concrete example of how this would work?"
```
