# Leçon 7: Node.js et Bases de données

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Installer et configurer Node.js
- Établir une connexion entre Node.js et MariaDB/MySQL
- Exécuter des requêtes SQL depuis Node.js
- Utiliser les Prepared Statements
- Implémenter les opérations CRUD de base

## Qu'est-ce que Node.js?

**Node.js** est un environnement d'exécution JavaScript côté serveur.

### Caractéristiques

- **JavaScript côté serveur**: Le même langage que dans le navigateur
- **Event-driven**: Traitement asynchrone des événements
- **Non-blocking I/O**: Très performant pour de nombreuses connexions simultanées
- **NPM**: Le plus grand registre de packages au monde
- **Single-threaded**: Mais avec Event Loop pour la concurrence

### Cas d'usage typiques

✅ **Bon pour:**
- API REST
- Applications en temps réel (chat, notifications)
- Microservices
- Streaming de données
- Applications IoT

❌ **Moins bon pour:**
- Calculs intensifs du CPU
- Applications nécessitant beaucoup de traitement synchrone

## Installation de Node.js

### Windows

1. Télécharger depuis [nodejs.org](https://nodejs.org)
2. Choisir la version LTS (Long Term Support)
3. Exécuter l'installateur
4. Vérifier l'installation:

```bash
node --version
npm --version
```

### Vérification

```bash
# Version de Node.js
node -v
# Devrait afficher: v20.x.x ou similaire

# Version de NPM
npm -v
# Devrait afficher: 10.x.x ou similaire
```

## Premier programme Node.js

### Hello World

```javascript
// hello.js
console.log('Hello World from Node.js!');
```

**Exécuter:**
```bash
node hello.js
```

### Serveur HTTP simple

```javascript
// server.js
const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello from Node.js server!');
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
```

**Exécuter:**
```bash
node server.js
```

**Tester:** Ouvrir `http://localhost:3000` dans le navigateur

## NPM - Node Package Manager

**NPM** gère les packages (bibliothèques) dans les projets Node.js.

### Initialiser un projet

```bash
# Créer un nouveau projet
mkdir my-database-app
cd my-database-app

# Initialiser avec package.json
npm init -y
```

**package.json créé:**
```json
{
  "name": "my-database-app",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

### Installer des packages

```bash
# Installer mysql2
npm install mysql2

# Installer Express (pour plus tard)
npm install express

# Installer dotenv (pour les variables d'environnement)
npm install dotenv

# Tout installer en une fois
npm install mysql2 express dotenv
```

**package.json mis à jour:**
```json
{
  "dependencies": {
    "mysql2": "^3.6.0",
    "express": "^4.18.2",
    "dotenv": "^16.3.1"
  }
}
```

### Scripts NPM

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "node test.js"
  }
}
```

**Exécuter:**
```bash
npm start
npm run dev
npm test
```

## Connexion à MariaDB/MySQL

### Package mysql2

**mysql2** est le driver MySQL pour Node.js (moderne, avec Promises).

### Configuration de base

```javascript
// database.js
const mysql = require('mysql2');

// Créer une connexion
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'your_password',
    database: 'hftm_library'
});

// Se connecter
connection.connect((err) => {
    if (err) {
        console.error('Error connecting to database:', err);
        return;
    }
    console.log('Connected to MariaDB database!');
});

module.exports = connection;
```

### Première requête

```javascript
// app.js
const connection = require('./database');

// Requête SELECT simple
connection.query('SELECT * FROM books LIMIT 5', (err, results) => {
    if (err) {
        console.error('Error executing query:', err);
        return;
    }
    
    console.log('Books:', results);
    connection.end();
});
```

## Variables d'environnement avec dotenv

**Ne jamais** stocker les credentials directement dans le code!

### .env fichier

```env
# .env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=hftm_library
DB_PORT=3306
```

### .gitignore

```
# .gitignore
node_modules/
.env
```

### Utilisation de dotenv

```javascript
// database.js
require('dotenv').config();
const mysql = require('mysql2');

const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
});

module.exports = connection;
```

## Connection Pool

Pour les applications avec plusieurs requêtes simultanées, utiliser un **Connection Pool**.

```javascript
// database.js
require('dotenv').config();
const mysql = require('mysql2');

// Créer un pool de connexions
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Export avec Promise wrapper
module.exports = pool.promise();
```

## Async/Await avec mysql2

La méthode moderne utilise **async/await** au lieu de callbacks.

```javascript
// app.js
const pool = require('./database');

async function getAllBooks() {
    try {
        const [rows] = await pool.query('SELECT * FROM books');
        console.log('Books:', rows);
        return rows;
    } catch (err) {
        console.error('Error:', err);
        throw err;
    }
}

// Appeler la fonction
getAllBooks();
```

## Opérations CRUD

### CREATE - Insérer des données

```javascript
async function createBook(title, authorId, publisherId, isbn) {
    try {
        const sql = `
            INSERT INTO books (title, author_id, publisher_id, isbn)
            VALUES (?, ?, ?, ?)
        `;
        
        const [result] = await pool.query(sql, [title, authorId, publisherId, isbn]);
        
        console.log('Book created with ID:', result.insertId);
        return result.insertId;
    } catch (err) {
        console.error('Error creating book:', err);
        throw err;
    }
}

// Utilisation
createBook('New Book', 1, 1, 'ISBN-12345');
```

### READ - Lire des données

```javascript
// Tous les livres
async function getAllBooks() {
    const [rows] = await pool.query('SELECT * FROM books');
    return rows;
}

// Un livre par ID
async function getBookById(id) {
    const [rows] = await pool.query(
        'SELECT * FROM books WHERE id = ?',
        [id]
    );
    return rows[0];
}

// Livres avec JOIN
async function getBooksWithAuthors() {
    const sql = `
        SELECT 
            b.id,
            b.title,
            b.isbn,
            a.firstname,
            a.lastname
        FROM books b
        INNER JOIN authors a ON b.author_id = a.id
    `;
    
    const [rows] = await pool.query(sql);
    return rows;
}

// Recherche
async function searchBooks(searchTerm) {
    const [rows] = await pool.query(
        'SELECT * FROM books WHERE title LIKE ?',
        [`%${searchTerm}%`]
    );
    return rows;
}
```

### UPDATE - Mettre à jour des données

```javascript
async function updateBook(id, title, isbn) {
    try {
        const sql = `
            UPDATE books 
            SET title = ?, isbn = ?
            WHERE id = ?
        `;
        
        const [result] = await pool.query(sql, [title, isbn, id]);
        
        console.log('Rows affected:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (err) {
        console.error('Error updating book:', err);
        throw err;
    }
}

// Utilisation
updateBook(1, 'Updated Title', 'ISBN-NEW');
```

### DELETE - Supprimer des données

```javascript
async function deleteBook(id) {
    try {
        const [result] = await pool.query(
            'DELETE FROM books WHERE id = ?',
            [id]
        );
        
        console.log('Rows deleted:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (err) {
        console.error('Error deleting book:', err);
        throw err;
    }
}

// Utilisation
deleteBook(5);
```

## Prepared Statements

Les **Prepared Statements** protègent contre les attaques par injection SQL.

### ❌ SQL Injection vulnérable

```javascript
// DANGEREUX! Ne JAMAIS faire ceci!
async function unsafeSearch(searchTerm) {
    const sql = `SELECT * FROM books WHERE title = '${searchTerm}'`;
    const [rows] = await pool.query(sql);
    return rows;
}

// Attaque possible:
// searchTerm = "'; DROP TABLE books; --"
```

### ✅ Avec Prepared Statements (Sûr)

```javascript
// SÛR avec placeholders
async function safeSearch(searchTerm) {
    const sql = 'SELECT * FROM books WHERE title = ?';
    const [rows] = await pool.query(sql, [searchTerm]);
    return rows;
}

// Les placeholders ? sont automatiquement échappés
```

### Plusieurs paramètres

```javascript
async function createAuthor(firstname, lastname, email) {
    const sql = `
        INSERT INTO authors (firstname, lastname, email)
        VALUES (?, ?, ?)
    `;
    
    const [result] = await pool.query(sql, [firstname, lastname, email]);
    return result.insertId;
}
```

## Transactions

```javascript
async function transferBookOwnership(bookId, fromCustomerId, toCustomerId) {
    const connection = await pool.getConnection();
    
    try {
        // Démarrer la transaction
        await connection.beginTransaction();
        
        // 1. Terminer l'ancien prêt
        await connection.query(
            'UPDATE lends SET returned = 1 WHERE book_id = ? AND customer_id = ?',
            [bookId, fromCustomerId]
        );
        
        // 2. Créer un nouveau prêt
        await connection.query(
            'INSERT INTO lends (book_id, customer_id, date_from) VALUES (?, ?, NOW())',
            [bookId, toCustomerId]
        );
        
        // Tout confirmer
        await connection.commit();
        console.log('Transaction successful!');
        
    } catch (err) {
        // En cas d'erreur: Rollback
        await connection.rollback();
        console.error('Transaction failed:', err);
        throw err;
        
    } finally {
        // Toujours libérer la connexion
        connection.release();
    }
}
```

## Gestion des erreurs

```javascript
async function getBookSafe(id) {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM books WHERE id = ?',
            [id]
        );
        
        if (rows.length === 0) {
            throw new Error('Book not found');
        }
        
        return rows[0];
        
    } catch (err) {
        if (err.code === 'ER_NO_SUCH_TABLE') {
            console.error('Table does not exist');
        } else if (err.code === 'ER_BAD_FIELD_ERROR') {
            console.error('Column does not exist');
        } else {
            console.error('Database error:', err);
        }
        
        throw err;
    }
}
```

## Structure du projet

```
my-database-app/
├── config/
│   └── database.js          # Configuration DB
├── controllers/
│   ├── bookController.js    # Logique pour les livres
│   └── authorController.js  # Logique pour les auteurs
├── models/
│   ├── Book.js              # Modèle de données
│   └── Author.js
├── routes/
│   ├── bookRoutes.js        # Routes API
│   └── authorRoutes.js
├── .env                      # Variables d'environnement
├── .gitignore
├── package.json
└── server.js                 # Point d'entrée
```

## Exercice pratique

### Exercice 1: Configuration

1. Créer un nouveau projet Node.js
2. Installer mysql2 et dotenv
3. Créer un fichier .env avec les credentials
4. Établir une connexion à HFTM Library

### Exercice 2: Opérations CRUD

Créer des fonctions pour:

```javascript
// Authors
async function getAllAuthors() { }
async function getAuthorById(id) { }
async function createAuthor(firstname, lastname, email) { }
async function updateAuthor(id, firstname, lastname, email) { }
async function deleteAuthor(id) { }

// Books
async function getAllBooks() { }
async function getBookById(id) { }
async function createBook(title, authorId, isbn) { }
async function updateBook(id, title, isbn) { }
async function deleteBook(id) { }
```

### Exercice 3: Requêtes avancées

```javascript
// 1. Recherche de livres par titre
async function searchBooksByTitle(searchTerm) { }

// 2. Livres avec auteurs (JOIN)
async function getBooksWithAuthors() { }

// 3. Nombre de livres par auteur
async function getBookCountByAuthor() { }

// 4. Prêts en retard
async function getOverdueLoans() { }
```

### Exercice 4: Transaction

Implémenter un prêt de livre avec transaction:
- Vérifier la disponibilité
- Réduire le stock
- Enregistrer le prêt
- Rollback en cas d'erreur

## Bonnes pratiques

### Structure du code

✅ **À FAIRE:**
- Connection Pool utiliser
- async/await utiliser
- Prepared Statements utiliser
- Gestion des erreurs appropriée
- Variables d'environnement pour les credentials
- Fermer les connexions

❌ **À NE PAS FAIRE:**
- Credentials dans le code
- SQL injection vulnérable
- Ignorer les erreurs
- Callbacks imbriqués (Callback Hell)
- Connexions non fermées

### Sécurité

```javascript
// ✅ Bon
const [rows] = await pool.query(
    'SELECT * FROM users WHERE email = ?',
    [userEmail]
);

// ❌ Mauvais - Injection SQL possible!
const [rows] = await pool.query(
    `SELECT * FROM users WHERE email = '${userEmail}'`
);
```

## Debugging

### Afficher les requêtes SQL

```javascript
const sql = 'SELECT * FROM books WHERE author_id = ?';
const params = [1];

console.log('SQL:', sql);
console.log('Params:', params);

const [rows] = await pool.query(sql, params);
```

### Afficher les résultats

```javascript
const [rows] = await pool.query('SELECT * FROM books LIMIT 5');

console.log('Number of rows:', rows.length);
console.log('First row:', rows[0]);
console.log('All rows:', JSON.stringify(rows, null, 2));
```

## Résumé

### Commandes importantes

```bash
# Initialiser le projet
npm init -y

# Installer les packages
npm install mysql2 dotenv

# Exécuter l'application
node app.js
```

### Code de base

```javascript
// database.js
require('dotenv').config();
const mysql = require('mysql2');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

module.exports = pool.promise();
```

```javascript
// app.js
const pool = require('./database');

async function main() {
    try {
        const [rows] = await pool.query('SELECT * FROM books');
        console.log(rows);
    } catch (err) {
        console.error(err);
    }
}

main();
```

## Devoirs

1. **Configurer le projet Node.js** avec connexion à la base de données
2. **Implémenter les opérations CRUD** pour 2 entités
3. **Tester toutes les fonctions** avec différents paramètres
4. **Documenter le code** avec des commentaires

## Ressources

- [Node.js Documentation](https://nodejs.org/docs)
- [mysql2 Package](https://github.com/sidorares/node-mysql2)
- [NPM Documentation](https://docs.npmjs.com/)
- [dotenv Documentation](https://github.com/motdotla/dotenv)

## Prochaines étapes

Dans la leçon 8, nous apprendrons:
- Express.js pour créer une API REST
- Routes et Controllers
- Middleware
- Tests API avec Postman
