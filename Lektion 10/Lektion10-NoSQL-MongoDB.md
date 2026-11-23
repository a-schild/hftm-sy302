# Lektion 10: NoSQL & MongoDB Basics

## Lernziele

Die Studierenden sind in der Lage...

- Die Unterschiede zwischen SQL- und NoSQL-Datenbanken zu erklären
- Die verschiedenen NoSQL-Datenbanktypen zu kennen
- Die Konzepte von MongoDB zu verstehen
- CRUD-Operationen in MongoDB durchzuführen
- MongoDB in eine Node.js-Anwendung zu integrieren
- Zu entscheiden, wann NoSQL und wann SQL eingesetzt werden sollte

## Was ist NoSQL?

**NoSQL** = **N**ot **o**nly **SQL** ("nicht nur SQL", nicht "No SQL"!)

NoSQL-Datenbanken sind Datenbanksysteme, die **nicht** auf dem traditionellen relationalen Modell basieren.

### Entstehung

- Entwickelt für Web-Scale-Anwendungen (Google, Facebook, Amazon)
- Bedarf an horizontaler Skalierung
- Flexible Datenstrukturen
- Hohe Performance bei grossen Datenmengen

## SQL vs. NoSQL

| Aspekt | SQL (relational) | NoSQL |
|--------|------------------|-------|
| **Datenmodell** | Tabellen mit festen Schemas | Flexibel (Dokumente, Key-Value usw.) |
| **Schema** | Starr, vordefiniert | Flexibel, dynamisch |
| **Skalierung** | Vertikal (grösserer Server) | Horizontal (mehr Server) |
| **Transaktionen** | ACID-Garantien | Oft Eventual Consistency |
| **Joins** | Ja, effizient | Meist nicht, oder teuer |
| **Beziehungen** | Stark strukturiert (FK) | Schwach oder eingebettet |
| **Abfragesprache** | SQL (standardisiert) | Proprietär, je nach System (API) |
| **Einsatzgebiete** | Strukturierte Daten, Transaktionen | Unstrukturierte Daten, Skalierbarkeit |
| **Beispiele** | MySQL, PostgreSQL, MariaDB | MongoDB, Redis, Cassandra |

### ACID vs. BASE

**ACID (SQL):**

- **A**tomicity: Alles oder nichts
- **C**onsistency: Daten immer konsistent
- **I**solation: Transaktionen unabhängig
- **D**urability: Daten dauerhaft gespeichert

**BASE (NoSQL):**

- **B**asically **A**vailable: System meist verfügbar
- **S**oft State: Zustand kann sich ändern
- **E**ventual Consistency: Konsistenz wird irgendwann erreicht

## NoSQL-Datenbanktypen

### 1. Document Stores (dokumentorientiert)

**Beispiele:** MongoDB, CouchDB

**Datenmodell:** JSON-ähnliche Dokumente (in MongoDB als BSON gespeichert)

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

**Vorteile:**

- Flexibles Schema
- Natürliche Darstellung von Objekten
- Einfach zu skalieren

**Nachteile:**

- Keine (oder nur teure) Joins
- Redundanz bei Beziehungen

**Geeignet für:** Content-Management-Systeme (CMS), Produktkataloge

### 2. Key-Value Stores

**Beispiele:** Redis, DynamoDB

**Datenmodell:** Einfache Schlüssel-Wert-Paare, sehr schneller Zugriff

```text
user:1001 → {"name": "John", "email": "john@example.com"}
session:abc123 → {"userId": 1001, "expires": "2024-12-31"}
```

**Geeignet für:**

- Caching
- Session-Management
- Echtzeit-Anwendungen

### 3. Column-Family Stores

**Beispiele:** Cassandra, HBase

**Datenmodell:** Spalten in Familien gruppiert, massiv skalierbar

```text
Row Key: user123
├─ PersonalInfo
│  ├─ name: "John Doe"
│  └─ email: "john@example.com"
└─ Preferences
   ├─ language: "de"
   └─ theme: "dark"
```

**Geeignet für:**

- Big-Data-Analytics
- Zeitreihendaten (Time Series)

### 4. Graph Databases

**Beispiele:** Neo4j, ArangoDB

**Datenmodell:** Knoten (Nodes) und Kanten (Edges) für komplexe Beziehungen

