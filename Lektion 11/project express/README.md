# Express.js REST API with MVC & Sequelize ORM

A complete REST API for library management with Express.js, Sequelize ORM and MVC pattern.

## Features

- **MVC Architecture**: Clear separation between Model, View (API), and Controller
- **Sequelize ORM**: Object-Relational Mapping for MySQL/MariaDB
- **Service Layer**: Business logic separated from controllers
- **Validation**: Automatic validation with middleware
- **Error Handling**: Centralized error management
- **REST API**: RESTful endpoints for books, authors and categories
- **Relationships**: 1:N and N:M relationships between entities

## Project Structure

```
project express/
├── src/
│   ├── models/              # Sequelize Models
│   │   ├── Book.js
│   │   ├── Author.js
│   │   ├── Category.js
│   │   └── index.js        # Model Relationships & Sync
│   ├── controllers/         # Request Handlers
│   │   ├── bookController.js
│   │   ├── authorController.js
│   │   └── categoryController.js
│   ├── services/            # Business Logic
│   │   ├── bookService.js
│   │   ├── authorService.js
│   │   └── categoryService.js
│   ├── routes/              # Route Definitions
│   │   ├── books.js
│   │   ├── authors.js
│   │   ├── categories.js
│   │   └── index.js
│   ├── middleware/          # Express Middleware
│   │   ├── errorHandler.js
│   │   └── validator.js
│   └── config/              # Configuration
│       └── database.js
├── .env.example             # Environment Variables Template
├── .gitignore
├── package.json
├── server.js                # Entry Point
└── README.md
```

## Installation

### 1. Clone or download project

```bash
cd "project express"
```

### 2. Install dependencies

```bash
npm install
```

### 3. Create database

Create a MySQL/MariaDB database:

```sql
CREATE DATABASE library_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 4. Configure environment variables

Copy `.env.example` to `.env` and adjust the values:

```bash
cp .env.example .env
```

Edit `.env`:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=library_db
DB_PORT=3306

PORT=3000
NODE_ENV=development
```

### 5. Start server

```bash
# Development with auto-reload
npm run dev

# Production
npm start
```

The API is now running on `http://localhost:3000/api`

## API Endpoints

### Books

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/books` | Get all books |
| GET | `/api/books/:id` | Get a book |
| POST | `/api/books` | Create new book |
| PUT | `/api/books/:id` | Update book |
| DELETE | `/api/books/:id` | Delete book |
| POST | `/api/books/:id/categories` | Add categories to book |
| GET | `/api/books/statistics` | Get statistics |

**Query parameters for GET /api/books:**
- `author` - Filter by author (e.g. `?author=Tolkien`)
- `year` - Filter by publication year (e.g. `?year=1937`)
- `search` - Full-text search in title (e.g. `?search=Hobbit`)
- `limit` - Number of results (default: 50)
- `offset` - Offset for pagination (default: 0)

### Authors

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/authors` | Get all authors |
| GET | `/api/authors/:id` | Get an author |
| POST | `/api/authors` | Create new author |
| PUT | `/api/authors/:id` | Update author |
| DELETE | `/api/authors/:id` | Delete author |
| GET | `/api/authors/:id/books` | Get books by author |

**Query parameters for GET /api/authors:**
- `country` - Filter by country (e.g. `?country=England`)
- `search` - Full-text search in name (e.g. `?search=Tolkien`)
- `withBooks` - Include books (e.g. `?withBooks=true`)
- `limit` - Number of results (default: 50)
- `offset` - Offset for pagination (default: 0)

### Categories

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | Get all categories |
| GET | `/api/categories/:id` | Get a category |
| POST | `/api/categories` | Create new category |
| PUT | `/api/categories/:id` | Update category |
| DELETE | `/api/categories/:id` | Delete category |

**Query parameters for GET /api/categories:**
- `withBooks` - Include books (e.g. `?withBooks=true`)
- `limit` - Number of results (default: 50)
- `offset` - Offset for pagination (default: 0)

## API Examples

### Create book

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit",
    "author_id": 1,
    "isbn": "978-3-423-21212-0",
    "publication_year": 1937,
    "pages": 336,
    "categories": [1, 2]
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Book successfully created",
  "data": {
    "book_id": 1,
    "title": "The Hobbit",
    "author_id": 1,
    "isbn": "978-3-423-21212-0",
    "publication_year": 1937,
    "pages": 336,
    "author": {
      "author_id": 1,
      "name": "J.R.R. Tolkien",
      "country": "England"
    },
    "categories": [
      {
        "category_id": 1,
        "name": "Fantasy"
      },
      {
        "category_id": 2,
        "name": "Adventure"
      }
    ]
  }
}
```

### Create author

```bash
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "J.R.R. Tolkien",
    "country": "England",
    "birth_year": 1892
  }'
