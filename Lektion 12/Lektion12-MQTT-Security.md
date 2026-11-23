# Lektion 12: MQTT & Security in Webprojekten

## Lernziele

- Mittels JavaScript auf einen MQTT Server zugreifen
- Die grundlegenden Sicherheitsthemen im Datenbankumfeld zu erklären
- IoT-Daten in einer Datenbank speichern
- Best Practices für Web-Security umsetzen

## Was ist MQTT?

**MQTT** (Message Queuing Telemetry Transport) ist ein leichtgewichtiges Publish/Subscribe Messaging-Protokoll für IoT-Geräte.

### MQTT Grundkonzepte

```
┌─────────────┐        ┌─────────────┐        ┌─────────────┐
│  Publisher  │───────▶│   Broker    │◀───────│ Subscriber  │
│  (Sensor)   │        │   (Server)  │        │  (Client)   │
└─────────────┘        └─────────────┘        └─────────────┘
     publish              dispatch                 receive
   "temp/room1"                              subscribe "temp/#"
```

### Wichtige Begriffe

- **Broker**: MQTT-Server (z.B. Mosquitto, HiveMQ)
- **Client**: Verbindet sich zum Broker
- **Topic**: Kanal für Nachrichten (z.B. `sensors/temperature/room1`)
- **Publish**: Nachricht senden
- **Subscribe**: Nachrichten empfangen
- **QoS**: Quality of Service (0, 1, 2)

### MQTT vs. HTTP

| Feature | MQTT | HTTP/REST |
|---------|------|-----------|
| **Kommunikation** | Publish/Subscribe | Request/Response |
| **Overhead** | Klein (~2 Bytes) | Gross (Header) |
| **Persistent** | Ja (Keep-Alive) | Nein (Stateless) |
| **Bandbreite** | Niedrig | Höher |
| **Use Case** | IoT, Real-time | Web APIs |

## MQTT mit Node.js

### Installation

```bash
npm install mqtt
```

### MQTT Broker Options

**Öffentliche Test-Broker:**
- `mqtt://test.mosquitto.org`
- `mqtt://broker.hivemq.com`

**Lokaler Broker (Mosquitto):**
```bash
# Windows: Download von mosquitto.org
# macOS: brew install mosquitto
# Linux: sudo apt-get install mosquitto
```

### Verbindung zum Broker

```javascript
const mqtt = require('mqtt');

// Verbindung zu öffentlichem Test-Broker
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    console.log('Verbunden mit MQTT Broker');
});

client.on('error', (error) => {
    console.error('MQTT Fehler:', error);
});
```

### Nachrichten publishen

```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    // Einfache Nachricht
    client.publish('hftm/temperature', '22.5');
    
    // Mit Optionen
    client.publish('hftm/temperature', '22.5', {
        qos: 1,      // Quality of Service
        retain: true // Nachricht speichern für neue Subscriber
    });
    
    // JSON-Daten
    const sensorData = {
        temperature: 22.5,
        humidity: 65,
        timestamp: new Date().toISOString()
    };
    client.publish('hftm/sensor/data', JSON.stringify(sensorData));
});
```

### Nachrichten subscriben

```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    // Einzelnes Topic
    client.subscribe('hftm/temperature');
    
    // Mehrere Topics
    client.subscribe(['hftm/temperature', 'hftm/humidity']);
    
    // Wildcards
    client.subscribe('hftm/#');      // Alle Topics unter hftm/
    client.subscribe('hftm/+/data'); // hftm/sensor1/data, hftm/sensor2/data, ...
});

client.on('message', (topic, message) => {
    console.log(`Topic: ${topic}`);
    console.log(`Message: ${message.toString()}`);
    
    // JSON parsen
    try {
        const data = JSON.parse(message.toString());
        console.log('Temperatur:', data.temperature);
    } catch (error) {
        console.error('Kein JSON:', error);
    }
});
```

## MQTT + Datenbank Integration

### Sensordaten in Datenbank speichern

**Datenbank-Schema:**
```sql
CREATE TABLE sensor_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sensor_id VARCHAR(50),
    topic VARCHAR(255),
    value FLOAT,
    unit VARCHAR(20),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    raw_data JSON
);

CREATE INDEX idx_sensor_timestamp ON sensor_data(sensor_id, timestamp);
CREATE INDEX idx_topic ON sensor_data(topic);
```

