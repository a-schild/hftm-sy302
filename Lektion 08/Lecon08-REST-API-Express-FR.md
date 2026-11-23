# Leçon 8: API REST avec Express.js

## Objectifs d'apprentissage

L'étudiant(e) est capable de...

- Expliquer l'idée de base de REST
- Concevoir une API REST et la réaliser avec Express.js
- Utiliser correctement les méthodes HTTP (GET, POST, PUT, DELETE) et les codes de statut HTTP
- Utiliser JSON comme format de données pour les API
- Structurer une API de manière professionnelle (routes, controllers, middleware)
- Valider les entrées et gérer les erreurs de manière centralisée
- Tester l'API avec Postman, Thunder Client ou curl et la documenter

## Préparation

- Le projet de la leçon 7 avec une connexion fonctionnelle à la base de données (`db.js` et `.env`)
- Le serveur MariaDB fonctionne, la base de données HFTM Library (`hftm_library`) est importée
- Postman ou l'extension VS Code Thunder Client est installé

## Qu'est-ce qu'une API REST?

**REST** (**RE**presentational **S**tate **T**ransfer) est un style d'architecture pour les systèmes distribués, en particulier pour les services web. Une API REST rend des données (p. ex. d'une base de données) accessibles via HTTP.

### Principes REST

1. **Architecture client-serveur**: Séparation du frontend et du backend
2. **Stateless**: Chaque requête est indépendante et contient toutes les informations nécessaires
3. **Cacheable**: Les réponses peuvent être mises en cache
4. **Uniform Interface**: Interface uniforme, les méthodes HTTP sont utilisées correctement
5. **Ressources**: Tout est une ressource (books, authors, lends, etc.) et possède sa propre URI
6. **Layered System**: Architecture en couches possible (p. ex. proxy, load balancer)

### Ressources et URIs

```text
GET    /api/books              - Tous les livres
GET    /api/books/5            - Livre avec ID 5
POST   /api/books              - Créer un nouveau livre
PUT    /api/books/5            - Mettre à jour le livre 5
DELETE /api/books/5            - Supprimer le livre 5

GET    /api/books/5/lends      - Emprunts du livre 5
POST   /api/lends              - Enregistrer un nouvel emprunt
```

**Règles:**

- Utiliser le pluriel: `/books` au lieu de `/book`
- Utiliser les minuscules: `/books` au lieu de `/Books`
- Pas de verbes dans les URLs: `/books` au lieu de `/getBooks`
- Représenter les hiérarchies: `/books/:id/lends`
- Versionnage: `/api/v1/books`

## Méthodes HTTP et codes de statut

### Méthodes HTTP (verbes)

| Méthode | Signification | Opération CRUD | Utilisation | Idempotent |
|---------|---------------|----------------|-------------|------------|
| GET | Lire | Read | Récupérer des données | Oui |
| POST | Créer | Create | Créer une nouvelle ressource | Non |
| PUT | Mettre à jour (complet) | Update | Remplacer entièrement une ressource | Oui |
| PATCH | Mettre à jour (partiel) | Update | Modifier partiellement une ressource | Non |
| DELETE | Supprimer | Delete | Supprimer une ressource | Oui |

**Idempotent** signifie: exécuter la requête plusieurs fois a le même effet que l'exécuter une seule fois.

### Codes de statut HTTP

Les codes de statut sont répartis en classes: **2xx** = succès, **4xx** = erreur du client, **5xx** = erreur du serveur.

| Code | Signification | Exemple |
|------|---------------|---------|
| 200 | OK | Requête GET/PUT réussie |
| 201 | Created | Ressource créée (POST) |
| 204 | No Content | Requête DELETE réussie, pas de données dans la réponse |
| 400 | Bad Request | Données d'entrée invalides |
| 401 | Unauthorized | Authentification requise |
| 403 | Forbidden | Pas d'autorisation |
| 404 | Not Found | La ressource n'existe pas |
| 409 | Conflict | L'enregistrement existe déjà ou est encore référencé |
| 500 | Internal Server Error | Erreur serveur |

## Configuration d'Express.js

**Express** est le framework web le plus populaire pour Node.js. Il gère le routage, les middlewares et l'envoi des réponses.

### Installation

