# SY302 Databases - Script Compact (Complet)

**HFTM Technique des systèmes | Leçons 1-13**

Ce script couvre les 13 leçons et sert de référence et d'aide à l'apprentissage.

**Volume:** ~70 pages | Tous les concepts importants avec exemples

---

# PARTIE 1: BASES SQL (Leçons 1-6)

## Leçon 1: Introduction aux bases de données

### Qu'est-ce qu'une base de données?

Une **base de données** est une collection structurée de données.

**Avantages:**
- ✅ Cohérence des données
- ✅ Pas de redondance
- ✅ Accès multi-utilisateurs
- ✅ Sécurité & droits d'accès
- ✅ Sauvegarde & récupération

### SGBD (Système de Gestion de Base de Données)

**SGBD connus:**
- MySQL / MariaDB
- PostgreSQL
- Oracle
- Microsoft SQL Server

### Bases de données relationnelles

**Concepts de base:**
- **Table**: Collection de données
- **Ligne**: Un enregistrement
- **Colonne**: Propriété
- **Clé primaire**: ID unique
- **Clé étrangère**: Référence vers autre table

### Types de données

**Numérique:**
```sql
INT           -- Entier
DECIMAL(10,2) -- Exact (pour argent)
FLOAT         -- Approximatif
```

**Texte:**
```sql
VARCHAR(255)  -- Longueur variable
TEXT          -- Textes longs
CHAR(10)      -- Longueur fixe
```

**Date/Heure:**
```sql
DATE          -- Date uniquement
DATETIME      -- Date + Heure
TIMESTAMP     -- Mise à jour automatique
```

---

## Leçon 2: Conception de BD & Normalisation

### Diagramme ER (Entité-Relation)

**Éléments:**
- **Entité**: Objet (Rectangle)
- **Attribut**: Propriété (Ovale)
- **Relation**: Connexion (Losange)
- **Clé primaire**: Soulignée

### Types de relations

**1:1** - Personne ↔ Passeport
**1:N** - Auteur ↔ Livres  
**N:M** - Étudiants ↔ Cours (nécessite table de jonction)

### Normalisation

**1ère Forme Normale (1FN):**
- ✅ Valeurs atomiques
- ✅ Clé primaire présente

**2ème Forme Normale (2FN):**
- ✅ 1FN remplie
- ✅ Pas de dépendances partielles

**3ème Forme Normale (3FN):**
- ✅ 2FN remplie
- ✅ Pas de dépendances transitives

---

## Leçon 3: SQL DDL (Data Definition Language)

### CREATE TABLE

```sql
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(17) UNIQUE,
    price DECIMAL(10,2) DEFAULT 0.00,
    author_id INT NOT NULL,
    
    FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
```

### Contraintes

```sql
PRIMARY KEY       -- ID unique
FOREIGN KEY       -- Référence
UNIQUE            -- Pas de doublons
NOT NULL          -- Champ obligatoire
CHECK             -- Condition
DEFAULT           -- Valeur par défaut
AUTO_INCREMENT    -- Incrémentation automatique
```

### ALTER TABLE

```sql
-- Ajouter colonne
ALTER TABLE books ADD COLUMN description TEXT;

-- Modifier colonne
ALTER TABLE books MODIFY COLUMN title VARCHAR(300);

-- Supprimer colonne
ALTER TABLE books DROP COLUMN description;
```

---

## Leçon 4: SQL DML (Data Manipulation Language)

### INSERT

```sql
INSERT INTO authors (first_name, last_name) VALUES
    ('George', 'Orwell'),
    ('Jane', 'Austen');
```

### SELECT

```sql
-- Bases
SELECT * FROM books;
SELECT title, price FROM books;

-- WHERE
SELECT * FROM books WHERE price > 50;
SELECT * FROM books WHERE title LIKE '%Harry%';

-- ORDER BY
SELECT * FROM books ORDER BY price DESC;

-- LIMIT
SELECT * FROM books LIMIT 10;
```

### UPDATE

```sql
UPDATE books 
SET price = 29.99 
WHERE id = 1;
```

### DELETE

```sql
DELETE FROM books WHERE id = 1;
```

### Fonctions d'agrégation

```sql
SELECT 
    COUNT(*) AS nombre,
    SUM(price) AS total,
    AVG(price) AS moyenne,
    MIN(price) AS min,
    MAX(price) AS max
FROM books;
```

### GROUP BY

```sql
SELECT author_id, COUNT(*) AS nombre
FROM books
GROUP BY author_id
HAVING nombre > 3;
```