**MQTT → Database Service:**
```javascript
const mqtt = require('mqtt');
const db = require('./config/database');

class MQTTService {
    constructor() {
        this.client = mqtt.connect('mqtt://test.mosquitto.org');
        this.setupHandlers();
    }
    
    setupHandlers() {
        this.client.on('connect', () => {
            console.log('MQTT verbunden');
            this.client.subscribe('sensors/#');
        });
        
        this.client.on('message', async (topic, message) => {
            await this.handleMessage(topic, message);
        });
    }
    
    async handleMessage(topic, message) {
        try {
            const data = JSON.parse(message.toString());
            
            await db.query(
                `INSERT INTO sensor_data (sensor_id, topic, value, unit, raw_data)
                 VALUES (?, ?, ?, ?, ?)`,
                [
                    data.sensor_id,
                    topic,
                    data.value,
                    data.unit,
                    JSON.stringify(data)
                ]
            );
            
            console.log(`Gespeichert: ${topic} = ${data.value}${data.unit}`);
        } catch (error) {
            console.error('Fehler beim Speichern:', error);
        }
    }
    
    async getLatestData(sensorId) {
        const [rows] = await db.query(
            `SELECT * FROM sensor_data 
             WHERE sensor_id = ? 
             ORDER BY timestamp DESC 
             LIMIT 10`,
            [sensorId]
        );
        return rows;
    }
    
    async getAverageValue(sensorId, hours = 24) {
        const [rows] = await db.query(
            `SELECT AVG(value) as avg_value 
             FROM sensor_data 
             WHERE sensor_id = ? 
             AND timestamp > DATE_SUB(NOW(), INTERVAL ? HOUR)`,
            [sensorId, hours]
        );
        return rows[0].avg_value;
    }
}

module.exports = new MQTTService();
```

### REST API für Sensordaten

```javascript
const express = require('express');
const router = express.Router();
const mqttService = require('../services/mqttService');

// GET /api/sensors/:id/latest
router.get('/:id/latest', async (req, res) => {
    try {
        const data = await mqttService.getLatestData(req.params.id);
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET /api/sensors/:id/average?hours=24
router.get('/:id/average', async (req, res) => {
    try {
        const hours = parseInt(req.query.hours) || 24;
        const avg = await mqttService.getAverageValue(req.params.id, hours);
        res.json({ average: avg, hours });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
```

## Security in Webprojekten

### 1. SQL-Injection Prevention

**Problem:**
```javascript
// NIEMALS SO!
const username = req.body.username;
const query = `SELECT * FROM users WHERE username = '${username}'`;
```

Ein Angreifer könnte eingeben: `admin' OR '1'='1`
Resultierende Query: `SELECT * FROM users WHERE username = 'admin' OR '1'='1'`

**Lösung: Prepared Statements**
```javascript
// Richtig mit Prepared Statements
const [users] = await db.query(
    'SELECT * FROM users WHERE username = ?',
    [username]
);
```

**Mit ORM (Sequelize):**
```javascript
// Automatisch geschützt
const user = await User.findOne({
    where: { username: username }
});
```

### 2. Authentication & Authorization

**JWT (JSON Web Tokens) für Authentifizierung:**

```bash
npm install jsonwebtoken bcrypt
```

**User Registration mit Password Hashing:**
```javascript
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Registration
async function registerUser(username, password) {
    // Password hashen (NIEMALS plain text speichern!)
    const hashedPassword = await bcrypt.hash(password, 10);
    
    await db.query(
        'INSERT INTO users (username, password_hash) VALUES (?, ?)',
        [username, hashedPassword]
    );
}

// Login
async function loginUser(username, password) {
    const [users] = await db.query(
        'SELECT * FROM users WHERE username = ?',
        [username]
    );
    
    if (users.length === 0) {
        throw new Error('User nicht gefunden');
    }
    
    const user = users[0];
    
    // Password vergleichen
    const valid = await bcrypt.compare(password, user.password_hash);
    
    if (!valid) {
        throw new Error('Falsches Passwort');
    }
    
    // JWT Token erstellen
    const token = jwt.sign(
        { userId: user.id, username: user.username },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
    );
    
    return token;
}
```

