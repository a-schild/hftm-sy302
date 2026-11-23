# Leçon 13: Protection des données, Sauvegardes & Conclusion du cours

## Objectifs d'apprentissage

- Créer et mettre en œuvre un concept de sauvegarde pour une base de données
- Connaître les termes les plus importants de la protection des données et leur impact sur les applications
- Comprendre les exigences du RGPD dans le contexte des bases de données
- Présenter le projet avec succès

## Protection des données & RGPD

### Qu'est-ce que le RGPD?

Le **RGPD (Règlement Général sur la Protection des Données)** / **GDPR (General Data Protection Regulation)** est la réglementation de l'UE pour la protection des données personnelles.

**En vigueur depuis:** 25 mai 2018
**S'applique à:** Toutes les entreprises qui traitent des données de citoyens de l'UE

### Données personnelles

**Définition:** Toutes les informations se rapportant à une personne identifiée ou identifiable.

**Exemples:**
- Nom, adresse, e-mail
- Numéro de téléphone, adresse IP
- Données de localisation, cookies
- Données financières, données de santé
- Données biométriques, données génétiques

**Non personnelles:**
- Statistiques anonymisées
- Données d'entreprise
- Données publiques

### Principes fondamentaux du RGPD

1. **Licéité, loyauté, transparence**
   - Traiter les données uniquement avec consentement ou base juridique
   - Informer les utilisateurs du traitement des données

2. **Limitation des finalités**
   - Collecter les données uniquement pour des finalités déterminées
   - Pas d'utilisation ultérieure pour d'autres finalités

3. **Minimisation des données**
   - Collecter uniquement les données nécessaires
   - "Autant que nécessaire, aussi peu que possible"

4. **Exactitude**
   - Les données doivent être exactes
   - Les données inexactes doivent être supprimées/corrigées

5. **Limitation de la conservation**
   - Conserver les données uniquement aussi longtemps que nécessaire
   - Définir des délais de suppression

6. **Intégrité et confidentialité**
   - Mesures de sécurité appropriées
   - Protection contre l'accès non autorisé

### Droits des personnes concernées

Chaque personne a les droits suivants:

| Droit | Description | Mise en œuvre technique |
|-------|-------------|-------------------------|
| **Accès** | Droit de savoir quelles données sont stockées | Implémenter fonction d'export |
| **Rectification** | Droit de corriger les données incorrectes | Fonctions de mise à jour |
| **Effacement** | "Droit à l'oubli" | Fonctions de suppression, Cascading |
| **Limitation** | Limiter le traitement des données | Flags de statut en BD |
| **Portabilité** | Recevoir les données en format lisible par machine | Export JSON/CSV |
| **Opposition** | S'opposer au traitement | Mécanisme d'opt-out |

## RGPD en pratique

### 1. Privacy by Design

Penser à la protection des données dès le début:

```javascript
// Schéma avec champs de protection des données
const userSchema = {
    user_id: 'INT PRIMARY KEY',
    email: 'VARCHAR(255) UNIQUE',
    username: 'VARCHAR(50)',
    
    // Champs de protection des données
    consent_marketing: 'BOOLEAN DEFAULT FALSE',
    consent_date: 'DATETIME',
    deletion_requested: 'BOOLEAN DEFAULT FALSE',
    deletion_date: 'DATETIME',
    data_retention_until: 'DATETIME'
};
```

### 2. Obtenir le consentement

```javascript
// Inscription avec consentement explicite
app.post('/api/register', async (req, res) => {
    const { email, password, acceptPrivacyPolicy, acceptMarketing } = req.body;
    
    if (!acceptPrivacyPolicy) {
        return res.status(400).json({
            error: 'La politique de confidentialité doit être acceptée'
        });
    }
    
    await db.query(`
        INSERT INTO users (email, password_hash, consent_marketing, consent_date)
        VALUES (?, ?, ?, NOW())
    `, [email, hashedPassword, acceptMarketing]);
    
    res.json({ success: true });
});
```

