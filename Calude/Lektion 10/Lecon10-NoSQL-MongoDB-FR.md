# Leçon 10: NoSQL & MongoDB

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Expliquer les différences entre SQL et NoSQL
- Comprendre les concepts de MongoDB
- Effectuer des opérations CRUD dans MongoDB
- Décider quand utiliser SQL vs NoSQL
- Intégrer MongoDB dans une application Node.js

## Qu'est-ce que NoSQL?

**NoSQL** = **N**ot **O**nly **SQL** (pas seulement SQL)

Bases de données qui n'utilisent pas le modèle relationnel traditionnel.

### Types de bases de données NoSQL

**1. Document Databases (MongoDB, CouchDB)**
- Stockent des documents (JSON/BSON)
- Structure flexible
- Bon pour: CMS, catalogues de produits

**2. Key-Value Stores (Redis, DynamoDB)**
- Paires clé-valeur simples
- Très rapide
- Bon pour: Cache, sessions

**3. Column-Family (Cassandra, HBase)**
- Stockage en colonnes
- Scalabilité massive
- Bon pour: Big Data, analytics

**4. Graph Databases (Neo4j, ArangoDB)**
- Relations complexes
- Noeuds et edges
- Bon pour: Réseaux sociaux, recommandations

## SQL vs NoSQL

### Comparaison

| Aspect | SQL | NoSQL |
|--------|-----|-------|
| **Structure** | Tables fixes, schéma rigide | Flexible, sans schéma |
| **Scalabilité** | Vertical (plus puissant) | Horizontal (plus de serveurs) |
| **Transactions** | ACID garanti | Eventual consistency |
| **Relations** | JOINs complexes | Documents imbriqués |
| **Langage** | SQL standard | API spécifique |
| **Use Cases** | Données structurées, transactions | Données non structurées, scalabilité |

### Quand utiliser SQL?

✅ **SQL est mieux pour:**
- Données structurées avec relations claires
- Transactions ACID importantes
- Requêtes complexes avec JOINs
- Données relationnelles (commandes, factures)
- Applications financières

**Exemples:**
- Systèmes bancaires
- ERP, CRM
- E-commerce (commandes, paiements)
- Systèmes de réservation

### Quand utiliser NoSQL?

✅ **NoSQL est mieux pour:**
- Données non structurées ou semi-structurées
- Schéma flexible, évolution rapide
- Scalabilité horizontale nécessaire
- Grandes quantités de données
- Lectures/écritures rapides

**Exemples:**
- Réseaux sociaux (posts, commentaires)
- Catalogues de produits
- Logs et analytics
- Applications IoT
- Content Management Systems

## MongoDB

**MongoDB** est la base de données document NoSQL la plus populaire.

### Concepts de base

**Document:**
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

## Installation de MongoDB

### Vérification

```bash
# Vérifier l'installation
mongod --version

# Démarrer MongoDB
mongod

# Se connecter avec mongo shell
mongosh
```

### MongoDB Atlas (Cloud)