```

### Create category

```bash
curl -X POST http://localhost:3000/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fantasy",
    "description": "Fantasy and fantastical literature"
  }'
```

### Get all books with filter

```bash
# Filter by author
curl http://localhost:3000/api/books?author=Tolkien

# Filter by year
curl http://localhost:3000/api/books?year=1937

# Full-text search
curl http://localhost:3000/api/books?search=Hobbit

# Pagination
curl http://localhost:3000/api/books?limit=10&offset=0
```

### Update book

```bash
curl -X PUT http://localhost:3000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit - Extended Edition",
    "pages": 400
  }'
```

### Add categories to book

```bash
curl -X POST http://localhost:3000/api/books/1/categories \
  -H "Content-Type: application/json" \
  -d '{
    "categoryIds": [3, 4]
  }'
```

### Get statistics

```bash
curl http://localhost:3000/api/books/statistics
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalBooks": 15,
    "totalAuthors": 8,
    "totalCategories": 6
  }
}
```

## MVC Pattern Explanation

### Model (src/models/)

Models define the data structure and relationships:

```javascript
const Book = sequelize.define('Book', {
    book_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    title: {
        type: DataTypes.STRING(255),
        allowNull: false
    }
    // ...
});
```

### Controller (src/controllers/)

Controllers process HTTP requests and responses:

```javascript
async getAllBooks(req, res, next) {
    try {
        const books = await bookService.getAllBooks(req.query);
        res.json({ success: true, data: books });
    } catch (error) {
        next(error);
    }
}
```

### Service (src/services/)

Services contain the business logic:

```javascript
async createBook(bookData) {
    // Validation
    if (!bookData.title) {
        throw new Error('Title is required');
    }

    // Create book
    const book = await Book.create(bookData);
    return book;
}
```

### Routes (src/routes/)

Routes connect URLs with controllers:

```javascript
router.get('/', bookController.getAllBooks);
router.post('/', validateBook, bookController.createBook);
```

## Database Relationships

### 1:N Relationship (Author → Books)

One author has many books:

```javascript
Author.hasMany(Book, { foreignKey: 'author_id', as: 'books' });
Book.belongsTo(Author, { foreignKey: 'author_id', as: 'author' });
```

### N:M Relationship (Books ↔ Categories)

Books have many categories, categories have many books:

```javascript
Book.belongsToMany(Category, {
    through: 'book_categories',
    foreignKey: 'book_id'
});

Category.belongsToMany(Book, {
    through: 'book_categories',
    foreignKey: 'category_id'
});
```

## Validation

### Automatic Sequelize Validation

```javascript
title: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
        notEmpty: true,
        len: [1, 255]
    }
}
```

### Manual Middleware Validation

```javascript
const validateBook = (req, res, next) => {
    const { title, isbn } = req.body;

    if (!title) {
        return res.status(400).json({
            error: 'Title is required'
        });
    }

    next();
};
```

## Error Handling

Centralized error handling in `errorHandler.js`:

```javascript
// Sequelize Validation Error
if (err instanceof ValidationError) {
    return res.status(400).json({
        error: 'Validation error',
        details: err.errors.map(e => e.message)
    });
}
```

## Testing with Postman

Import this collection for quick testing:

```json
{
  "info": {
    "name": "Library API",
    "_postman_id": "library-api-collection",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Get All Books",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/api/books"
      }
    }
  ]
}
```

## Troubleshooting

### Error: "Cannot connect to database"

- Check DB credentials in `.env`
- Ensure MySQL/MariaDB is running
- Verify that the database exists

### Error: "Port 3000 already in use"

Change the port in `.env`:
```env
PORT=3001
```

### Error: "SequelizeDatabaseError: Table doesn't exist"

The server creates tables automatically in development mode. Ensure:
```env
NODE_ENV=development
```

## Best Practices

1. **Separation of Concerns**: Model/Controller/Service clearly separated
2. **Error Handling**: Always use try-catch in async functions
3. **Validation**: Both at model and middleware level
4. **Environment Variables**: Never put sensitive data in code
5. **Async/Await**: Instead of callbacks for better readability
6. **HTTP Status Codes**: Use correct status codes (200, 201, 400, 404, 500)

## Advanced Topics

- [ ] Authentication & Authorization (JWT)
- [ ] Rate Limiting
- [ ] API Documentation (Swagger)
- [ ] Unit & Integration Tests
- [ ] Docker Containerization
- [ ] CI/CD Pipeline
- [ ] Logging (Winston, Morgan)
- [ ] Caching (Redis)

## License

MIT

## Author

HFTM SY302 - Databases with Frameworks
Lesson 11: Express Frameworks & ORM
