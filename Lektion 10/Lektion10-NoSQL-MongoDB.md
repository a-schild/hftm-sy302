# Lektion 10: NoSQL & MongoDB Basics

## Lernziele

- Die Unterschiede zwischen SQL und NoSQL Datenbanken verstehen
- Die verschiedenen NoSQL-Datenbanktypen kennen
- MongoDB grundlegend bedienen können
- Wissen, wann NoSQL und wann SQL eingesetzt werden sollte

## Was ist NoSQL?

**NoSQL** = "Not only SQL" (nicht "No SQL"!)

NoSQL-Datenbanken sind Datenbanksysteme, die **nicht** auf dem relationalen Modell basieren.

### Entstehung

- Entwickelt für Web-Scale Anwendungen (Google, Facebook, Amazon)
- Bedarf an horizontaler Skalierung
- Flexible Datenstrukturen
- Hohe Performance bei großen Datenmengen

## SQL vs. NoSQL

| Aspekt | SQL (Relational) | NoSQL |
|--------|------------------|-------|
| **Datenmodell** | Tabellen mit festen Schemas | Flexibel (Dokumente, Key-Value, etc.) |
| **Schema** | Starr, vordefiniert | Flexibel, dynamisch |
| **Skalierung** | Vertikal (größerer Server) | Horizontal (mehr Server) |
| **Transaktionen** | ACID-Garantien | Oft eventual consistency |
| **Joins** | Ja, effizient | Meist nicht, oder teuer |
| **Beziehungen** | Stark strukturiert (FK) | Schwach oder eingebettet |
| **Query Language** | SQL (standardisiert) | Proprietär je nach System |
| **Beispiele** | MySQL, PostgreSQL, MariaDB | MongoDB, Redis, Cassandra |

### ACID vs. BASE

**ACID (SQL):**
- **A**tomicity: Alles oder nichts
- **C**onsistency: Daten immer konsistent
- **I**solation: Transaktionen unabhängig
- **D**urability: Daten dauerhaft gespeichert

**BASE (NoSQL):**
- **B**asically **A**vailable: System meist verfügbar
- **S**oft state: Zustand kann sich ändern
- **E**ventual consistency: Konsistenz wird irgendwann erreicht

## NoSQL-Datenbanktypen

### 1. Document Stores (Dokument-orientiert)

**Beispiele:** MongoDB, CouchDB

**Datenmodell:** JSON-ähnliche Dokumente

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
- Keine Joins
- Redundanz bei Beziehungen

### 2. Key-Value Stores

**Beispiele:** Redis, DynamoDB

**Datenmodell:** Einfache Schlüssel-Wert-Paare

```
user:1001 → {"name": "John", "email": "john@example.com"}
session:abc123 → {"userId": 1001, "expires": "2024-12-31"}
```

**Verwendung:**
- Caching
- Session-Management
- Real-time Anwendungen

### 3. Column-Family Stores

**Beispiele:** Cassandra, HBase

**Datenmodell:** Spalten in Familien gruppiert

```
Row Key: user123
├─ PersonalInfo
│  ├─ name: "John Doe"
│  └─ email: "john@example.com"
└─ Preferences
   ├─ language: "de"
   └─ theme: "dark"
```

**Verwendung:**
- Big Data Analytics
- Time-series Daten

### 4. Graph Databases

**Beispiele:** Neo4j, ArangoDB

**Datenmodell:** Knoten und Kanten

```
(Person:John)-[:KNOWS]->(Person:Jane)
(Person:John)-[:WORKS_AT]->(Company:HFTM)
```

**Verwendung:**
- Social Networks
- Empfehlungssysteme
- Netzwerkanalyse

## MongoDB - Einführung

MongoDB ist eine dokumentenorientierte NoSQL-Datenbank.

### Wichtige Konzepte

| SQL | MongoDB |
|-----|---------|
| Database | Database |
| Table | Collection |
| Row | Document |
| Column | Field |
| Primary Key | _id (automatisch) |
| JOIN | Embedding oder Referencing |

### MongoDB Atlas Setup

1. **Account erstellen:** https://www.mongodb.com/cloud/atlas
2. **Cluster erstellen:** (Free Tier M0)
3. **Database User anlegen**
4. **IP Whitelist:** 0.0.0.0/0 (für Entwicklung)
5. **Connection String kopieren**

### Installation für lokale Entwicklung

**Alternative 1: MongoDB Community Server**
```bash
# Download von mongodb.com
# Installation durchführen
```

