# Bases de données - Script compact pour étudiants (Suite)

```sql
-- Une seule ligne
DELETE FROM livres WHERE id = 1;

-- Plusieurs lignes
DELETE FROM livres WHERE annee_publication < 2000;

-- Toutes les lignes (avec prudence!)
DELETE FROM livres;

-- Plus rapide: vider la table
TRUNCATE TABLE livres;
```

⚠️ **IMPORTANT:** Toujours utiliser WHERE, sinon TOUTES les lignes sont supprimées!

---

## 5. JOINs & Agrégations

### INNER JOIN

Seulement les lignes avec correspondance dans les deux tables.

```sql
SELECT 
    l.titre,
    a.prenom,
    a.nom
FROM livres l
INNER JOIN auteurs a ON l.auteur_id = a.id;
```

### LEFT JOIN

Toutes les lignes de la table de gauche, même sans correspondance.

```sql
SELECT 
    a.prenom,
    a.nom,
    COUNT(l.id) AS nombre_livres
FROM auteurs a
LEFT JOIN livres l ON a.id = l.auteur_id
GROUP BY a.id;
```

### RIGHT JOIN

Toutes les lignes de la table de droite, même sans correspondance.

```sql
SELECT 
    l.titre,
    a.nom
FROM auteurs a
RIGHT JOIN livres l ON a.id = l.auteur_id;
```

### JOINs multiples

```sql
SELECT 
    l.titre,
    CONCAT(a.prenom, ' ', a.nom) AS auteur,
    e.nom AS editeur
FROM livres l
INNER JOIN auteurs a ON l.auteur_id = a.id
LEFT JOIN editeurs e ON l.editeur_id = e.id;
```

### GROUP BY

```sql
SELECT 
    auteur_id,
    COUNT(*) AS nombre,
    AVG(prix) AS prix_moyen
FROM livres
GROUP BY auteur_id;
```

### HAVING

Comme WHERE, mais après GROUP BY.

```sql
SELECT 
    auteur_id,
    COUNT(*) AS nombre
FROM livres
GROUP BY auteur_id
HAVING nombre > 3;
```

### UNION

Combine les résultats de plusieurs requêtes.

```sql
SELECT titre FROM livres WHERE prix < 20
UNION
SELECT titre FROM livres WHERE annee_publication > 2020;

-- Avec doublons
SELECT titre FROM livres WHERE prix < 20
UNION ALL
SELECT titre FROM livres WHERE annee_publication > 2020;
```

---

## 6. Transactions & Permissions

### Transactions

```sql
START TRANSACTION;

UPDATE comptes SET montant = montant - 100 WHERE id = 1;
UPDATE comptes SET montant = montant + 100 WHERE id = 2;

-- Tout sauvegarder
COMMIT;

-- Ou annuler
ROLLBACK;
```

**Principes ACID:**
- **A**tomicité: Tout ou rien
- **C**ohérence: État valide
- **I**solation: Indépendant
- **D**urabilité: Sauvegardé de manière permanente

### Utilisateurs & Permissions (DCL)

```sql
-- Créer un utilisateur
CREATE USER 'etudiant'@'localhost' 
IDENTIFIED BY 'mot_de_passe_securise';

-- Accorder des droits
GRANT SELECT, INSERT, UPDATE, DELETE 
ON bibliotheque.* 
TO 'etudiant'@'localhost';

-- Accorder tous les droits
GRANT ALL PRIVILEGES 
ON bibliotheque.* 
TO 'admin'@'localhost';

-- Révoquer des droits
REVOKE DELETE 
ON bibliotheque.* 
FROM 'etudiant'@'localhost';

-- Activer les modifications
FLUSH PRIVILEGES;
```

**Types de permissions:**
- `SELECT` - Lire
- `INSERT` - Insérer
- `UPDATE` - Modifier
- `DELETE` - Supprimer
- `CREATE` - Créer
- `DROP` - Supprimer (structure)
- `ALTER` - Modifier (structure)
- `ALL PRIVILEGES` - Tous les droits

---

## 7. Node.js & Bases de données

### Configuration

```bash
npm init -y
npm install mysql2 dotenv express
```

### Connection Pool

```javascript
// config/database.js
require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    connectionLimit: 10
});

module.exports = pool;
```

### Opérations CRUD

```javascript
const pool = require('./config/database');

// CREATE
async function createBook(title, authorId) {
    const [result] = await pool.query(
        'INSERT INTO books (title, author_id) VALUES (?, ?)',
        [title, authorId]
    );
    return result.insertId;
}

// READ
async function getAllBooks() {
    const [books] = await pool.query('SELECT * FROM books');
    return books;
}

// UPDATE
async function updateBook(id, title) {
    await pool.query(
        'UPDATE books SET title = ? WHERE id = ?',
        [title, id]
    );
}

// DELETE
async function deleteBook(id) {
    await pool.query('DELETE FROM books WHERE id = ?', [id]);
}
```

---

## 8. API REST avec Express

