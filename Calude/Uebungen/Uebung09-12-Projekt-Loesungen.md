# Übungen 9-12: Teil 2 - Security & Validation

## Fortsetzung Aufgabe 2: Auth Middleware

```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

function authenticate(req, res, next) {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ 
            error: 'No token provided' 
        });
    }
    
    const token = authHeader.split(' ')[1];
    
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        if (err.name === 'TokenExpiredError') {
            return res.status(401).json({ 
                error: 'Token expired' 
            });
        }
        return res.status(401).json({ 
            error: 'Invalid token' 
        });
    }
}

// Optional: Role-based middleware
function authorize(...roles) {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ 
                error: 'Unauthorized' 
            });
        }
        
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({ 
                error: 'Forbidden - insufficient permissions' 
            });
        }
        
        next();
    };
}

module.exports = { authenticate, authorize };
```

**Verwendung in Routes:**
```javascript
const { authenticate, authorize } = require('../middleware/auth');

// Geschützte Route - nur für authentifizierte User
router.get('/profile', authenticate, async (req, res) => {
    const user = await User.findByPk(req.user.id);
    res.json(user);
});

// Admin-only Route
router.delete('/books/:id', 
    authenticate, 
    authorize('admin'), 
    async (req, res) => {
        // Nur Admins können Bücher löschen
        await Book.destroy({ where: { id: req.params.id } });
        res.status(204).send();
    }
);
```

---

### Aufgabe 3: Input Validation (2 Punkte)

**Installation:**
```bash
npm install express-validator
```

**middleware/validation.js:**
```javascript
const { body, param, query, validationResult } = require('express-validator');

// Book Validation Rules
const bookValidation = {
    create: [
        body('title')
            .trim()
            .isLength({ min: 3, max: 200 })
            .withMessage('Title must be 3-200 characters'),
        body('author_id')
            .isInt({ min: 1 })
            .withMessage('Valid author_id is required'),
        body('isbn')
            .optional()
            .matches(/^[0-9-]{10,17}$/)
            .withMessage('Invalid ISBN format'),
        body('price')
            .optional()
            .isFloat({ min: 0, max: 9999.99 })
            .withMessage('Price must be between 0 and 9999.99')
    ],
    
    update: [
        param('id')
            .isInt({ min: 1 })
            .withMessage('Valid ID required'),
        body('title')
            .optional()
            .trim()
            .isLength({ min: 3, max: 200 })
            .withMessage('Title must be 3-200 characters'),
        body('price')
            .optional()
            .isFloat({ min: 0, max: 9999.99 })
            .withMessage('Price must be between 0 and 9999.99')
    ],
    
    getById: [
        param('id')
            .isInt({ min: 1 })
            .withMessage('Valid ID required')
    ],
    
    getAll: [
        query('limit')
            .optional()
            .isInt({ min: 1, max: 100 })
            .withMessage('Limit must be 1-100'),
        query('offset')
            .optional()
            .isInt({ min: 0 })
            .withMessage('Offset must be >= 0')
    ]
};

// User Validation Rules
const userValidation = {
    register: [
        body('username')
            .trim()
            .isLength({ min: 3, max: 50 })
            .withMessage('Username must be 3-50 characters')
            .matches(/^[a-zA-Z0-9_]+$/)
            .withMessage('Username can only contain letters, numbers and underscore'),
        body('email')
            .trim()
            .isEmail()
            .normalizeEmail()
            .withMessage('Valid email required'),
        body('password')
            .isLength({ min: 8 })
            .withMessage('Password must be at least 8 characters')
            .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
            .withMessage('Password must contain uppercase, lowercase and number')
    ],
    
    login: [
        body('username')
            .trim()
            .notEmpty()
            .withMessage('Username required'),
        body('password')
            .notEmpty()
            .withMessage('Password required')
    ]
};

// Validation middleware
function validate(req, res, next) {
    const errors = validationResult(req);
    
    if (!errors.isEmpty()) {
        return res.status(400).json({
            error: 'Validation failed',
            details: errors.array().map(err => ({
                field: err.path,
                message: err.msg,
                value: err.value
            }))
        });
    }
    
    next();
}

module.exports = { 
    bookValidation, 
    userValidation, 
    validate 
};
```