---

## Leçon 5: SQL JOINs

### INNER JOIN

```sql
SELECT books.title, authors.name
FROM books
INNER JOIN authors ON books.author_id = authors.id;
```

### LEFT JOIN

```sql
SELECT authors.name, COUNT(books.id) AS nombre
FROM authors
LEFT JOIN books ON authors.id = books.author_id
GROUP BY authors.id;
```

### JOINs multiples

```sql
SELECT 
    books.title,
    authors.name,
    categories.name AS categorie
FROM books
INNER JOIN authors ON books.author_id = authors.id
LEFT JOIN categories ON books.category_id = categories.id;
```

---

## Leçon 6: DCL, TCL & Préparation test

### DCL (Data Control Language)

```sql
-- Créer utilisateur
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';

-- Accorder droits
GRANT SELECT, INSERT ON mydatabase.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;

-- Révoquer droits
REVOKE INSERT ON mydatabase.* FROM 'app_user'@'localhost';
```

### TCL (Transaction Control Language)

```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;      -- Enregistrer
-- ou
ROLLBACK;    -- Annuler
```

---

# PARTIE 2: DÉVELOPPEMENT BACKEND (Leçons 7-13)

## Leçon 7: Node.js & Bases de données

### Configuration Node.js

```bash
npm init -y
npm install express mysql2
```

### Serveur Express

```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.get('/', (req, res) => {
    res.send('Hello World!');
});

app.listen(3000);
```

### Connexion MySQL

```javascript
const mysql = require('mysql2');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'library'
});

module.exports = pool.promise();
```

### Exécuter des requêtes

```javascript
const db = require('./config/database');

// SELECT
const [books] = await db.query('SELECT * FROM books');

// INSERT
const [result] = await db.query(
    'INSERT INTO books (title, author_id) VALUES (?, ?)',
    [title, authorId]
);

// UPDATE
await db.query(
    'UPDATE books SET title = ? WHERE id = ?',
    [newTitle, id]
);

// DELETE
await db.query('DELETE FROM books WHERE id = ?', [id]);
```

---

## Leçon 8: Développement API REST

### Méthodes HTTP

| Méthode | But | Exemple |
|---------|-----|---------|
| GET | Lire | `GET /api/books` |
| POST | Créer | `POST /api/books` |
| PUT | Remplacer | `PUT /api/books/1` |
| DELETE | Supprimer | `DELETE /api/books/1` |

### API CRUD

```javascript
const express = require('express');
const router = express.Router();
const db = require('../config/database');

// CREATE
router.post('/', async (req, res) => {
    const { title, author_id } = req.body;
    const [result] = await db.query(
        'INSERT INTO books (title, author_id) VALUES (?, ?)',
        [title, author_id]
    );
    res.status(201).json({ id: result.insertId });
});

// READ ALL
router.get('/', async (req, res) => {
    const [books] = await db.query('SELECT * FROM books');
    res.json(books);
});

// READ ONE
router.get('/:id', async (req, res) => {
    const [books] = await db.query(
        'SELECT * FROM books WHERE id = ?',
        [req.params.id]
    );
    if (books.length === 0) {
        return res.status(404).json({ error: 'Non trouvé' });
    }
    res.json(books[0]);
});

// UPDATE
router.put('/:id', async (req, res) => {
    const { title, author_id } = req.body;
    await db.query(
        'UPDATE books SET title = ?, author_id = ? WHERE id = ?',
        [title, author_id, req.params.id]
    );
    res.json({ message: 'Mis à jour' });
});

// DELETE
router.delete('/:id', async (req, res) => {
    await db.query('DELETE FROM books WHERE id = ?', [req.params.id]);
    res.status(204).send();
});

module.exports = router;
```

---

## Leçon 9: IA & Bases de données

### Outils IA

- ChatGPT
- Claude
- GitHub Copilot
- Perplexity AI

### Cas d'usage

**Générer requêtes SQL:**
```
"Crée requête SQL pour tous les livres avec plus de 3 emprunts"
```

**Révision de code:**
```
"Révise ce code pour problèmes de sécurité"
```

**Optimisation:**
```
"Optimise cette requête pour meilleure performance"
```

### Meilleures pratiques

✅ **À faire:**
- Prompts spécifiques
- Vérifier le code soi-même
- Utiliser comme outil d'apprentissage

❌ **À ne pas faire:**
- Copier aveuglément
- Ignorer la sécurité

