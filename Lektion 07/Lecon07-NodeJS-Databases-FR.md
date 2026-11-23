# Leçon 7: Node.js et bases de données

## Objectifs d'apprentissage

L'étudiant(e) est capable de...

- Installer Node.js et configurer un projet avec npm
- Établir une connexion entre JavaScript et MariaDB/MySQL
- Remplir une base de données depuis JavaScript et exécuter des requêtes SQL
- Implémenter les opérations CRUD de base
- Comprendre et utiliser les Prepared Statements pour éviter l'injection SQL
- Utiliser les transactions et la gestion des erreurs dans Node.js

## Préparation

- Node.js et npm installés sur l'ordinateur portable
- Le serveur MariaDB est démarré
- HeidiSQL installé
- La base de données HFTM Library (`hftm_library`) est importée
- Le projet de démonstration `db-nodejs-demo/` de ce dossier est disponible

## Qu'est-ce que Node.js?

**Node.js** est un environnement d'exécution JavaScript qui permet d'exécuter du JavaScript en dehors du navigateur. Il permet de développer des applications serveur qui accèdent à des bases de données.

### Caractéristiques

- **JavaScript côté serveur**: Le même langage que dans le navigateur
- **Event-driven**: Les événements sont traités de manière asynchrone
- **Non-blocking I/O**: Très performant pour de nombreuses connexions simultanées
- **NPM**: Le plus grand registre de packages au monde
- **Single-threaded**: La concurrence est assurée par l'Event Loop

### Cas d'usage typiques

**Bien adapté pour:**

- API REST
- Applications en temps réel (chat, notifications)
- Microservices
- Streaming de données
- Applications IoT

**Moins adapté pour:**

- Calculs intensifs pour le CPU
- Applications nécessitant beaucoup de traitement synchrone

## Installation de Node.js

### Windows

1. Télécharger depuis [nodejs.org](https://nodejs.org)
2. Choisir la version LTS (Long Term Support)
3. Exécuter l'installateur
4. Vérifier l'installation (voir ci-dessous)

### Vérification

```bash
# Vérifier la version de Node.js
node --version
# Devrait afficher environ v20.x.x ou plus récent

# Vérifier la version de npm
npm --version
# Devrait afficher environ 10.x.x ou plus récent
```

## Premier programme Node.js

### Hello World

```javascript
// hello.js
console.log('Hello World from Node.js!');
```

Exécuter:

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

Exécuter:

```bash
node server.js
```

Tester: ouvrir `http://localhost:3000` dans le navigateur.

## NPM - Node Package Manager

**npm** est le gestionnaire de packages de Node.js et gère les bibliothèques (packages) d'un projet.

### Initialiser un projet

```bash
# Créer un nouveau dossier
mkdir db-nodejs-demo
cd db-nodejs-demo

# Initialiser le projet npm
npm init -y
```

Ceci crée un fichier `package.json` avec les métadonnées du projet:

```json
{
  "name": "db-nodejs-demo",
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
# mysql2: driver pour MariaDB/MySQL
npm install mysql2

# dotenv: charger les variables d'environnement depuis un fichier .env
npm install dotenv

# Ou les deux en une fois
npm install mysql2 dotenv

# Express ne sera nécessaire qu'à la leçon 8
npm install express
```

Les packages installés apparaissent dans le `package.json`:

```json
{
  "dependencies": {
    "dotenv": "^17.2.3",
    "mysql2": "^3.15.3"
  }
}
```

### Scripts NPM

Des commandes peuvent être définies comme scripts dans le `package.json`:

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "node test-connection.js"
  }
}
```

Exécuter:

```bash
npm start
npm run dev
npm test
```

## Variables d'environnement avec dotenv

Les identifiants (credentials) ne doivent **jamais** être stockés directement dans le code. Avec `dotenv`, les données sensibles comme les mots de passe sont enregistrées dans un fichier `.env`.

### Fichier .env

Créer un fichier `.env` dans le dossier du projet (le projet de démonstration contient le modèle `env.sample`):

```ini
DB_HOST=localhost
DB_USER=hftm_library
DB_PASSWORD=hftm-2025
DB_NAME=hftm_library
DB_PORT=3306
```

### .gitignore

**Important:** Le fichier `.env` doit être ajouté au `.gitignore` afin que les mots de passe n'arrivent pas dans le dépôt.

```text
node_modules/
.env
```

## Connexion à MariaDB/MySQL

### Package mysql2

**mysql2** est le driver MySQL/MariaDB pour Node.js. Il est moderne, rapide et prend en charge les Promises (async/await).

### Connexion simple (style callback)

Une connexion unique avec des callbacks montre le principe de base:

```javascript
// simple-connection.js
require('dotenv').config();
const mysql = require('mysql2');