### 3. Implémenter le droit d'accès

```javascript
// GET /api/users/me/data-export
router.get('/me/data-export', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    // Collecter toutes les données de l'utilisateur
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
    
    // Supprimer les données sensibles
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

### 4. Droit à l'effacement

```javascript
// DELETE /api/users/me
router.delete('/me', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    // Soft Delete (marquer les données d'abord)
    await db.query(`
        UPDATE users 
        SET deletion_requested = TRUE, 
            deletion_date = DATE_ADD(NOW(), INTERVAL 30 DAY),
            email = CONCAT('deleted_', user_id, '@deleted.local')
        WHERE user_id = ?
    `, [userId]);
    
    res.json({
        message: 'Suppression demandée. Le compte sera supprimé dans 30 jours.'
    });
});

// Cron Job pour suppression finale
async function deleteExpiredAccounts() {
    await db.query(`
        DELETE FROM users 
        WHERE deletion_requested = TRUE 
        AND deletion_date <= NOW()
    `);
}
```

### 5. Minimisation des données

```javascript
// Retourner uniquement les données nécessaires
router.get('/api/users', async (req, res) => {
    const [users] = await db.query(`
        SELECT user_id, username, created_at
        FROM users
        -- PAS: email, password_hash, phone, etc.
    `);
    
    res.json(users);
});
```

### 6. Pseudonymisation & Anonymisation

**Pseudonymisation:** Les données peuvent être attribuées à une personne avec des informations supplémentaires
**Anonymisation:** La référence à la personne ne peut plus être établie

```javascript
// Pseudonymisation pour Analytics
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

// Anonymisation pour statistiques
async function createStatistics() {
    // Uniquement données agrégées, pas d'user-IDs
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

### 7. Chiffrement des données sensibles

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

// Utilisation
const encryption = new DataEncryption();

// Sauvegarder
const sensitive = "Numéro de carte de crédit: 1234-5678-9012-3456";
const { encrypted, iv, authTag } = encryption.encrypt(sensitive);

await db.query(
    'INSERT INTO payments (user_id, encrypted_data, iv, auth_tag) VALUES (?, ?, ?, ?)',
    [userId, encrypted, iv, authTag]
);

// Lire
const [rows] = await db.query('SELECT * FROM payments WHERE user_id = ?', [userId]);
const decrypted = encryption.decrypt(
    rows[0].encrypted_data,
    rows[0].iv,
    rows[0].auth_tag
);
```

## Sauvegardes de base de données

### Pourquoi les sauvegardes?

- **Panne matérielle**: Les disques durs peuvent tomber en panne
- **Erreurs humaines**: Suppression accidentelle
- **Bugs logiciels**: Perte de données due à des bugs
- **Cyberattaques**: Ransomware, hacking
- **Catastrophes naturelles**: Incendie, inondation

### Règle de sauvegarde 3-2-1

- **3** copies des données (Original + 2 sauvegardes)
- **2** médias différents (ex. disque dur + cloud)
- **1** copie externe/hors site

### Types de sauvegardes

#### 1. Full Backup (Sauvegarde complète)

La base de données complète est sauvegardée.

**Avantages:**
- Restauration simple
- Données complètes

**Inconvénients:**
- Prend du temps
- Beaucoup d'espace

```bash
# MariaDB/MySQL Full Backup
mysqldump -u root -p --all-databases > full_backup_$(date +%Y%m%d).sql

# Avec compression
mysqldump -u root -p --all-databases | gzip > full_backup_$(date +%Y%m%d).sql.gz

# Base de données unique
mysqldump -u root -p mydatabase > mydatabase_backup.sql
```

#### 2. Incremental Backup (Sauvegarde incrémentale)

Uniquement les modifications depuis la dernière sauvegarde.

**Avantages:**
- Plus rapide
- Moins d'espace

**Inconvénients:**
- Restauration plus complexe
- Toutes les sauvegardes depuis le dernier Full Backup nécessaires

#### 3. Differential Backup

Toutes les modifications depuis la dernière sauvegarde complète.

**Avantages:**
- Restauration plus rapide qu'Incremental
- Moins d'espace que Full

**Inconvénients:**
- Augmente avec le temps

### Configurer les sauvegardes automatiques

#### Linux Cron Job

```bash
# Éditer crontab
crontab -e

# Sauvegarde quotidienne à 2h00
0 2 * * * /usr/bin/mysqldump -u backup_user -pPASSWORD mydatabase | gzip > /backups/db_$(date +\%Y\%m\%d).sql.gz

# Sauvegarde hebdomadaire (Dimanche 3h00)
0 3 * * 0 /usr/bin/mysqldump -u backup_user -pPASSWORD mydatabase > /backups/weekly/db_$(date +\%Y\%m\%d).sql

# Supprimer anciennes sauvegardes (plus de 30 jours)
0 4 * * * find /backups -name "*.sql.gz" -mtime +30 -delete
```

#### Script de sauvegarde Node.js

```javascript
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

class DatabaseBackup {
    constructor(config) {
        this.config = config;
        this.backupDir = config.backupDir || './backups';
        
        // Créer le répertoire de sauvegarde
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
                    console.error('Erreur de sauvegarde:', error);
                    reject(error);
                    return;
                }
                
                console.log(`Sauvegarde créée: ${filename}`);
                
                // Compresser
                exec(`gzip ${filepath}`, (err) => {
                    if (err) {
                        console.error('Échec de la compression:', err);
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
                console.log(`Ancienne sauvegarde supprimée: ${file}`);
            }
        });
    }
    
    async uploadToCloud(filename) {
        // Exemple: Upload vers AWS S3, Google Cloud Storage, etc.
        // Seulement concept ici
        console.log(`Upload ${filename} vers le cloud...`);
        // Implementation depends on cloud provider
    }
}