```bash
# Dans le projet de la leçon 7 (mysql2 et dotenv sont déjà installés)
npm install express
npm install cors  # Pour les requêtes cross-origin
```

### Structure de base d'un serveur Express

Créer `server.js`:

```javascript
// server.js
require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware: parser le body JSON des requêtes
app.use(express.json());

// Route de test
app.get('/', (req, res) => {
    res.json({ message: 'HFTM Library API v1.0' });
});

// Démarrer le serveur
app.listen(PORT, () => {
    console.log(`Serveur démarré sur http://localhost:${PORT}`);
});
```

### Démarrer le serveur

```bash
node server.js
```

Ouvrir ensuite `http://localhost:3000` dans le navigateur. La réponse est un objet JSON.

## Endpoints CRUD pour Books

Les exemples utilisent la table `books` de HFTM Library (`ID`, `Titel`, `ISBN`, `Published_Date`, `AmountInStock`, `AuthorsID`, `PublishersID`, `GenresID`) et le module `db.js` de la leçon 7, placé dans `config/db.js`. Les endpoints sont d'abord écrits directement dans `server.js`, puis répartis en controllers et routes dans le chapitre suivant.

### GET - Lire tous les livres

```javascript
const db = require('./config/db');

// GET /api/books - tous les livres
app.get('/api/books', async (req, res) => {
    try {
        // La table contient plusieurs milliers de livres, donc limiter
        const [books] = await db.query('SELECT * FROM books LIMIT 100');
        res.json(books);
    } catch (err) {
        console.error('Erreur lors de la lecture des livres:', err);
        res.status(500).json({ error: 'Erreur interne du serveur' });
    }
});
```

### GET - Lire un livre par ID

```javascript
// GET /api/books/:id - un livre
app.get('/api/books/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const [books] = await db.query(
            'SELECT * FROM books WHERE ID = ?',
            [id]
        );

        if (books.length === 0) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        res.json(books[0]);
    } catch (err) {
        console.error('Erreur:', err);
        res.status(500).json({ error: 'Erreur interne du serveur' });
    }
});
```

### POST - Créer un nouveau livre

```javascript
// POST /api/books - créer un nouveau livre
app.post('/api/books', async (req, res) => {
    try {
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;

        // Validation simple (détails dans le chapitre Validation des entrées)
        if (!Titel || !AuthorsID || !PublishersID) {
            return res.status(400).json({
                error: 'Titel, AuthorsID et PublishersID sont obligatoires'
            });
        }

        const stock = AmountInStock ?? 0;

        const [result] = await db.query(
            `INSERT INTO books (Titel, ISBN, AmountInStock, AuthorsID, PublishersID)
             VALUES (?, ?, ?, ?, ?)`,
            [Titel, ISBN, stock, AuthorsID, PublishersID]
        );

        res.status(201).json({
            ID: result.insertId,
            Titel,
            ISBN,
            AmountInStock: stock,
            AuthorsID,
            PublishersID
        });
    } catch (err) {
        console.error('Erreur lors de la création:', err);
        res.status(500).json({ error: 'Erreur interne du serveur' });
    }
});
```

### PUT - Mettre à jour un livre

```javascript
// PUT /api/books/:id - mettre à jour un livre
app.put('/api/books/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;

        const [result] = await db.query(
            `UPDATE books
             SET Titel = ?, ISBN = ?, AmountInStock = ?, AuthorsID = ?, PublishersID = ?
             WHERE ID = ?`,
            [Titel, ISBN, AmountInStock, AuthorsID, PublishersID, id]
        );

        // affectedRows = 0: il n'existe aucun livre avec cet ID
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        res.json({ ID: Number(id), Titel, ISBN, AmountInStock, AuthorsID, PublishersID });
    } catch (err) {
        console.error('Erreur lors de la mise à jour:', err);
        res.status(500).json({ error: 'Erreur interne du serveur' });
    }
});
```

### DELETE - Supprimer un livre

```javascript
// DELETE /api/books/:id - supprimer un livre
app.delete('/api/books/:id', async (req, res) => {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE ID = ?',
            [req.params.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        res.status(204).send(); // No Content
    } catch (err) {
        console.error('Erreur lors de la suppression:', err);
        res.status(500).json({ error: 'Erreur interne du serveur' });
    }
});
```

