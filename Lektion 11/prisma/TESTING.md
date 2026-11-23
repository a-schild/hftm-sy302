# API Testing Guide - Prisma Version

Complete guide for testing the Library API with Prisma ORM.

## Prerequisites

- Server running at `http://localhost:3000`
- Database is set up and connected
- Tools: curl, Postman, or HTTPie

## Quick Start

### 1. Setup

```bash
# Install dependencies
npm install

# Generate Prisma Client
npx prisma generate

# Create database schema
npx prisma db push

# Seed database with sample data
npm run prisma:seed

# Start server
npm run dev
```

### 2. Health Check

```bash
curl http://localhost:3000/api/health
```

**Expected Response:**
```json
{
  "success": true,
  "message": "API is running",
  "timestamp": "2024-10-27T12:00:00.000Z"
}
```

## Testing Authors

### Create Authors

```bash
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "J.R.R. Tolkien",
    "country": "England",
    "birthYear": 1892
  }'
```

```bash
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "George Orwell",
    "country": "England",
    "birthYear": 1903
  }'
```

### Get All Authors

```bash
curl http://localhost:3000/api/authors
```

### Get Single Author

```bash
curl http://localhost:3000/api/authors/1
```

### Update Author

```bash
curl -X PUT http://localhost:3000/api/authors/1 \
  -H "Content-Type: application/json" \
  -d '{
    "country": "United Kingdom"
  }'
```

## Testing Categories

### Create Categories

```bash
curl -X POST http://localhost:3000/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fantasy",
    "description": "Fantasy and fantastical literature"
  }'
```

```bash
curl -X POST http://localhost:3000/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Classics",
    "description": "Literary classics"
  }'
```

```bash
curl -X POST http://localhost:3000/api/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Science Fiction",
    "description": "Science fiction literature"
  }'
```

### Get All Categories

```bash
curl http://localhost:3000/api/categories
```

## Testing Books

### Create Books

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

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "1984",
    "authorId": 2,
    "isbn": "978-3-548-23440-9",
    "publicationYear": 1949,
    "pages": 336,
    "categories": [2, 3]
  }'
```

### Get All Books

```bash
curl http://localhost:3000/api/books
```

### Get Single Book with Relationships

```bash
curl http://localhost:3000/api/books/1
```

### Update Book

```bash
curl -X PUT http://localhost:3000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Hobbit - Extended Edition",
    "pages": 400
  }'
```

### Add Categories to Book

```bash
curl -X POST http://localhost:3000/api/books/1/categories \
  -H "Content-Type: application/json" \
  -d '{
    "categoryIds": [3]
  }'
```

### Delete Book

```bash
curl -X DELETE http://localhost:3000/api/books/1
```

## Testing Filters & Search

### Filter by Author

```bash
curl "http://localhost:3000/api/books?author=Tolkien"
```

### Filter by Year

```bash
curl "http://localhost:3000/api/books?year=1937"
```

### Full-text Search in Title

```bash
curl "http://localhost:3000/api/books?search=Hobbit"
```

### Filter by Category

```bash
curl "http://localhost:3000/api/books?category=Fantasy"
```

### Authors with Books

```bash
curl "http://localhost:3000/api/authors?withBooks=true"
```

### Categories with Books

```bash
curl "http://localhost:3000/api/categories?withBooks=true"
```

### Books by Author

```bash
curl http://localhost:3000/api/authors/1/books
```

### Pagination

```bash
# First 10 books
curl "http://localhost:3000/api/books?limit=10&offset=0"

# Next 10 books
curl "http://localhost:3000/api/books?limit=10&offset=10"
```

## Testing Statistics

```bash
curl http://localhost:3000/api/books/statistics
```

## Error Cases Testing

### Invalid ID

```bash
curl http://localhost:3000/api/books/999
# Expected: 404 Not Found
```

### Missing Required Fields

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "isbn": "978-1234567890"
  }'
# Expected: 400 Bad Request - Title is required
```

### Duplicate ISBN

```bash
# Create book with ISBN
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Book",
    "isbn": "978-0000000001",
    "authorId": 1
  }'

# Try again with same ISBN
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Another Book",
    "isbn": "978-0000000001",
    "authorId": 1
  }'
# Expected: 400 Bad Request - Book with ISBN already exists
```

### Invalid Year

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Future Book",
    "publicationYear": 3000,
    "authorId": 1
  }'