// Créer une connexion unique
const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
});

// Première requête
connection.query('SELECT * FROM books LIMIT 5', (err, results) => {
    if (err) {
        console.error('Erreur lors de la requête:', err.message);
        return connection.end();
    }
    console.log('Livres:', results);
    connection.end();
});
```

Pour de vraies applications, ce style est peu pratique: les callbacks imbriqués deviennent vite illisibles ("Callback Hell") et une connexion unique ne peut traiter qu'une requête à la fois.

### Connection Pool (recommandé)

Un **Connection Pool** garde plusieurs connexions ouvertes et y répartit les requêtes. C'est efficace pour les applications avec de nombreuses requêtes simultanées.

Créer le fichier `db.js` (correspond à `db-nodejs-demo/db.js`):

```javascript
// db.js
require('dotenv').config();
const mysql = require('mysql2');

// Créer un pool de connexions (efficace pour plusieurs requêtes)
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Wrapper Promise pour async/await
const promisePool = pool.promise();

module.exports = promisePool;
```

### Tester la connexion

Créer `test-connection.js`:

```javascript
// test-connection.js
const db = require('./db');

async function testConnection() {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS result');
        console.log('Connexion à la base de données réussie!');
        console.log('Test Query Result:', rows[0].result);
    } catch (error) {
        console.error('Erreur de connexion à la base de données:', error.message);
    } finally {
        process.exit();
    }
}

testConnection();
```

Exécuter:

```bash
node test-connection.js
```

## Async/Await avec mysql2

La méthode moderne utilise **async/await** au lieu de callbacks. `db.query()` retourne un tableau: le premier élément contient les lignes, le second les informations sur les champs.

```javascript
// test-read.js
const db = require('./db');

async function getAllBooks() {
    try {
        const [books] = await db.query('SELECT * FROM books LIMIT 3');
        console.log('Tous les livres:', books);
        return books;
    } catch (error) {
        console.error('Erreur lors de la lecture:', error.message);
    }
}

getAllBooks();
```

## Opérations CRUD

Les exemples suivants utilisent les tables de la base de données HFTM Library:

| Table | Colonnes importantes |
|---|---|
| `books` | `ID`, `ISBN`, `Titel`, `Published_Date`, `AmountInStock`, `AuthorsID`, `PublishersID`, `GenresID` |
| `authors` | `ID`, `Firstname`, `Lastname`, `Email` |
| `customers` | `ID`, `Lastname`, `Firstname`, `Email`, `LocationID` |
| `lends` | `ID`, `Date_From`, `Date_To`, `Price`, `CustomerID`, `BookID` |

### CREATE - Insérer des données

```javascript
const db = require('./db');

async function createBook(title, isbn, amountInStock, authorId, publisherId) {
    try {
        const sql = `
            INSERT INTO books (Titel, ISBN, AmountInStock, AuthorsID, PublishersID)
            VALUES (?, ?, ?, ?, ?)
        `;
        const [result] = await db.query(sql, [title, isbn, amountInStock, authorId, publisherId]);
        console.log('Livre ajouté avec l\'ID:', result.insertId);
        return result.insertId;
    } catch (error) {
        console.error('Erreur lors de l\'insertion:', error.message);
        throw error;
    }
}

// Utilisation
createBook('Clean Code', '978-0-13-235088-4', 3, 1, 1);
```

### READ - Lire des données

```javascript
// Tous les livres (limité à 10)
async function getAllBooks() {
    const [rows] = await db.query('SELECT * FROM books LIMIT 10');
    return rows;
}

// Rechercher un livre par ID
async function getBookById(id) {
    const [rows] = await db.query(
        'SELECT * FROM books WHERE ID = ?',
        [id]
    );
    return rows[0];
}

