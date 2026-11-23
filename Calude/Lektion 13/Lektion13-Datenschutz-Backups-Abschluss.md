# Lektion 13: Datenschutz, Backups & Kursabschluss

## Lernziele

- Ein Backupkonzept für eine Datenbank zu erstellen und umzusetzen
- Die wichtigsten Begriffe zum Datenschutz und deren Auswirkung auf Applikationen kennen
- DSGVO-Anforderungen im Datenbankkontext verstehen
- Erfolgreich das Projekt präsentieren

## Datenschutz & DSGVO

### Was ist die DSGVO?

Die **Datenschutz-Grundverordnung (DSGVO)** / **General Data Protection Regulation (GDPR)** ist die EU-weite Regelung zum Schutz personenbezogener Daten.

**Gültig seit:** 25. Mai 2018
**Gilt für:** Alle Unternehmen, die Daten von EU-Bürgern verarbeiten

### Personenbezogene Daten

**Definition:** Alle Informationen, die sich auf eine identifizierte oder identifizierbare Person beziehen.

**Beispiele:**
- Name, Adresse, E-Mail
- Telefonnummer, IP-Adresse
- Standortdaten, Cookies
- Finanzdaten, Gesundheitsdaten
- Biometrische Daten, genetische Daten

**Nicht personenbezogen:**
- Anonymisierte Statistiken
- Firmendaten
- Öffentliche Daten

### Grundprinzipien der DSGVO

1. **Rechtmäßigkeit, Verarbeitung nach Treu und Glauben, Transparenz**
   - Daten nur mit Einwilligung oder rechtlicher Grundlage verarbeiten
   - Nutzer über Datenverarbeitung informieren

2. **Zweckbindung**
   - Daten nur für festgelegte Zwecke erheben
   - Keine Weiterverwendung für andere Zwecke

3. **Datenminimierung**
   - Nur notwendige Daten erheben
   - "So viel wie nötig, so wenig wie möglich"

4. **Richtigkeit**
   - Daten müssen korrekt sein
   - Ungenaue Daten müssen gelöscht/korrigiert werden

5. **Speicherbegrenzung**
   - Daten nur so lange speichern wie nötig
   - Löschfristen definieren

6. **Integrität und Vertraulichkeit**
   - Angemessene Sicherheitsmaßnahmen
   - Schutz vor unbefugtem Zugriff

### Betroffenenrechte

Jede Person hat folgende Rechte:

| Recht | Beschreibung | Technische Umsetzung |
|-------|--------------|----------------------|
| **Auskunft** | Recht zu erfahren, welche Daten gespeichert sind | Export-Funktion implementieren |
| **Berichtigung** | Recht auf Korrektur falscher Daten | Update-Funktionen |
| **Löschung** | "Recht auf Vergessenwerden" | Delete-Funktionen, Cascading |
| **Einschränkung** | Datenverarbeitung einschränken | Status-Flags in DB |
| **Datenübertragbarkeit** | Daten in maschinenlesbarem Format erhalten | JSON/CSV Export |
| **Widerspruch** | Verarbeitung widersprechen | Opt-out Mechanismus |

## DSGVO in der Praxis

### 1. Privacy by Design

Datenschutz von Anfang an mitdenken:

```javascript
// Schema mit Datenschutz-Feldern
const userSchema = {
    user_id: 'INT PRIMARY KEY',
    email: 'VARCHAR(255) UNIQUE',
    username: 'VARCHAR(50)',
    
    // Datenschutz-Felder
    consent_marketing: 'BOOLEAN DEFAULT FALSE',
    consent_date: 'DATETIME',
    deletion_requested: 'BOOLEAN DEFAULT FALSE',
    deletion_date: 'DATETIME',
    data_retention_until: 'DATETIME'
};
```

### 2. Einwilligung einholen

```javascript
// Registration mit expliziter Einwilligung
app.post('/api/register', async (req, res) => {
    const { email, password, acceptPrivacyPolicy, acceptMarketing } = req.body;
    
    if (!acceptPrivacyPolicy) {
        return res.status(400).json({
            error: 'Datenschutzerklärung muss akzeptiert werden'
        });
    }
    
    await db.query(`
        INSERT INTO users (email, password_hash, consent_marketing, consent_date)
        VALUES (?, ?, ?, NOW())
    `, [email, hashedPassword, acceptMarketing]);
    
    res.json({ success: true });
});
```

### 3. Auskunftsrecht implementieren

