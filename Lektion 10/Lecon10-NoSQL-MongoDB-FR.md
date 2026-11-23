# Leçon 10: NoSQL & MongoDB - les bases

## Objectifs d'apprentissage

L'étudiant(e) est capable de...

- Expliquer les différences entre les bases de données SQL et NoSQL
- Connaître les différents types de bases de données NoSQL
- Comprendre les concepts de MongoDB
- Effectuer des opérations CRUD dans MongoDB
- Intégrer MongoDB dans une application Node.js
- Décider quand utiliser NoSQL et quand utiliser SQL

## Qu'est-ce que NoSQL?

**NoSQL** = **N**ot **o**nly **SQL** ("pas seulement SQL", et non "pas de SQL"!)

Les bases de données NoSQL sont des systèmes de bases de données qui ne reposent **pas** sur le modèle relationnel traditionnel.

### Origines

- Développées pour des applications à l'échelle du Web (Google, Facebook, Amazon)
- Besoin de scalabilité horizontale
- Structures de données flexibles
- Hautes performances avec de grandes quantités de données

## SQL vs. NoSQL

| Aspect | SQL (relationnel) | NoSQL |
|--------|-------------------|-------|
| **Modèle de données** | Tables avec schémas fixes | Flexible (documents, clé-valeur, etc.) |
| **Schéma** | Rigide, prédéfini | Flexible, dynamique |
| **Scalabilité** | Verticale (serveur plus puissant) | Horizontale (plus de serveurs) |
| **Transactions** | Garanties ACID | Souvent eventual consistency |
| **Jointures** | Oui, efficaces | Généralement non, ou coûteuses |
| **Relations** | Fortement structurées (FK) | Faibles ou imbriquées |
| **Langage de requête** | SQL (standardisé) | Propriétaire, selon le système (API) |
| **Cas d'utilisation** | Données structurées, transactions | Données non structurées, scalabilité |
| **Exemples** | MySQL, PostgreSQL, MariaDB | MongoDB, Redis, Cassandra |

### ACID vs. BASE

**ACID (SQL):**

- **A**tomicity (atomicité): tout ou rien
- **C**onsistency (cohérence): données toujours cohérentes
- **I**solation: transactions indépendantes
- **D**urability (durabilité): données stockées de façon permanente

**BASE (NoSQL):**

- **B**asically **A**vailable: système presque toujours disponible
- **S**oft State: l'état peut changer
- **E**ventual Consistency: la cohérence est atteinte à terme

## Types de bases de données NoSQL

### 1. Document Stores (orientés documents)

**Exemples:** MongoDB, CouchDB

**Modèle de données:** documents de type JSON (stockés en BSON dans MongoDB)

```json
{
    "_id": "507f1f77bcf86cd799439011",
    "title": "Clean Code",
    "author": {
        "name": "Robert C. Martin",
        "country": "USA"
    },
    "isbn": "978-0132350884",
    "tags": ["programming", "best-practices"],
    "ratings": [5, 4, 5, 5]
}
```

**Avantages:**

- Schéma flexible
- Représentation naturelle des objets
- Facile à faire évoluer (scalabilité)

**Inconvénients:**

- Pas de jointures (ou seulement coûteuses)
- Redondance en cas de relations

**Bon pour:** systèmes de gestion de contenu (CMS), catalogues de produits

### 2. Key-Value Stores

**Exemples:** Redis, DynamoDB

**Modèle de données:** simples paires clé-valeur, accès très rapide

```text
user:1001 → {"name": "John", "email": "john@example.com"}
session:abc123 → {"userId": 1001, "expires": "2024-12-31"}
```

**Bon pour:**

- Cache
- Gestion des sessions
- Applications temps réel

### 3. Column-Family Stores

**Exemples:** Cassandra, HBase

**Modèle de données:** colonnes regroupées en familles, scalabilité massive

```text
Row Key: user123
├─ PersonalInfo
│  ├─ name: "John Doe"
│  └─ email: "john@example.com"
└─ Preferences
   ├─ language: "de"
   └─ theme: "dark"
```

**Bon pour:**

- Big Data, analytics
- Séries temporelles (time series)

### 4. Graph Databases

**Exemples:** Neo4j, ArangoDB

**Modèle de données:** nœuds (nodes) et arêtes (edges) pour des relations complexes

