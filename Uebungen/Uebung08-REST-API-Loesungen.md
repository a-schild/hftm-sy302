# Übung 8: REST API mit Express - Lösungen (Teil 2)

## Fortsetzung: DELETE Endpoint und erweiterte Features

```javascript
// DELETE /api/books/:id - Fortsetzung
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        // Validierung
        if (!id || isNaN(id)) {
            return res.status(400).json({ error: 'Invalid book ID' });
        }
        
        // Prüfe ob Buch existiert
        const [existing] = await pool.query(
            'SELECT id FROM books WHERE id = ?',
            [id]
        );
        
        if (existing.length === 0) {
            return res.status(404).json({ error: 'Book not found' });
        }
        
        // Lösche Buch
        await pool.query('DELETE FROM books WHERE id = ?', [id]);
        
        res.status(204).send();
        
    } catch (err) {
        console.error('Error in DELETE /api/books/:id:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;
```

**Bewertung Aufgabe 2:**
- 1.5 Punkte: GET /api/books (mit Pagination)
- 1 Punkt: GET /api/books/:id (mit Validierung)
- 1.5 Punkte: POST /api/books (mit Validierung & Error Handling)
- 1 Punkt: PUT /api/books/:id (mit Validierung)
- 1 Punkt: DELETE /api/books/:id (mit Existenz-Check)

---

### Aufgabe 3: JOIN Endpoint (2 Punkte)

**Aufgabe:** Erstelle einen Endpoint der Bücher mit Autoren-Information zurückgibt.

**Lösung in routes/bookRoutes.js ergänzen:**

```javascript
// ==========================================
// GET /api/books/with-authors - Bücher mit Autoren
// ==========================================
router.get('/with-authors', async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 20;
        const offset = parseInt(req.query.offset) || 0;
        
        const [books] = await pool.query(`
            SELECT 
                b.id,
                b.title,
                b.isbn,
                b.price,
                b.author_id,
                CONCAT(a.firstname, ' ', a.lastname) AS author_name,
                a.firstname AS author_firstname,
                a.lastname AS author_lastname,
                a.birthdate AS author_birthdate
            FROM books b
            INNER JOIN authors a ON b.author_id = a.id
            ORDER BY b.title
            LIMIT ? OFFSET ?
        `, [limit, offset]);
        
        // Count total
        const [countResult] = await pool.query(`
            SELECT COUNT(*) as total 
            FROM books b
            INNER JOIN authors a ON b.author_id = a.id
        `);
        
        res.json({
            data: books,
            pagination: {
                total: countResult[0].total,
                limit: limit,
                offset: offset,
                returned: books.length
            }
        });
        
    } catch (err) {
        console.error('Error in GET /api/books/with-authors:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});
```

**WICHTIG:** Diese Route muss VOR `router.get('/:id')` stehen, sonst wird "with-authors" als ID interpretiert!

**Korrekte Reihenfolge in bookRoutes.js:**
```javascript
// 1. Spezifische Routes zuerst
router.get('/with-authors', ...);

// 2. Dann parametrisierte Routes
router.get('/:id', ...);
```

**Bewertung Aufgabe 3:**
- 2 Punkte: JOIN Endpoint funktioniert, liefert korrekte Daten mit Author-Info

---

## Testing mit Postman

### Postman Collection erstellen

**1. Collection Setup:**
- Neue Collection: "Library API"
- Base URL Variable: `{{base_url}}` = `http://localhost:3000`

**2. Requests:**

#### 2.1 GET All Books
```
GET {{base_url}}/api/books
```

Query Parameters:
- `limit`: 10
- `offset`: 0

**Expected Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "author_id": 1,
      "isbn": "978-0-7432-7356-5",
      "price": 15.99
    }
  ],
  "pagination": {
    "total": 20,
    "limit": 10,
    "offset": 0,
    "returned": 10
  }
}
```

#### 2.2 GET Single Book
```
GET {{base_url}}/api/books/1
```

**Expected Response (200):**
```json
{
  "id": 1,
  "title": "The Great Gatsby",
  "author_id": 1,
  "isbn": "978-0-7432-7356-5",
  "price": 15.99
}
```

#### 2.3 POST Create Book
```
POST {{base_url}}/api/books
Content-Type: application/json
```

**Body:**
```json
{
  "title": "Test Book from Postman",
  "author_id": 1,
  "isbn": "978-1-234-56789-0",
  "price": 29.99
}
```

**Expected Response (201):**
```json
{
  "id": 21,
  "title": "Test Book from Postman",
  "author_id": 1,
  "isbn": "978-1-234-56789-0",
  "price": 29.99
}
```

#### 2.4 PUT Update Book
```
PUT {{base_url}}/api/books/21
Content-Type: application/json
```

**Body:**
```json
{
  "title": "Updated Test Book",
  "price": 34.99
}
```

**Expected Response (200):**
```json
{
  "id": 21,
  "title": "Updated Test Book",
  "author_id": 1,
  "isbn": "978-1-234-56789-0",
  "price": 34.99
}
```

#### 2.5 DELETE Book
```
DELETE {{base_url}}/api/books/21
```

**Expected Response (204 No Content)**

#### 2.6 GET Books with Authors
```
GET {{base_url}}/api/books/with-authors?limit=5
```

**Expected Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "isbn": "978-0-7432-7356-5",
      "price": 15.99,
      "author_id": 1,
      "author_name": "F. Scott Fitzgerald",
      "author_firstname": "F. Scott",
      "author_lastname": "Fitzgerald",
      "author_birthdate": "1896-09-24"
    }
  ],
  "pagination": {
    "total": 20,
    "limit": 5,
    "offset": 0,
    "returned": 5
  }
}
```