# Expected: 400 Bad Request - Validation error
```

### Delete Author with Books

```bash
# Delete author who has books
curl -X DELETE http://localhost:3000/api/authors/1
# Expected: 400 Bad Request - Author has X books
```

## Prisma Studio

Open Prisma Studio for GUI database access:

```bash
npm run prisma:studio
```

This opens a browser at `http://localhost:5555` where you can:
- View all data
- Edit records
- Create new records
- Delete records
- See relationships visually

## Complete Test Workflow

Execute these steps in order:

```bash
# 1. Start server (in separate terminal)
npm run dev

# 2. Health check
curl http://localhost:3000/api/health

# 3. Create authors
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name": "J.R.R. Tolkien", "country": "England", "birthYear": 1892}'

curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name": "George Orwell", "country": "England", "birthYear": 1903}'

# 4. Create categories
curl -X POST http://localhost:3000/api/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Fantasy", "description": "Fantasy and fantastical literature"}'

curl -X POST http://localhost:3000/api/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Classics", "description": "Literary classics"}'

# 5. Create books
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{"title": "The Hobbit", "authorId": 1, "isbn": "978-3-423-21212-0", "publicationYear": 1937, "pages": 336, "categories": [1, 2]}'

curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{"title": "1984", "authorId": 2, "isbn": "978-3-548-23440-9", "publicationYear": 1949, "pages": 336, "categories": [2]}'

# 6. Get data
curl http://localhost:3000/api/books
curl http://localhost:3000/api/authors?withBooks=true
curl http://localhost:3000/api/categories?withBooks=true

# 7. Statistics
curl http://localhost:3000/api/books/statistics

# 8. Test filters
curl "http://localhost:3000/api/books?author=Tolkien"
curl "http://localhost:3000/api/books?year=1937"

# 9. Update
curl -X PUT http://localhost:3000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{"pages": 400}'

# 10. Verify
curl http://localhost:3000/api/books/1
```

## Expected Outputs

All successful requests should contain `"success": true`.

### Successful Responses

- **GET**: Status 200, list of objects
- **POST**: Status 201, created object
- **PUT**: Status 200, updated object
- **DELETE**: Status 204, no body

### Error Responses

- **404**: Resource not found
- **400**: Validation error, missing data
- **409**: Conflict (e.g., duplicate ISBN)
- **500**: Server error

## Prisma-Specific Testing

### Test Prisma Migrations

```bash
# Create a new migration
npx prisma migrate dev --name add_new_field

# Run migrations
npx prisma migrate deploy

# Reset database (WARNING: deletes all data)
npx prisma migrate reset
```

### Test Database Seeding

```bash
# Run seeder
npm run prisma:seed

# Verify data was created
curl http://localhost:3000/api/books
```

### Test Prisma Client Generation

```bash
# Generate client
npx prisma generate

# Verify by starting server
npm run dev
```

## Tips

1. Use `jq` for prettier JSON output:
   ```bash
   curl http://localhost:3000/api/books | jq
   ```

2. Save IDs for further requests:
   ```bash
   BOOK_ID=$(curl -s -X POST http://localhost:3000/api/books \
     -H "Content-Type: application/json" \
     -d '{"title": "Test"}' | jq -r '.data.id')

   curl http://localhost:3000/api/books/$BOOK_ID
   ```

3. Use environment variables:
   ```bash
   export API_URL=http://localhost:3000/api
   curl $API_URL/books
   ```

4. Use Prisma Studio for visual debugging:
   ```bash
   npm run prisma:studio
   ```

## Postman Collection

Import this collection into Postman for easier testing:

```json
{
  "info": {
    "name": "Library API - Prisma",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "variable": [
    {
      "key": "baseUrl",
      "value": "http://localhost:3000/api"
    }
  ],
  "item": [
    {
      "name": "Books",
      "item": [
        {
          "name": "Get All Books",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/books"
          }
        },
        {
          "name": "Create Book",
          "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/json"}],
            "body": {
              "mode": "raw",
              "raw": "{\\n  \\"title\\": \\"The Hobbit\\",\\n  \\"authorId\\": 1,\\n  \\"isbn\\": \\"978-3-423-21212-0\\",\\n  \\"publicationYear\\": 1937,\\n  \\"pages\\": 336,\\n  \\"categories\\": [1, 2]\\n}"
            },
            "url": "{{baseUrl}}/books"
          }
        }
      ]
    }
  ]
}
```