```javascript
// GET /api/users/me/data-export
router.get('/me/data-export', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    // Alle Daten des Users sammeln
    const [userData] = await db.query(
        'SELECT * FROM users WHERE user_id = ?',
        [userId]
    );
    
    const [orders] = await db.query(
        'SELECT * FROM orders WHERE user_id = ?',
        [userId]
    );
    
    const [activities] = await db.query(
        'SELECT * FROM user_activities WHERE user_id = ?',
        [userId]
    );
    
    // Sensible Daten entfernen
    delete userData[0].password_hash;
    
    const exportData = {
        personal_data: userData[0],
        orders: orders,
        activities: activities,
        export_date: new Date().toISOString()
    };
    
    res.json(exportData);
});
```

### 4. Recht auf Löschung

```javascript
// DELETE /api/users/me
router.delete('/me', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    // Soft Delete (Daten erst mal markieren)
    await db.query(`
        UPDATE users 
        SET deletion_requested = TRUE, 
            deletion_date = DATE_ADD(NOW(), INTERVAL 30 DAY),
            email = CONCAT('deleted_', user_id, '@deleted.local')
        WHERE user_id = ?
    `, [userId]);
    
    res.json({
        message: 'Löschung beantragt. Account wird in 30 Tagen gelöscht.'
    });
});

// Cron Job für finale Löschung
async function deleteExpiredAccounts() {
    await db.query(`
        DELETE FROM users 
        WHERE deletion_requested = TRUE 
        AND deletion_date <= NOW()
    `);
}
```

### 5. Datenminimierung

```javascript
// Nur notwendige Daten zurückgeben
router.get('/api/users', async (req, res) => {
    const [users] = await db.query(`
        SELECT user_id, username, created_at
        FROM users
        -- NICHT: email, password_hash, phone, etc.
    `);
    
    res.json(users);
});
```

### 6. Pseudonymisierung & Anonymisierung

**Pseudonymisierung:** Daten können mit Zusatzinformationen einer Person zugeordnet werden
**Anonymisierung:** Personenbezug kann nicht mehr hergestellt werden

```javascript
// Pseudonymisierung für Analytics
async function trackPageView(userId, page) {
    const crypto = require('crypto');
    const pseudonym = crypto.createHash('sha256')
        .update(userId + process.env.ANALYTICS_SALT)
        .digest('hex');
    
    await db.query(
        'INSERT INTO page_views (user_pseudonym, page, timestamp) VALUES (?, ?, NOW())',
        [pseudonym, page]
    );
}

// Anonymisierung für Statistiken
async function createStatistics() {
    // Nur aggregierte Daten, keine User-IDs
    const [stats] = await db.query(`
        SELECT 
            DATE(created_at) as date,
            COUNT(*) as user_count,
            AVG(age) as avg_age
        FROM users
        GROUP BY DATE(created_at)
    `);
    
    return stats;
}
```

### 7. Verschlüsselung sensibler Daten

```javascript
const crypto = require('crypto');

class DataEncryption {
    constructor() {
        this.algorithm = 'aes-256-gcm';
        this.key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex');
    }
    
    encrypt(text) {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
        
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        
        const authTag = cipher.getAuthTag();
        
        return {
            encrypted,
            iv: iv.toString('hex'),
            authTag: authTag.toString('hex')
        };
    }
    
    decrypt(encrypted, iv, authTag) {
        const decipher = crypto.createDecipheriv(
            this.algorithm,
            this.key,
            Buffer.from(iv, 'hex')
        );
        
        decipher.setAuthTag(Buffer.from(authTag, 'hex'));
        
        let decrypted = decipher.update(encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        
        return decrypted;
    }
}

// Verwendung
const encryption = new DataEncryption();

// Speichern
const sensitive = "Kreditkartennummer: 1234-5678-9012-3456";
const { encrypted, iv, authTag } = encryption.encrypt(sensitive);

await db.query(
    'INSERT INTO payments (user_id, encrypted_data, iv, auth_tag) VALUES (?, ?, ?, ?)',
    [userId, encrypted, iv, authTag]
);

// Lesen
const [rows] = await db.query('SELECT * FROM payments WHERE user_id = ?', [userId]);
const decrypted = encryption.decrypt(
    rows[0].encrypted_data,
    rows[0].iv,
    rows[0].auth_tag
);
```

## Datenbank Backups

### Warum Backups?

- **Hardware-Ausfall**: Festplatten können kaputt gehen
- **Menschliche Fehler**: Versehentliches Löschen
- **Software-Bugs**: Datenverlust durch Bugs
- **Cyberangriffe**: Ransomware, Hacking
- **Naturkatastrophen**: Feuer, Überschwemmung