**Alternative 2: MongoDB Compass (GUI)**
- Download: https://www.mongodb.com/products/compass
- Grafische Oberfläche für MongoDB

## MongoDB mit Node.js

### Installation

```bash
npm install mongodb
```

### Verbindung herstellen

```javascript
const { MongoClient } = require('mongodb');

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

### Alternative: Mongoose ODM

Mongoose ist ein Object Document Mapper (ODM) für MongoDB.

```bash
npm install mongoose
```

```javascript
const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/library')
    .then(() => console.log('MongoDB verbunden'))
    .catch(err => console.error('Verbindungsfehler:', err));

// Schema definieren
const bookSchema = new mongoose.Schema({
    title: { type: String, required: true },
    author: { type: String, required: true },
    isbn: String,
    publicationYear: Number,
    tags: [String]
});

// Model erstellen
const Book = mongoose.model('Book', bookSchema);
```

## CRUD Operationen in MongoDB

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
    { title: "Book 2", author: "Author 2" }
];

const results = await collection.insertMany(books);
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

// Mit Projektion (nur bestimmte Felder)
const bookTitles = await collection.find(
    {},
    { projection: { title: 1, author: 1, _id: 0 } }
).toArray();

// Mit Bedingungen
const recentBooks = await collection.find({
    publicationYear: { $gte: 2000 }
}).toArray();
```

### Query Operators

```javascript
// Vergleichsoperatoren
{ publicationYear: { $gt: 2000 } }      // größer als
{ publicationYear: { $gte: 2000 } }     // größer oder gleich
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

// Array Operatoren
{ tags: "fantasy" }                     // enthält "fantasy"
{ tags: { $all: ["fantasy", "adventure"] } }  // enthält beide
{ tags: { $size: 2 } }                  // Array-Länge = 2

// Text-Suche
{ title: /Hobbit/i }                    // Regex (case-insensitive)
```

### Update

```javascript
// Ein Dokument aktualisieren
await collection.updateOne(
    { isbn: "978-0547928227" },
    { 
        $set: { 
            publicationYear: 1938,
            lastModified: new Date()
        } 
    }
);

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
await collection.deleteOne({ 
    isbn: "978-0547928227" 
});

// Mehrere Dokumente löschen
await collection.deleteMany({ 
    publicationYear: { $lt: 1900 } 
});

// Alle Dokumente löschen
await collection.deleteMany({});
```

## Datenmodellierung in MongoDB

### 1. Embedding (Einbetten)

Verwenden, wenn:
- Daten zusammengehören (1:1 oder 1:N mit wenigen N)
- Daten meist zusammen gelesen werden
- Keine Referenzen von außen nötig

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
- Schneller Zugriff (1 Query)
- Atomare Updates

**Nachteile:**
- Dokumente können groß werden (16MB Limit!)
- Redundanz bei mehrfacher Verwendung

### 2. Referencing (Referenzieren)

Verwenden, wenn:
- Viele Beziehungen (1:N mit vielen N oder M:N)
- Daten werden unabhängig voneinander aktualisiert
- Daten werden einzeln abgefragt

```json
// Books Collection
{
    "_id": "book1",
    "title": "Clean Code",
    "author_id": "author1",
    "isbn": "978-0132350884"
}

// Authors Collection
{
    "_id": "author1",
    "name": "Robert C. Martin",
    "country": "USA",
    "birthYear": 1952
}
```

**Lookup in Node.js:**
```javascript
const book = await booksCollection.findOne({ _id: "book1" });
const author = await authorsCollection.findOne({ _id: book.author_id });

book.author = author;
```

**Aggregation Pipeline (wie JOIN):**
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

## MongoDB Aggregation Pipeline

Die Aggregation Pipeline ist MongoDB's Antwort auf SQL GROUP BY und komplexe Queries.

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

### Wichtige Pipeline Stages

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
SELECT author, COUNT(*) as count, AVG(publication_year) as avg_year
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

## Wann SQL, wann NoSQL?

### Verwende SQL wenn:

✅ **Strukturierte Daten mit klaren Beziehungen**
- Bankensysteme
- ERP-Systeme
- CRM-Systeme

✅ **ACID-Transaktionen erforderlich**
- Finanz-Transaktionen
- Bestellsysteme
- Inventarverwaltung

✅ **Komplexe Queries und Joins**
- Reporting
- Business Intelligence
- Datenanalyse