**Remarque:** Un livre référencé dans `lends` ne peut pas être supprimé à cause de la clé étrangère (code d'erreur `ER_ROW_IS_REFERENCED_2`). Ce cas est traité avec le statut 409 dans le chapitre Middleware de gestion des erreurs.

## Structure du projet (MVC)

Lorsque tous les endpoints se trouvent dans `server.js`, le fichier devient vite illisible. C'est pourquoi le code est réparti selon le principe MVC: les **routes** définissent les URLs, les **controllers** contiennent la logique. Les models (modèles de données avec un ORM) suivent dans la leçon 11.

### Organisation des dossiers

```text
library-api/
├── config/
│   └── db.js                # Connexion à la base de données (leçon 7)
├── controllers/
│   ├── bookController.js    # Logique pour les livres
│   ├── authorController.js  # Logique pour les auteurs
│   └── lendController.js    # Logique pour les emprunts
├── routes/
│   ├── bookRoutes.js        # Routes pour les livres
│   ├── authorRoutes.js      # Routes pour les auteurs
│   └── lendRoutes.js        # Routes pour les emprunts
├── middleware/
│   ├── errorHandler.js      # Gestion centralisée des erreurs
│   └── validation.js        # Validation des entrées
├── .env
├── .gitignore
├── package.json
└── server.js                # Point d'entrée
```

### Connexion à la base de données (config/db.js)

Le module de la leçon 7 est repris sans modification:

```javascript
// config/db.js
require('dotenv').config();
const mysql = require('mysql2');

// Créer un connection pool
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
module.exports = pool.promise();
```

### Controller (controllers/bookController.js)

Dans le controller, les erreurs ne sont plus traitées directement, mais transmises avec `next(err)` au middleware central de gestion des erreurs (voir plus bas).

```javascript
// controllers/bookController.js
const db = require('../config/db');

// GET /api/books - tous les livres
exports.getAllBooks = async (req, res, next) => {
    try {
        const [books] = await db.query('SELECT * FROM books LIMIT 100');
        res.json(books);
    } catch (err) {
        next(err); // transmettre au middleware de gestion des erreurs
    }
};

// GET /api/books/:id - un livre
exports.getBookById = async (req, res, next) => {
    try {
        const [books] = await db.query(
            'SELECT * FROM books WHERE ID = ?',
            [req.params.id]
        );

        if (books.length === 0) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        res.json(books[0]);
    } catch (err) {
        next(err);
    }
};

// POST /api/books - créer un nouveau livre
exports.createBook = async (req, res, next) => {
    try {
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
        const stock = AmountInStock ?? 0;

        const [result] = await db.query(
            `INSERT INTO books (Titel, ISBN, AmountInStock, AuthorsID, PublishersID)
             VALUES (?, ?, ?, ?, ?)`,
            [Titel, ISBN, stock, AuthorsID, PublishersID]
        );

        res.status(201).json({
            ID: result.insertId,
            Titel,
            ISBN,
            AmountInStock: stock,
            AuthorsID,
            PublishersID
        });
    } catch (err) {
        next(err);
    }
};

// PUT /api/books/:id - mettre à jour un livre
exports.updateBook = async (req, res, next) => {
    try {
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
        const { id } = req.params;

        const [result] = await db.query(
            `UPDATE books
             SET Titel = ?, ISBN = ?, AmountInStock = ?, AuthorsID = ?, PublishersID = ?
             WHERE ID = ?`,
            [Titel, ISBN, AmountInStock, AuthorsID, PublishersID, id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        res.json({ ID: Number(id), Titel, ISBN, AmountInStock, AuthorsID, PublishersID });
    } catch (err) {
        next(err);
    }
};

// DELETE /api/books/:id - supprimer un livre
exports.deleteBook = async (req, res, next) => {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE ID = ?',
            [req.params.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        res.status(204).send();
    } catch (err) {
        next(err);
    }
};
```

### Routes (routes/bookRoutes.js)

```javascript
// routes/bookRoutes.js
const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');

router.get('/', bookController.getAllBooks);
router.get('/:id', bookController.getBookById);
router.post('/', bookController.createBook);
router.put('/:id', bookController.updateBook);
router.delete('/:id', bookController.deleteBook);

module.exports = router;
```

### Point d'entrée (server.js)

```javascript
// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());                                  // autoriser les requêtes cross-origin
app.use(express.json());                          // parser le body JSON
app.use(express.urlencoded({ extended: true }));  // parser les données de formulaire

// Routes
const bookRoutes = require('./routes/bookRoutes');
const authorRoutes = require('./routes/authorRoutes');

app.use('/api/books', bookRoutes);
app.use('/api/authors', authorRoutes);

// Route racine avec aperçu
app.get('/', (req, res) => {
    res.json({
        message: 'HFTM Library API v1.0',
        endpoints: {
            books: '/api/books',
            authors: '/api/authors'
        }
    });
});

// Endpoints inconnus: 404
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint non trouvé' });
});

// Gestion des erreurs: doit être après toutes les routes
app.use(errorHandler);

// Démarrer le serveur
app.listen(PORT, () => {
    console.log(`Serveur démarré sur http://localhost:${PORT}`);
});
```

## Query Parameters

Les query parameters sont ajoutés à l'URL (`?key=value&key2=value2`) et lus dans Express via `req.query`. Ils conviennent pour le filtrage, le tri et la pagination. Les fonctions suivantes remplacent chacune `getAllBooks` dans le controller.

### Filtrage et recherche

```javascript
// GET /api/books?search=harry&authorId=1&year=1997
exports.getAllBooks = async (req, res, next) => {
    try {
        const { search, authorId, year } = req.query;

        let sql = 'SELECT * FROM books WHERE 1=1';
        const params = [];

        if (search) {
            sql += ' AND Titel LIKE ?';
            params.push(`%${search}%`);
        }

        if (authorId) {
            sql += ' AND AuthorsID = ?';
            params.push(authorId);
        }

        if (year) {
            sql += ' AND YEAR(Published_Date) = ?';
            params.push(year);
        }

        sql += ' LIMIT 100';

        const [books] = await db.query(sql, params);
        res.json(books);
    } catch (err) {
        next(err);
    }
};
```

### Tri

Les noms de colonnes et l'ordre de tri ne peuvent pas être transmis avec des placeholders (`?`). C'est pourquoi ils sont vérifiés à l'aide d'une liste blanche (whitelist), afin qu'aucune injection SQL ne soit possible.

```javascript
// GET /api/books?sortBy=Titel&order=asc
exports.getAllBooks = async (req, res, next) => {
    try {
        const { sortBy, order } = req.query;

        let sql = 'SELECT * FROM books';

        const validColumns = ['ID', 'Titel', 'Published_Date', 'AmountInStock'];
        const validOrder = ['asc', 'desc'];

        if (sortBy && validColumns.includes(sortBy)) {
            sql += ` ORDER BY ${sortBy}`;

            if (order && validOrder.includes(order.toLowerCase())) {
                sql += ` ${order.toUpperCase()}`;
            }
        }

        sql += ' LIMIT 100';

        const [books] = await db.query(sql);
        res.json(books);
    } catch (err) {
        next(err);
    }
};
```

### Pagination

Pour les grandes tables, les données sont livrées page par page:

```javascript
// GET /api/books?page=2&limit=10
exports.getAllBooks = async (req, res, next) => {
    try {
        const page = Math.max(parseInt(req.query.page) || 1, 1);
        const limit = Math.min(parseInt(req.query.limit) || 10, 100); // max. 100
        const offset = (page - 1) * limit;

        const [books] = await db.query(
            'SELECT * FROM books ORDER BY ID LIMIT ? OFFSET ?',
            [limit, offset]
        );

        const [countResult] = await db.query(
            'SELECT COUNT(*) AS total FROM books'
        );
        const total = countResult[0].total;

        res.json({
            data: books,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        });
    } catch (err) {
        next(err);
    }
};
```

## Endpoints JOIN

Avec des JOINs, l'API livre des données liées provenant de plusieurs tables en une seule réponse.

### Livres avec auteurs

```javascript
// GET /api/books/with-authors
exports.getBooksWithAuthors = async (req, res, next) => {
    try {
        const sql = `
            SELECT
                b.ID,
                b.Titel,
                b.ISBN,
                b.Published_Date,
                a.ID AS AuthorID,
                a.Firstname,
                a.Lastname
            FROM books b
            INNER JOIN authors a ON b.AuthorsID = a.ID
            ORDER BY b.Titel
            LIMIT 100
        `;

        const [books] = await db.query(sql);
        res.json(books);
    } catch (err) {
        next(err);
    }
};
```

### Livre avec tous les détails

```javascript
// GET /api/books/:id/details - livre avec auteur, genre et éditeur
exports.getBookDetails = async (req, res, next) => {
    try {
        const sql = `
            SELECT
                b.ID,
                b.Titel,
                b.ISBN,
                b.Published_Date,
                b.AmountInStock,
                a.ID AS AuthorID,
                CONCAT(a.Firstname, ' ', a.Lastname) AS Author,
                g.Genre,
                p.Name AS Publisher
            FROM books b
            LEFT JOIN authors a ON b.AuthorsID = a.ID
            LEFT JOIN genres g ON b.GenresID = g.ID
            LEFT JOIN publishers p ON b.PublishersID = p.ID
            WHERE b.ID = ?
        `;

        const [books] = await db.query(sql, [req.params.id]);

        if (books.length === 0) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        res.json(books[0]);
    } catch (err) {
        next(err);
    }
};
```

### Emprunts d'un livre

```javascript
// GET /api/books/:id/lends - tous les emprunts d'un livre avec le client
exports.getBookLends = async (req, res, next) => {
    try {
        const sql = `
            SELECT
                l.ID,
                l.Date_From,
                l.Date_To,
                l.Price,
                c.ID AS CustomerID,
                c.Firstname,
                c.Lastname
            FROM lends l
            INNER JOIN customers c ON l.CustomerID = c.ID
            WHERE l.BookID = ?
            ORDER BY l.Date_From DESC
        `;

        const [lends] = await db.query(sql, [req.params.id]);
        res.json(lends);
    } catch (err) {
        next(err);
    }
};
```

Les nouveaux endpoints sont ajoutés dans `routes/bookRoutes.js`. **Important:** Les chemins fixes comme `/with-authors` doivent se trouver **avant** `/:id`, sinon `with-authors` est interprété comme un ID.

```javascript
// routes/bookRoutes.js
router.get('/with-authors', bookController.getBooksWithAuthors); // avant '/:id'!
router.get('/:id', bookController.getBookById);
router.get('/:id/details', bookController.getBookDetails);
router.get('/:id/lends', bookController.getBookLends);
```

## Validation des entrées

Les entrées du client ne doivent jamais être écrites dans la base de données sans vérification. La validation est exécutée comme middleware avant le controller.

### Validation manuelle comme middleware

```javascript
// middleware/validation.js
exports.validateBook = (req, res, next) => {
    const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
    const errors = [];

    if (!Titel || Titel.trim().length === 0) {
        errors.push('Titel est obligatoire');
    } else if (Titel.length > 50) {
        errors.push('Titel peut contenir au maximum 50 caractères');
    }

    // ISBN dans HFTM Library: p. ex. 586-25-07337-83-2
    if (ISBN && !/^\d{3}-\d{2}-\d{5}-\d{2}-\d$/.test(ISBN)) {
        errors.push('ISBN doit être au format XXX-XX-XXXXX-XX-X');
    }

    if (AmountInStock !== undefined && (!Number.isInteger(AmountInStock) || AmountInStock < 0)) {
        errors.push('AmountInStock doit être un nombre entier >= 0');
    }

    if (!Number.isInteger(AuthorsID) || AuthorsID < 1) {
        errors.push('Un AuthorsID valide est obligatoire');
    }

    if (!Number.isInteger(PublishersID) || PublishersID < 1) {
        errors.push('Un PublishersID valide est obligatoire');
    }

    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    next(); // données valides: continuer vers le controller
};
```

**Utilisation dans les routes:**

```javascript
// routes/bookRoutes.js
const { validateBook } = require('../middleware/validation');