**Verwendung:**
```javascript
const { bookValidation, validate } = require('../middleware/validation');

router.post('/', 
    bookValidation.create, 
    validate, 
    async (req, res) => {
        // Validation erfolgreich, erstelle Buch
    }
);

router.put('/:id', 
    bookValidation.update, 
    validate, 
    async (req, res) => {
        // Validation erfolgreich, update Buch
    }
);
```

---

### Aufgabe 4: Security Headers & Rate Limiting (2 Punkte)

**Installation:**
```bash
npm install helmet express-rate-limit
```

**server.js erweitern:**
```javascript
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Security Headers
app.use(helmet());

// Rate Limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 Minuten
    max: 100, // max 100 requests pro windowMs
    message: 'Too many requests, please try again later',
    standardHeaders: true,
    legacyHeaders: false,
});

app.use('/api/', limiter);

// Strengeres Limit für Login
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5, // max 5 Login-Versuche
    message: 'Too many login attempts, please try again later',
    skipSuccessfulRequests: true
});

app.use('/api/auth/login', loginLimiter);

// CORS konfigurieren
const cors = require('cors');
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true
}));
```

**Vollständige .env:**
```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=hftm_library
DB_PORT=3306

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your-super-secret-key-change-in-production

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

---

### Aufgabe 5: SQL Injection Prevention (Immer!)

**❌ NIEMALS SO:**
```javascript
// GEFÄHRLICH - SQL Injection möglich!
const query = `SELECT * FROM books WHERE title = '${req.body.title}'`;
const [books] = await pool.query(query);
```

**✅ IMMER SO:**
```javascript
// SICHER - Prepared Statements
const [books] = await pool.query(
    'SELECT * FROM books WHERE title = ?',
    [req.body.title]
);
```

**Beispiel SQL Injection Angriff:**
```javascript
// User Input: '; DROP TABLE books; --
// Ohne Prepared Statement würde ausgeführt:
// SELECT * FROM books WHERE title = ''; DROP TABLE books; --'
```

---

## Testing mit authentifizierten Requests

### Postman Setup

**1. Login und Token speichern:**
```
POST http://localhost:3000/api/auth/login
Body:
{
  "username": "admin",
  "password": "Password123"
}
```

**2. Token in Environment Variable speichern:**
- Nach Login: Tests Tab in Postman
```javascript
pm.test("Login successful", function() {
    const json = pm.response.json();
    pm.environment.set("token", json.token);
});
```

**3. Token in anderen Requests verwenden:**
```
GET http://localhost:3000/api/profile
Headers:
Authorization: Bearer {{token}}
```

---

## Bewertungsraster Credit 12

| Aufgabe | Punkte | Kriterien |
|---------|--------|-----------|
| **1.1** User Model & Registration | 2 | bcrypt, validation, endpoint funktioniert |
| **1.2** Login & JWT | 2 | Token generation, password check |
| **2** Auth Middleware | 2 | authenticate & authorize funktionieren |
| **3** Input Validation | 2 | express-validator, mehrere Validierungen |
| **4** Security Headers | 2 | helmet, rate-limit, CORS |
| **TOTAL** | **10** | |

---

## Abgabe Credit 12

**Format:** ZIP-Datei

**Enthält:**
- [ ] Kompletter Code mit Security Features
- [ ] User Model implementiert
- [ ] Auth Routes (register, login)
- [ ] Auth Middleware
- [ ] Validation Middleware
- [ ] Security Headers (helmet, rate-limit)
- [ ] Postman Collection mit:
  - [ ] Register Request
  - [ ] Login Request
  - [ ] Protected Route mit Token
  - [ ] Admin-only Route
- [ ] Screenshots:
  - [ ] Erfolgreicher Login
  - [ ] Request mit gültigem Token
  - [ ] Request ohne Token (401)
  - [ ] Request mit abgelaufenem Token (401)
  - [ ] Validation Error (400)
- [ ] README mit Security Features dokumentiert

**Naming:** `Credit12_Vorname_Nachname.zip`

---

## Security Checklist

### ✅ Must Have

- [ ] **Passwords hashen** (bcrypt, min. 10 rounds)
- [ ] **JWT für Authentication** (mit Secret, Expiry)
- [ ] **Prepared Statements** (ÜBERALL!)
- [ ] **Input Validation** (express-validator)
- [ ] **Helmet** (Security Headers)
- [ ] **CORS** richtig konfiguriert
- [ ] **Rate Limiting** (Login, API)
- [ ] **.env für Secrets** (nie committen!)
- [ ] **HTTPS in Production** (Let's Encrypt)
- [ ] **Error Messages** (keine Stacktraces an Client)

### ✅ Good to Have

- [ ] **Refresh Tokens** (zusätzlich zu Access Token)
- [ ] **Account Lockout** (nach X fehlgeschlagenen Login-Versuchen)
- [ ] **Email Verification** (nach Registration)
- [ ] **Password Reset** (via Email)
- [ ] **2FA** (Two-Factor Authentication)
- [ ] **Audit Logging** (wer hat was wann geändert)
- [ ] **CSP** (Content Security Policy)
- [ ] **XSS Protection** (Input Sanitization)

---

## Zusätzliche Ressourcen

### Dokumentation
- JWT: https://jwt.io
- bcrypt: https://github.com/kelektiv/node.bcrypt.js
- helmet: https://helmetjs.github.io
- express-validator: https://express-validator.github.io

### OWASP Top 10
- SQL Injection
- Broken Authentication
- Sensitive Data Exposure
- XML External Entities (XXE)
- Broken Access Control
- Security Misconfiguration
- Cross-Site Scripting (XSS)
- Insecure Deserialization
- Using Components with Known Vulnerabilities
- Insufficient Logging & Monitoring

### Testing Tools
- **Postman** - API Testing
- **OWASP ZAP** - Security Testing
- **npm audit** - Dependency Vulnerabilities
- **Snyk** - Code Security Analysis

---

## Häufige Sicherheitsfehler

### ❌ Fehler 1: Passwords im Klartext speichern
```javascript
// FALSCH!
await User.create({
    password: req.body.password
});
```

### ✅ Richtig: Hash verwenden
```javascript
const bcrypt = require('bcryptjs');
const hashedPassword = await bcrypt.hash(req.body.password, 10);
await User.create({
    password: hashedPassword
});
```

---

### ❌ Fehler 2: SQL Injection
```javascript
// FALSCH!
const query = `SELECT * FROM users WHERE username = '${username}'`;
```

### ✅ Richtig: Prepared Statements
```javascript
const [users] = await pool.query(
    'SELECT * FROM users WHERE username = ?',
    [username]
);
```

---

### ❌ Fehler 3: JWT Secret im Code
```javascript
// FALSCH!
const token = jwt.sign(payload, 'mysecret123');
```

### ✅ Richtig: Secret in .env
```javascript
const token = jwt.sign(payload, process.env.JWT_SECRET);
```

---

### ❌ Fehler 4: Keine Input Validation
```javascript
// FALSCH!
const { email } = req.body;
await User.create({ email });
```

### ✅ Richtig: Validation
```javascript
const { email } = req.body;