---

### Error Cases Testing

#### Invalid ID
```
GET {{base_url}}/api/books/abc
```
**Expected Response (400):**
```json
{
  "error": "Invalid book ID"
}
```

#### Book Not Found
```
GET {{base_url}}/api/books/9999
```
**Expected Response (404):**
```json
{
  "error": "Book not found"
}
```

#### Missing Required Fields
```
POST {{base_url}}/api/books
Content-Type: application/json

{
  "isbn": "123"
}
```
**Expected Response (400):**
```json
{
  "error": "Missing required fields",
  "required": ["title", "author_id"]
}
```

#### Invalid Author
```
POST {{base_url}}/api/books
Content-Type: application/json

{
  "title": "Test Book",
  "author_id": 9999
}
```
**Expected Response (400):**
```json
{
  "error": "Author not found",
  "author_id": 9999
}
```

---

## Komplettes Test-Script

**Erstelle: test-api.js**

```javascript
// test-api.js
const axios = require('axios');

const API_URL = 'http://localhost:3000/api';
let createdBookId = null;

async function testAPI() {
    console.log('='.repeat(60));
    console.log('REST API TEST');
    console.log('='.repeat(60));
    
    try {
        // 1. Test GET all books
        console.log('\n1️⃣  GET /api/books');
        const getAllRes = await axios.get(`${API_URL}/books?limit=3`);
        console.log(`✅ Status: ${getAllRes.status}`);
        console.log(`✅ Retrieved ${getAllRes.data.data.length} books`);
        console.log(`   Total in DB: ${getAllRes.data.pagination.total}`);
        
        // 2. Test GET single book
        console.log('\n2️⃣  GET /api/books/1');
        const getOneRes = await axios.get(`${API_URL}/books/1`);
        console.log(`✅ Status: ${getOneRes.status}`);
        console.log(`✅ Book: ${getOneRes.data.title}`);
        
        // 3. Test POST create book
        console.log('\n3️⃣  POST /api/books');
        const createRes = await axios.post(`${API_URL}/books`, {
            title: 'API Test Book',
            author_id: 1,
            isbn: 'TEST-API-123',
            price: 25.50
        });
        console.log(`✅ Status: ${createRes.status}`);
        console.log(`✅ Created book ID: ${createRes.data.id}`);
        createdBookId = createRes.data.id;
        
        // 4. Test PUT update book
        console.log('\n4️⃣  PUT /api/books/' + createdBookId);
        const updateRes = await axios.put(`${API_URL}/books/${createdBookId}`, {
            title: 'API Test Book UPDATED',
            price: 30.00
        });
        console.log(`✅ Status: ${updateRes.status}`);
        console.log(`✅ Updated title: ${updateRes.data.title}`);
        console.log(`✅ Updated price: ${updateRes.data.price}`);
        
        // 5. Test GET with authors
        console.log('\n5️⃣  GET /api/books/with-authors');
        const withAuthorsRes = await axios.get(`${API_URL}/books/with-authors?limit=3`);
        console.log(`✅ Status: ${withAuthorsRes.status}`);
        console.log(`✅ Retrieved ${withAuthorsRes.data.data.length} books with authors`);
        withAuthorsRes.data.data.forEach(book => {
            console.log(`   - "${book.title}" by ${book.author_name}`);
        });
        
        // 6. Test DELETE
        console.log('\n6️⃣  DELETE /api/books/' + createdBookId);
        const deleteRes = await axios.delete(`${API_URL}/books/${createdBookId}`);
        console.log(`✅ Status: ${deleteRes.status}`);
        console.log(`✅ Book deleted`);
        
        // 7. Test error case: book not found
        console.log('\n7️⃣  Test Error: Book not found');
        try {
            await axios.get(`${API_URL}/books/99999`);
        } catch (err) {
            console.log(`✅ Status: ${err.response.status} (expected 404)`);
            console.log(`✅ Error: ${err.response.data.error}`);
        }
        
        // 8. Test error case: invalid data
        console.log('\n8️⃣  Test Error: Invalid data');
        try {
            await axios.post(`${API_URL}/books`, {
                isbn: '123'
            });
        } catch (err) {
            console.log(`✅ Status: ${err.response.status} (expected 400)`);
            console.log(`✅ Error: ${err.response.data.error}`);
        }
        
        console.log('\n' + '='.repeat(60));
        console.log('✅ ALL API TESTS SUCCESSFUL!');
        console.log('='.repeat(60));
        
    } catch (err) {
        console.error('\n' + '='.repeat(60));
        console.error('❌ API TEST FAILED:');
        console.error(err.message);
        if (err.response) {
            console.error('Status:', err.response.status);
            console.error('Data:', err.response.data);
        }
        console.error('='.repeat(60));
        
        // Cleanup
        if (createdBookId) {
            try {
                await axios.delete(`${API_URL}/books/${createdBookId}`);
                console.log('🧹 Cleanup: Test book deleted');
            } catch (cleanupErr) {
                // Ignore
            }
        }
    }
}

// Prüfe ob Server läuft
axios.get('http://localhost:3000')
    .then(() => {
        console.log('✅ Server is running, starting tests...\n');
        testAPI();
    })
    .catch(() => {
        console.error('❌ Server is not running! Please start with: npm run dev');
        process.exit(1);
    });
```

