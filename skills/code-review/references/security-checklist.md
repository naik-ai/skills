# Security Review Checklist

## Injection Attacks

### SQL Injection
```typescript
// ❌ Vulnerable
db.query(`SELECT * FROM users WHERE email = '${email}'`);

// ✅ Safe - Parameterized
db.query('SELECT * FROM users WHERE email = $1', [email]);
```

### Command Injection
```typescript
// ❌ Vulnerable
exec(`convert ${userFilename} output.png`);

// ✅ Safe - Avoid shell, use arrays
execFile('convert', [userFilename, 'output.png']);
```

### NoSQL Injection
```typescript
// ❌ Vulnerable
db.users.find({ username: req.body.username });
// Attacker sends: { "$gt": "" }

// ✅ Safe - Validate type
if (typeof req.body.username !== 'string') throw new Error();
db.users.find({ username: req.body.username });
```

## Cross-Site Scripting (XSS)

### DOM XSS
```typescript
// ❌ Vulnerable
element.innerHTML = userInput;
document.write(userInput);

// ✅ Safe
element.textContent = userInput;
```

### React XSS
```tsx
// ❌ Vulnerable
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ Safe (React auto-escapes)
<div>{userInput}</div>

// ✅ If HTML needed, sanitize first
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

## Authentication

### Password Storage
```typescript
// ❌ Never store plaintext
await db.user.create({ password: req.body.password });

// ✅ Always hash
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(req.body.password, 12);
await db.user.create({ password: hash });
```

### Session Security
```typescript
// ✅ Secure cookie settings
res.cookie('session', token, {
  httpOnly: true,     // No JS access
  secure: true,       // HTTPS only
  sameSite: 'strict', // CSRF protection
  maxAge: 3600000,    // 1 hour
});
```

### JWT Security
```typescript
// ❌ Weak
jwt.sign(payload, 'secret');

// ✅ Strong secret, proper algorithm
jwt.sign(payload, process.env.JWT_SECRET, {
  algorithm: 'HS256',
  expiresIn: '1h',
});

// ✅ Always verify
jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ['HS256'], // Prevent algorithm confusion
});
```

## Authorization

### Broken Access Control
```typescript
// ❌ No authorization check
app.get('/api/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
});

// ✅ Verify ownership
app.get('/api/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  if (user.id !== req.user.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  res.json(user);
});
```

### IDOR (Insecure Direct Object Reference)
```typescript
// ❌ Predictable IDs expose data
GET /api/invoices/12345

// ✅ Use UUIDs + ownership check
GET /api/invoices/550e8400-e29b-41d4-a716-446655440000
// + verify req.user owns this invoice
```

## Data Exposure

### Sensitive Data in Logs
```typescript
// ❌ Logs sensitive data
console.log('User login:', { email, password });

// ✅ Redact sensitive fields
console.log('User login:', { email, password: '[REDACTED]' });
```

### API Response Filtering
```typescript
// ❌ Returns everything including password hash
res.json(user);

// ✅ Select only needed fields
res.json({
  id: user.id,
  email: user.email,
  name: user.name,
});
```

### Error Messages
```typescript
// ❌ Reveals internal details
catch (err) {
  res.status(500).json({ error: err.stack });
}

// ✅ Generic message, log details server-side
catch (err) {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
}
```

## Input Validation

### Required Checks
```typescript
// Validate all user input
const schema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150),
});

const validated = schema.parse(req.body);
```

### File Upload
```typescript
// ✅ Validate file type, size, name
const allowedTypes = ['image/jpeg', 'image/png'];
const maxSize = 5 * 1024 * 1024; // 5MB

if (!allowedTypes.includes(file.mimetype)) throw new Error();
if (file.size > maxSize) throw new Error();

// Sanitize filename
const safeName = path.basename(file.originalname).replace(/[^a-zA-Z0-9.-]/g, '_');
```

## CSRF Protection

```typescript
// ✅ Use CSRF tokens
import csrf from 'csurf';
app.use(csrf({ cookie: true }));

// In forms
<input type="hidden" name="_csrf" value={csrfToken} />

// For APIs, use SameSite cookies + check Origin header
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// ✅ Protect sensitive endpoints
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts',
});

app.post('/login', loginLimiter, loginHandler);
```

## Secrets Management

```typescript
// ❌ Never commit secrets
const apiKey = 'sk-1234567890abcdef';

// ✅ Use environment variables
const apiKey = process.env.API_KEY;

// ✅ Validate required env vars at startup
const requiredEnvVars = ['DATABASE_URL', 'API_KEY', 'JWT_SECRET'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Missing required env var: ${envVar}`);
  }
}
```