router.post('/', validateBook, bookController.createBook);
router.put('/:id', validateBook, bookController.updateBook);
```

### Avec express-validator

Le package `express-validator` offre des règles de validation prêtes à l'emploi:

```bash
npm install express-validator
```

```javascript
// middleware/validation.js (variante avec express-validator)
const { body, validationResult } = require('express-validator');

exports.validateBook = [
    body('Titel').trim().notEmpty().withMessage('Titel est obligatoire')
        .isLength({ max: 50 }).withMessage('Titel peut contenir au maximum 50 caractères'),
    body('ISBN').optional().matches(/^\d{3}-\d{2}-\d{5}-\d{2}-\d$/)
        .withMessage('Format ISBN invalide'),
    body('AmountInStock').optional().isInt({ min: 0 })
        .withMessage('AmountInStock doit être un nombre entier >= 0'),
    body('AuthorsID').isInt({ min: 1 }).withMessage('Un AuthorsID valide est obligatoire'),
    body('PublishersID').isInt({ min: 1 }).withMessage('Un PublishersID valide est obligatoire'),

    // évaluer le résultat des vérifications
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        next();
    }
];
```

L'utilisation dans les routes reste la même que pour la validation manuelle.

## Middleware de gestion des erreurs

Un middleware de gestion des erreurs a **quatre** paramètres `(err, req, res, next)`. Il intercepte toutes les erreurs transmises avec `next(err)` et traduit les erreurs typiques de la base de données en codes de statut HTTP appropriés.

Créer `middleware/errorHandler.js`:

```javascript
// middleware/errorHandler.js
exports.errorHandler = (err, req, res, next) => {
    console.error(err.stack);

    // Erreur de validation
    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: err.message });
    }

    // L'enregistrement existe déjà (p. ex. contrainte UNIQUE)
    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'L\'enregistrement existe déjà' });
    }

    // La clé étrangère pointe vers un enregistrement inexistant
    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
        return res.status(400).json({ error: 'L\'enregistrement référencé n\'existe pas' });
    }

    // L'enregistrement est encore référencé (p. ex. supprimer un livre avec des emprunts)
    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
        return res.status(409).json({ error: 'L\'enregistrement est encore utilisé' });
    }

    // Par défaut: 500, détails uniquement en développement
    res.status(500).json({
        error: 'Une erreur inattendue s\'est produite',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
};
```

**Utilisation dans server.js:**

```javascript
const { errorHandler } = require('./middleware/errorHandler');

// ... toutes les routes ...

// Doit être après toutes les routes
app.use(errorHandler);
```

**Remarque:** Dans Express 4, les erreurs dans les fonctions `async` ne sont pas transmises automatiquement au middleware de gestion des erreurs. C'est pourquoi chaque controller a besoin de `try/catch` avec `next(err)`. À partir d'Express 5, les promesses rejetées sont transmises automatiquement.

## CORS

**CORS** (Cross-Origin Resource Sharing) détermine si un navigateur peut accéder à l'API depuis une autre origine (p. ex. un frontend sur `http://localhost:5173`). Sans en-têtes CORS, le navigateur bloque de telles requêtes.

### Installation

```bash
npm install cors
```

### Configuration

```javascript
const cors = require('cors');

// Autoriser toutes les origines (développement)
app.use(cors());

// Autoriser seulement certaines origines (production)
app.use(cors({
    origin: 'https://myapp.com',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### Alternative sans package

Les en-têtes CORS peuvent aussi être définis avec un middleware personnalisé:

```javascript
// Définir les en-têtes CORS manuellement
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});
```

## Tester l'API

### Postman / Thunder Client

- **Postman**: Téléchargement sur [postman.com](https://www.postman.com/downloads/)
- **Thunder Client**: Extension directement dans VS Code (Extensions, rechercher "Thunder Client")

Procédure dans Postman:

1. Créer une **New Collection**, p. ex. "HFTM Library API"
2. Ajouter une requête pour chaque endpoint
3. Pour POST et PUT, choisir sous **Body** l'option **raw** et **JSON**
4. Exporter la collection (pour la remise)

### Cas de test

**1. GET tous les livres**

```http
GET http://localhost:3000/api/books
```

**2. GET un livre**

```http
GET http://localhost:3000/api/books/1
```

**3. POST nouveau livre**

```http
POST http://localhost:3000/api/books
Content-Type: application/json

