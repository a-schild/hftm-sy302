# API Testing Guide

Complete guide for testing the Library API.

## Prerequisites

- Server running on `http://localhost:3000`
- Database is set up and connected
- Tools: curl, Postman, or HTTPie

## 1. Health Check

```bash
# Check if server is running
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

## 2. Test Authors

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

```bash
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "George Orwell",
    "country": "England",
    "birth_year": 1903
  }'
```

### Get all authors

```bash
curl http://localhost:3000/api/authors
```

### Get one author

```bash
curl http://localhost:3000/api/authors/1
```

### Update author

```bash
curl -X PUT http://localhost:3000/api/authors/1 \
  -H "Content-Type: application/json" \
  -d '{
    "country": "United Kingdom"
  }'
```

## 3. Test Categories

### Create categories

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

### Get all categories

```bash
curl http://localhost:3000/api/categories
```

## 4. Test Books

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

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "1984",
    "author_id": 2,
    "isbn": "978-3-548-23440-9",
    "publication_year": 1949,
    "pages": 336,
    "categories": [2, 3]
  }'
```

### Get all books

```bash
curl http://localhost:3000/api/books
```

### Get a book with all relationships

```bash
curl http://localhost:3000/api/books/1
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
    "categoryIds": [3]
  }'
```

### Delete book

```bash
curl -X DELETE http://localhost:3000/api/books/1
```

## 5. Test Filters & Search

### Filter by author

```bash
curl "http://localhost:3000/api/books?author=Tolkien"
```

### Filter by year

```bash
curl "http://localhost:3000/api/books?year=1937"
```

### Full-text search in title

```bash
curl "http://localhost:3000/api/books?search=Hobbit"
```

### Authors with their books

```bash
curl "http://localhost:3000/api/authors?withBooks=true"
```

### Categories with their books

```bash
curl "http://localhost:3000/api/categories?withBooks=true"
```

### Books by an author

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

## 6. Test Statistics

```bash
curl http://localhost:3000/api/books/statistics
```

## 7. Test Error Cases

### Invalid ID

```bash
curl http://localhost:3000/api/books/999
# Expected: 404 Not Found
```

### Missing required fields

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
    "author_id": 1
  }'

# Try again with same ISBN
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Another Book",
    "isbn": "978-0000000001",
    "author_id": 1
  }'
# Expected: 400 Bad Request - ISBN already exists
```

### Invalid year

```bash
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Future Book",
    "publication_year": 3000,
    "author_id": 1
  }'
# Expected: 400 Bad Request - Validation error
```

### Delete author with books

```bash
# Delete author with books
curl -X DELETE http://localhost:3000/api/authors/1
# Expected: 400 Bad Request - Author still has X books
```

## 8. Postman Collection

Import this collection into Postman:

```json
{
  "info": {
    "name": "Library API",
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
          "name": "Get Book by ID",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/books/1"
          }
        },
        {
          "name": "Create Book",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"title\": \"The Hobbit\",\n  \"author_id\": 1,\n  \"isbn\": \"978-3-423-21212-0\",\n  \"publication_year\": 1937,\n  \"pages\": 336,\n  \"categories\": [1, 2]\n}"
            },
            "url": "{{baseUrl}}/books"
          }
        },
        {
          "name": "Update Book",
          "request": {
            "method": "PUT",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"title\": \"The Hobbit - Extended Edition\",\n  \"pages\": 400\n}"
            },
            "url": "{{baseUrl}}/books/1"
          }
        },
        {
          "name": "Delete Book",
          "request": {
            "method": "DELETE",
            "url": "{{baseUrl}}/books/1"
          }
        }
      ]
    },
    {
      "name": "Authors",
      "item": [
        {
          "name": "Get All Authors",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/authors"
          }
        },
        {
          "name": "Create Author",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"name\": \"J.R.R. Tolkien\",\n  \"country\": \"England\",\n  \"birth_year\": 1892\n}"
            },
            "url": "{{baseUrl}}/authors"
          }
        }
      ]
    },
    {
      "name": "Categories",
      "item": [
        {
          "name": "Get All Categories",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/categories"
          }
        },
        {
          "name": "Create Category",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "body": {
              "mode": "raw",
              "raw": "{\n  \"name\": \"Fantasy\",\n  \"description\": \"Fantasy and fantastical literature\"\n}"
            },
            "url": "{{baseUrl}}/categories"
          }
        }
      ]
    }
  ]
}
```

## 9. Complete Test Workflow

Execute these steps sequentially:

```bash
# 1. Start server (in separate terminal)
npm run dev

# 2. Health check
curl http://localhost:3000/api/health

# 3. Create authors
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name": "J.R.R. Tolkien", "country": "England", "birth_year": 1892}'

curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{"name": "George Orwell", "country": "England", "birth_year": 1903}'

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
  -d '{"title": "The Hobbit", "author_id": 1, "isbn": "978-3-423-21212-0", "publication_year": 1937, "pages": 336, "categories": [1, 2]}'

curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{"title": "1984", "author_id": 2, "isbn": "978-3-548-23440-9", "publication_year": 1949, "pages": 336, "categories": [2]}'

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
- **409**: Conflict (e.g. duplicate ISBN)
- **500**: Server error

## Tips

1. Use `jq` for prettier JSON output:
   ```bash
   curl http://localhost:3000/api/books | jq
   ```

2. Save IDs for further requests:
   ```bash
   BOOK_ID=$(curl -s -X POST http://localhost:3000/api/books \
     -H "Content-Type: application/json" \
     -d '{"title": "Test"}' | jq -r '.data.book_id')

   curl http://localhost:3000/api/books/$BOOK_ID
   ```

3. Use environment variables:
   ```bash
   export API_URL=http://localhost:3000/api
   curl $API_URL/books
   ```
