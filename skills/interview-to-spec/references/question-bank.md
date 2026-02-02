# Interview Question Bank

Comprehensive domain-specific questions organized by product type and technical area. These are NOT generic — they are the questions that *actually matter* and that people *actually forget*.

## Universal Grilling Questions

Apply to EVERY project. Ask these regardless of domain:

```
"What's the dumbest way a user could misuse this?"

"You wake up to 500 angry support tickets. What went wrong?"

"If you could only ship 3 features, which 3? Force-rank them."

"What's the thing you're most unsure about?"

"Describe the first 30 seconds of a brand new user's experience."

"What existing tool are users currently using instead? Why will they switch?"

"If this is wildly successful, what problems does that create?"

"What happens to existing users/data when we ship this?"

"It's one year from now. What do users complain is missing?"

"What's the one thing that must work perfectly on day one?"
```

## By Product Type

### Web Application

**Authentication & Access**
- Authentication method? (email/password, social login, magic link, phone OTP, SSO?)
- Who can NOT access this? What happens when they try?
- Session length? Auto-logout policy? Multi-device?
- Password requirements? Reset flow? Account recovery?
- Rate limiting on login attempts? Brute force protection?

**State & Navigation**
- What happens on page refresh? Is state lost or preserved?
- What happens when user clicks back button?
- Multiple tabs open — do they sync or conflict?
- Deep linking — what URLs should work?
- Bookmarks — what should be bookmarkable?

**Data & Real-Time**
- What data is user-specific vs. shared?
- How fresh does data need to be? (real-time, near-time, cached?)
- Optimistic updates or wait for server confirmation?
- What happens when user is offline? PWA requirements?
- WebSocket vs polling vs SSE for updates?

**SEO & Performance**
- SEO requirements? Which pages need to be indexable?
- SSR, SSG, ISR, or client-only rendering?
- Core Web Vitals targets? LCP, FID, CLS budgets?
- Image handling? Lazy loading? CDN?
- What's the performance budget? Bundle size limit?

### Mobile Application

**Platform & Distribution**
- iOS, Android, or both? Priority order?
- React Native, Flutter, or native?
- App Store / Play Store requirements?
- Beta testing strategy? TestFlight / Firebase App Distribution?
- Update strategy? Force update for breaking changes?

**Offline & Sync**
- Offline-first or online-required?
- What data is cached locally? What's fetched?
- Conflict resolution when online data differs from local?
- Sync strategy — push, pull, or real-time?
- What happens with poor connectivity? Retry strategy?

**Device Features**
- Camera access? Photo library permissions?
- Location services? Background location?
- Push notifications? Notification preferences?
- Biometrics? Face ID / fingerprint?
- Deep linking / universal links?

**Performance**
- Battery impact? Background processing limits?
- Memory constraints? Large data handling?
- Network data usage concerns?
- Cold start time requirements?

### API / Backend

**Design & Contracts**
- REST, GraphQL, or gRPC?
- Versioning strategy? URL, header, or query param?
- Breaking change policy? Deprecation timeline?
- API key vs OAuth vs JWT for auth?
- Rate limiting? Per user, per IP, per key?

**Reliability**
- SLA requirements? Uptime target?
- Retry policy for failed requests?
- Idempotency for mutations?
- Timeout handling? Circuit breaker?
- Health check endpoints?

**Data & Validation**
- Request validation — where? How strict?
- Response pagination strategy?
- Error response format? Error codes?
- What data is nullable vs required?
- Input sanitization? XSS prevention?

**Webhooks & Async**
- Webhook retry policy?
- Dead letter queue for failed webhooks?
- Signature verification for incoming webhooks?
- Event ordering guarantees?
- Async job status polling?

### E-commerce

**Products & Inventory**
- Product catalog size? Variant complexity?
- Real-time inventory or eventual consistency?
- Overselling allowed or hard block?
- Pre-order / backorder handling?
- Digital vs physical products?

**Pricing & Promotions**
- Dynamic pricing? Time-based? User-based?
- Coupon codes? Stacking rules?
- Flash sales? Limited quantity handling?
- Subscription / recurring billing?
- Multi-currency support?

**Cart & Checkout**
- Guest checkout or login required?
- Cart persistence? Across devices?
- Cart abandonment — what data captured?
- Express checkout options?
- Address validation? Autocomplete?

**Payments & Compliance**
- Payment gateway? Stripe, Razorpay, Adyen?
- Refund policy? Partial refunds?
- Dispute / chargeback handling?
- PCI compliance requirements?
- Tax calculation? GST, VAT, Sales Tax?

**Fulfillment**
- Shipping carriers? Rate calculation?
- Order tracking integration?
- Multi-warehouse / dropship?
- Returns / exchanges flow?
- Delivery notifications?

### SaaS / B2B

**Multi-tenancy**
- Shared database or isolated per tenant?
- Data isolation requirements?
- Custom domains per tenant?
- Tenant-level configuration options?
- White-labeling requirements?