**Installiere axios:**
```bash
npm install axios
```

**Test ausführen:**
```bash
node test-api.js
```

---

## Bewertungsraster Credit 8

| Aufgabe | Punkte | Kriterien |
|---------|--------|-----------|
| **1** Express Setup | 2 | Server läuft, Middleware korrekt, Root-Endpoint |
| **2a** GET /api/books | 1.5 | Funktioniert mit Pagination |
| **2b** GET /api/books/:id | 1 | Funktioniert mit Validierung |
| **2c** POST /api/books | 1.5 | Funktioniert mit Validierung & Error Handling |
| **2d** PUT /api/books/:id | 1 | Funktioniert mit Validierung |
| **2e** DELETE /api/books/:id | 1 | Funktioniert mit Existenz-Check |
| **3** JOIN Endpoint | 2 | Bücher mit Autoren-Info |
| **TOTAL** | **10** | |

---

## Abgabe

**Format:** ZIP-Datei mit komplettem Projekt

**Enthält:**
- [ ] Kompletter Code (ohne node_modules/)
- [ ] Postman Collection (exportiert als JSON)
- [ ] Screenshots aller 6 Endpoints getestet in Postman:
  - [ ] GET /api/books
  - [ ] GET /api/books/:id
  - [ ] POST /api/books
  - [ ] PUT /api/books/:id
  - [ ] DELETE /api/books/:id
  - [ ] GET /api/books/with-authors
- [ ] Screenshot von mindestens 2 Error Cases
- [ ] README.md mit API Dokumentation

**Naming:** `Credit8_Vorname_Nachname.zip`

**Deadline:** Siehe Moodle

---

## API Dokumentation Template (README.md)

```markdown
# Library API

REST API für die HFTM Library Datenbank.

## Installation

```bash
npm install
cp .env.example .env
# .env mit Datenbank-Credentials füllen
npm run dev
```

## Endpoints

### GET /api/books
Gibt alle Bücher zurück (mit Pagination).

**Query Parameters:**
- `limit` (optional): Anzahl Einträge (default: 50)
- `offset` (optional): Offset für Pagination (default: 0)

**Response:** 200 OK
```json
{
  "data": [...],
  "pagination": {
    "total": 20,
    "limit": 10,
    "offset": 0,
    "returned": 10
  }
}
```

### GET /api/books/:id
Gibt ein einzelnes Buch zurück.

**Response:** 200 OK / 404 Not Found

### POST /api/books
Erstellt ein neues Buch.

**Body:**
```json
{
  "title": "Book Title",
  "author_id": 1,
  "isbn": "978-...",
  "price": 29.99
}
```

**Response:** 201 Created / 400 Bad Request

### PUT /api/books/:id
Aktualisiert ein Buch.

**Body:**
```json
{
  "title": "New Title",
  "price": 34.99
}
```

**Response:** 200 OK / 404 Not Found

### DELETE /api/books/:id
Löscht ein Buch.

**Response:** 204 No Content / 404 Not Found

### GET /api/books/with-authors
Gibt Bücher mit Autoren-Information zurück.

**Response:** 200 OK
```

---

## Tipps für beste Praxis

✅ **HTTP Status Codes korrekt verwenden:**
- 200: OK (GET, PUT erfolgreich)
- 201: Created (POST erfolgreich)
- 204: No Content (DELETE erfolgreich)
- 400: Bad Request (Validierungsfehler)
- 404: Not Found (Ressource nicht gefunden)
- 500: Internal Server Error (Serverfehler)

✅ **Validierung:**
- Immer Input validieren
- Klare Fehlermeldungen
- Hilfreiche Error Responses

✅ **Error Handling:**
- Try-catch bei allen async Operationen
- Aussagekräftige Fehler loggen
- Nie Stack Traces an Client senden

✅ **Sicherheit:**
- Prepared Statements (SQL Injection Schutz)
- Input Sanitization
- CORS korrekt konfiguriert

---

**Viel Erfolg! 🚀**