### 3-2-1 Backup-Regel

- **3** Kopien der Daten (Original + 2 Backups)
- **2** verschiedene Medien (z.B. Festplatte + Cloud)
- **1** Kopie extern/offsite

### Backup-Arten

#### 1. Full Backup (Vollsicherung)

Komplette Datenbank wird gesichert.

**Vorteile:**
- Einfache Wiederherstellung
- Vollständige Daten

**Nachteile:**
- Zeitaufwändig
- Viel Speicherplatz

```bash
# MariaDB/MySQL Full Backup
mysqldump -u root -p --all-databases > full_backup_$(date +%Y%m%d).sql

# Mit Kompression
mysqldump -u root -p --all-databases | gzip > full_backup_$(date +%Y%m%d).sql.gz

# Einzelne Datenbank
mysqldump -u root -p mydatabase > mydatabase_backup.sql
```

#### 2. Incremental Backup (Inkrementelles Backup)

Nur Änderungen seit letztem Backup.

**Vorteile:**
- Schneller
- Weniger Speicherplatz

**Nachteile:**
- Komplexere Wiederherstellung
- Alle Backups seit letztem Full Backup nötig

#### 3. Differential Backup

Alle Änderungen seit letztem Full Backup.

**Vorteile:**
- Schnellere Wiederherstellung als Incremental
- Weniger Speicherplatz als Full

**Nachteile:**
- Wächst mit der Zeit

### Automatische Backups einrichten

#### Linux Cron Job

```bash
# Crontab bearbeiten
crontab -e

# Tägliches Backup um 2:00 Uhr
0 2 * * * /usr/bin/mysqldump -u backup_user -pPASSWORD mydatabase | gzip > /backups/db_$(date +\%Y\%m\%d).sql.gz

# Wöchentliches Backup (Sonntag 3:00 Uhr)
0 3 * * 0 /usr/bin/mysqldump -u backup_user -pPASSWORD mydatabase > /backups/weekly/db_$(date +\%Y\%m\%d).sql

# Alte Backups löschen (älter als 30 Tage)
0 4 * * * find /backups -name "*.sql.gz" -mtime +30 -delete
```

#### Node.js Backup Script

```javascript
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

class DatabaseBackup {
    constructor(config) {
        this.config = config;
        this.backupDir = config.backupDir || './backups';
        
        // Backup-Verzeichnis erstellen
        if (!fs.existsSync(this.backupDir)) {
            fs.mkdirSync(this.backupDir, { recursive: true });
        }
    }
    
    async createBackup() {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = `backup_${timestamp}.sql`;
        const filepath = path.join(this.backupDir, filename);
        
        const command = `mysqldump -u ${this.config.user} -p${this.config.password} ${this.config.database} > ${filepath}`;
        
        return new Promise((resolve, reject) => {
            exec(command, (error, stdout, stderr) => {
                if (error) {
                    console.error('Backup Fehler:', error);
                    reject(error);
                    return;
                }
                
                console.log(`Backup erstellt: ${filename}`);
                
                // Komprimieren
                exec(`gzip ${filepath}`, (err) => {
                    if (err) {
                        console.error('Komprimierung fehlgeschlagen:', err);
                    }
                    resolve(`${filename}.gz`);
                });
            });
        });
    }
    
    async deleteOldBackups(days = 30) {
        const files = fs.readdirSync(this.backupDir);
        const now = Date.now();
        const maxAge = days * 24 * 60 * 60 * 1000;
        
        files.forEach(file => {
            const filepath = path.join(this.backupDir, file);
            const stats = fs.statSync(filepath);
            const age = now - stats.mtimeMs;
            
            if (age > maxAge) {
                fs.unlinkSync(filepath);
                console.log(`Altes Backup gelöscht: ${file}`);
            }
        });
    }
    
    async uploadToCloud(filename) {
        // Beispiel: Upload zu AWS S3, Google Cloud Storage, etc.
        // Hier nur Konzept
        console.log(`Upload ${filename} zur Cloud...`);
        // Implementation depends on cloud provider
    }
}

// Verwendung
const backup = new DatabaseBackup({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    backupDir: './backups'
});

// Backup erstellen
backup.createBackup()
    .then(() => backup.deleteOldBackups(30))
    .catch(err => console.error('Backup fehlgeschlagen:', err));
```

### Backup wiederherstellen

```bash
# SQL-Datei importieren
mysql -u root -p mydatabase < backup.sql

# Komprimierte Datei
gunzip < backup.sql.gz | mysql -u root -p mydatabase

# Gesamtes Backup (alle Datenbanken)
mysql -u root -p < full_backup.sql
```