---

## Leçon 10: NoSQL & MongoDB

### Bases MongoDB

```javascript
const { MongoClient } = require('mongodb');

const client = new MongoClient('mongodb://localhost:27017');
const db = client.db('library');
const books = db.collection('books');

// CREATE
await books.insertOne({
    title: 'Harry Potter',
    author: 'J.K. Rowling',
    year: 1997
});

// READ
const allBooks = await books.find().toArray();
const oneBook = await books.findOne({ title: 'Harry Potter' });

// UPDATE
await books.updateOne(
    { title: 'Harry Potter' },
    { $set: { year: 1998 } }
);

// DELETE
await books.deleteOne({ title: 'Harry Potter' });
```

### SQL vs. NoSQL

| Caractéristique | SQL | NoSQL |
|-----------------|-----|-------|
| Schéma | Fixe | Flexible |
| Évolutivité | Verticale | Horizontale |
| Transactions | ACID | Eventual Consistency |
| Relations | JOINs | Embedded/Refs |

---

## Leçon 11: ORMs & Frameworks

### Sequelize (ORM)

```bash
npm install sequelize mysql2
```

**Définir modèle:**
```javascript
const { Sequelize, DataTypes } = require('sequelize');

const sequelize = new Sequelize('database', 'user', 'password', {
    host: 'localhost',
    dialect: 'mysql'
});

const Book = sequelize.define('Book', {
    title: {
        type: DataTypes.STRING,
        allowNull: false
    },
    price: {
        type: DataTypes.DECIMAL(10, 2),
        defaultValue: 0
    }
});

await sequelize.sync();
```

**Opérations CRUD:**
```javascript
// CREATE
const book = await Book.create({
    title: 'Harry Potter',
    price: 29.99
});

// READ
const books = await Book.findAll();
const book = await Book.findByPk(1);
const harryBooks = await Book.findAll({
    where: { title: { [Op.like]: '%Harry%' } }
});

// UPDATE
await Book.update(
    { price: 34.99 },
    { where: { id: 1 } }
);

// DELETE
await Book.destroy({ where: { id: 1 } });
```

---

## Leçon 12: MQTT & Sécurité

### Bases MQTT

```bash
npm install mqtt
```

**Publisher:**
```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    client.publish('sensors/temperature', '22.5');
});
```

**Subscriber:**
```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    client.subscribe('sensors/#');
});

client.on('message', (topic, message) => {
    console.log(`${topic}: ${message.toString()}`);
});
```

### Meilleures pratiques de sécurité

**1. Prévenir injection SQL:**
```javascript
// ❌ Non sécurisé
const query = `SELECT * FROM users WHERE name = '${userName}'`;

// ✅ Sécurisé (Prepared Statements)
const [users] = await db.query(
    'SELECT * FROM users WHERE name = ?',
    [userName]
);
```

**2. Hacher les mots de passe:**
```bash
npm install bcrypt
```

```javascript
const bcrypt = require('bcrypt');

// Hacher
const hashedPassword = await bcrypt.hash(password, 10);

// Comparer
const valid = await bcrypt.compare(password, hashedPassword);
```

**3. Authentification JWT:**
```bash
npm install jsonwebtoken
```

```javascript
const jwt = require('jsonwebtoken');

// Créer token
const token = jwt.sign(
    { userId: user.id },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
);

// Vérifier token
jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: 'Token invalide' });
    req.user = decoded;
    next();
});
```

**4. Variables d'environnement:**
```bash
npm install dotenv
```

**.env:**
```
DB_PASSWORD=secret123
JWT_SECRET=supersecret
```

**Code:**
```javascript
require('dotenv').config();
const password = process.env.DB_PASSWORD;
```

**5. En-têtes de sécurité:**
```bash
npm install helmet
```

```javascript
const helmet = require('helmet');
app.use(helmet());
```

**6. Limitation de débit:**
```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // Max 100 requêtes
});

app.use('/api/', limiter);
```

---

## Leçon 13: Protection données, Sauvegardes & Conclusion

### RGPD (GDPR)

**Principes fondamentaux:**
1. Licéité & Transparence
2. Limitation des finalités
3. Minimisation des données
4. Exactitude
5. Limitation de la conservation
6. Intégrité & Confidentialité

**Droits des personnes:**
- ✅ Droit d'accès
- ✅ Droit de rectification
- ✅ Droit à l'effacement ("Droit à l'oubli")
- ✅ Droit à la portabilité

**Implémentation:**