// Utilisation
const backup = new DatabaseBackup({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    backupDir: './backups'
});

// Créer sauvegarde
backup.createBackup()
    .then(() => backup.deleteOldBackups(30))
    .catch(err => console.error('Échec de la sauvegarde:', err));
```

### Restaurer une sauvegarde

```bash
# Importer fichier SQL
mysql -u root -p mydatabase < backup.sql

# Fichier compressé
gunzip < backup.sql.gz | mysql -u root -p mydatabase

# Sauvegarde complète (toutes les bases de données)
mysql -u root -p < full_backup.sql
```

### Tester les sauvegardes

**IMPORTANT:** Tester régulièrement si les sauvegardes fonctionnent!

```bash
# Test-Restore dans base de données séparée
mysql -u root -p -e "CREATE DATABASE test_restore"
mysql -u root -p test_restore < backup.sql

# Vérifier
mysql -u root -p test_restore -e "SHOW TABLES"
mysql -u root -p test_restore -e "SELECT COUNT(*) FROM users"

# Supprimer BD de test
mysql -u root -p -e "DROP DATABASE test_restore"
```

### Solutions de sauvegarde Cloud

#### AWS RDS Automated Backups
- Snapshots quotidiens automatiques
- Point-in-time Recovery
- Rétention jusqu'à 35 jours

#### Google Cloud SQL
- Sauvegardes automatiques
- Sauvegardes à la demande
- Export vers Cloud Storage

#### Azure Database
- Sauvegardes automatiques
- Stockage géo-redondant
- Rétention à long terme

## Plan de reprise après sinistre

### 1. Définir RTO & RPO

**RTO (Recovery Time Objective):** Combien de temps maximum le système peut être en panne?
- Exemple: 4 heures

**RPO (Recovery Point Objective):** Quelle perte de données est acceptable?
- Exemple: 1 heure (les données de la dernière heure peuvent être perdues)

### 2. Stratégie de sauvegarde basée sur RTO/RPO

| RPO/RTO | Stratégie de sauvegarde | Coûts |
|---------|------------------------|-------|
| Heures | Sauvegardes Full quotidiennes | Faible |
| Minutes | Incremental horaire + Log Shipping | Moyen |
| Secondes | Réplication Master-Slave + Sauvegardes | Élevé |
| Aucun (24/7) | Cluster Multi-Master + Sauvegardes | Très élevé |

### 3. Documenter le plan d'urgence

```markdown
# Procédure de reprise après sinistre