{
    "Titel": "The Hobbit",
    "ISBN": "978-05-47928-22-7",
    "AmountInStock": 3,
    "AuthorsID": 1,
    "PublishersID": 1
}
```

**4. PUT mettre à jour un livre**

```http
PUT http://localhost:3000/api/books/1
Content-Type: application/json

{
    "Titel": "The Hobbit - Updated",
    "ISBN": "978-05-47928-22-7",
    "AmountInStock": 5,
    "AuthorsID": 1,
    "PublishersID": 1
}
```

**5. DELETE supprimer un livre**

```http
DELETE http://localhost:3000/api/books/1
```

**6. GET livre avec détails (JOIN)**

```http
GET http://localhost:3000/api/books/2/details
```

**7. Vérifier les cas d'erreur**

```http
# Le livre n'existe pas: 404 attendu
GET http://localhost:3000/api/books/999999

# Titel manquant: 400 attendu
POST http://localhost:3000/api/books
Content-Type: application/json

{
    "AuthorsID": 1,
    "PublishersID": 1
}
```

### Tests avec curl

```bash
# Requête GET
curl http://localhost:3000/api/books

# Requête POST
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{"Titel":"Test Book","ISBN":"123-45-67890-12-3","AuthorsID":1,"PublishersID":1}'

# Requête PUT
curl -X PUT http://localhost:3000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{"Titel":"Updated Title","ISBN":"123-45-67890-12-3","AmountInStock":2,"AuthorsID":1,"PublishersID":1}'