**1. Consentement:**
```javascript
const userSchema = {
    email: 'VARCHAR(255)',
    consent_marketing: 'BOOLEAN DEFAULT FALSE',
    consent_date: 'DATETIME'
};
```

**2. Export de données:**
```javascript
router.get('/me/data-export', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    const [userData] = await db.query(
        'SELECT * FROM users WHERE user_id = ?',
        [userId]
    );
    
    const [orders] = await db.query(
        'SELECT * FROM orders WHERE user_id = ?',
        [userId]
    );
    
    res.json({
        personal_data: userData[0],
        orders: orders,
        export_date: new Date()
    });
});
```

**3. Droit à l'effacement:**
```javascript
router.delete('/me', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    // Soft Delete
    await db.query(`
        UPDATE users 
        SET deletion_requested = TRUE,
            deletion_date = DATE_ADD(NOW(), INTERVAL 30 DAY)
        WHERE user_id = ?
    `, [userId]);
    
    res.json({ message: 'Suppression demandée' });
});
```

### Sauvegardes de base de données

**Règle 3-2-1:**
- **3** copies des données
- **2** médias différents
- **1** copie externe/hors site

**Types de sauvegardes:**

**1. Sauvegarde complète:**
```bash
mysqldump -u root -p mydatabase > backup.sql
mysqldump -u root -p mydatabase | gzip > backup.sql.gz
```

**2. Sauvegardes automatisées:**
```bash
# Cron Job (quotidien 2h00)
0 2 * * * mysqldump -u root -p mydatabase > /backups/db_$(date +\%Y\%m\%d).sql
```

**3. Restaurer sauvegarde:**
```bash
mysql -u root -p mydatabase < backup.sql
gunzip < backup.sql.gz | mysql -u root -p mydatabase
```

**Script Node.js de sauvegarde:**
```javascript
const { exec } = require('child_process');

class DatabaseBackup {
    async createBackup() {
        const timestamp = new Date().toISOString();
        const filename = `backup_${timestamp}.sql`;
        
        const command = `mysqldump -u ${this.user} -p${this.password} ${this.database} > ${filename}`;
        
        return new Promise((resolve, reject) => {
            exec(command, (error) => {
                if (error) reject(error);
                else resolve(filename);
            });
        });
    }
    
    async deleteOldBackups(days = 30) {
        // Supprimer anciennes sauvegardes (plus de X jours)
    }
}
```

### Reprise après sinistre

**RTO & RPO:**
- **RTO** (Recovery Time Objective): Temps d'arrêt maximum
- **RPO** (Recovery Point Objective): Perte de données acceptable

**Plan d'urgence:**
1. Évaluer la situation
2. Trouver dernière sauvegarde fonctionnelle
3. Effectuer restauration de test
4. Restauration en production
5. Documentation

### Surveillance

```javascript
// Endpoint de santé
router.get('/health', async (req, res) => {
    try {
        await db.query('SELECT 1');
        res.json({ status: 'sain', database: 'connectée' });
    } catch (error) {
        res.status(503).json({ status: 'malade' });
    }
});

// Statut de sauvegarde
router.get('/backup-status', async (req, res) => {
    const files = fs.readdirSync('./backups');
    const latestBackup = files.sort().reverse()[0];
    
    const stats = fs.statSync(`./backups/${latestBackup}`);
    const age = Date.now() - stats.mtimeMs;
    const ageHours = age / (1000 * 60 * 60);
    
    res.json({
        latestBackup,
        ageHours: Math.round(ageHours),
        status: ageHours < 24 ? 'ok' : 'avertissement'
    });
});
```

---

## Présentations de projets

### Structure (5-7 minutes)

1. **Présenter le projet** (1 min)
   - Que fait l'application?
   - Public cible?

2. **Conception BD** (2 min)
   - Diagramme ER
   - Tables & relations
   - Normalisation

3. **Démonstration en direct** (3 min)
   - Montrer le frontend
   - Opérations CRUD
   - Fonctionnalités spéciales

4. **Stack technique** (1 min)
   - Technologies
   - Défis

### Critères d'évaluation

- **Conception BD** (15 points)
- **Implémentation** (10 points)
- **API REST** (30 points)
- **Frontend** (25 points)
- **Présentation** (20 points)

**Total: 100 points**

---

## Rétrospective du cours

### Ce que nous avons appris

**Semaines 1-6: Bases SQL**
- Bases de données & Normalisation
- SQL DDL, DML, DCL, TCL
- JOINs & Requêtes complexes

