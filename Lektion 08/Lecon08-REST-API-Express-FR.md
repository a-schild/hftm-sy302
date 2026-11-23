# Leçon 8: API REST avec Express.js

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Expliquer ce qu'est une API REST
- Créer une API REST avec Express.js
- Implémenter les méthodes HTTP (GET, POST, PUT, DELETE)
- Structurer une API de manière professionnelle
- Tester l'API avec Postman

## Qu'est-ce qu'une API REST?

**REST** = **RE**presentational **S**tate **T**ransfer

### Principes REST

1. **Client-Server**: Séparation des préoccupations
2. **Stateless**: Chaque requête est indépendante
3. **Uniform Interface**: Interface uniforme
4. **Ressources**: Tout est une ressource (books, authors, etc.)
5. **HTTP Methods**: Utiliser correctement GET, POST, PUT, DELETE

### Ressources et URIs

```
GET    /api/books           # Tous les livres
GET    /api/books/5         # Livre avec ID 5
POST   /api/books           # Créer un nouveau livre
PUT    /api/books/5         # Mettre à jour le livre 5
DELETE /api/books/5         # Supprimer le livre 5
```

## Express.js

**Express** est le framework web le plus populaire pour Node.js.

### Installation

```bash
npm install express
```

### Serveur de base

```javascript
// server.js
const express = require('express');
const app = express();
const PORT = 3000;

// Middleware pour parser le JSON
app.use(express.json());

// Route de test
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to the API' });
});

// Démarrer le serveur
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
```

## Méthodes HTTP

| Méthode | Signification | Opération CRUD | Idempotent |
|---------|---------------|----------------|------------|
| GET | Lire | Read | ✅ Oui |
| POST | Créer | Create | ❌ Non |
| PUT | Mettre à jour (complet) | Update | ✅ Oui |
| PATCH | Mettre à jour (partiel) | Update | ❌ Non |
| DELETE | Supprimer | Delete | ✅ Oui |

### Codes de statut HTTP

**2xx - Succès:**
- 200 OK - Requête réussie
- 201 Created - Ressource créée
- 204 No Content - Succès sans contenu

**4xx - Erreur client:**
- 400 Bad Request - Données invalides
- 401 Unauthorized - Non authentifié
- 403 Forbidden - Pas d'autorisation
- 404 Not Found - Ressource non trouvée

**5xx - Erreur serveur:**
- 500 Internal Server Error - Erreur serveur

## CRUD API pour Books

### GET - Lire tous les livres