# Requête DELETE (-i affiche le code de statut 204)
curl -i -X DELETE http://localhost:3000/api/books/1
```

**Remarque pour Windows:** Exécuter les exemples dans Git Bash. Dans PowerShell, utiliser `curl.exe` au lieu de `curl`, car `curl` peut y être un alias de `Invoke-WebRequest`.

## Exercices pratiques

### Exercice 1: API REST pour HFTM Library

Créer une API REST complète pour HFTM Library avec:

1. Books CRUD (les 5 opérations)
2. Authors CRUD: `GET /api/authors`, `GET /api/authors/:id`, `POST /api/authors`, `PUT /api/authors/:id`, `DELETE /api/authors/:id`
3. `GET /api/books/:id/lends` - Emprunts d'un livre
4. `POST /api/lends` - Enregistrer un nouvel emprunt (utiliser la transaction de la leçon 7)
5. `PUT /api/lends/:id/return` - Rendre un livre (mettre `Date_To` à la date actuelle, augmenter `AmountInStock`)

### Exercice 2: Recherche avancée

Implémenter:

- Recherche par titre: `GET /api/books?search=harry`
- Filtrage par auteur: `GET /api/books?authorId=1`
- Pagination: `GET /api/books?page=2&limit=10`
- Tri: `GET /api/books?sortBy=Titel&order=asc`

### Exercice 3: Relations

Implémenter:

- Livres d'un auteur: `GET /api/authors/:id/books`
- Auteurs d'un genre: `GET /api/genres/:id/authors` (via la table `authors_genres`)
- Statistiques: `GET /api/stats/books-by-genre` (nombre de livres par genre)

### Exercice 4: API du centre médical

Implémenter les endpoints suivants pour le centre médical:

1. `/api/patients` - CRUD pour les patients
2. `/api/doctors` - CRUD pour les médecins
3. `/api/appointments` - CRUD pour les rendez-vous
4. `GET /api/doctors/:id/appointments` - Rendez-vous d'un médecin
5. `GET /api/patients/:id/appointments` - Rendez-vous d'un patient

### Exercice 5: Documentation API

Documenter votre API (modèle voir chapitre Documentation API) avec:

- Tous les endpoints (URL, méthode)
- Des exemples de body de requête
- Des exemples de réponse
- Les codes d'erreur

## Bonnes pratiques

### Conventions de nommage

**Bien (pluriel, minuscules):**

```text
GET /api/books
GET /api/authors
GET /api/books/5/lends
```

**À éviter:**

```text
GET /api/getBooks
GET /api/Book
GET /api/books/getAllBooks
```

### Codes de statut appropriés

```javascript
// 200 - OK (GET, PUT réussi)
res.status(200).json(data);