### Backup-Testing

**WICHTIG:** Regelmäßig testen ob Backups funktionieren!

```bash
# Test-Restore in separate Datenbank
mysql -u root -p -e "CREATE DATABASE test_restore"
mysql -u root -p test_restore < backup.sql

# Prüfen
mysql -u root -p test_restore -e "SHOW TABLES"
mysql -u root -p test_restore -e "SELECT COUNT(*) FROM users"

# Test-DB löschen
mysql -u root -p -e "DROP DATABASE test_restore"
```

### Cloud Backup Lösungen

#### AWS RDS Automated Backups
- Automatische tägliche Snapshots
- Point-in-time Recovery
- Retention bis zu 35 Tage

#### Google Cloud SQL
- Automatische Backups
- On-demand Backups
- Export zu Cloud Storage

#### Azure Database
- Automatische Backups
- Geo-redundant Storage
- Long-term Retention

## Disaster Recovery Plan

### 1. RTO & RPO definieren

**RTO (Recovery Time Objective):** Wie lange darf das System maximal ausfallen?
- Beispiel: 4 Stunden

**RPO (Recovery Point Objective):** Wie viel Datenverlust ist akzeptabel?
- Beispiel: 1 Stunde (Daten der letzten Stunde können verloren gehen)

### 2. Backup-Strategie basierend auf RTO/RPO

| RPO/RTO | Backup-Strategie | Kosten |
|---------|------------------|--------|
| Stunden | Tägliche Full Backups | Niedrig |
| Minuten | Stündliche Incremental + Log Shipping | Mittel |
| Sekunden | Master-Slave Replication + Backups | Hoch |
| Keine (24/7) | Multi-Master Cluster + Backups | Sehr hoch |

### 3. Notfallplan dokumentieren

```markdown
# Disaster Recovery Procedure

## Im Notfall kontaktieren:
- DB Admin: +41 XX XXX XX XX
- Backup-Verantwortlicher: +41 XX XXX XX XX
- IT-Leiter: +41 XX XXX XX XX

## Schritt-für-Schritt Recovery:

1. **Situation einschätzen**
   - Was ist passiert?
   - Welche Daten sind betroffen?
   - Seit wann?

2. **Letztes funktionierendes Backup finden**
   - Backup-Server: 192.168.1.100
   - Backup-Pfad: /mnt/backups/
   - Neuestes Backup: backup_YYYYMMDD.sql.gz

3. **Test-Restore durchführen**
   - Auf separatem Server testen
   - Datenintegrität prüfen

4. **Produktiv-Restore**
   - Applikation stoppen
   - Datenbank wiederherstellen
   - Tests durchführen
   - Applikation starten

5. **Dokumentation**
   - Was ist passiert?
   - Was wurde gemacht?
   - Lessons learned
```

## Monitoring & Alerting

### Database Monitoring

```javascript
// Einfaches Health-Check Endpoint
router.get('/health', async (req, res) => {
    try {
        // DB Connection testen
        const [result] = await db.query('SELECT 1');
        
        // Disk Space prüfen (konzeptuell)
        const [diskSpace] = await db.query('SHOW VARIABLES LIKE "datadir"');
        
        res.json({
            status: 'healthy',
            database: 'connected',
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            error: error.message
        });
    }
});

// Backup-Status prüfen
router.get('/backup-status', async (req, res) => {
    const fs = require('fs');
    const backupDir = './backups';
    
    const files = fs.readdirSync(backupDir);
    const latestBackup = files
        .filter(f => f.endsWith('.sql.gz'))
        .sort()
        .reverse()[0];
    
    if (!latestBackup) {
        return res.json({
            status: 'warning',
            message: 'Kein Backup gefunden'
        });
    }
    
    const stats = fs.statSync(`${backupDir}/${latestBackup}`);
    const age = Date.now() - stats.mtimeMs;
    const ageHours = age / (1000 * 60 * 60);
    
    res.json({
        latestBackup,
        ageHours: Math.round(ageHours),
        status: ageHours < 24 ? 'ok' : 'warning'
    });
});
```

## Projektpräsentationen

### Vorbereitung

**Zeit:** 5-7 Minuten pro Präsentation

**Struktur:**
1. **Projekt vorstellen** (1 min)
   - Was macht die Applikation?
   - Wer ist die Zielgruppe?

2. **Datenbankdesign** (2 min)
   - ER-Diagramm zeigen
   - Tabellen und Beziehungen erklären
   - Normalisierung erwähnen