```text
(Person:John)-[:KNOWS]->(Person:Jane)
(Person:John)-[:WORKS_AT]->(Company:HFTM)
```

**Bon pour:**

- Réseaux sociaux
- Systèmes de recommandation
- Analyse de réseaux

## MongoDB - Introduction

**MongoDB** est la base de données NoSQL orientée documents la plus populaire.

### Concepts de base

| SQL | MongoDB |
|-----|---------|
| Database | Database |
| Table | Collection |
| Row | Document |
| Column | Field |
| Primary Key | `_id` (automatique) |
| JOIN | Embedding ou Referencing |

**Document:** un enregistrement au format JSON/BSON, qui peut aussi contenir des objets imbriqués et des tableaux.

```json
{
    "_id": "507f1f77bcf86cd799439011",
    "title": "MongoDB Introduction",
    "author": "John Doe",
    "tags": ["database", "nosql", "mongodb"],
    "comments": [
        {
            "user": "Alice",
            "message": "Great article!",
            "date": "2024-01-15"
        }
    ]
}
```

**Collection:**

- Groupe de documents
- Équivalent d'une table SQL
- Pas de schéma fixe

**Database:**

- Contient plusieurs collections
- Équivalent d'une base de données SQL

## Installation et configuration

### Installation locale

**Variante 1: MongoDB Community Server**

- Téléchargement et installation: <https://www.mongodb.com/try/download/community>
- Ensuite, vérifier l'installation dans la console:

```bash
# Vérifier l'installation
mongod --version

# Démarrer MongoDB (si non installé comme service)
mongod

# Se connecter avec le MongoDB Shell
mongosh
```

**Variante 2: MongoDB Compass (GUI)**

- Téléchargement: <https://www.mongodb.com/products/compass>
- Interface graphique pour MongoDB

### MongoDB Atlas (Cloud)

Alternative à l'installation locale: MongoDB Atlas (gratuit pour commencer)

1. **Créer un compte:** <https://www.mongodb.com/atlas>
2. **Créer un cluster:** Free Tier (M0)
3. **Créer un utilisateur de base de données** (Database User)
4. **IP Access List:** 0.0.0.0/0 (uniquement pour le développement!)
5. **Copier la connection string**

## MongoDB avec Node.js

### Installation

```bash
npm install mongodb
```

### Connexion avec le driver MongoDB

**Variante A: script simple** (voir le code de démonstration dans `mongoproject/server.js`)

```javascript
const { MongoClient } = require('mongodb');

// Atlas: connection string du tableau de bord Atlas
// Local: "mongodb://127.0.0.1:27017"
const uri = "mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority";
const client = new MongoClient(uri);

async function connect() {
    try {
        await client.connect();
        console.log("Connecté à MongoDB!");

        const database = client.db('library');
        const collection = database.collection('books');

        // ... opérations ici

    } finally {
        await client.close();
    }
}

connect();
```

**Variante B: module réutilisable** (p. ex. pour un projet Express)

```javascript
// config/mongodb.js
const { MongoClient } = require('mongodb');

const url = 'mongodb://127.0.0.1:27017';
const dbName = 'library';

let db;

async function connectDB() {
    try {
        const client = await MongoClient.connect(url);
        db = client.db(dbName);
        console.log('Connecté à MongoDB');
        return db;
    } catch (err) {
        console.error('Erreur de connexion MongoDB:', err);
        throw err;
    }
}

function getDB() {
    return db;
}

module.exports = { connectDB, getDB };
```

**Remarque:** en local, utiliser plutôt `127.0.0.1` que `localhost`. Les versions récentes de Node.js résolvent souvent `localhost` en IPv6 (`::1`), alors que `mongod` n'écoute par défaut que sur IPv4, ce qui provoque une erreur `ECONNREFUSED`.

## Opérations CRUD avec MongoDB

Les exemples suivants utilisent la variable `collection` de la variante A (`database.collection('books')`).

### Create (Insert)

```javascript
// Insérer un seul document
const newBook = {
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    isbn: "978-0547928227",
    publicationYear: 1937,
    tags: ["fantasy", "adventure"]
};

const result = await collection.insertOne(newBook);
console.log('Inséré avec l\'ID:', result.insertedId);

// Insérer plusieurs documents
const books = [
    { title: "Book 1", author: "Author 1" },
    { title: "Book 2", author: "Author 2" },
    { title: "Book 3", author: "Author 3" }
];

const results = await collection.insertMany(books);
console.log('Nombre insérés:', results.insertedCount);
console.log('IDs insérés:', results.insertedIds);
```