// 201 - Created (POST réussi)
res.status(201).json(newResource);

// 204 - No Content (DELETE réussi)
res.status(204).send();

// 400 - Bad Request (données invalides)
res.status(400).json({ error: 'Données invalides' });

// 404 - Not Found (ressource inexistante)
res.status(404).json({ error: 'Ressource non trouvée' });

// 500 - Internal Server Error
res.status(500).json({ error: 'Erreur interne du serveur' });
```

### Validation

```javascript
// Toujours valider les données entrantes
if (!Titel || Titel.trim() === '') {
    return res.status(400).json({ error: 'Titel est obligatoire' });
}

if (ISBN && !/^\d{3}-\d{2}-\d{5}-\d{2}-\d$/.test(ISBN)) {
    return res.status(400).json({ error: 'Format ISBN invalide' });
}
```

### Sécurité

```javascript
// BIEN: Prepared Statements (toujours!)
const [books] = await db.query(
    'SELECT * FROM books WHERE Titel = ?',
    [searchTerm]
);

// MAUVAIS: injection SQL possible!
const [unsafeBooks] = await db.query(
    `SELECT * FROM books WHERE Titel = '${searchTerm}'`
);
```

Autres points:

- N'accepter les noms de colonnes pour `ORDER BY` que depuis une liste blanche
- Données d'accès uniquement dans le fichier `.env`, jamais dans le code
- N'afficher les messages d'erreur avec détails techniques qu'en développement

## Documentation API

Une API ne vaut que par sa documentation. Une variante simple est un fichier `README.md` dans le projet.

### README.md

````markdown
# HFTM Library API

## Base URL

`http://localhost:3000/api`