3. **Live-Demo** (3 min)
   - Frontend zeigen
   - CRUD-Operationen demonstrieren
   - Besondere Features

4. **Tech-Stack** (1 min)
   - Technologien (Node.js, Express, MariaDB, etc.)
   - Besondere Libraries
   - Herausforderungen und Lösungen

### Präsentations-Checkliste

- [ ] Laptop geladen
- [ ] Datenbank mit Testdaten gefüllt
- [ ] Server läuft
- [ ] Browser vorbereitet (Tabs geöffnet)
- [ ] Backup der Präsentation (USB-Stick)
- [ ] ER-Diagramm bereit
- [ ] Code-Beispiele vorbereitet
- [ ] Notizen für Präsentation

### Was zeigen?

**Must-Show:**
- Datenbankdesign (ER-Diagramm)
- Funktionierendes Frontend
- CRUD-Operationen
- API-Endpoints (Postman/Thunder Client)

**Nice-to-Have:**
- Code-Qualität (MVC-Pattern)
- Security-Features
- Tests
- Deployment

### Bewertungskriterien (Reminder)

- **Datenbankdesign** (15 Punkte)
- **Implementation** (10 Punkte)
- **REST API** (30 Punkte)
- **Frontend** (25 Punkte)
- **Präsentation** (20 Punkte)

## Kursrückblick

### Was wir gelernt haben

**Woche 1-6: Grundlagen**
- Daten und Datenbanksysteme
- Datenbankdesign & Normalisierung
- SQL (DDL, DML, DCL, TCL)
- JOINs und komplexe Queries

**Woche 7-13: Praxis**
- Node.js + Datenbanken
- REST API Development
- KI-Tools im Datenbankumfeld
- NoSQL & MongoDB
- Frameworks & ORMs
- MQTT & IoT
- Security
- Datenschutz & Backups

### Wichtige Konzepte

1. **Normalisierung**: Redundanz vermeiden
2. **ACID**: Transaktionen
3. **Prepared Statements**: SQL-Injection verhindern
4. **MVC-Pattern**: Code-Struktur
5. **REST**: API-Design
6. **DSGVO**: Datenschutz
7. **Backups**: Datensicherheit

### Weiterführende Themen

- **Advanced SQL**: Window Functions, CTEs
- **Performance Tuning**: Indexing, Query Optimization
- **Replication**: Master-Slave, Multi-Master
- **Sharding**: Horizontal Scaling
- **GraphQL**: Alternative zu REST
- **Microservices**: Service-orientierte Architektur
- **DevOps**: CI/CD, Containerization (Docker)

## Abschluss-Checkliste

- [ ] Projekt vollständig abgegeben
- [ ] Alle Credits eingereicht (1-10)
- [ ] SQL-Test absolviert
- [ ] Präsentation vorbereitet
- [ ] Dokumentation vollständig
- [ ] Code auf GitHub/GitLab

## Ressourcen für die Zukunft

### Online-Kurse
- [MySQL for Developers](https://planetscale.com/courses/mysql-for-developers)
- [MongoDB University](https://university.mongodb.com/)
- [SQL Tutorial - W3Schools](https://www.w3schools.com/sql/)

### Bücher
- "SQL Performance Explained" - Markus Winand
- "Designing Data-Intensive Applications" - Martin Kleppmann
- "Database Design for Mere Mortals" - Michael J. Hernandez

### Tools
- [DB Fiddle](https://www.db-fiddle.com/) - SQL Online-Editor
- [DrawSQL](https://drawsql.app/) - ER-Diagramme erstellen
- [DBeaver](https://dbeaver.io/) - Universeller DB-Client

### Communities
- Stack Overflow
- Reddit: r/database, r/sql
- Discord: Database-Developer Communities

## Feedback & Verbesserungsvorschläge

Was hat euch gefallen? Was könnte verbessert werden?

## Danke & Viel Erfolg!

Vielen Dank für eure Teilnahme am Kurs! Viel Erfolg mit euren zukünftigen Projekten und bei der Arbeit mit Datenbanken!

**Stay in touch:**
- Bei Fragen auch nach dem Kurs
- LinkedIn/XING für berufliche Vernetzung
- GitHub für Code-Austausch

---

**Abschließende Worte:**

Datenbanken sind das Herzstück fast jeder modernen Applikation. Die Konzepte, die ihr in diesem Kurs gelernt habt, sind zeitlos und werden euch in eurer gesamten Karriere begleiten. Viel Erfolg!