### Read (Find)

```javascript
// Tous les documents
const allBooks = await collection.find({}).toArray();

// Avec filtre
const tolkienBooks = await collection.find({
    author: "J.R.R. Tolkien"
}).toArray();

// Un seul document
const book = await collection.findOne({
    isbn: "978-0547928227"
});

// Avec plusieurs conditions
const recentTolkienBooks = await collection.find({
    publicationYear: { $gte: 1950 },
    author: "J.R.R. Tolkien"
}).toArray();

// Avec projection (seulement certains champs)
const bookTitles = await collection.find(
    {},
    { projection: { title: 1, author: 1, _id: 0 } }
).toArray();

// Avec tri et limite
const newestBooks = await collection
    .find()
    .sort({ publicationYear: -1 })
    .limit(10)
    .toArray();
```

### Opérateurs de requête

```javascript
// Opérateurs de comparaison
{ publicationYear: { $gt: 2000 } }      // plus grand que
{ publicationYear: { $gte: 2000 } }     // plus grand ou égal
{ publicationYear: { $lt: 2000 } }      // plus petit que
{ publicationYear: { $lte: 2000 } }     // plus petit ou égal
{ publicationYear: { $ne: 2000 } }      // différent de
{ publicationYear: { $in: [1937, 1954, 1955] } }  // dans la liste

// Opérateurs logiques
{
    $and: [
        { author: "J.R.R. Tolkien" },
        { publicationYear: { $gte: 1950 } }
    ]
}

{
    $or: [
        { author: "J.R.R. Tolkien" },
        { author: "C.S. Lewis" }
    ]
}

// Opérateurs de tableau
{ tags: "fantasy" }                     // contient "fantasy"
{ tags: { $all: ["fantasy", "adventure"] } }  // contient les deux
{ tags: { $size: 2 } }                  // longueur du tableau = 2

// Recherche par expression régulière
{ title: /Hobbit/i }                    // Regex (insensible à la casse)
```

### Update

```javascript
// Mettre à jour un document
const updateResult = await collection.updateOne(
    { isbn: "978-0547928227" },
    {
        $set: {
            publicationYear: 1938,
            lastModified: new Date()
        }
    }
);
console.log('Modifiés:', updateResult.modifiedCount);

// Mettre à jour plusieurs documents
await collection.updateMany(
    { author: "J.R.R. Tolkien" },
    { $set: { genre: "Fantasy" } }
);

// Opérations sur les tableaux
await collection.updateOne(
    { isbn: "978-0547928227" },
    { $push: { tags: "classic" } }  // ajouter un élément
);

await collection.updateOne(
    { isbn: "978-0547928227" },
    { $pull: { tags: "adventure" } }  // retirer un élément
);

// Incrémenter
await collection.updateOne(
    { isbn: "978-0547928227" },
    { $inc: { viewCount: 1 } }  // augmenter le compteur
);
```

### Delete

```javascript
// Supprimer un document
const deleteResult = await collection.deleteOne({
    isbn: "978-0547928227"
});
console.log('Supprimés:', deleteResult.deletedCount);

// Supprimer plusieurs documents
await collection.deleteMany({
    publicationYear: { $lt: 1900 }
});

// Supprimer tous les documents
await collection.deleteMany({});
```

## MongoDB Aggregation Pipeline

L'Aggregation Pipeline est la réponse de MongoDB au `GROUP BY` de SQL et aux requêtes complexes. Les documents passent successivement par plusieurs étapes (stages).

### Exemple: compter les livres par auteur

```javascript
const result = await collection.aggregate([
    {
        $group: {
            _id: "$author",
            count: { $sum: 1 },
            titles: { $push: "$title" }
        }
    },
    {
        $sort: { count: -1 }
    },
    {
        $limit: 10
    }
]).toArray();
```

### Stages importants du pipeline