**Billing & Subscription**
- Pricing tiers? Feature gating?
- Free trial? Credit card required?
- Seat-based or usage-based billing?
- Upgrade / downgrade flows?
- Invoice generation? Payment terms?

**Team & Permissions**
- Role-based access control? What roles?
- Custom roles or predefined only?
- Invite flow? Email or link?
- SSO / SAML requirements?
- Audit logging? Who did what when?

**Onboarding & Adoption**
- Time to first value? What's the aha moment?
- Onboarding checklist? Progress tracking?
- In-app tutorials? Tooltips?
- Setup wizard or self-guided?
- Success metrics? How do you measure adoption?

### AI / ML Product

**Model Behavior**
- Deterministic or stochastic outputs?
- Temperature / randomness controls?
- Fallback when model fails?
- Confidence thresholds? When to abstain?
- Streaming responses or batch?

**Cost & Scale**
- Cost per inference? Budget limits?
- Rate limiting for expensive operations?
- Caching strategy for repeated queries?
- Batch vs real-time inference?
- GPU requirements? Serverless or dedicated?

**Evaluation & Quality**
- How do you know it's working?
- Ground truth dataset? A/B testing?
- User feedback collection?
- Model versioning? Rollback strategy?
- Regression testing for prompts?

**Ethics & Safety**
- Content filtering? Harmful output prevention?
- Bias detection? Fairness metrics?
- User consent for data usage?
- Explainability requirements?
- PII in prompts? Data retention?

### Platform / Marketplace

**Supply & Demand**
- Two-sided (buyers/sellers) or multi-sided?
- Chicken-and-egg — which side to build first?
- Network effects — how do they compound?
- Supply quality control? Verification?
- Matching algorithm? Search ranking?

**Trust & Safety**
- User verification? Identity, payment, reputation?
- Content moderation? Manual or automated?
- Dispute resolution process?
- Fraud detection? Prevention measures?
- Reporting / flagging mechanism?

**Transactions**
- Escrow? When is money released?
- Platform fee structure?
- Cancellation policy? Who bears cost?
- Refund / guarantee policy?
- Cross-border transactions?

## Edge Cases That ALWAYS Bite

### Time & Timezone

```
"What timezone is displayed? User's local, server, or data's origin?"

"What happens at midnight UTC? Day boundaries?"

"Daylight saving time — how do recurring events handle the switch?"

"Historical data — timezone at time of event or current?"

"Scheduling across timezones — what's the mental model?"
```

### Internationalization

```
"Right-to-left languages? Arabic, Hebrew?"

"Unicode in usernames? Emoji in data fields?"

"Number formatting? 1,234.56 vs 1.234,56?"

"Date formatting? MM/DD vs DD/MM?"

"Address formats? International variations?"

"Currency display? Decimal places per currency?"
```

### Concurrency

```
"Two users edit the same thing — who wins?"

"Optimistic locking or pessimistic locking?"

"What's the conflict resolution UI?"

"Real-time collaboration or turn-based editing?"

"Undo after someone else's change — what happens?"
```

### Rate of Change

```
"How often does this data change? Per second? Per day? Per month?"

"What triggers cache invalidation?"

"Event-driven updates or polling?"

"What's the acceptable staleness window?"

"Version numbers — who increments and when?"
```

### Migration & Legacy

```
"What happens to existing users when this ships?"

"Data migration strategy? Backfill required?"

"Breaking changes — forced upgrade or gradual?"

"Old API versions — sunset timeline?"

"Feature flags — cleanup strategy?"
```

### Scale Extremes

```
"What if there's 1 item? Does the UI break?"

"What if there's 1 million items? Pagination strategy?"

"Name is 1 character — is that valid?"

"Name is 1000 characters — truncation?"

"100 concurrent users doing this — race conditions?"

"Peak load is 1000x normal — scaling strategy?"
```

### Failure Modes

```
"Database is down — what does user see?"

"Third-party API times out — fallback behavior?"

"File upload fails halfway — resume or restart?"

"Payment succeeds but webhook fails — recovery?"

"Deploy fails midway — rollback or fix forward?"
```

## Questions That Reveal Hidden Complexity

```
"You said 'notification'. What kind? Push, email, in-app, SMS, all of them?"

"You said 'search'. Full-text? Filters? Fuzzy matching? Autocomplete?"

"You said 'export'. What format? PDF, CSV, Excel? How large can it be?"

"You said 'integration'. API, webhook, file upload, manual import?"

"You said 'analytics'. What metrics exactly? Real-time or historical?"

"You said 'admin'. What can admin do that users can't? List it all."

"You said 'settings'. List every toggle, dropdown, and text field."

"You said 'history'. How far back? Can it be deleted? Export?"
```

## Closing Questions

```
"What haven't I asked that I should have?"

"What keeps you up at night about this project?"

"What would make you regret building this?"

"If this is wildly successful, what breaks first?"

"What's the biggest technical risk you're aware of?"

"What's the biggest product risk — users not wanting this?"
```