**Semaines 7-9: Backend**
- Node.js + Express
- Développement API REST
- IA & Bases de données

**Semaines 10-11: Avancé**
- NoSQL & MongoDB
- ORMs & Frameworks

**Semaines 12-13: Projet**
- MQTT & IoT
- Sécurité & RGPD
- Sauvegardes & Récupération

### Concepts importants

1. **Normalisation** - Éviter redondance
2. **ACID** - Transactions
3. **Prepared Statements** - Prévenir injection SQL
4. **Pattern MVC** - Structure du code
5. **REST** - Conception API
6. **RGPD** - Protection des données
7. **Sauvegardes** - Sécurité des données

---

## Aide-mémoires

### Référence rapide SQL

```sql
-- BASE DE DONNÉES
CREATE DATABASE dbname;
USE dbname;
DROP DATABASE dbname;

-- TABLE
CREATE TABLE tablename (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (other_id) REFERENCES other(id)
);
ALTER TABLE tablename ADD COLUMN newcol VARCHAR(50);
DROP TABLE tablename;

-- INSERT
INSERT INTO tablename (col1, col2) VALUES ('val1', 'val2');

-- SELECT
SELECT * FROM tablename WHERE condition;
SELECT col1, col2 FROM tablename ORDER BY col1 DESC LIMIT 10;

-- JOIN
SELECT a.*, b.name 
FROM table_a a
INNER JOIN table_b b ON a.b_id = b.id;

-- UPDATE
UPDATE tablename SET col1 = 'newval' WHERE id = 1;

-- DELETE
DELETE FROM tablename WHERE id = 1;

-- AGRÉGATION
SELECT COUNT(*), SUM(price), AVG(price) FROM products GROUP BY category;

-- TRANSACTION
START TRANSACTION;
-- requêtes ici
COMMIT; -- ou ROLLBACK;
```

### Référence rapide Node.js/Express

```javascript
// Configuration
const express = require('express');
const app = express();
app.use(express.json());

// Routes
app.get('/api/items', async (req, res) => {
    const [items] = await db.query('SELECT * FROM items');
    res.json(items);
});

app.post('/api/items', async (req, res) => {
    const { name } = req.body;
    const [result] = await db.query(
        'INSERT INTO items (name) VALUES (?)',
        [name]
    );
    res.status(201).json({ id: result.insertId });
});

app.put('/api/items/:id', async (req, res) => {
    const { name } = req.body;
    await db.query(
        'UPDATE items SET name = ? WHERE id = ?',
        [name, req.params.id]
    );
    res.json({ message: 'Mis à jour' });
});

app.delete('/api/items/:id', async (req, res) => {
    await db.query('DELETE FROM items WHERE id = ?', [req.params.id]);
    res.status(204).send();
});

app.listen(3000, () => console.log('Serveur en cours'));
```

---

## Préparation à l'examen

### Thèmes du test SQL

1. ✅ CREATE TABLE (DDL)
2. ✅ INSERT, UPDATE, DELETE (DML)
3. ✅ SELECT avec WHERE, ORDER BY, LIMIT
4. ✅ Fonctions d'agrégation
5. ✅ GROUP BY, HAVING
6. ✅ JOINs (INNER, LEFT)
7. ✅ Normalisation (1FN, 2FN, 3FN)

### Checklist du projet

- [ ] Conception BD (Diagramme ER, SQL)
- [ ] API REST (au moins 3 ressources)
- [ ] Frontend (dynamique avec API)
- [ ] Opérations CRUD fonctionnent
- [ ] Documentation (README, Docs API)
- [ ] Code sur GitHub
- [ ] Dump SQL de la base de données

---

## Ressources

### Cours en ligne
- [MySQL for Developers](https://planetscale.com/courses/mysql-for-developers)
- [MongoDB University](https://university.mongodb.com/)
- [Tutoriel SQL - W3Schools](https://www.w3schools.com/sql/)

### Outils
- [DB Fiddle](https://www.db-fiddle.com/) - Éditeur SQL en ligne
- [DrawSQL](https://drawsql.app/) - Diagrammes ER
- [DBeaver](https://dbeaver.io/) - Client BD

### Documentation
- [Docs MariaDB](https://mariadb.com/kb/)
- [Express.js](https://expressjs.com/)
- [Node.js](https://nodejs.org/docs)

---

**🎉 Bonne chance pour le projet et l'examen! 🎉**

© 2024 HFTM - Tous droits réservés