```text
(Person:John)-[:KNOWS]->(Person:Jane)
(Person:John)-[:WORKS_AT]->(Company:HFTM)
```

**Geeignet für:**

- Soziale Netzwerke
- Empfehlungssysteme
- Netzwerkanalyse

## MongoDB - Einführung

**MongoDB** ist die populärste dokumentorientierte NoSQL-Datenbank.

### Wichtige Konzepte

| SQL | MongoDB |
|-----|---------|
| Database | Database |
| Table | Collection |
| Row | Document |
| Column | Field |
| Primary Key | `_id` (automatisch) |
| JOIN | Embedding oder Referencing |

**Document:** Ein Datensatz im JSON/BSON-Format, der auch verschachtelte Objekte und Arrays enthalten kann.

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

- Gruppe von Dokumenten
- Entspricht einer SQL-Tabelle
- Kein festes Schema

**Database:**

- Enthält mehrere Collections
- Entspricht einer SQL-Datenbank

## Installation und Setup

### Lokale Installation

**Variante 1: MongoDB Community Server**

- Download und Installation: <https://www.mongodb.com/try/download/community>
- Danach die Installation in der Konsole prüfen:

```bash
# Installation prüfen
mongod --version

# MongoDB starten (falls nicht als Dienst installiert)
mongod

# Mit der MongoDB Shell verbinden
mongosh
```

**Variante 2: MongoDB Compass (GUI)**

- Download: <https://www.mongodb.com/products/compass>
- Grafische Oberfläche für MongoDB

### MongoDB Atlas (Cloud)

Alternative zur lokalen Installation: MongoDB Atlas (kostenlos für den Einstieg). MongoDB auf dem Raspberry Pi folgt als optionales Buffet in Lektion 13.

1. **Account erstellen:** <https://www.mongodb.com/atlas>
2. **Cluster erstellen:** Free Tier (M0)
3. **Database User anlegen**
4. **IP Access List:** 0.0.0.0/0 (nur für die Entwicklung!)
5. **Connection String kopieren**

## MongoDB mit Node.js

### Installation

```bash
npm install mongodb
```

### Verbindung herstellen

**Variante A: Einfaches Skript** (siehe Demo-Code in `mongoproject/server.js`)

```javascript
const { MongoClient } = require('mongodb');

// Atlas: Connection String aus dem Atlas-Dashboard
// Lokal: "mongodb://127.0.0.1:27017"
const uri = "mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority";
const client = new MongoClient(uri);

async function connect() {
    try {
        await client.connect();
        console.log("Verbunden mit MongoDB!");

        const database = client.db('library');
        const collection = database.collection('books');

        // ... Operationen hier

    } finally {
        await client.close();
    }
}

connect();
```

**Variante B: Wiederverwendbares Modul** (z.B. für ein Express-Projekt)

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
        console.log('Verbunden mit MongoDB');
        return db;
    } catch (err) {
        console.error('MongoDB-Verbindungsfehler:', err);
        throw err;
    }
}

function getDB() {
    return db;
}

module.exports = { connectDB, getDB };
```

**Hinweis:** Lokal besser `127.0.0.1` statt `localhost` verwenden. Neuere Node.js-Versionen lösen `localhost` oft zu IPv6 (`::1`) auf, während `mongod` standardmässig nur auf IPv4 hört, was zu `ECONNREFUSED` führt.

## CRUD-Operationen in MongoDB

Die folgenden Beispiele verwenden die Variable `collection` aus Variante A (`database.collection('books')`).

### Create (Insert)

```javascript
// Ein Dokument einfügen
const newBook = {
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    isbn: "978-0547928227",
    publicationYear: 1937,
    tags: ["fantasy", "adventure"]
};

const result = await collection.insertOne(newBook);
console.log('Eingefügt mit ID:', result.insertedId);

// Mehrere Dokumente einfügen
const books = [
    { title: "Book 1", author: "Author 1" },
    { title: "Book 2", author: "Author 2" },
    { title: "Book 3", author: "Author 3" }
];

const results = await collection.insertMany(books);
console.log('Anzahl eingefügt:', results.insertedCount);
console.log('Eingefügte IDs:', results.insertedIds);
```

### Read (Find)

```javascript
// Alle Dokumente
const allBooks = await collection.find({}).toArray();

// Mit Filter
const tolkienBooks = await collection.find({
    author: "J.R.R. Tolkien"
}).toArray();