```javascript
// $match - filtrer (comme WHERE)
{ $match: { publicationYear: { $gte: 2000 } } }

// $group - grouper (comme GROUP BY)
{
    $group: {
        _id: "$author",
        avgYear: { $avg: "$publicationYear" }
    }
}

// $sort - trier (comme ORDER BY)
{ $sort: { publicationYear: -1 } }

// $limit - limiter (comme LIMIT)
{ $limit: 10 }

// $project - sélectionner des champs (comme SELECT)
{
    $project: {
        title: 1,
        author: 1,
        _id: 0
    }
}

// $lookup - jointure
{
    $lookup: {
        from: "authors",
        localField: "author_id",
        foreignField: "_id",
        as: "author_details"
    }
}
```

### Agrégation SQL vs. MongoDB

**SQL:**

```sql
SELECT author, COUNT(*) AS count, AVG(publication_year) AS avg_year
FROM books
WHERE publication_year >= 2000
GROUP BY author
HAVING COUNT(*) > 5
ORDER BY count DESC
LIMIT 10;
```

**MongoDB:**

```javascript
await collection.aggregate([
    { $match: { publicationYear: { $gte: 2000 } } },
    {
        $group: {
            _id: "$author",
            count: { $sum: 1 },
            avgYear: { $avg: "$publicationYear" }
        }
    },
    { $match: { count: { $gt: 5 } } },
    { $sort: { count: -1 } },
    { $limit: 10 }
]).toArray();
```

## Modélisation des données dans MongoDB

### 1. Embedding (imbriquer)

À utiliser lorsque:

- Les données vont ensemble (1:1 ou 1:N avec N petit)
- Les données sont généralement lues ensemble
- Les données changent rarement
- Aucune référence depuis l'extérieur n'est nécessaire

```json
{
    "_id": "book1",
    "title": "Clean Code",
    "author": {
        "name": "Robert C. Martin",
        "country": "USA",
        "birthYear": 1952
    },
    "reviews": [
        {
            "user": "user1",
            "rating": 5,
            "comment": "Excellent book!"
        },
        {
            "user": "user2",
            "rating": 4,
            "comment": "Very helpful"
        }
    ]
}
```

**Avantages:**

- Accès rapide (1 requête)
- Mises à jour atomiques

**Inconvénients:**

- Les documents peuvent devenir volumineux (limite de 16 MB!)
- Redondance en cas d'utilisation multiple

### 2. Referencing (référencer)

À utiliser lorsque:

- Il existe de nombreuses relations (1:N avec N très grand ou N:M)
- Les données sont mises à jour indépendamment ou changent souvent
- Les données sont interrogées séparément

```javascript
// Collection: books
{
    "_id": "book1",
    "title": "Clean Code",
    "author_id": "author1",
    "isbn": "978-0132350884"
}

// Collection: authors
{
    "_id": "author1",
    "name": "Robert C. Martin",
    "country": "USA",
    "birthYear": 1952
}
```

**Lookup dans Node.js (deux requêtes):**

```javascript
const book = await booksCollection.findOne({ _id: "book1" });
const author = await authorsCollection.findOne({ _id: book.author_id });

book.author = author;
```

**Aggregation Pipeline (comme un JOIN):**

```javascript
const booksWithAuthors = await booksCollection.aggregate([
    {
        $lookup: {
            from: "authors",
            localField: "author_id",
            foreignField: "_id",
            as: "author"
        }
    },
    {
        $unwind: "$author"
    }
]).toArray();
```

## Comparaison SQL vs. MongoDB

### Structure des données

**SQL (HFTM Library, simplifiée):**

```sql
-- Table: authors (à créer en premier, car books y fait référence)
CREATE TABLE authors (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Table: books
CREATE TABLE books (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    publication_year INT,
    author_id INT,
    FOREIGN KEY (author_id) REFERENCES authors(id)
);
```

**MongoDB:**

```javascript
// Collection: books (avec document imbriqué)
{
    "_id": ObjectId("..."),
    "title": "Book Title",
    "publicationYear": 2021,
    "author": {
        "name": "John Doe",
        "email": "john@example.com"
    }
}

// Ou avec référence
{
    "_id": ObjectId("..."),
    "title": "Book Title",
    "publicationYear": 2021,
    "author_id": ObjectId("...")
}
```

### Requêtes

**SQL:**

```sql
SELECT b.title, a.name
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE b.publication_year > 2020;
```

**MongoDB (mongosh):**

