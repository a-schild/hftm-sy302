# Leçon 12: MQTT & Sécurité dans les projets web

## Objectifs d'apprentissage

- Accéder à un serveur MQTT via JavaScript
- Expliquer les thèmes de sécurité fondamentaux dans l'environnement de bases de données
- Stocker des données IoT dans une base de données
- Mettre en œuvre les meilleures pratiques de sécurité web

## Qu'est-ce que MQTT?

**MQTT** (Message Queuing Telemetry Transport) est un protocole de messagerie Publish/Subscribe léger pour les appareils IoT.

### Concepts de base MQTT

```
┌─────────────┐        ┌─────────────┐        ┌─────────────┐
│  Publisher  │───────▶│   Broker    │◀───────│ Subscriber  │
│  (Capteur)  │        │  (Serveur)  │        │  (Client)   │
└─────────────┘        └─────────────┘        └─────────────┘
     publish              dispatch                 receive
   "temp/salle1"                              subscribe "temp/#"
```

### Termes importants

- **Broker**: Serveur MQTT (ex. Mosquitto, HiveMQ)
- **Client**: Se connecte au broker
- **Topic**: Canal pour les messages (ex. `sensors/temperature/room1`)
- **Publish**: Envoyer un message
- **Subscribe**: Recevoir des messages
- **QoS**: Quality of Service (0, 1, 2)

### MQTT vs. HTTP

| Fonctionnalité | MQTT | HTTP/REST |
|----------------|------|-----------|
| **Communication** | Publish/Subscribe | Request/Response |
| **Overhead** | Petit (~2 Bytes) | Grand (En-tête) |
| **Persistant** | Oui (Keep-Alive) | Non (Stateless) |
| **Bande passante** | Faible | Plus élevée |
| **Cas d'usage** | IoT, Temps réel | APIs Web |

## MQTT avec Node.js

### Installation

```bash
npm install mqtt
```

### Options de Broker MQTT

**Brokers de test publics:**
- `mqtt://test.mosquitto.org`
- `mqtt://broker.hivemq.com`

**Broker local (Mosquitto):**
```bash
# Windows: Télécharger depuis mosquitto.org
# macOS: brew install mosquitto
# Linux: sudo apt-get install mosquitto
```

### Connexion au Broker

```javascript
const mqtt = require('mqtt');

// Connexion au broker de test public
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    console.log('Connecté au broker MQTT');
});

client.on('error', (error) => {
    console.error('Erreur MQTT:', error);
});
```

### Publier des messages

```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    // Message simple
    client.publish('hftm/temperature', '22.5');
    
    // Avec options
    client.publish('hftm/temperature', '22.5', {
        qos: 1,      // Quality of Service
        retain: true // Sauvegarder le message pour les nouveaux abonnés
    });
    
    // Données JSON
    const sensorData = {
        temperature: 22.5,
        humidity: 65,
        timestamp: new Date().toISOString()
    };
    client.publish('hftm/sensor/data', JSON.stringify(sensorData));
});
```

### S'abonner aux messages

```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    // Topic unique
    client.subscribe('hftm/temperature');
    
    // Plusieurs topics
    client.subscribe(['hftm/temperature', 'hftm/humidity']);
    
    // Wildcards
    client.subscribe('hftm/#');      // Tous les topics sous hftm/
    client.subscribe('hftm/+/data'); // hftm/sensor1/data, hftm/sensor2/data, ...
});

client.on('message', (topic, message) => {
    console.log(`Topic: ${topic}`);
    console.log(`Message: ${message.toString()}`);
    
    // Parser JSON
    try {
        const data = JSON.parse(message.toString());
        console.log('Température:', data.temperature);
    } catch (error) {
        console.error('Pas JSON:', error);
    }
});
```

## Intégration MQTT + Base de données

### Sauvegarder les données des capteurs dans la base de données

**Schéma de base de données:**
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