## Contacter en cas d'urgence:
- Admin BD: +41 XX XXX XX XX
- Responsable sauvegarde: +41 XX XXX XX XX
- Chef IT: +41 XX XXX XX XX

## Récupération étape par étape:

1. **Évaluer la situation**
   - Que s'est-il passé?
   - Quelles données sont affectées?
   - Depuis quand?

2. **Trouver la dernière sauvegarde fonctionnelle**
   - Serveur de sauvegarde: 192.168.1.100
   - Chemin de sauvegarde: /mnt/backups/
   - Dernière sauvegarde: backup_YYYYMMDD.sql.gz

3. **Effectuer Test-Restore**
   - Tester sur serveur séparé
   - Vérifier l'intégrité des données

4. **Restore en production**
   - Arrêter l'application
   - Restaurer la base de données
   - Effectuer des tests
   - Démarrer l'application

5. **Documentation**
   - Que s'est-il passé?
   - Qu'a été fait?
   - Leçons apprises
```

## Monitoring & Alerting

### Surveillance de base de données

```javascript
// Endpoint simple de contrôle de santé
router.get('/health', async (req, res) => {
    try {
        // Tester connexion BD
        const [result] = await db.query('SELECT 1');
        
        // Vérifier espace disque (conceptuel)
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

// Vérifier statut de sauvegarde
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
            message: 'Aucune sauvegarde trouvée'
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

## Buffet (optionnel): MongoDB sur le Raspberry Pi

Ceux qui ont terminé le projet peuvent faire tourner MongoDB de la leçon 10 sur leur propre Raspberry Pi. Le plus simple est d'utiliser Docker:

```bash
ssh <utilisateur>@<pi-host>
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER      # puis se reconnecter

# Raspberry Pi 5 (OS 64 bits):
docker run -d --name mongo -p 127.0.0.1:27017:27017 -v mongo-data:/data/db mongo:7
# Raspberry Pi 4: les versions actuelles de MongoDB n'y fonctionnent pas, seulement 4.4
# docker run -d --name mongo -p 127.0.0.1:27017:27017 -v mongo-data:/data/db mongo:4.4.18

docker exec -it mongo mongosh      # avec mongo:4.4: mongo au lieu de mongosh
```

Ensuite, exécutez les exercices de la leçon 10 (CRUD, agrégation) sur le Raspberry Pi et connectez une application Node.js avec `mongodb://127.0.0.1:27017`. Depuis le portable, cela fonctionne comme pour MariaDB via un tunnel SSH: `ssh -L 27017:127.0.0.1:27017 <utilisateur>@<pi-host>`.

## Présentations des projets

### Préparation

**Temps:** 5-7 minutes par présentation

**Structure:**
1. **Présenter le projet** (1 min)
   - Que fait l'application?
   - Qui est le public cible?

2. **Conception de base de données** (2 min)
   - Montrer le diagramme ER
   - Expliquer tables et relations
   - Mentionner la normalisation

3. **Démonstration en direct** (3 min)
   - Montrer le frontend
   - Démontrer opérations CRUD
   - Fonctionnalités spéciales

4. **Stack technologique** (1 min)
   - Technologies (Node.js, Express, MariaDB, etc.)
   - Bibliothèques spéciales
   - Défis et solutions

### Checklist de présentation

- [ ] Ordinateur chargé
- [ ] Base de données remplie avec données de test
- [ ] Serveur en cours d'exécution
- [ ] Navigateur préparé (onglets ouverts)
- [ ] Sauvegarde de la présentation (clé USB)
- [ ] Diagramme ER prêt
- [ ] Exemples de code préparés
- [ ] Notes pour présentation

### Que montrer?

**Must-Show:**
- Conception de base de données (Diagramme ER)
- Frontend fonctionnel
- Opérations CRUD
- Endpoints API (Postman/Thunder Client)

**Nice-to-Have:**
- Qualité du code (Pattern MVC)
- Fonctionnalités de sécurité
- Tests
- Déploiement

### Critères d'évaluation (Rappel)

- **Conception de BD** (15 points)
- **Implémentation** (10 points)
- **API REST** (30 points)
- **Frontend** (25 points)
- **Présentation** (20 points)

## Rétrospective du cours

### Ce que nous avons appris

**Semaines 1-6: Fondamentaux**
- Données et systèmes de bases de données
- Conception de BD & Normalisation
- SQL (DDL, DML, DCL, TCL)
- JOINs et requêtes complexes

**Semaines 7-13: Pratique**
- Node.js + Bases de données
- Développement API REST
- Outils IA dans l'environnement BD
- NoSQL & MongoDB
- Frameworks & ORMs
- MQTT & IoT
- Sécurité
- Protection des données & Sauvegardes

### Concepts importants

1. **Normalisation**: Éviter la redondance
2. **ACID**: Transactions
3. **Prepared Statements**: Prévenir l'injection SQL
4. **Pattern MVC**: Structure du code
5. **REST**: Conception d'API
6. **RGPD**: Protection des données
7. **Sauvegardes**: Sécurité des données

### Sujets à approfondir

- **SQL Avancé**: Window Functions, CTEs
- **Optimisation des performances**: Indexing, Query Optimization
- **Réplication**: Master-Slave, Multi-Master
- **Sharding**: Mise à l'échelle horizontale
- **GraphQL**: Alternative à REST
- **Microservices**: Architecture orientée services
- **DevOps**: CI/CD, Containerisation (Docker)

## Checklist de fin

- [ ] Projet complètement soumis
- [ ] Tous les crédits soumis (1-10)
- [ ] Test SQL passé
- [ ] Présentation préparée
- [ ] Documentation complète
- [ ] Code sur GitHub/GitLab

## Ressources pour l'avenir

### Cours en ligne
- [MySQL for Developers](https://planetscale.com/courses/mysql-for-developers)
- [MongoDB University](https://university.mongodb.com/)
- [SQL Tutorial - W3Schools](https://www.w3schools.com/sql/)

### Livres
- "SQL Performance Explained" - Markus Winand
- "Designing Data-Intensive Applications" - Martin Kleppmann
- "Database Design for Mere Mortals" - Michael J. Hernandez

### Outils
- [DB Fiddle](https://www.db-fiddle.com/) - Éditeur SQL en ligne
- [DrawSQL](https://drawsql.app/) - Créer diagrammes ER
- [DBeaver](https://dbeaver.io/) - Client BD universel

### Communautés
- Stack Overflow
- Reddit: r/database, r/sql
- Discord: Communautés Database-Developer

## Feedback & Suggestions d'amélioration

Qu'avez-vous aimé? Que pourrait être amélioré?

## Merci & Bonne chance!

Merci pour votre participation au cours! Bonne chance avec vos futurs projets et votre travail avec les bases de données!

**Restons en contact:**
- Pour les questions même après le cours
- LinkedIn/XING pour le réseautage professionnel
- GitHub pour l'échange de code

---

**Mots de conclusion:**

Les bases de données sont au cœur de presque toutes les applications modernes. Les concepts que vous avez appris dans ce cours sont intemporels et vous accompagneront tout au long de votre carrière. Bonne chance!