```javascript
// Avec documents imbriqués (pas de JOIN nécessaire)
db.books.find(
    { publicationYear: { $gt: 2020 } },
    { title: 1, 'author.name': 1 }
);

// Avec référence (agrégation)
db.books.aggregate([
    { $match: { publicationYear: { $gt: 2020 } } },
    { $lookup: {
        from: 'authors',
        localField: 'author_id',
        foreignField: '_id',
        as: 'author'
    }}
]);
```

## Mongoose ODM

**Mongoose** est un Object Document Mapper (ODM) pour MongoDB. Il complète MongoDB avec des schémas, de la validation et des modèles.

```bash
npm install mongoose
```

### Schéma et modèle

```javascript
// models/Book.js
const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true
    },
    author: {
        type: String,
        required: true
    },
    isbn: {
        type: String,
        unique: true
    },
    publicationYear: {
        type: Number,
        min: 1450,
        max: 2100
    },
    price: {
        type: Number,
        default: 0
    },
    tags: [String],
    inStock: {
        type: Boolean,
        default: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

const Book = mongoose.model('Book', bookSchema);

module.exports = Book;
```

```javascript
// app.js - établir la connexion
const mongoose = require('mongoose');

mongoose.connect('mongodb://127.0.0.1:27017/library')
    .then(() => console.log('MongoDB connecté'))
    .catch(err => console.error('Erreur de connexion:', err));
```

### CRUD avec Mongoose

```javascript
const Book = require('./models/Book');

// CREATE
const newBook = new Book({
    title: 'MongoDB with Mongoose',
    author: 'Jane Smith',
    isbn: '978-1234567890',
    publicationYear: 2024,
    tags: ['database', 'mongoose']
});

await newBook.save();

// READ
const books = await Book.find();
const bookById = await Book.findById('507f1f77bcf86cd799439011');
const bookByTitle = await Book.findOne({ title: 'MongoDB with Mongoose' });

// UPDATE
const bookId = newBook._id;

await Book.updateOne(
    { _id: bookId },
    { $set: { price: 29.99 } }
);

// Ou avec findByIdAndUpdate (retourne le document mis à jour)
const updated = await Book.findByIdAndUpdate(
    bookId,
    { price: 29.99 },
    { new: true }
);

// DELETE
await Book.deleteOne({ _id: bookId });
// ou
await Book.findByIdAndDelete(bookId);
```

### Validation

```javascript
// Validation avec Mongoose
const bookSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Le titre est obligatoire'],
        minlength: [3, 'Le titre doit contenir au moins 3 caractères'],
        maxlength: [200, 'Le titre ne peut pas dépasser 200 caractères']
    },
    price: {
        type: Number,
        min: [0, 'Le prix ne peut pas être négatif'],
        validate: {
            validator: function(v) {
                return v >= 0 && v <= 10000;
            },
            message: 'Le prix doit être compris entre 0 et 10000'
        }
    },
    email: {
        type: String,
        match: [/^\S+@\S+\.\S+$/, 'Format d\'e-mail invalide']
    }
});
```

## Quand utiliser SQL, quand utiliser NoSQL?

### Utiliser SQL quand:

✅ **Données structurées avec des relations claires**

- Systèmes bancaires
- Systèmes ERP et CRM
- Systèmes de réservation

✅ **Transactions ACID nécessaires**

- Transactions financières
- Systèmes de commande, e-commerce (commandes, paiements)
- Gestion des stocks

✅ **Requêtes complexes et jointures**

- Reporting
- Business Intelligence
- Analyse de données

✅ **Stabilité du schéma et intégrité référentielle**

- Projets à long terme avec peu de changements

### Utiliser NoSQL quand:

✅ **Schémas flexibles**

- Données non structurées ou semi-structurées
- Exigences qui changent rapidement, prototypage
- Gestion de contenu, catalogues de produits

✅ **Grandes quantités de données (Big Data)**

- Données de réseaux sociaux (posts, commentaires)
- Données de capteurs IoT
- Logs et analytics

✅ **Scalabilité horizontale nécessaire**

- Trafic élevé, lectures/écritures rapides
- Systèmes géographiquement distribués

✅ **Modèles de données simples**

- Documents sans beaucoup de relations
- Paires clé-valeur
- Données hiérarchiques

### Avantages et inconvénients

**SQL - Avantages:**

- ✅ ACID garanti
- ✅ Relations complexes
- ✅ Standard établi
- ✅ Outils matures

**SQL - Inconvénients:**

- ❌ Schéma rigide
- ❌ Scalabilité horizontale difficile
- ❌ Performances avec de très grandes quantités de données