**Authentication Middleware:**
```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
        return res.status(401).json({ error: 'Token erforderlich' });
    }
    
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Ungültiger Token' });
        }
        req.user = user;
        next();
    });
}

module.exports = { authenticateToken };
```

**Verwendung:**
```javascript
const { authenticateToken } = require('./middleware/auth');

// Geschützte Route
router.get('/api/protected', authenticateToken, (req, res) => {
    res.json({ message: 'Du bist eingeloggt!', user: req.user });
});
```

### 3. XSS (Cross-Site Scripting) Prevention

**Problem:**
Benutzer gibt JavaScript-Code ein, der ausgeführt wird.

```javascript
// Gefährlich!
const comment = req.body.comment;
// comment = "<script>alert('XSS')</script>"
```

**Lösung:**
```javascript
// Input Sanitization
const sanitizeHtml = require('sanitize-html');

const cleanComment = sanitizeHtml(req.body.comment, {
    allowedTags: ['b', 'i', 'em', 'strong'],
    allowedAttributes: {}
});
```

**Im Frontend:**
```javascript
// React escaped automatisch
<div>{comment}</div>  // Sicher

// Gefährlich (NIEMALS verwenden ohne Sanitization)
<div dangerouslySetInnerHTML={{__html: comment}} />
```

### 4. CSRF (Cross-Site Request Forgery) Prevention

```bash
npm install csurf
```

```javascript
const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });

app.use(csrfProtection);

// CSRF Token an Frontend senden
app.get('/form', (req, res) => {
    res.json({ csrfToken: req.csrfToken() });
});

// Bei POST-Requests wird automatisch geprüft
app.post('/api/data', (req, res) => {
    // Token wird automatisch validiert
    res.json({ success: true });
});
```

### 5. Rate Limiting

Schutz vor Brute-Force Attacken:

```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 Minuten
    max: 5, // Max 5 Versuche
    message: 'Zu viele Login-Versuche, bitte später versuchen'
});

app.post('/api/login', loginLimiter, loginController);
```

### 6. HTTPS / SSL

**In Produktion IMMER HTTPS verwenden!**

```javascript
const https = require('https');
const fs = require('fs');

const options = {
    key: fs.readFileSync('private-key.pem'),
    cert: fs.readFileSync('certificate.pem')
};

https.createServer(options, app).listen(443);
```

**Let's Encrypt für kostenlose SSL-Zertifikate:**
- https://letsencrypt.org/

### 7. Environment Variables

**NIEMALS** sensible Daten im Code!

**.env Datei:**
```env
DB_PASSWORD=secret123
JWT_SECRET=supersecretkey
API_KEY=abcdef123456
```

**.gitignore:**
```
.env
node_modules/
```

**Verwendung:**
```javascript
require('dotenv').config();

const dbPassword = process.env.DB_PASSWORD;
const jwtSecret = process.env.JWT_SECRET;
```

### 8. Input Validation

```bash
npm install express-validator
```

```javascript
const { body, validationResult } = require('express-validator');

app.post('/api/register',
    // Validierung
    body('username').isLength({ min: 3, max: 20 }).isAlphanumeric(),
    body('email').isEmail(),
    body('password').isLength({ min: 8 }).matches(/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)/),
    
    (req, res) => {
        const errors = validationResult(req);
        
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        
        // Registrierung durchführen
    }
);
```

### 9. CORS (Cross-Origin Resource Sharing)

```bash
npm install cors
```

```javascript
const cors = require('cors');

// Alle Origins erlauben (nur für Entwicklung!)
app.use(cors());

// Spezifische Origins (Produktion)
app.use(cors({
    origin: ['https://myapp.com', 'https://www.myapp.com'],
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));
```

### 10. Security Headers

```bash
npm install helmet
```

```javascript
const helmet = require('helmet');

// Setzt verschiedene HTTP Security Headers
app.use(helmet());
```

## Database Security Best Practices

### 1. Principle of Least Privilege

Erstelle spezifische DB-User mit minimalen Rechten:

```sql
-- Nur SELECT, INSERT, UPDATE, DELETE (keine DDL-Rechte)
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE, DELETE ON mydb.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Connection String Security

```javascript
// FALSCH - Credentials im Code
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'password123'
});

// RICHTIG - Aus Environment Variables
const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD
});
```

### 3. Datenbank-Backups

```bash
# Backup erstellen
mysqldump -u root -p mydatabase > backup.sql

# Backup wiederherstellen
mysql -u root -p mydatabase < backup.sql

# Automatische Backups (Cron Job)
0 2 * * * mysqldump -u root -p mydatabase > /backups/db_$(date +\%Y\%m\%d).sql
```

### 4. Encryption at Rest

Sensible Daten verschlüsseln:

```javascript
const crypto = require('crypto');

function encrypt(text) {
    const cipher = crypto.createCipher('aes-256-cbc', process.env.ENCRYPTION_KEY);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
}

function decrypt(encrypted) {
    const decipher = crypto.createDecipher('aes-256-cbc', process.env.ENCRYPTION_KEY);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
}

// Speichern
const encrypted = encrypt('Sensible Information');
await db.query('INSERT INTO data (encrypted_field) VALUES (?)', [encrypted]);

// Lesen
const [rows] = await db.query('SELECT encrypted_field FROM data WHERE id = ?', [1]);
const decrypted = decrypt(rows[0].encrypted_field);
```

## Security Checklist

### Vor dem Deployment

- [ ] Alle Passwörter in Environment Variables
- [ ] SQL-Injection Schutz (Prepared Statements)
- [ ] XSS-Schutz (Input Sanitization)
- [ ] CSRF-Schutz implementiert
- [ ] Authentication implementiert
- [ ] Rate Limiting aktiviert
- [ ] HTTPS aktiviert
- [ ] Security Headers (Helmet)
- [ ] CORS korrekt konfiguriert
- [ ] Input Validation
- [ ] Error Messages enthalten keine sensiblen Infos
- [ ] Logging aktiviert (ohne sensible Daten)
- [ ] Database Backups eingerichtet
- [ ] Principle of Least Privilege für DB-User
- [ ] Dependencies aktuell (npm audit)

## Praktische Übung

### Übung 1: MQTT Integration

Erstelle eine kleine IoT-Anwendung:

1. MQTT Client der Temperaturdaten published
2. MQTT Service der Daten in DB speichert
3. REST API zum Abrufen der Daten
4. Frontend zeigt aktuelle Temperatur

**Topics:**
- `hftm/sensors/temp/room1`
- `hftm/sensors/temp/room2`
- `hftm/sensors/humidity/room1`

### Übung 2: Security Audit

Führe einen Security-Audit deines Projekts durch:

1. Teste auf SQL-Injection
2. Implementiere Authentication
3. Füge Rate Limiting hinzu
4. Setze Helmet ein
5. Validiere alle Inputs
6. Dokumentiere alle Security-Massnahmen

### Übung 3: JWT Authentication

Implementiere vollständige User-Authentifizierung:

1. Registration Endpoint
2. Login Endpoint (mit JWT)
3. Protected Routes
4. Refresh Token Mechanismus
5. Logout Funktionalität

## Tools für Security Testing

### 1. OWASP ZAP
Automatische Security-Scans:
- https://www.zaproxy.org/

### 2. npm audit
Dependency Vulnerabilities:
```bash
npm audit
npm audit fix
```

### 3. Snyk
Continuous Security Monitoring:
```bash
npm install -g snyk
snyk test
```

## Zusätzliche Ressourcen

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [MQTT.org Documentation](https://mqtt.org/)

## Abgabe Projekt

**Deadline: Ende Lektion 12**

Vollständiges Projekt mit:
- Datenbankdesign (ER-Diagramm, SQL)
- REST API (mindestens 3 Ressourcen mit CRUD)
- Frontend (dynamisch mit API-Anbindung)
- Dokumentation (README, API-Docs)
- Security-Features implementiert

## Nächste Schritte

In Lektion 13 präsentieren alle ihre Projekte und wir schliessen den Kurs mit Themen zu Datenschutz und Backups ab.