```javascript
// GET /api/books
app.get('/api/books', async (req, res) => {
    try {
        const [books] = await pool.query('SELECT * FROM books');
        res.json(books);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

### GET - Lire un livre par ID

```javascript
// GET /api/books/:id
app.get('/api/books/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        const [books] = await pool.query(
            'SELECT * FROM books WHERE id = ?',
            [id]
        );
        
        if (books.length === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        res.json(books[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

### POST - Créer un nouveau livre

```javascript
// POST /api/books
app.post('/api/books', async (req, res) => {
    try {
        const { title, author_id, publisher_id, isbn } = req.body;
        
        // Validation
        if (!title || !author_id) {
            return res.status(400).json({ error: 'Title and author_id are required' });
        }
        
        const [result] = await pool.query(
            'INSERT INTO books (title, author_id, publisher_id, isbn) VALUES (?, ?, ?, ?)',
            [title, author_id, publisher_id, isbn]
        );
        
        res.status(201).json({
            id: result.insertId,
            title,
            author_id,
            publisher_id,
            isbn
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

### PUT - Mettre à jour un livre

```javascript
// PUT /api/books/:id
app.put('/api/books/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { title, author_id, publisher_id, isbn } = req.body;
        
        // Vérifier si le livre existe
        const [existing] = await pool.query(
            'SELECT * FROM books WHERE id = ?',
            [id]
        );
        
        if (existing.length === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        // Mettre à jour
        await pool.query(
            'UPDATE books SET title = ?, author_id = ?, publisher_id = ?, isbn = ? WHERE id = ?',
            [title, author_id, publisher_id, isbn, id]
        );
        
        res.json({
            id,
            title,
            author_id,
            publisher_id,
            isbn
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

### DELETE - Supprimer un livre

```javascript
// DELETE /api/books/:id
app.delete('/api/books/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        const [result] = await pool.query(
            'DELETE FROM books WHERE id = ?',
            [id]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        res.status(204).send();
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

## Structure professionnelle du projet

### Organisation MVC

```
project/
├── config/
│   └── database.js          # Configuration DB
├── controllers/
│   ├── bookController.js    # Logique métier Books
│   └── authorController.js  # Logique métier Authors
├── routes/
│   ├── bookRoutes.js        # Routes Books
│   └── authorRoutes.js      # Routes Authors
├── middleware/
│   ├── errorHandler.js      # Gestion centralisée des erreurs
│   └── validation.js        # Validation des données
├── .env
├── .gitignore
├── package.json
└── server.js                # Point d'entrée
```

### database.js

```javascript
// config/database.js
require('dotenv').config();
const mysql = require('mysql2');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = pool.promise();
```

### bookController.js

```javascript
// controllers/bookController.js
const pool = require('../config/database');

// GET all books
exports.getAllBooks = async (req, res) => {
    try {
        const [books] = await pool.query('SELECT * FROM books');
        res.json(books);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// GET book by ID
exports.getBookById = async (req, res) => {
    try {
        const [books] = await pool.query(
            'SELECT * FROM books WHERE id = ?',
            [req.params.id]
        );
        
        if (books.length === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        res.json(books[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// CREATE book
exports.createBook = async (req, res) => {
    try {
        const { title, author_id, publisher_id, isbn } = req.body;
        
        const [result] = await pool.query(
            'INSERT INTO books (title, author_id, publisher_id, isbn) VALUES (?, ?, ?, ?)',
            [title, author_id, publisher_id, isbn]
        );
        
        res.status(201).json({
            id: result.insertId,
            title,
            author_id,
            publisher_id,
            isbn
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// UPDATE book
exports.updateBook = async (req, res) => {
    try {
        const { title, author_id, publisher_id, isbn } = req.body;
        const { id } = req.params;
        
        const [result] = await pool.query(
            'UPDATE books SET title = ?, author_id = ?, publisher_id = ?, isbn = ? WHERE id = ?',
            [title, author_id, publisher_id, isbn, id]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        res.json({ id, title, author_id, publisher_id, isbn });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
};

// DELETE book
exports.deleteBook = async (req, res) => {
    try {
        const [result] = await pool.query(
            'DELETE FROM books WHERE id = ?',
            [req.params.id]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        res.status(204).send();
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
};
```

### bookRoutes.js

```javascript
// routes/bookRoutes.js
const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');

// Routes
router.get('/', bookController.getAllBooks);
router.get('/:id', bookController.getBookById);
router.post('/', bookController.createBook);
router.put('/:id', bookController.updateBook);
router.delete('/:id', bookController.deleteBook);

module.exports = router;
```

### server.js

```javascript
// server.js
require('dotenv').config();
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS (pour les requêtes cross-origin)
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});

// Routes
const bookRoutes = require('./routes/bookRoutes');
const authorRoutes = require('./routes/authorRoutes');

app.use('/api/books', bookRoutes);
app.use('/api/authors', authorRoutes);

// Route racine
app.get('/', (req, res) => {
    res.json({
        message: 'Welcome to Library API',
        endpoints: {
            books: '/api/books',
            authors: '/api/authors'
        }
    });
});

// Gestion des erreurs 404
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Démarrer le serveur
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
```

## Query Parameters

### Filtrage et recherche

```javascript
// GET /api/books?search=harry&limit=10
app.get('/api/books', async (req, res) => {
    try {
        const { search, limit, offset } = req.query;
        
        let sql = 'SELECT * FROM books';
        let params = [];
        
        if (search) {
            sql += ' WHERE title LIKE ?';
            params.push(`%${search}%`);
        }
        
        if (limit) {
            sql += ' LIMIT ?';
            params.push(parseInt(limit));
        }
        
        if (offset) {
            sql += ' OFFSET ?';
            params.push(parseInt(offset));
        }
        
        const [books] = await pool.query(sql, params);
        res.json(books);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

### Tri

```javascript
// GET /api/books?sortBy=title&order=asc
app.get('/api/books', async (req, res) => {
    try {
        const { sortBy, order } = req.query;
        
        let sql = 'SELECT * FROM books';
        
        if (sortBy) {
            const validColumns = ['title', 'published_date', 'author_id'];
            const validOrder = ['asc', 'desc'];
            
            if (validColumns.includes(sortBy)) {
                sql += ` ORDER BY ${sortBy}`;
                
                if (order && validOrder.includes(order.toLowerCase())) {
                    sql += ` ${order.toUpperCase()}`;
                }
            }
        }
        
        const [books] = await pool.query(sql);
        res.json(books);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

## Relations et JOINs dans l'API

### Livres avec auteurs

```javascript
// GET /api/books/with-authors
app.get('/api/books/with-authors', async (req, res) => {
    try {
        const sql = `
            SELECT 
                b.id,
                b.title,
                b.isbn,
                b.published_date,
                a.id AS author_id,
                a.firstname,
                a.lastname
            FROM books b
            INNER JOIN authors a ON b.author_id = a.id
        `;
        
        const [books] = await pool.query(sql);
        res.json(books);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

### Livre avec tous les détails

```javascript
// GET /api/books/:id/details
app.get('/api/books/:id/details', async (req, res) => {
    try {
        const { id } = req.params;
        
        const sql = `
            SELECT 
                b.id,
                b.title,
                b.isbn,
                b.published_date,
                b.amount_in_stock,
                a.id AS author_id,
                CONCAT(a.firstname, ' ', a.lastname) AS author_name,
                g.genre,
                p.name AS publisher
            FROM books b
            LEFT JOIN authors a ON b.author_id = a.id
            LEFT JOIN genres g ON b.genre_id = g.id
            LEFT JOIN publishers p ON b.publisher_id = p.id
            WHERE b.id = ?
        `;
        
        const [books] = await pool.query(sql, [id]);
        
        if (books.length === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        res.json(books[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

## Middleware

### Validation

```javascript
// middleware/validation.js
exports.validateBook = (req, res, next) => {
    const { title, author_id } = req.body;
    
    if (!title || title.trim() === '') {
        return res.status(400).json({ error: 'Title is required' });
    }
    
    if (!author_id || isNaN(author_id)) {
        return res.status(400).json({ error: 'Valid author_id is required' });
    }
    
    next();
};
```

**Utilisation:**
```javascript
const { validateBook } = require('../middleware/validation');

router.post('/', validateBook, bookController.createBook);
router.put('/:id', validateBook, bookController.updateBook);
```

### Gestion centralisée des erreurs

```javascript
// middleware/errorHandler.js
exports.errorHandler = (err, req, res, next) => {
    console.error(err.stack);
    
    // Erreur de validation
    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: err.message });
    }
    
    // Erreur de base de données
    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'Resource already exists' });
    }
    
    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
        return res.status(400).json({ error: 'Referenced resource does not exist' });
    }
    
    // Erreur par défaut
    res.status(500).json({ error: 'Internal server error' });
};
```

**Utilisation dans server.js:**
```javascript
const { errorHandler } = require('./middleware/errorHandler');

// ... routes ...

// Doit être après toutes les routes
app.use(errorHandler);
```

## Postman - Tester l'API

### Installation

Télécharger depuis [postman.com](https://www.postman.com/downloads/)

### Créer une collection

1. **New Collection** → "Library API"
2. Ajouter les requêtes:

### GET - Tous les livres

```
GET http://localhost:3000/api/books
```

### GET - Livre par ID

```
GET http://localhost:3000/api/books/1
```

### POST - Créer un livre

```
POST http://localhost:3000/api/books
Content-Type: application/json

{
    "title": "New Book",
    "author_id": 1,
    "publisher_id": 1,
    "isbn": "978-1234567890"
}
```

### PUT - Mettre à jour un livre

```
PUT http://localhost:3000/api/books/1
Content-Type: application/json

{
    "title": "Updated Book",
    "author_id": 1,
    "publisher_id": 1,
    "isbn": "978-1234567890"
}
```

### DELETE - Supprimer un livre

```
DELETE http://localhost:3000/api/books/1
```

## CORS

**CORS** = Cross-Origin Resource Sharing

### Installation

```bash
npm install cors
```

### Configuration

```javascript
const cors = require('cors');

// Tous les origines (développement)
app.use(cors());

// Origines spécifiques (production)
app.use(cors({
    origin: 'https://myapp.com',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
```

## Exercices pratiques

### Exercice 1: API complète pour Authors

Créer une API REST complète pour les auteurs:
- GET /api/authors
- GET /api/authors/:id
- POST /api/authors
- PUT /api/authors/:id
- DELETE /api/authors/:id

### Exercice 2: Recherche avancée

Implémenter:
- Recherche par titre: `GET /api/books?search=harry`
- Filtrage par auteur: `GET /api/books?author_id=1`
- Pagination: `GET /api/books?limit=10&offset=20`
- Tri: `GET /api/books?sortBy=title&order=asc`

### Exercice 3: Relations

Implémenter:
- Livres d'un auteur: `GET /api/authors/:id/books`
- Auteurs d'un genre: `GET /api/genres/:id/authors`
- Statistiques: `GET /api/stats/books-by-genre`

## Bonnes pratiques

### Conventions de nommage

✅ **URI (Pluriel, lowercase):**
```
GET /api/books
GET /api/authors
GET /api/books/5/reviews
```

❌ **À éviter:**
```
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
res.status(400).json({ error: 'Invalid data' });

// 404 - Not Found (ressource inexistante)
res.status(404).json({ error: 'Resource not found' });

// 500 - Internal Server Error
res.status(500).json({ error: 'Internal server error' });
```

### Validation

```javascript
// Toujours valider les données entrantes
if (!title || title.trim() === '') {
    return res.status(400).json({ error: 'Title is required' });
}

if (isbn && !/^978-\d{10}$/.test(isbn)) {
    return res.status(400).json({ error: 'Invalid ISBN format' });
}
```

### Sécurité

```javascript
// ✅ Prepared Statements (toujours!)
const [books] = await pool.query(
    'SELECT * FROM books WHERE title = ?',
    [searchTerm]
);

// ❌ Injection SQL vulnérable
const [books] = await pool.query(
    `SELECT * FROM books WHERE title = '${searchTerm}'`
);
```

## Documentation API

### README.md

```markdown
# Library API

## Base URL
`http://localhost:3000/api`

## Endpoints

### Books

#### GET /books
Retourne tous les livres

**Query Parameters:**
- `search` (optional): Recherche dans le titre
- `limit` (optional): Nombre de résultats
- `offset` (optional): Offset pour la pagination

**Response:**
```json
[
    {
        "id": 1,
        "title": "Harry Potter",
        "author_id": 1,
        "isbn": "978-1234567890"
    }
]
```

#### POST /books
Crée un nouveau livre

**Body:**
```json
{
    "title": "New Book",
    "author_id": 1,
    "isbn": "978-1234567890"
}
```

**Response:** 201 Created
```

## Résumé

### Structure d'un endpoint REST

```javascript
app.METHOD('/api/resource/:id?', async (req, res) => {
    try {
        // 1. Récupérer les paramètres
        const { id } = req.params;
        const { search } = req.query;
        const { title } = req.body;
        
        // 2. Valider
        if (!title) {
            return res.status(400).json({ error: 'Title required' });
        }
        
        // 3. Opération DB
        const [result] = await pool.query(sql, params);
        
        // 4. Répondre
        res.status(200).json(result);
        
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

## Devoirs

1. **Créer une API REST complète** pour votre projet
2. **Au moins 2 ressources** avec toutes les opérations CRUD
3. **Tester avec Postman** (screenshots)
4. **Documentation** de tous les endpoints

## Ressources

- [Express.js Documentation](https://expressjs.com/)
- [REST API Best Practices](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [Postman Learning Center](https://learning.postman.com/)

## Prochaines étapes

Dans la leçon 9:
- Intelligence artificielle dans l'environnement de bases de données
- Intégration de Claude AI
- Génération de données de test
- Analyse de données avec l'IA