## Endpoints

### Books

#### GET /books

Retourne tous les livres.

**Query Parameters:**

- `search` (optionnel): Recherche dans le titre
- `page` (optionnel): Page pour la pagination (par défaut: 1)
- `limit` (optionnel): Nombre de résultats par page (par défaut: 10)

**Response:** 200 OK

```json
[
    {
        "ID": 2,
        "Titel": "Paradise Lost",
        "ISBN": "586-25-07337-83-2",
        "AmountInStock": 5,
        "AuthorsID": 1252,
        "PublishersID": 15
    }
]
```

#### POST /books

Crée un nouveau livre.

**Body:**

```json
{
    "Titel": "New Book",
    "ISBN": "978-12-34567-89-0",
    "AmountInStock": 1,
    "AuthorsID": 1,
    "PublishersID": 1
}
```

**Response:** 201 Created

**Erreur:** 400 Bad Request (données invalides)
````

## Résumé

### Structure d'un endpoint REST

```javascript
exports.handler = async (req, res, next) => {
    try {
        // 1. Lire les paramètres
        const { id } = req.params;    // de l'URL: /api/books/:id
        const { search } = req.query; // de la query string: ?search=...
        const { Titel } = req.body;   // du body JSON

        // 2. Valider
        if (!Titel) {
            return res.status(400).json({ error: 'Titel est obligatoire' });
        }

        // 3. Opération sur la base de données (Prepared Statement)
        const [result] = await db.query(sql, params);

        // 4. Répondre (avec le code de statut approprié)
        res.status(200).json(result);

    } catch (err) {
        // 5. Transmettre l'erreur au middleware de gestion des erreurs
        next(err);
    }
};
```

## Devoirs

1. **Créer une API REST complète** pour votre projet
2. **Au moins 2 ressources** avec toutes les opérations CRUD
3. **Tester avec Postman** (captures d'écran)
4. **Documenter** tous les endpoints

## Liste de contrôle pour le crédit 7

- [ ] Express installé, le serveur démarre sans erreur
- [ ] Les 5 endpoints CRUD pour Books fonctionnent
- [ ] Controller et routes séparés
- [ ] Au moins un endpoint JOIN implémenté
- [ ] Entrées validées, codes de statut HTTP corrects (200, 201, 204, 400, 404, 500)
- [ ] Tous les endpoints testés (collection Postman exportée, captures d'écran)
- [ ] Documentation API (README.md) créée
- [ ] API REST fonctionnelle et documentation remises

## Ressources

- [Express.js Documentation](https://expressjs.com/)
- [REST API Best Practices](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)
- [Codes de statut HTTP (MDN)](https://developer.mozilla.org/fr/docs/Web/HTTP/Status)
- [express-validator Documentation](https://express-validator.github.io/docs/)
- [Package CORS](https://github.com/expressjs/cors)
- [Postman Learning Center](https://learning.postman.com/)

## Prochaines étapes

Dans la leçon 9, nous verrons comment les outils d'IA peuvent aider au développement de bases de données et nous continuerons le travail de projet:

- Intelligence artificielle dans l'environnement de bases de données
- Intégration de Claude AI dans votre application
- Génération de données de test
- Analyse de données avec l'IA