// Ein Dokument
const book = await collection.findOne({
    isbn: "978-0547928227"
});

// Mit mehreren Bedingungen
const recentTolkienBooks = await collection.find({
    publicationYear: { $gte: 1950 },
    author: "J.R.R. Tolkien"
}).toArray();

// Mit Projektion (nur bestimmte Felder)
const bookTitles = await collection.find(
    {},
    { projection: { title: 1, author: 1, _id: 0 } }
).toArray();

// Mit Sortierung und Limit
const newestBooks = await collection
    .find()
    .sort({ publicationYear: -1 })
    .limit(10)
    .toArray();
```

### Query-Operatoren

```javascript
// Vergleichsoperatoren
{ publicationYear: { $gt: 2000 } }      // grösser als
{ publicationYear: { $gte: 2000 } }     // grösser oder gleich
{ publicationYear: { $lt: 2000 } }      // kleiner als
{ publicationYear: { $lte: 2000 } }     // kleiner oder gleich
{ publicationYear: { $ne: 2000 } }      // nicht gleich
{ publicationYear: { $in: [1937, 1954, 1955] } }  // in Liste

// Logische Operatoren
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

// Array-Operatoren
{ tags: "fantasy" }                     // enthält "fantasy"
{ tags: { $all: ["fantasy", "adventure"] } }  // enthält beide
{ tags: { $size: 2 } }                  // Array-Länge = 2

// Suche mit regulärem Ausdruck
{ title: /Hobbit/i }                    // Regex (Gross-/Kleinschreibung ignoriert)
```

### Update

```javascript
// Ein Dokument aktualisieren
const updateResult = await collection.updateOne(
    { isbn: "978-0547928227" },
    {
        $set: {
            publicationYear: 1938,
            lastModified: new Date()
        }
    }
);
console.log('Geändert:', updateResult.modifiedCount);

// Mehrere Dokumente aktualisieren
await collection.updateMany(
    { author: "J.R.R. Tolkien" },
    { $set: { genre: "Fantasy" } }
);

// Array-Operationen
await collection.updateOne(
    { isbn: "978-0547928227" },
    { $push: { tags: "classic" } }  // Element hinzufügen
);

await collection.updateOne(
    { isbn: "978-0547928227" },
    { $pull: { tags: "adventure" } }  // Element entfernen
);

// Increment
await collection.updateOne(
    { isbn: "978-0547928227" },
    { $inc: { viewCount: 1 } }  // Zähler erhöhen
);
```

### Delete

```javascript
// Ein Dokument löschen
const deleteResult = await collection.deleteOne({
    isbn: "978-0547928227"
});
console.log('Gelöscht:', deleteResult.deletedCount);

// Mehrere Dokumente löschen
await collection.deleteMany({
    publicationYear: { $lt: 1900 }
});

// Alle Dokumente löschen
await collection.deleteMany({});
```

## MongoDB Aggregation Pipeline

Die Aggregation Pipeline ist die Antwort von MongoDB auf SQL `GROUP BY` und komplexe Abfragen. Die Dokumente durchlaufen nacheinander mehrere Stufen (Stages).

### Beispiel: Bücher pro Autor zählen

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

### Wichtige Pipeline-Stages

```javascript
// $match - Filtern (wie WHERE)
{ $match: { publicationYear: { $gte: 2000 } } }

// $group - Gruppieren (wie GROUP BY)
{
    $group: {
        _id: "$author",
        avgYear: { $avg: "$publicationYear" }
    }
}

// $sort - Sortieren (wie ORDER BY)
{ $sort: { publicationYear: -1 } }

// $limit - Begrenzen (wie LIMIT)
{ $limit: 10 }

// $project - Felder auswählen (wie SELECT)
{
    $project: {
        title: 1,
        author: 1,
        _id: 0
    }
}