✅ **Schema-Stabilität**
- Langfristige Projekte mit wenigen Änderungen

### Verwende NoSQL wenn:

✅ **Flexible Schemas**
- Schnell wechselnde Anforderungen
- Prototyping
- Content Management

✅ **Große Datenmengen (Big Data)**
- Social Media Daten
- IoT-Sensordaten
- Log-Daten

✅ **Horizontale Skalierung nötig**
- Hoher Traffic
- Geografisch verteilte Systeme

✅ **Einfache Datenmodelle**
- Dokumente ohne viele Beziehungen
- Key-Value Paare
- Hierarchische Daten

## Polyglot Persistence

Moderne Anwendungen nutzen oft **mehrere Datenbanktypen** gleichzeitig:

```
Web-Application
├── MySQL/PostgreSQL → Transaktionale Daten (Bestellungen, Nutzer)
├── MongoDB → Produktkatalog, Content
├── Redis → Session-Management, Caching
└── Elasticsearch → Volltextsuche
```

## Praktische Übungen

### Übung 1: MongoDB Atlas Setup

1. MongoDB Atlas Account erstellen
2. Free Cluster erstellen
3. Testdatenbank anlegen
4. Mit Node.js verbinden
5. Testdaten einfügen

### Übung 2: CRUD Operationen

Erstelle eine kleine Bibliotheks-Anwendung mit MongoDB:

```javascript
// books Collection
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

### Übung 3: Embedding vs. Referencing

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
```json
// Posts Collection
{
    "title": "My Blog Post",
    "content": "...",
    "author_id": "author1"
}

// Authors Collection
{
    "_id": "author1",
    "name": "John",
    "email": "john@example.com"
}

// Comments Collection
{
    "post_id": "post1",
    "user": "Jane",
    "text": "Great post!",
    "date": "2024-10-10"
}
```

Diskutiere Vor- und Nachteile beider Ansätze.

### Übung 4: Aggregation Pipeline

Gegeben ist eine E-Commerce Orders Collection:

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

Erstelle Aggregation Queries für:
1. Gesamtumsatz pro Kunde
2. Top 5 meistverkaufte Produkte
3. Durchschnittlicher Bestellwert pro Monat
4. Anzahl Bestellungen nach Status

## MongoDB Best Practices

### 1. Index Strategy

```javascript
// Index erstellen für häufige Queries
await collection.createIndex({ author: 1 });
await collection.createIndex({ isbn: 1 }, { unique: true });

// Compound Index
await collection.createIndex({ author: 1, publicationYear: -1 });

// Text Index für Volltextsuche
await collection.createIndex({ title: "text", content: "text" });
```

### 2. Schema Design Patterns

**Pattern 1: Subset Pattern**
Nur relevante Daten einbetten:
```json
{
    "movie": "Inception",
    "cast": [
        { "name": "Leonardo DiCaprio", "role": "Cobb" }
        // Nur Haupt-Cast, nicht alle Details
    ]
}
```

**Pattern 2: Computed Pattern**
Vorberechnete Werte speichern:
```json
{
    "product": "Laptop",
    "reviews": [...],
    "avgRating": 4.5,  // Vorberechnet
    "reviewCount": 127
}
```

### 3. Document Size beachten

- Maximum: 16MB pro Dokument
- Bei großen Arrays: Referencing verwenden
- Große Dateien: GridFS verwenden

### 4. Connection Pooling

```javascript
const client = new MongoClient(uri, {
    maxPoolSize: 10,
    minPoolSize: 2
});
```

## Checkliste für Credit 9

- [ ] MongoDB Atlas Account erstellt
- [ ] Verbindung zu MongoDB mit Node.js funktioniert
- [ ] CRUD-Operationen implementiert
- [ ] Aggregation Pipeline verwendet
- [ ] Embedding vs. Referencing verstanden
- [ ] Dokumentation der Lösungen

## Zusätzliche Ressourcen

- [MongoDB University (kostenlose Kurse)](https://university.mongodb.com/)
- [MongoDB Dokumentation](https://docs.mongodb.com/)
- [Mongoose Dokumentation](https://mongoosejs.com/)
- [MongoDB Schema Design Best Practices](https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design)

## Nächste Schritte

In Lektion 11 schauen wir uns Frameworks für JavaScript an, die uns helfen, strukturierten Code mit MVC-Pattern zu schreiben, und ORMs für effizienteren Datenbankzugriff.