### Serveur Express

```javascript
const express = require('express');
const app = express();

app.use(express.json());

// Routes
app.get('/api/books', async (req, res) => {
    const [books] = await pool.query('SELECT * FROM books');
    res.json(books);
});

app.get('/api/books/:id', async (req, res) => {
    const [books] = await pool.query(
        'SELECT * FROM books WHERE id = ?',
        [req.params.id]
    );
    res.json(books[0]);
});

app.post('/api/books', async (req, res) => {
    const { title, author_id } = req.body;
    const [result] = await pool.query(
        'INSERT INTO books (title, author_id) VALUES (?, ?)',
        [title, author_id]
    );
    res.status(201).json({ id: result.insertId });
});

app.listen(3000, () => {
    console.log('Serveur en cours sur le port 3000');
});
```

### Codes de statut HTTP

- `200` OK - Succès
- `201` Created - Créé
- `204` No Content - Pas de contenu (ex: après DELETE)
- `400` Bad Request - Requête erronée
- `401` Unauthorized - Non authentifié
- `403` Forbidden - Pas d'autorisation
- `404` Not Found - Non trouvé
- `500` Internal Server Error - Erreur serveur

---

## 9. Sécurité & Meilleures pratiques

### Prévenir l'injection SQL

❌ **JAMAIS COMME ÇA:**
```javascript
const query = `SELECT * FROM users WHERE username = '${username}'`;
```

✅ **TOUJOURS COMME ÇA:**
```javascript
const [users] = await pool.query(
    'SELECT * FROM users WHERE username = ?',
    [username]
);
```

### Hachage de mot de passe

```javascript
const bcrypt = require('bcryptjs');

// Créer un hash
const hashedPassword = await bcrypt.hash(password, 10);

// Comparer
const isValid = await bcrypt.compare(password, hashedPassword);
```

### Authentification JWT

```javascript
const jwt = require('jsonwebtoken');

// Créer un token
const token = jwt.sign(
    { userId: user.id },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
);

// Vérifier le token
const decoded = jwt.verify(token, process.env.JWT_SECRET);
```

### Validation des entrées

```javascript
const { body, validationResult } = require('express-validator');

app.post('/api/books',
    body('title').isLength({ min: 3, max: 200 }),
    body('price').isFloat({ min: 0 }),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        // ...
    }
);
```

---

## 10. Développement de projet

### Structure du projet

```
project/
├── config/
│   └── database.js
├── controllers/
│   └── bookController.js
├── routes/
│   └── bookRoutes.js
├── middleware/
│   ├── auth.js
│   └── validation.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

### Meilleures pratiques

✅ **À FAIRE:**
- Utiliser les Prepared Statements
- Hacher les mots de passe (bcrypt)
- Valider les entrées
- Gestion des erreurs
- Variables d'environnement (.env)
- Utiliser Git
- Commenter le code

❌ **À NE PAS FAIRE:**
- Credentials dans le code
- Permettre l'injection SQL
- Ignorer les erreurs
- Committer node_modules/
- Travailler sans backup

### Dessiner un diagramme ER

1. Identifier les entités
2. Définir les attributs
3. Établir les relations
4. Déterminer les cardinalités
5. Marquer les clés primaires
6. Indiquer les clés étrangères

### Checklist soumission de projet

- [ ] Le code fonctionne
- [ ] Toutes les opérations CRUD
- [ ] README.md avec instructions
- [ ] Diagramme ER
- [ ] Dump SQL
- [ ] .env.example (sans vrais credentials)
- [ ] Documentation des endpoints API
- [ ] Dépôt Git
- [ ] Présentation préparée

---

## Annexe: Référence des commandes SQL importantes

### DDL (Data Definition Language)
```sql
CREATE DATABASE nom;
CREATE TABLE nom (...);
ALTER TABLE nom ADD COLUMN ...;
DROP TABLE nom;
```

### DML (Data Manipulation Language)
```sql
INSERT INTO table VALUES (...);
SELECT * FROM table WHERE ...;
UPDATE table SET ... WHERE ...;
DELETE FROM table WHERE ...;
```

### DCL (Data Control Language)
```sql
GRANT privileges ON database.* TO 'user'@'host';
REVOKE privileges ON database.* FROM 'user'@'host';
```

### TCL (Transaction Control Language)
```sql
START TRANSACTION;
COMMIT;
ROLLBACK;
```

---

## Glossaire

**ACID** - Atomicity, Consistency, Isolation, Durability

**API** - Application Programming Interface

**CRUD** - Create, Read, Update, Delete

**DDL** - Data Definition Language

**DML** - Data Manipulation Language

**Diagramme ER** - Diagramme Entity-Relationship

**Clé étrangère** - Foreign Key

**JWT** - JSON Web Token

**ORM** - Object-Relational Mapping

**Clé primaire** - Primary Key

**REST** - Representational State Transfer

**SQL** - Structured Query Language

---

**Fin du script**

© 2024 HFTM - Tous droits réservés