// $lookup - Join
{
    $lookup: {
        from: "authors",
        localField: "author_id",
        foreignField: "_id",
        as: "author_details"
    }
}
```

### SQL vs. MongoDB Aggregation

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

## Datenmodellierung in MongoDB

### 1. Embedding (Einbetten)

Verwenden, wenn:

- Daten zusammengehören (1:1 oder 1:N mit wenigen N)
- Daten meist zusammen gelesen werden
- Daten sich selten ändern
- Keine Referenzen von aussen nötig sind

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

**Vorteile:**

- Schneller Zugriff (1 Abfrage)
- Atomare Updates

**Nachteile:**

- Dokumente können gross werden (16 MB Limit!)
- Redundanz bei mehrfacher Verwendung

### 2. Referencing (Referenzieren)

Verwenden, wenn:

- Viele Beziehungen bestehen (1:N mit sehr vielen N oder N:M)
- Daten unabhängig voneinander aktualisiert werden oder sich oft ändern
- Daten einzeln abgefragt werden

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

**Lookup in Node.js (zwei Abfragen):**

```javascript
const book = await booksCollection.findOne({ _id: "book1" });
const author = await authorsCollection.findOne({ _id: book.author_id });

book.author = author;
```

**Aggregation Pipeline (wie ein JOIN):**

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

## Vergleich SQL vs. MongoDB

### Datenstruktur

**SQL (HFTM Library, vereinfacht):**

```sql
-- Tabelle: authors (zuerst anlegen, da books darauf verweist)
CREATE TABLE authors (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Tabelle: books
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
// Collection: books (mit eingebettetem Dokument)
{
    "_id": ObjectId("..."),
    "title": "Book Title",
    "publicationYear": 2021,
    "author": {
        "name": "John Doe",
        "email": "john@example.com"
    }
}

// Oder mit Referenz
{
    "_id": ObjectId("..."),
    "title": "Book Title",
    "publicationYear": 2021,
    "author_id": ObjectId("...")
}
```

### Abfragen

**SQL:**

```sql
SELECT b.title, a.name
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE b.publication_year > 2020;
```

**MongoDB (mongosh):**

```javascript
// Mit eingebetteten Dokumenten (kein JOIN nötig)
db.books.find(
    { publicationYear: { $gt: 2020 } },
    { title: 1, 'author.name': 1 }
);

// Mit Referenz (Aggregation)
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

**Mongoose** ist ein Object Document Mapper (ODM) für MongoDB. Es ergänzt MongoDB um Schemas, Validierung und Models.

```bash
npm install mongoose
```

### Schema und Model

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
// app.js - Verbindung herstellen
const mongoose = require('mongoose');

mongoose.connect('mongodb://127.0.0.1:27017/library')
    .then(() => console.log('MongoDB verbunden'))
    .catch(err => console.error('Verbindungsfehler:', err));
```

### CRUD mit Mongoose

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

// Oder mit findByIdAndUpdate (gibt das aktualisierte Dokument zurück)
const updated = await Book.findByIdAndUpdate(
    bookId,
    { price: 29.99 },
    { new: true }
);

// DELETE
await Book.deleteOne({ _id: bookId });
// oder
await Book.findByIdAndDelete(bookId);
```

### Validierung

```javascript
// Validierung mit Mongoose
const bookSchema = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Titel ist erforderlich'],
        minlength: [3, 'Titel muss mindestens 3 Zeichen lang sein'],
        maxlength: [200, 'Titel darf höchstens 200 Zeichen lang sein']
    },
    price: {
        type: Number,
        min: [0, 'Preis darf nicht negativ sein'],
        validate: {
            validator: function(v) {
                return v >= 0 && v <= 10000;
            },
            message: 'Preis muss zwischen 0 und 10000 liegen'
        }
    },
    email: {
        type: String,
        match: [/^\S+@\S+\.\S+$/, 'Ungültiges E-Mail-Format']
    }
});
```

## Wann SQL, wann NoSQL?

### Verwende SQL, wenn:

✅ **Strukturierte Daten mit klaren Beziehungen**

- Bankensysteme
- ERP- und CRM-Systeme
- Reservationssysteme

✅ **ACID-Transaktionen erforderlich**

- Finanztransaktionen
- Bestellsysteme, E-Commerce (Bestellungen, Zahlungen)
- Inventarverwaltung

✅ **Komplexe Abfragen und Joins**

- Reporting
- Business Intelligence
- Datenanalyse

✅ **Schema-Stabilität und referentielle Integrität**

- Langfristige Projekte mit wenigen Änderungen

### Verwende NoSQL, wenn:

✅ **Flexible Schemas**

- Unstrukturierte oder semi-strukturierte Daten
- Schnell wechselnde Anforderungen, Prototyping
- Content-Management, Produktkataloge

✅ **Grosse Datenmengen (Big Data)**

- Social-Media-Daten (Posts, Kommentare)
- IoT-Sensordaten
- Log-Daten und Analytics

✅ **Horizontale Skalierung nötig**

- Hoher Traffic, schnelle Lese-/Schreibzugriffe
- Geografisch verteilte Systeme

✅ **Einfache Datenmodelle**

- Dokumente ohne viele Beziehungen
- Key-Value-Paare
- Hierarchische Daten

### Vor- und Nachteile

**SQL - Vorteile:**

- ✅ ACID garantiert
- ✅ Komplexe Beziehungen
- ✅ Etablierter Standard
- ✅ Ausgereifte Werkzeuge

**SQL - Nachteile:**

- ❌ Starres Schema
- ❌ Horizontale Skalierung schwierig
- ❌ Performance bei sehr grossen Datenmengen

**NoSQL (MongoDB) - Vorteile:**

- ✅ Flexibles Schema
- ✅ Horizontale Skalierung
- ✅ Hohe Performance
- ✅ Schnelle Entwicklung

**NoSQL (MongoDB) - Nachteile:**

- ❌ Keine nativen JOINs (nur `$lookup`)
- ❌ Eventual Consistency, z.B. beim Lesen von Secondary-Knoten
- ❌ Datenredundanz
- ❌ Multi-Dokument-Transaktionen erst seit Version 4.0 und aufwändiger als in SQL

## Polyglot Persistence

Moderne Anwendungen nutzen oft **mehrere Datenbanktypen** gleichzeitig: **SQL und NoSQL** in derselben Applikation!

### Beispiel-Architektur

```text
Web-Applikation
├── MySQL/MariaDB → transaktionale Daten
│   ├── Users (Authentifizierung)
│   ├── Orders (Transaktionen)
│   └── Payments (ACID wichtig)
├── MongoDB → flexible Daten
│   ├── Products (Katalog)
│   ├── Reviews (Kommentare)
│   └── Logs (Analytics)
├── Redis → Session-Management, Caching
└── Elasticsearch → Volltextsuche
```

### Implementierung

```javascript
// config/databases.js
const mysql = require('mysql2/promise');
const mongoose = require('mongoose');

// MySQL/MariaDB-Verbindung
const mysqlPool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DB
});

// MongoDB-Verbindung
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

        // 1. Produkt aus MongoDB lesen
        const product = await Product.findById(productId);
        if (!product) {
            return res.status(404).json({ error: 'Produkt nicht gefunden' });
        }

        // 2. Bestellung in MySQL/MariaDB anlegen
        const [result] = await mysqlPool.query(
            'INSERT INTO orders (user_id, product_id, quantity, total) VALUES (?, ?, ?, ?)',
            [userId, productId, quantity, product.price * quantity]
        );

        res.status(201).json({ orderId: result.insertId });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Fehler beim Erstellen der Bestellung' });
    }
};
```

## Praktische Übungen

### Übung 1: MongoDB-Setup

1. MongoDB lokal installieren oder einen MongoDB Atlas Account mit einem Free Cluster erstellen
2. Testdatenbank anlegen
3. Mit Node.js verbinden
4. Eine Collection erstellen und Testdaten einfügen

### Übung 2: CRUD-Operationen

Erstelle eine kleine Bibliotheks-Anwendung mit MongoDB:

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

Implementiere:

1. Buch hinzufügen
2. Alle Bücher auflisten
3. Bücher nach Autor suchen
4. Buch als ausgeliehen markieren
5. Bücher mit Tag "fantasy" finden

### Übung 3: CRUD-API mit Mongoose

Erstelle eine REST-API mit:

- Collection: `products`
- Endpoints: GET, POST, PUT, DELETE
- Verwendung von Mongoose (Schema mit Validierung)

### Übung 4: Embedding vs. Referencing

Modelliere ein Blog-System in MongoDB auf zwei Arten:

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

Diskutiere Vor- und Nachteile beider Ansätze.

### Übung 5: Aggregation Pipeline

Gegeben ist eine E-Commerce-Collection `orders`:

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

Erstelle Aggregation-Abfragen für:

1. Gesamtumsatz pro Kunde
2. Top 5 der meistverkauften Produkte
3. Durchschnittlicher Bestellwert pro Monat
4. Anzahl Bestellungen nach Status

### Übung 6: Datenmigration

1. Die Tabellen `books` und `authors` aus der HFTM Library DB (MariaDB/MySQL) exportieren
2. Die Daten ins MongoDB-Format umwandeln (z.B. Autor als eingebettetes Dokument)
3. In MongoDB importieren
4. Abfragen und Performance vergleichen

### Übung 7: Hybride Applikation

Erstelle eine Applikation, die Folgendes verwendet:

- MySQL/MariaDB für `users` und `orders`
- MongoDB für `products` und `reviews`

## MongoDB Best Practices

### 1. Index-Strategie

```javascript
// Index für häufige Abfragen erstellen
await collection.createIndex({ author: 1 });
await collection.createIndex({ isbn: 1 }, { unique: true });

// Compound Index
await collection.createIndex({ author: 1, publicationYear: -1 });

// Text-Index für Volltextsuche
await collection.createIndex({ title: "text", description: "text" });

// Mit Mongoose (im Schema definiert)
bookSchema.index({ title: 1 });
bookSchema.index({ author: 1, publicationYear: -1 });
```

### 2. Schema Design Patterns

**Pattern 1: Subset Pattern** - nur relevante Daten einbetten:

```javascript
{
    "movie": "Inception",
    "cast": [
        { "name": "Leonardo DiCaprio", "role": "Cobb" }
        // Nur die Hauptbesetzung, nicht alle Details
    ]
}
```

**Pattern 2: Computed Pattern** - vorberechnete Werte speichern:

```javascript
{
    "product": "Laptop",
    "reviews": [ /* ... */ ],
    "avgRating": 4.5,  // vorberechnet
    "reviewCount": 127
}
```

### 3. Dokumentgrösse beachten

- Maximum: 16 MB pro Dokument
- Bei grossen oder unbegrenzt wachsenden Arrays: Referencing verwenden
- Grosse Dateien: GridFS verwenden

### 4. Connection Pooling

```javascript
const client = new MongoClient(uri, {
    maxPoolSize: 10,
    minPoolSize: 2
});
```

## Zusammenfassung

### Die richtige Datenbank wählen

**SQL verwenden, wenn:**

- Die Datenstruktur klar und stabil ist
- Komplexe Beziehungen wichtig sind
- ACID-Transaktionen entscheidend sind
- Referentielle Integrität nötig ist

**NoSQL verwenden, wenn:**

- Ein flexibles Schema nötig ist
- Horizontale Skalierung wichtig ist
- Grosse Datenmengen anfallen
- Schnelle Lese-/Schreibzugriffe Priorität haben

**Beide verwenden, wenn:**

- Eine komplexe Applikation unterschiedliche Anforderungen hat
- Gewisse Daten ACID benötigen
- Andere Daten Flexibilität benötigen

## Hausaufgaben

1. **MongoDB installieren** (lokal oder Atlas)
2. **Eine MongoDB-API** für eine Entität erstellen
3. **Performance vergleichen:** SQL vs. NoSQL
4. **Entscheiden**, welche Datenbank für das eigene Projekt verwendet wird

## Checkliste für Credit 9

- [ ] MongoDB installiert oder MongoDB Atlas Account erstellt
- [ ] Verbindung zu MongoDB mit Node.js funktioniert
- [ ] CRUD-Operationen implementiert
- [ ] Aggregation Pipeline verwendet
- [ ] Embedding vs. Referencing verstanden
- [ ] Dokumentation der Lösungen

## Zusätzliche Ressourcen

- [MongoDB Dokumentation](https://www.mongodb.com/docs/)
- [Mongoose Dokumentation](https://mongoosejs.com/)
- [MongoDB University (kostenlose Kurse)](https://learn.mongodb.com/)
- [MongoDB Schema Design Best Practices](https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design)
- [SQL vs. NoSQL Guide](https://www.mongodb.com/nosql-explained/nosql-vs-sql)

## Nächste Schritte

In Lektion 11 schauen wir uns Frameworks für JavaScript an, die uns helfen, strukturierten Code mit dem MVC-Pattern zu schreiben, sowie ORMs für einen effizienteren Datenbankzugriff:

- Express-Frameworks und MVC-Pattern
- ORM: Sequelize für SQL
- Datenbank-Migrationen
- Vergleich ORM vs. reines SQL