**NoSQL (MongoDB) - Avantages:**

- ✅ Schéma flexible
- ✅ Scalabilité horizontale
- ✅ Performances élevées
- ✅ Développement rapide

**NoSQL (MongoDB) - Inconvénients:**

- ❌ Pas de JOINs natifs (seulement `$lookup`)
- ❌ Eventual consistency, p. ex. lors de la lecture sur des nœuds secondaires
- ❌ Redondance de données
- ❌ Transactions multi-documents seulement depuis la version 4.0 et plus lourdes qu'en SQL

## Polyglot Persistence

Les applications modernes utilisent souvent **plusieurs types de bases de données** simultanément: **SQL et NoSQL** dans la même application!

### Exemple d'architecture

```text
Application Web
├── MySQL/MariaDB → données transactionnelles
│   ├── Users (authentification)
│   ├── Orders (transactions)
│   └── Payments (ACID important)
├── MongoDB → données flexibles
│   ├── Products (catalogue)
│   ├── Reviews (commentaires)
│   └── Logs (analytics)
├── Redis → gestion des sessions, cache
└── Elasticsearch → recherche plein texte
```

### Implémentation

```javascript
// config/databases.js
const mysql = require('mysql2/promise');
const mongoose = require('mongoose');

// Connexion MySQL/MariaDB
const mysqlPool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DB
});

// Connexion MongoDB
mongoose.connect(process.env.MONGODB_URI);

module.exports = { mysqlPool, mongoose };
```

```javascript
// controllers/orderController.js
const { mysqlPool } = require('../config/databases');
const Product = require('../models/Product'); // Mongoose

exports.createOrder = async (req, res) => {
    try {
        const { userId, productId, quantity } = req.body;

        // 1. Lire le produit depuis MongoDB
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ error: 'Produit introuvable' });
        }

        // 2. Créer la commande dans MySQL/MariaDB
        const [result] = await mysqlPool.query(
            'INSERT INTO orders (user_id, product_id, quantity, total) VALUES (?, ?, ?, ?)',
            [userId, productId, quantity, product.price * quantity]
        );

        res.status(201).json({ orderId: result.insertId });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Erreur lors de la création de la commande' });
    }
};
```

## Exercices pratiques

### Exercice 1: Setup MongoDB

1. Installer MongoDB localement ou créer un compte MongoDB Atlas avec un cluster gratuit
2. Créer une base de données de test
3. Se connecter avec Node.js
4. Créer une collection et insérer des données de test

### Exercice 2: Opérations CRUD

Créer une petite application de bibliothèque avec MongoDB:

```javascript
// Collection: books
{
    title: String,
    author: String,
    isbn: String,
    publicationYear: Number,
    tags: [String],
    available: Boolean
}
```

Implémenter:

1. Ajouter un livre
2. Lister tous les livres
3. Rechercher des livres par auteur
4. Marquer un livre comme emprunté
5. Trouver les livres avec le tag "fantasy"

### Exercice 3: API CRUD avec Mongoose

Créer une API REST avec:

- Collection: `products`
- Endpoints: GET, POST, PUT, DELETE
- Utilisation de Mongoose (schéma avec validation)

### Exercice 4: Embedding vs. Referencing

Modéliser un système de blog dans MongoDB de deux manières:

**Variante A: Embedding**

```json
{
    "title": "My Blog Post",
    "content": "...",
    "author": { "name": "John", "email": "john@example.com" },
    "comments": [
        { "user": "Jane", "text": "Great post!", "date": "2024-10-10" }
    ]
}
```

**Variante B: Referencing**

```javascript
// Collection: posts
{
    "_id": "post1",
    "title": "My Blog Post",
    "content": "...",
    "author_id": "author1"
}

// Collection: authors
{
    "_id": "author1",
    "name": "John",
    "email": "john@example.com"
}

// Collection: comments
{
    "post_id": "post1",
    "user": "Jane",
    "text": "Great post!",
    "date": "2024-10-10"
}
```

Discuter des avantages et inconvénients des deux approches.

### Exercice 5: Aggregation Pipeline

On dispose d'une collection e-commerce `orders`:

```json
{
    "order_id": "ORD001",
    "customer": "John Doe",
    "items": [
        { "product": "Laptop", "price": 1200, "quantity": 1 },
        { "product": "Mouse", "price": 25, "quantity": 2 }
    ],
    "order_date": "2024-10-01",
    "status": "delivered"
}
```