// Recherche par titre (sous-chaîne)
async function searchBooks(searchTerm) {
    const [rows] = await db.query(
        'SELECT * FROM books WHERE Titel LIKE ?',
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
            SET Titel = ?, ISBN = ?
            WHERE ID = ?
        `;
        const [result] = await db.query(sql, [title, isbn, id]);
        console.log('Lignes mises à jour:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Erreur lors de la mise à jour:', error.message);
        throw error;
    }
}

// Utilisation
updateBook(1, 'Clean Code (2nd Edition)', '978-0-13-235088-4');
```

### DELETE - Supprimer des données

```javascript
async function deleteBook(id) {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE ID = ?',
            [id]
        );
        console.log('Lignes supprimées:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Erreur lors de la suppression:', error.message);
        throw error;
    }
}

// Utilisation
deleteBook(5);
```

**Remarque:** Un livre référencé dans `lends` ne peut pas être supprimé à cause de la clé étrangère (code d'erreur `ER_ROW_IS_REFERENCED_2`).

## Prepared Statements et injection SQL

### Qu'est-ce que l'injection SQL?

L'injection SQL est une faille de sécurité dans laquelle un attaquant introduit du code SQL dans une requête via des champs de saisie.

### Requête vulnérable

```javascript
// NE JAMAIS FAIRE CECI!
async function unsafeFindCustomer(userInput) {
    const sql = `SELECT * FROM customers WHERE ID = ${userInput}`;
    const [rows] = await db.query(sql);
    return rows;
}

// Attaque: userInput = "1 OR 1=1"
// Requête résultante: SELECT * FROM customers WHERE ID = 1 OR 1=1
// Retourne TOUS les clients!

async function unsafeSearch(searchTerm) {
    const sql = `SELECT * FROM books WHERE Titel = '${searchTerm}'`;
    const [rows] = await db.query(sql);
    return rows;
}

// Attaque: searchTerm = "' OR '1'='1"
// Retourne TOUS les livres!
```

**Remarque:** Par défaut, mysql2 n'autorise pas plusieurs instructions par requête (`multipleStatements: false`). Une attaque comme `'; DROP TABLE books; --` échoue donc, mais la lecture de données étrangères comme ci-dessus fonctionne quand même.

### Requête sûre avec Prepared Statements

Le caractère `?` sert de placeholder. La valeur est transmise séparément, automatiquement échappée et ne peut pas modifier la commande SQL.

```javascript
// SÛR avec placeholders
async function safeFindCustomer(userInput) {
    const [rows] = await db.query(
        'SELECT * FROM customers WHERE ID = ?',
        [userInput]
    );
    return rows;
}

async function safeSearch(searchTerm) {
    const sql = 'SELECT * FROM books WHERE Titel = ?';
    const [rows] = await db.query(sql, [searchTerm]);
    return rows;
}
```

`db.query()` remplace les placeholders côté client par des valeurs correctement échappées. `db.execute()` envoie en revanche un véritable Prepared Statement côté serveur. Les deux variantes protègent contre l'injection SQL.

### Plusieurs paramètres

Les valeurs du tableau sont attribuées aux placeholders dans l'ordre:

```javascript
async function createAuthor(firstname, lastname, email) {
    const sql = `
        INSERT INTO authors (Firstname, Lastname, Email)
        VALUES (?, ?, ?)
    `;
    const [result] = await db.query(sql, [firstname, lastname, email]);
    return result.insertId;
}
```

## Requêtes JOIN dans Node.js

```javascript
async function getBooksWithAuthors() {
    try {
        const sql = `
            SELECT
                b.ID,
                b.Titel,
                b.ISBN,
                a.Firstname,
                a.Lastname
            FROM books b
            INNER JOIN authors a ON b.AuthorsID = a.ID
            ORDER BY b.Titel
            LIMIT 20
        `;
        const [rows] = await db.query(sql);
        return rows;
    } catch (error) {
        console.error('Erreur lors du JOIN:', error.message);
        throw error;
    }
}
```

## Transactions

Les transactions garantissent que plusieurs opérations sur la base de données réussissent toutes ou sont toutes annulées. Pour cela, une connexion dédiée est obtenue du pool.

Exemple: emprunter un livre (vérifier le stock, réduire le stock, enregistrer le prêt):

```javascript
async function lendBook(bookId, customerId, days = 30) {
    const connection = await db.getConnection();

    try {
        // Démarrer la transaction
        await connection.beginTransaction();

        // 1. Vérifier la disponibilité (verrouiller la ligne pour les autres transactions)
        const [books] = await connection.query(
            'SELECT AmountInStock FROM books WHERE ID = ? FOR UPDATE',
            [bookId]
        );
        if (books.length === 0 || books[0].AmountInStock < 1) {
            throw new Error('Livre non disponible');
        }

        // 2. Réduire le stock
        await connection.query(
            'UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = ?',
            [bookId]
        );

        // 3. Enregistrer le prêt
        await connection.query(
            `INSERT INTO lends (BookID, CustomerID, Date_From, Date_To)
             VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY))`,
            [bookId, customerId, days]
        );

        // Confirmer la transaction
        await connection.commit();
        console.log('Prêt réussi');

    } catch (error) {
        // En cas d'erreur: annuler la transaction
        await connection.rollback();
        console.error('Échec du prêt:', error.message);
        throw error;

    } finally {
        // Toujours rendre la connexion au pool
        connection.release();
    }
}
```

## Gestion des erreurs

Une fonction utilitaire centrale fournit un résultat uniforme:

```javascript
async function safeQuery(sql, params = []) {
    try {
        const [rows] = await db.query(sql, params);
        return { success: true, data: rows };
    } catch (error) {
        console.error('Erreur de base de données:', error.message);
        return { success: false, error: error.message };
    }
}

// Utilisation (await uniquement dans une fonction async)
async function main() {
    const result = await safeQuery('SELECT * FROM books WHERE ID = ?', [42]);
    if (result.success) {
        console.log('Données:', result.data);
    } else {
        console.log('Erreur:', result.error);
    }
}

main();
```

Les erreurs MariaDB/MySQL possèdent un code (`err.code`) qui permet de réagir de manière ciblée:

```javascript
async function getBookSafe(id) {
    try {
        const [rows] = await db.query(
            'SELECT * FROM books WHERE ID = ?',
            [id]
        );

        if (rows.length === 0) {
            throw new Error('Livre introuvable');
        }

        return rows[0];

    } catch (err) {
        if (err.code === 'ER_NO_SUCH_TABLE') {
            console.error('La table n\'existe pas');
        } else if (err.code === 'ER_BAD_FIELD_ERROR') {
            console.error('La colonne n\'existe pas');
        } else {
            console.error('Erreur:', err.message);
        }

        throw err;
    }
}
```

## Structure du projet

Pour des applications plus grandes (dès la leçon 8), la structure suivante a fait ses preuves:

```text
db-nodejs-demo/
├── config/
│   └── db.js                # Configuration de la base de données
├── controllers/
│   ├── bookController.js    # Logique pour les livres
│   └── authorController.js  # Logique pour les auteurs
├── models/
│   ├── Book.js              # Modèle de données
│   └── Author.js
├── routes/
│   ├── bookRoutes.js        # Routes API
│   └── authorRoutes.js
├── .env                     # Variables d'environnement
├── .gitignore
├── package.json
└── server.js                # Point d'entrée
```

## Debugging

### Afficher les requêtes SQL

```javascript
// dans une fonction async
const sql = 'SELECT * FROM books WHERE AuthorsID = ?';
const params = [1];

console.log('SQL:', sql);
console.log('Paramètres:', params);

const [rows] = await db.query(sql, params);
```

### Afficher les résultats

```javascript
// dans une fonction async
const [rows] = await db.query('SELECT * FROM books LIMIT 5');

console.log('Nombre de lignes:', rows.length);
console.log('Première ligne:', rows[0]);
console.log('Toutes les lignes:', JSON.stringify(rows, null, 2));
```

## Exercices pratiques

### Exercice 1: Configuration

1. Créer un nouveau projet Node.js
2. Installer `mysql2` et `dotenv`
3. Créer un fichier `.env` avec les identifiants
4. Établir une connexion à HFTM Library et la tester avec `test-connection.js`

### Exercice 2: Opérations CRUD

Créer des fonctions pour les opérations suivantes:

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
async function createBook(title, isbn, amountInStock, authorId, publisherId) { }
async function updateBook(id, title, isbn) { }
async function deleteBook(id) { }
```

### Exercice 3: Requêtes avancées dans HFTM Library

```javascript
// 1. Rechercher des livres par titre
async function searchBooksByTitle(searchTerm) { }

// 2. Afficher tous les livres d'un auteur donné
async function getBooksByAuthor(authorId) { }

// 3. Livres avec auteurs (JOIN)
async function getBooksWithAuthors() { }

// 4. Nombre de livres par auteur
async function getBookCountByAuthor() { }

// 5. Nombre de livres empruntés par client (JOIN)
async function getLendCountByCustomer() { }

// 6. Prêts en retard (Date_To dans le passé)
async function getOverdueLoans() { }
```

### Exercice 4: Transaction

Implémenter un prêt de livre avec transaction (voir `lendBook()`):

- Vérifier la disponibilité
- Réduire le stock
- Enregistrer le prêt avec la date d'emprunt
- Effectuer un rollback en cas d'erreur

Implémenter en plus la fonction inverse `returnBook(lendId)`: clôturer le prêt (mettre `Date_To` à `NOW()`) et augmenter à nouveau le stock, également dans une transaction.

### Exercice 5: Propre base de données

Implémenter les opérations CRUD pour votre propre base de données du centre médical:

1. Gérer les patients (CREATE, READ, UPDATE, DELETE)
2. Interroger les rendez-vous (avec JOIN vers médecins et patients)
3. Créer de nouveaux rendez-vous
4. Annuler des rendez-vous

### Exercice 6: Tester l'injection SQL

1. Créer une requête non sécurisée (concaténation de chaînes)
2. Tester avec une tentative d'injection (p. ex. `' OR '1'='1`)
3. Implémenter la version sûre avec Prepared Statements
4. Documenter la différence

## Bonnes pratiques

### Structure du code

**À faire:**

- Utiliser un Connection Pool
- Utiliser async/await
- Utiliser des Prepared Statements (placeholder `?`)
- Gérer correctement les erreurs
- Stocker les identifiants dans des variables d'environnement
- Fermer les connexions ou les rendre au pool

**À éviter:**

- Identifiants dans le code
- Requêtes vulnérables à l'injection SQL
- Ignorer les erreurs
- Callbacks imbriqués (Callback Hell)
- Connexions non fermées

### Sécurité

```javascript
// BON: placeholders
const [customers] = await db.query(
    'SELECT * FROM customers WHERE Email = ?',
    [userEmail]
);

// MAUVAIS: injection SQL possible!
const [unsafeCustomers] = await db.query(
    `SELECT * FROM customers WHERE Email = '${userEmail}'`
);
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
// db.js
require('dotenv').config();
const mysql = require('mysql2');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
});

module.exports = pool.promise();
```

```javascript
// app.js
const db = require('./db');

async function main() {
    try {
        const [rows] = await db.query('SELECT * FROM books LIMIT 10');
        console.log(rows);
    } catch (err) {
        console.error(err);
    } finally {
        // Fermer le pool pour que le programme se termine
        await db.end();
    }
}

main();
```

## Devoirs

1. **Configurer le projet Node.js** avec connexion à la base de données
2. **Implémenter les opérations CRUD** pour 2 entités
3. **Tester toutes les fonctions** avec différents paramètres
4. **Documenter le code** avec des commentaires

## Liste de contrôle pour le crédit 6

- [ ] Node.js et npm installés
- [ ] Projet créé avec `package.json`
- [ ] La connexion à la base de données fonctionne
- [ ] Au moins 3 opérations CRUD implémentées
- [ ] Prepared Statements utilisés
- [ ] Code documenté et testé
- [ ] Capture d'écran ou sortie des requêtes fonctionnelles

## Ressources

- [Node.js Documentation](https://nodejs.org/docs/latest/api/)
- [mysql2 Package](https://github.com/sidorares/node-mysql2)
- [npm Documentation](https://docs.npmjs.com/)
- [dotenv Documentation](https://github.com/motdotla/dotenv)
- [Explication de l'injection SQL (OWASP)](https://owasp.org/www-community/attacks/SQL_Injection)

## Prochaines étapes

Dans la leçon 8, nous créerons une API REST qui rend ces opérations sur la base de données accessibles via des endpoints HTTP:

- Express.js pour une API REST
- Routes et Controllers
- Middleware
- Tests API avec Postman