**Service MQTT → Database:**
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
            console.log('MQTT connecté');
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
            
            console.log(`Sauvegardé: ${topic} = ${data.value}${data.unit}`);
        } catch (error) {
            console.error('Erreur lors de la sauvegarde:', error);
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

### API REST pour les données de capteurs

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

## Sécurité dans les projets web

### 1. Prévention de l'injection SQL

**Problème:**
```javascript
// JAMAIS COMME ÇA!
const username = req.body.username;
const query = `SELECT * FROM users WHERE username = '${username}'`;
```

Un attaquant pourrait entrer: `admin' OR '1'='1`
Requête résultante: `SELECT * FROM users WHERE username = 'admin' OR '1'='1'`

**Solution: Prepared Statements**
```javascript
// Correct avec Prepared Statements
const [users] = await db.query(
    'SELECT * FROM users WHERE username = ?',
    [username]
);
```

**Avec ORM (Sequelize):**
```javascript
// Automatiquement protégé
const user = await User.findOne({
    where: { username: username }
});
```

### 2. Authentification & Autorisation

**JWT (JSON Web Tokens) pour l'authentification:**

```bash
npm install jsonwebtoken bcrypt
```

**Inscription utilisateur avec hachage de mot de passe:**
```javascript
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Inscription
async function registerUser(username, password) {
    // Hacher le mot de passe (JAMAIS stocker en texte brut!)
    const hashedPassword = await bcrypt.hash(password, 10);
    
    await db.query(
        'INSERT INTO users (username, password_hash) VALUES (?, ?)',
        [username, hashedPassword]
    );
}

// Connexion
async function loginUser(username, password) {
    const [users] = await db.query(
        'SELECT * FROM users WHERE username = ?',
        [username]
    );
    
    if (users.length === 0) {
        throw new Error('Utilisateur non trouvé');
    }
    
    const user = users[0];
    
    // Comparer le mot de passe
    const valid = await bcrypt.compare(password, user.password_hash);
    
    if (!valid) {
        throw new Error('Mot de passe incorrect');
    }
    
    // Créer un token JWT
    const token = jwt.sign(
        { userId: user.id, username: user.username },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
    );
    
    return token;
}
```

**Middleware d'authentification:**
```javascript
// middleware/auth.js
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
        return res.status(401).json({ error: 'Token requis' });
    }
    
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Token invalide' });
        }
        req.user = user;
        next();
    });
}

module.exports = { authenticateToken };
```

**Utilisation:**
```javascript
const { authenticateToken } = require('./middleware/auth');

// Route protégée
router.get('/api/protected', authenticateToken, (req, res) => {
    res.json({ message: 'Vous êtes connecté!', user: req.user });
});
```

### 3. Prévention XSS (Cross-Site Scripting)

**Problème:**
L'utilisateur entre du code JavaScript qui est exécuté.

```javascript
// Dangereux!
const comment = req.body.comment;
// comment = "<script>alert('XSS')</script>"
```

**Solution:**
```javascript
// Sanitization de l'input
const sanitizeHtml = require('sanitize-html');

const cleanComment = sanitizeHtml(req.body.comment, {
    allowedTags: ['b', 'i', 'em', 'strong'],
    allowedAttributes: {}
});
```

**Dans le Frontend:**
```javascript
// React échappe automatiquement
<div>{comment}</div>  // Sûr

// Dangereux (JAMAIS utiliser sans sanitization)
<div dangerouslySetInnerHTML={{__html: comment}} />
```

### 4. Prévention CSRF (Cross-Site Request Forgery)

```bash
npm install csurf
```

```javascript
const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });

app.use(csrfProtection);

// Envoyer le token CSRF au frontend
app.get('/form', (req, res) => {
    res.json({ csrfToken: req.csrfToken() });
});

// Pour les requêtes POST, la validation est automatique
app.post('/api/data', (req, res) => {
    // Token validé automatiquement
    res.json({ success: true });
});
```

### 5. Rate Limiting

Protection contre les attaques par force brute:

```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // Max 5 tentatives
    message: 'Trop de tentatives de connexion, veuillez réessayer plus tard'
});

app.post('/api/login', loginLimiter, loginController);
```

### 6. HTTPS / SSL

**Toujours utiliser HTTPS en production!**

```javascript
const https = require('https');
const fs = require('fs');

const options = {
    key: fs.readFileSync('private-key.pem'),
    cert: fs.readFileSync('certificate.pem')
};

https.createServer(options, app).listen(443);
```

**Let's Encrypt pour des certificats SSL gratuits:**
- https://letsencrypt.org/

### 7. Variables d'environnement

**JAMAIS** de données sensibles dans le code!

**Fichier .env:**
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

**Utilisation:**
```javascript
require('dotenv').config();

const dbPassword = process.env.DB_PASSWORD;
const jwtSecret = process.env.JWT_SECRET;
```

### 8. Validation des entrées

```bash
npm install express-validator
```

```javascript
const { body, validationResult } = require('express-validator');

app.post('/api/register',
    // Validation
    body('username').isLength({ min: 3, max: 20 }).isAlphanumeric(),
    body('email').isEmail(),
    body('password').isLength({ min: 8 }).matches(/^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)/),
    
    (req, res) => {
        const errors = validationResult(req);
        
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        
        // Effectuer l'inscription
    }
);
```

### 9. CORS (Cross-Origin Resource Sharing)

```bash
npm install cors
```

```javascript
const cors = require('cors');

// Autoriser toutes les origines (développement uniquement!)
app.use(cors());

// Origines spécifiques (production)
app.use(cors({
    origin: ['https://monapp.com', 'https://www.monapp.com'],
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));
```

### 10. En-têtes de sécurité

```bash
npm install helmet
```

```javascript
const helmet = require('helmet');

// Définit différents en-têtes de sécurité HTTP
app.use(helmet());
```

## Meilleures pratiques de sécurité des bases de données

### 1. Principe du moindre privilège

Créer des utilisateurs DB spécifiques avec des droits minimaux:

```sql
-- Seulement SELECT, INSERT, UPDATE, DELETE (pas de droits DDL)
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';
GRANT SELECT, INSERT, UPDATE, DELETE ON mydb.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;
```

### 2. Sécurité de la chaîne de connexion

```javascript
// FAUX - Credentials dans le code
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'password123'
});

// CORRECT - Depuis les variables d'environnement
const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD
});
```

### 3. Sauvegardes de base de données

```bash
# Créer une sauvegarde
mysqldump -u root -p mydatabase > backup.sql

# Restaurer une sauvegarde
mysql -u root -p mydatabase < backup.sql

# Sauvegardes automatiques (Cron Job)
0 2 * * * mysqldump -u root -p mydatabase > /backups/db_$(date +\%Y\%m\%d).sql
```

### 4. Chiffrement au repos

Chiffrer les données sensibles:

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

// Sauvegarder
const encrypted = encrypt('Information sensible');
await db.query('INSERT INTO data (encrypted_field) VALUES (?)', [encrypted]);

// Lire
const [rows] = await db.query('SELECT encrypted_field FROM data WHERE id = ?', [1]);
const decrypted = decrypt(rows[0].encrypted_field);
```

## Checklist de sécurité

### Avant le déploiement

- [ ] Tous les mots de passe dans les variables d'environnement
- [ ] Protection contre l'injection SQL (Prepared Statements)
- [ ] Protection XSS (Sanitization des entrées)
- [ ] Protection CSRF implémentée
- [ ] Authentification implémentée
- [ ] Rate Limiting activé
- [ ] HTTPS activé
- [ ] En-têtes de sécurité (Helmet)
- [ ] CORS configuré correctement
- [ ] Validation des entrées
- [ ] Messages d'erreur ne contiennent pas d'infos sensibles
- [ ] Logging activé (sans données sensibles)
- [ ] Sauvegardes de base de données configurées
- [ ] Principe du moindre privilège pour les utilisateurs DB
- [ ] Dépendances à jour (npm audit)

## Exercice pratique

### Exercice 1: Intégration MQTT

Créer une petite application IoT:

1. Client MQTT qui publie des données de température
2. Service MQTT qui sauvegarde les données dans la DB
3. API REST pour récupérer les données
4. Frontend affichant la température actuelle

**Topics:**
- `hftm/sensors/temp/room1`
- `hftm/sensors/temp/room2`
- `hftm/sensors/humidity/room1`

### Exercice 2: Audit de sécurité

Effectuer un audit de sécurité de votre projet:

1. Tester l'injection SQL
2. Implémenter l'authentification
3. Ajouter le rate limiting
4. Utiliser Helmet
5. Valider toutes les entrées
6. Documenter toutes les mesures de sécurité

### Exercice 3: Authentification JWT

Implémenter l'authentification utilisateur complète:

1. Endpoint d'inscription
2. Endpoint de connexion (avec JWT)
3. Routes protégées
4. Mécanisme de refresh token
5. Fonctionnalité de déconnexion

## Outils pour les tests de sécurité

### 1. OWASP ZAP
Analyses de sécurité automatiques:
- https://www.zaproxy.org/

### 2. npm audit
Vulnérabilités des dépendances:
```bash
npm audit
npm audit fix
```

### 3. Snyk
Surveillance continue de la sécurité:
```bash
npm install -g snyk
snyk test
```

## Ressources supplémentaires

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Meilleures pratiques de sécurité Node.js](https://nodejs.org/en/docs/guides/security/)
- [Meilleures pratiques de sécurité Express](https://expressjs.com/en/advanced/best-practice-security.html)
- [Documentation MQTT.org](https://mqtt.org/)

## Remise du projet

**Échéance: Fin de la leçon 12**

Projet complet avec:
- Conception de base de données (Diagramme ER, SQL)
- API REST (au moins 3 ressources avec CRUD)
- Frontend (dynamique avec connexion API)
- Documentation (README, Docs API)
- Fonctionnalités de sécurité implémentées

## Prochaines étapes

Dans la leçon 13, tous présenteront leurs projets et nous conclurons le cours avec des thèmes sur la protection des données et les sauvegardes.

---

© 2024 HFTM - Tous droits réservés