if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Invalid email' });
}

await User.create({ email });
```

---

### ❌ Fehler 5: Detaillierte Error Messages
```javascript
// FALSCH! - Gibt zu viel Info preis
catch (err) {
    res.status(500).json({ 
        error: err.stack 
    });
}
```

### ✅ Richtig: Generische Messages
```javascript
catch (err) {
    console.error(err); // Log intern
    res.status(500).json({ 
        error: 'Internal server error' 
    });
}
```

---

## Best Practices Zusammenfassung

### 🔐 Authentication & Authorization
✅ Hash passwords mit bcrypt (10+ rounds)
✅ JWT mit Secret und Expiry
✅ Refresh Token Strategie
✅ Role-based Access Control

### 🛡️ Input Validation
✅ Validate ALL user input
✅ Sanitize HTML input
✅ Use express-validator
✅ Type checking

### 🔒 SQL Security
✅ ALWAYS use Prepared Statements
✅ Principle of Least Privilege (DB User)
✅ Never expose DB errors to client

### 🌐 HTTP Security
✅ Use Helmet for security headers
✅ Configure CORS properly
✅ Rate limiting
✅ HTTPS in production

### 📝 Logging & Monitoring
✅ Log authentication attempts
✅ Log sensitive operations
✅ Monitor for suspicious activity
✅ Never log passwords or tokens

---

**Viel Erfolg mit der Security-Implementierung! 🔐**
