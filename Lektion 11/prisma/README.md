# Express.js REST API with MVC & Prisma ORM

A complete REST API for library management using Express.js, Prisma ORM, and MVC pattern.

## Features

- **MVC Architecture**: Clean separation between Model, View (API), and Controller
- **Prisma ORM**: Modern TypeScript-first ORM for MySQL/MariaDB
- **Service Layer**: Business logic separated from controllers
- **Validation**: Automatic validation with middleware
- **Error Handling**: Centralized error management
- **REST API**: RESTful endpoints for books, authors, and categories
- **Relationships**: 1:N and N:M relationships between entities

## Project Structure

```
prisma/
├── prisma/
│   ├── schema.prisma        # Prisma schema definition
│   └── seed.js              # Database seeder
├── src/
│   ├── config/
│   │   └── prisma.js        # Prisma client configuration
│   ├── services/            # Business Logic
│   │   ├── bookService.js
│   │   ├── authorService.js
│   │   └── categoryService.js
│   ├── controllers/         # Request Handlers
│   │   ├── bookController.js
│   │   ├── authorController.js
│   │   └── categoryController.js
│   ├── routes/              # Route Definitions
│   │   ├── books.js
│   │   ├── authors.js
│   │   ├── categories.js
│   │   └── index.js
│   └── middleware/          # Express Middleware
│       ├── errorHandler.js
│       └── validator.js
├── .env.example             # Environment variables template
├── .gitignore
├── package.json
├── server.js                # Entry Point
└── README.md
```

## Installation

### 1. Clone or download the project

```bash
cd prisma
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
DATABASE_URL="mysql://root:yourpassword@localhost:3306/library_db"
PORT=3000
NODE_ENV=development
```

### 5. Initialize Prisma

```bash
# Generate Prisma Client
npx prisma generate

# Create database tables
npx prisma db push

# Seed database with sample data (optional)
npm run prisma:seed
```

### 6. Start server

```bash
# Development with auto-reload
npm run dev

# Production
npm start
```

The API is now running at `http://localhost:3000/api`

## Prisma Commands

```bash
# Generate Prisma Client after schema changes
npm run prisma:generate

# Create/update database schema
npx prisma db push

# Create migration
npx prisma migrate dev --name your_migration_name

# Run migrations
npm run prisma:migrate

# Open Prisma Studio (Database GUI)
npm run prisma:studio

# Seed database
npm run prisma:seed

# Reset database (WARNING: deletes all data)
npx prisma migrate reset
```

## API Endpoints

### Books

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/books` | Get all books |
| GET | `/api/books/:id` | Get a single book |
| POST | `/api/books` | Create new book |
| PUT | `/api/books/:id` | Update book |
| DELETE | `/api/books/:id` | Delete book |
| POST | `/api/books/:id/categories` | Add categories to book |
| GET | `/api/books/statistics` | Get statistics |

**Query parameters for GET /api/books:**
- `author` - Filter by author (e.g., `?author=Tolkien`)
- `year` - Filter by publication year (e.g., `?year=1937`)
- `search` - Full-text search in title (e.g., `?search=Hobbit`)
- `category` - Filter by category (e.g., `?category=Fantasy`)
- `limit` - Number of results (default: 50)
- `offset` - Offset for pagination (default: 0)

### Authors

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/authors` | Get all authors |
| GET | `/api/authors/:id` | Get a single author |
| POST | `/api/authors` | Create new author |
| PUT | `/api/authors/:id` | Update author |
| DELETE | `/api/authors/:id` | Delete author |
| GET | `/api/authors/:id/books` | Get author's books |

**Query parameters for GET /api/authors:**
- `country` - Filter by country (e.g., `?country=England`)
- `search` - Full-text search in name (e.g., `?search=Tolkien`)
- `withBooks` - Include books (e.g., `?withBooks=true`)
- `limit` - Number of results (default: 50)
- `offset` - Offset for pagination (default: 0)

### Categories

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/categories` | Get all categories |
| GET | `/api/categories/:id` | Get a single category |
| POST | `/api/categories` | Create new category |
| PUT | `/api/categories/:id` | Update category |
| DELETE | `/api/categories/:id` | Delete category |

**Query parameters for GET /api/categories:**
- `withBooks` - Include books (e.g., `?withBooks=true`)
- `limit` - Number of results (default: 50)
- `offset` - Offset for pagination (default: 0)

## API Examples

### Create a book

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit",
    "authorId": 1,
    "isbn": "978-3-423-21212-0",
    "publicationYear": 1937,
    "pages": 336,
    "categories": [1, 2]
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Book created successfully",
  "data": {
    "id": 1,
    "title": "The Hobbit",
    "authorId": 1,
    "isbn": "978-3-423-21212-0",
    "publicationYear": 1937,
    "pages": 336,
    "author": {
      "id": 1,
      "name": "J.R.R. Tolkien",
      "country": "England"
    },
    "categories": [
      {
        "id": 1,
        "name": "Fantasy"
      },
      {
        "id": 2,
        "name": "Classics"
      }
    ]
  }
}
```