Alternative: Utiliser MongoDB Atlas (gratuit pour commencer)
1. Créer un compte sur [mongodb.com/atlas](https://www.mongodb.com/atlas)
2. Créer un cluster gratuit
3. Obtenir la connection string

## MongoDB avec Node.js

### Installation

```bash
npm install mongodb mongoose
```

### Connection avec MongoDB Driver

```javascript
// config/mongodb.js
const { MongoClient } = require('mongodb');

const url = 'mongodb://localhost:27017';
const dbName = 'library';

let db;

async function connectDB() {
    try {
        const client = await MongoClient.connect(url);
        db = client.db(dbName);
        console.log('Connected to MongoDB');
        return db;
    } catch (err) {
        console.error('MongoDB connection error:', err);
        throw err;
    }
}

function getDB() {
    return db;
}

module.exports = { connectDB, getDB };
```

## CRUD Operations avec MongoDB

### CREATE - Insérer des documents

```javascript
// Insérer un seul document
const result = await db.collection('books').insertOne({
    title: 'MongoDB Basics',
    author: 'John Doe',
    year: 2024,
    tags: ['database', 'nosql']
});

console.log('Inserted ID:', result.insertedId);

// Insérer plusieurs documents
const books = [
    { title: 'Book 1', author: 'Author 1' },
    { title: 'Book 2', author: 'Author 2' },
    { title: 'Book 3', author: 'Author 3' }
];

const result = await db.collection('books').insertMany(books);
console.log('Inserted:', result.insertedCount);
```

### READ - Lire des documents

```javascript
// Trouver tous les documents
const books = await db.collection('books').find().toArray();

// Trouver avec filtre
const book = await db.collection('books').findOne({ title: 'MongoDB Basics' });

// Avec plusieurs conditions
const recentBooks = await db.collection('books').find({
    year: { $gte: 2020 },
    author: 'John Doe'
}).toArray();

// Avec projection (sélectionner des champs)
const titles = await db.collection('books').find(
    {},
    { projection: { title: 1, author: 1, _id: 0 } }
).toArray();

// Avec limite et tri
const topBooks = await db.collection('books')
    .find()
    .sort({ year: -1 })
    .limit(10)
    .toArray();
```

### UPDATE - Mettre à jour des documents

```javascript
// Mettre à jour un document
const result = await db.collection('books').updateOne(
    { title: 'MongoDB Basics' },
    { $set: { year: 2025, updated: new Date() } }
);

console.log('Modified:', result.modifiedCount);

// Mettre à jour plusieurs documents
await db.collection('books').updateMany(
    { author: 'John Doe' },
    { $set: { verified: true } }
);

// Incrémenter une valeur
await db.collection('books').updateOne(
    { title: 'MongoDB Basics' },
    { $inc: { views: 1 } }
);

// Ajouter à un tableau
await db.collection('books').updateOne(
    { title: 'MongoDB Basics' },
    { $push: { tags: 'tutorial' } }
);
```

### DELETE - Supprimer des documents

```javascript
// Supprimer un document
const result = await db.collection('books').deleteOne({
    title: 'MongoDB Basics'
});

console.log('Deleted:', result.deletedCount);

// Supprimer plusieurs documents
await db.collection('books').deleteMany({
    year: { $lt: 2000 }
});
```

## Mongoose ODM

**Mongoose** est un Object Document Mapper pour MongoDB.

### Schema et Model

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
    year: {
        type: Number,
        min: 1900,
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

### CRUD avec Mongoose

```javascript
// CREATE
const book = new Book({
    title: 'MongoDB with Mongoose',
    author: 'Jane Smith',
    isbn: '978-1234567890',
    year: 2024,
    tags: ['database', 'mongoose']
});

await book.save();

// READ
const books = await Book.find();
const book = await Book.findById('507f1f77bcf86cd799439011');
const book = await Book.findOne({ title: 'MongoDB with Mongoose' });

// UPDATE
await Book.updateOne(
    { _id: bookId },
    { $set: { price: 29.99 } }
);

// Ou avec findByIdAndUpdate
const updated = await Book.findByIdAndUpdate(
    bookId,
    { price: 29.99 },
    { new: true }
);

// DELETE
await Book.deleteOne({ _id: bookId });
await Book.findByIdAndDelete(bookId);
```

## Comparaison SQL vs MongoDB

### Structure des données

**SQL:**
```sql
-- Table: books
CREATE TABLE books (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    author_id INT,
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

-- Table: authors
CREATE TABLE authors (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);
```

**MongoDB:**
```javascript
// Collection: books (documents imbriqués)
{
    "_id": ObjectId("..."),
    "title": "Book Title",
    "author": {
        "name": "John Doe",
        "email": "john@example.com"
    }
}

// Ou avec référence
{
    "_id": ObjectId("..."),
    "title": "Book Title",
    "authorId": ObjectId("...")
}
```

### Requêtes

**SQL:**
```sql
SELECT b.title, a.name
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE b.year > 2020;
```

**MongoDB:**
```javascript
// Avec documents imbriqués (pas de JOIN nécessaire)
db.books.find({
    year: { $gt: 2020 }
}, {
    title: 1,
    'author.name': 1
});

// Avec référence (aggregation)
db.books.aggregate([
    { $match: { year: { $gt: 2020 } } },
    { $lookup: {
        from: 'authors',
        localField: 'authorId',
        foreignField: '_id',
        as: 'author'
    }}
]);
```

## Hybrid Approach - Polyglot Persistence

Utiliser **SQL et NoSQL** dans la même application!

### Exemple d'architecture

```
Application
    ├── MySQL
    │   ├── Users (authentification)
    │   ├── Orders (transactions)
    │   └── Payments (ACID important)
    │
    └── MongoDB
        ├── Products (catalogue)
        ├── Reviews (commentaires)
        └── Logs (analytics)
```

### Implémentation

```javascript
// config/databases.js
const mysql = require('mysql2/promise');
const mongoose = require('mongoose');

// MySQL Connection
const mysqlPool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DB
});

// MongoDB Connection
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
        
        // 1. Get product from MongoDB
        const product = await Product.findById(productId);
        
        // 2. Create order in MySQL
        const [result] = await mysqlPool.query(
            'INSERT INTO orders (user_id, product_id, quantity, total) VALUES (?, ?, ?, ?)',
            [userId, productId, quantity, product.price * quantity]
        );
        
        res.status(201).json({ orderId: result.insertId });
        
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error creating order' });
    }
};
```

## Exercices pratiques

### Exercice 1: Setup MongoDB

1. Installer MongoDB localement ou créer un cluster Atlas
2. Se connecter avec Node.js
3. Créer une collection et insérer des documents de test

### Exercice 2: CRUD API avec MongoDB

Créer une API REST avec:
- Collection: products
- Endpoints: GET, POST, PUT, DELETE
- Utiliser Mongoose

### Exercice 3: Migration de données

1. Exporter des données de MySQL
2. Transformer en format MongoDB
3. Importer dans MongoDB
4. Comparer les performances

### Exercice 4: Hybrid Application

Créer une application qui utilise:
- MySQL pour les users et orders
- MongoDB pour les products et reviews

## Bonnes pratiques

### Modélisation de données MongoDB

✅ **Imbriquer (Embed):**
- Données qui sont toujours lues ensemble
- Relations 1:1 ou 1:N avec N petit
- Données qui ne changent pas souvent

```javascript
// Bon: Adresse imbriquée
{
    name: "John Doe",
    address: {
        street: "Main St",
        city: "Bern",
        zip: "3000"
    }
}
```

✅ **Référencer:**
- Relations N:M
- Données accédées indépendamment
- Données qui changent souvent
- N très grand

```javascript
// Bon: Référence à l'auteur
{
    title: "Book Title",
    authorId: ObjectId("...")
}
```

### Indexation

```javascript
// Créer des index pour les requêtes fréquentes
db.books.createIndex({ title: 1 });
db.books.createIndex({ author: 1, year: -1 });

// Index texte pour la recherche
db.books.createIndex({ title: "text", description: "text" });

// Avec Mongoose
bookSchema.index({ title: 1 });
bookSchema.index({ author: 1, year: -1 });
```

### Validation

```javascript
// Mongoose validation
const bookSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Title is required'],
        minlength: [3, 'Title must be at least 3 characters'],
        maxlength: [200, 'Title cannot exceed 200 characters']
    },
    price: {
        type: Number,
        min: [0, 'Price cannot be negative'],
        validate: {
            validator: function(v) {
                return v >= 0 && v <= 10000;
            },
            message: 'Price must be between 0 and 10000'
        }
    },
    email: {
        type: String,
        match: [/^\S+@\S+\.\S+$/, 'Invalid email format']
    }
});
```

## Avantages et inconvénients

### SQL

**Avantages:**
- ✅ ACID garanti
- ✅ Relations complexes
- ✅ Standard établi
- ✅ Outils matures

**Inconvénients:**
- ❌ Schéma rigide
- ❌ Scalabilité horizontale difficile
- ❌ Performances avec grandes données

### NoSQL (MongoDB)

**Avantages:**
- ✅ Schéma flexible
- ✅ Scalabilité horizontale
- ✅ Performances élevées
- ✅ Développement rapide

**Inconvénients:**
- ❌ Pas de JOINs natifs
- ❌ Eventual consistency
- ❌ Redondance de données
- ❌ Moins mature pour transactions

## Résumé

### Choisir la bonne base de données

**Utilisez SQL quand:**
- Structure de données claire et stable
- Relations complexes importantes
- Transactions ACID cruciales
- Intégrité référentielle nécessaire

**Utilisez NoSQL quand:**
- Schéma flexible nécessaire
- Scalabilité horizontale importante
- Grandes quantités de données
- Lectures/écritures rapides prioritaires

**Utilisez les deux quand:**
- Application complexe avec différents besoins
- Certaines données nécessitent ACID
- D'autres nécessitent flexibilité

## Devoirs

1. **Installer MongoDB** (local ou Atlas)
2. **Créer une API MongoDB** pour une entité
3. **Comparer les performances** SQL vs NoSQL
4. **Décider** quelle base de données pour votre projet

## Ressources

- [MongoDB Documentation](https://docs.mongodb.com/)
- [Mongoose Documentation](https://mongoosejs.com/)
- [MongoDB University](https://university.mongodb.com/) (Cours gratuits)
- [SQL vs NoSQL Guide](https://www.mongodb.com/nosql-explained/nosql-vs-sql)

## Prochaines étapes

Dans la leçon 11:
- Frameworks Express avancés
- ORM: Sequelize pour SQL
- Migrations de base de données
- Comparaison ORM vs SQL brut