Créer des requêtes d'agrégation pour:

1. Le chiffre d'affaires total par client
2. Le top 5 des produits les plus vendus
3. La valeur moyenne des commandes par mois
4. Le nombre de commandes par statut

### Exercice 6: Migration de données

1. Exporter les tables `books` et `authors` de la HFTM Library DB (MariaDB/MySQL)
2. Transformer les données au format MongoDB (p. ex. l'auteur comme document imbriqué)
3. Importer dans MongoDB
4. Comparer les requêtes et les performances

### Exercice 7: Application hybride

Créer une application qui utilise:

- MySQL/MariaDB pour `users` et `orders`
- MongoDB pour `products` et `reviews`

## Bonnes pratiques MongoDB

### 1. Stratégie d'indexation

```javascript
// Créer des index pour les requêtes fréquentes
await collection.createIndex({ author: 1 });
await collection.createIndex({ isbn: 1 }, { unique: true });

// Index composé (compound index)
await collection.createIndex({ author: 1, publicationYear: -1 });

// Index texte pour la recherche plein texte
await collection.createIndex({ title: "text", description: "text" });

// Avec Mongoose (défini dans le schéma)
bookSchema.index({ title: 1 });
bookSchema.index({ author: 1, publicationYear: -1 });
```

### 2. Schema Design Patterns

**Pattern 1: Subset Pattern** - n'imbriquer que les données pertinentes:

```javascript
{
    "movie": "Inception",
    "cast": [
        { "name": "Leonardo DiCaprio", "role": "Cobb" }
        // Seulement les acteurs principaux, pas tous les détails
    ]
}
```

**Pattern 2: Computed Pattern** - stocker des valeurs précalculées:

```javascript
{
    "product": "Laptop",
    "reviews": [ /* ... */ ],
    "avgRating": 4.5,  // précalculé
    "reviewCount": 127
}
```

### 3. Taille des documents

- Maximum: 16 MB par document
- Pour les tableaux volumineux ou qui grandissent sans limite: utiliser le referencing
- Pour les gros fichiers: utiliser GridFS

### 4. Connection Pooling

```javascript
const client = new MongoClient(uri, {
    maxPoolSize: 10,
    minPoolSize: 2
});
```

## Résumé

### Choisir la bonne base de données

**Utiliser SQL quand:**

- La structure des données est claire et stable
- Les relations complexes sont importantes
- Les transactions ACID sont cruciales
- L'intégrité référentielle est nécessaire

**Utiliser NoSQL quand:**

- Un schéma flexible est nécessaire
- La scalabilité horizontale est importante
- Les quantités de données sont grandes
- Les lectures/écritures rapides sont prioritaires

**Utiliser les deux quand:**

- Une application complexe a des besoins différents
- Certaines données nécessitent ACID
- D'autres données nécessitent de la flexibilité

## Devoirs

1. **Installer MongoDB** (local ou Atlas)
2. **Créer une API MongoDB** pour une entité
3. **Comparer les performances:** SQL vs. NoSQL
4. **Décider** quelle base de données utiliser pour votre projet

## Liste de contrôle pour le Credit 9

- [ ] MongoDB installé ou compte MongoDB Atlas créé
- [ ] Connexion à MongoDB avec Node.js fonctionnelle
- [ ] Opérations CRUD implémentées
- [ ] Aggregation Pipeline utilisé
- [ ] Embedding vs. Referencing compris
- [ ] Documentation des solutions

## Ressources supplémentaires

- [Documentation MongoDB](https://www.mongodb.com/docs/)
- [Documentation Mongoose](https://mongoosejs.com/)
- [MongoDB University (cours gratuits)](https://learn.mongodb.com/)
- [MongoDB Schema Design Best Practices](https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design)
- [Guide SQL vs. NoSQL](https://www.mongodb.com/nosql-explained/nosql-vs-sql)

## Prochaines étapes

Dans la leçon 11, nous verrons des frameworks JavaScript qui nous aident à écrire du code structuré avec le pattern MVC, ainsi que des ORM pour un accès plus efficace à la base de données:

- Frameworks Express et pattern MVC
- ORM: Sequelize pour SQL
- Migrations de base de données
- Comparaison ORM vs. SQL brut