### Create an author

```bash
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "J.R.R. Tolkien",
    "country": "England",
    "birthYear": 1892
  }'
```

### Create a category

```bash
curl -X POST http://localhost:3000/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fantasy",
    "description": "Fantasy and fantastical literature"
  }'
```

### Get all books with filters

```bash
# Filter by author
curl http://localhost:3000/api/books?author=Tolkien

# Filter by year
curl http://localhost:3000/api/books?year=1937

# Full-text search
curl http://localhost:3000/api/books?search=Hobbit

# Filter by category
curl http://localhost:3000/api/books?category=Fantasy

# Pagination
curl http://localhost:3000/api/books?limit=10&offset=0
```

### Update a book

```bash
curl -X PUT http://localhost:3000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit - Extended Edition",
    "pages": 400
  }'
```

### Add categories to a book

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

## Prisma Schema Explanation

### Models

```prisma
model Author {
  id         Int      @id @default(autoincrement())
  name       String
  country    String?
  birthYear  Int?
  books      Book[]   // One-to-Many relationship
}

model Book {
  id              Int      @id @default(autoincrement())
  title           String
  authorId        Int?
  author          Author?  @relation(fields: [authorId], references: [id])
  categories      BookCategory[]  // Many-to-Many through junction table
}

model Category {
  id          Int      @id @default(autoincrement())
  name        String   @unique
  books       BookCategory[]
}

// Junction table for Many-to-Many
model BookCategory {
  bookId     Int
  categoryId Int
  book       Book     @relation(fields: [bookId], references: [id])
  category   Category @relation(fields: [categoryId], references: [id])
}
```

## MVC Pattern Explanation

### Model (Prisma Schema)

Defines the data structure and relationships in `prisma/schema.prisma`.

### Service (src/services/)

Contains business logic:

```javascript
async createBook(bookData) {
  // Validation
  if (!bookData.title) {
    throw new Error('Title is required');
  }

  // Create book with Prisma
  const book = await prisma.book.create({
    data: bookData,
  });

  return book;
}
```

### Controller (src/controllers/)

Handles HTTP requests and responses:

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

### Routes (src/routes/)

Connects URLs to controllers:

```javascript
router.get('/', bookController.getAllBooks);
router.post('/', validateBook, bookController.createBook);
```

## Database Relationships

### 1:N Relationship (Author → Books)

An author has many books:

```javascript
const author = await prisma.author.findUnique({
  where: { id: 1 },
  include: { books: true }
});
```

### N:M Relationship (Books ↔ Categories)

Books have many categories, categories have many books:

```javascript
const book = await prisma.book.findUnique({
  where: { id: 1 },
  include: {
    categories: {
      include: {
        category: true
      }
    }
  }
});
```

## Validation

### Prisma Schema Validation

```prisma
model Book {
  title String @db.VarChar(255)  // Max length
  isbn  String? @unique           // Unique constraint
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
// Prisma Unique Constraint Error
if (err.code === 'P2002') {
  return res.status(409).json({
    error: 'Record already exists'
  });
}
```

## Prisma vs Sequelize

### Key Differences

| Feature | Prisma | Sequelize |
|---------|--------|-----------|
| **Type Safety** | Native TypeScript | Via types package |
| **Schema Definition** | Declarative (schema.prisma) | Code-based models |
| **Migrations** | Built-in | Via CLI |
| **Query Builder** | Type-safe | String-based |
| **Performance** | Optimized queries | Good |
| **Learning Curve** | Low | Medium |

### Prisma Advantages

1. **Type Safety**: Auto-generated types from schema
2. **Declarative Schema**: Easy to understand data model
3. **Prisma Studio**: Built-in database GUI
4. **Auto-completion**: Better IDE support
5. **Migration System**: Robust migration tools

### Example Comparison

**Sequelize:**
```javascript
const book = await Book.findAll({
  include: [{ model: Author, as: 'author' }]
});
```

**Prisma:**
```javascript
const book = await prisma.book.findMany({
  include: { author: true }
});
```

## Troubleshooting

### Error: "Cannot connect to database"

- Check DATABASE_URL in `.env`
- Ensure MySQL/MariaDB is running
- Verify database exists

### Error: "Prisma Client is not generated"

Run:
```bash
npx prisma generate
```

### Error: "Port 3000 already in use"

Change port in `.env`:
```env
PORT=3001
```

### Error: "Table doesn't exist"

Run:
```bash
npx prisma db push
```

## Best Practices

1. **Separation of Concerns**: Model/Controller/Service clearly separated
2. **Error Handling**: Always use try-catch in async functions
3. **Validation**: Both on schema and middleware level
4. **Environment Variables**: Never hardcode sensitive data
5. **Async/Await**: Use instead of callbacks for better readability
6. **HTTP Status Codes**: Use correct status codes (200, 201, 400, 404, 500)
7. **Prisma Migrations**: Always use migrations in production

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
Lesson 11: Express Frameworks & ORM (Prisma Implementation)
