# Prisma vs Sequelize Comparison

A detailed comparison between the Prisma and Sequelize implementations of the Library API.

## Overview

Both projects implement the same Library Management API with identical functionality, but use different ORMs:

- **Sequelize**: Traditional ORM with code-based models
- **Prisma**: Modern ORM with schema-first approach

## Project Structure Comparison

### Sequelize Structure
```
project express/
├── src/
│   ├── config/
│   │   └── database.js          # Sequelize configuration
│   ├── models/
│   │   ├── Book.js              # Model definition
│   │   ├── Author.js
│   │   ├── Category.js
│   │   └── index.js             # Relationships
│   ├── services/
│   ├── controllers/
│   └── middleware/
```

### Prisma Structure
```
prisma/
├── prisma/
│   ├── schema.prisma            # All models in one file
│   └── seed.js                  # Database seeder
├── src/
│   ├── config/
│   │   └── prisma.js            # Prisma client
│   ├── services/
│   ├── controllers/
│   └── middleware/
```

## Schema Definition

### Sequelize (Code-based)

```javascript
// models/Book.js
const Book = sequelize.define('Book', {
  book_id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  title: {
    type: DataTypes.STRING(255),
    allowNull: false,
    validate: {
      notEmpty: true
    }
  },
  isbn: {
    type: DataTypes.STRING(20),
    unique: true
  }
}, {
  tableName: 'books',
  timestamps: true
});
```

### Prisma (Schema-first)

```prisma
// prisma/schema.prisma
model Book {
  id              Int      @id @default(autoincrement()) @map("book_id")
  title           String   @db.VarChar(255)
  isbn            String?  @unique @db.VarChar(20)
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")

  @@map("books")
}
```

## Relationships

### Sequelize (models/index.js)

```javascript
// 1:N Relationship
Author.hasMany(Book, {
  foreignKey: 'author_id',
  as: 'books'
});

Book.belongsTo(Author, {
  foreignKey: 'author_id',
  as: 'author'
});

// N:M Relationship
Book.belongsToMany(Category, {
  through: 'book_categories',
  foreignKey: 'book_id'
});
```

### Prisma (schema.prisma)

```prisma
model Author {
  id    Int    @id @default(autoincrement())
  books Book[] // One-to-Many
}

model Book {
  id         Int    @id @default(autoincrement())
  authorId   Int?
  author     Author? @relation(fields: [authorId], references: [id])
  categories BookCategory[] // Many-to-Many
}

model BookCategory {
  bookId     Int
  categoryId Int
  book       Book     @relation(fields: [bookId], references: [id])
  category   Category @relation(fields: [categoryId], references: [id])
  @@id([bookId, categoryId])
}
```

## CRUD Operations

### Create

**Sequelize:**
```javascript
const book = await Book.create({
  title: 'The Hobbit',
  author_id: 1,
  isbn: '978-3-423-21212-0'
});
```

**Prisma:**
```javascript
const book = await prisma.book.create({
  data: {
    title: 'The Hobbit',
    authorId: 1,
    isbn: '978-3-423-21212-0'
  }
});
```

### Read

**Sequelize:**
```javascript
const books = await Book.findAll({
  include: [{
    model: Author,
    as: 'author'
  }]
});
```

**Prisma:**
```javascript
const books = await prisma.book.findMany({
  include: {
    author: true
  }
});
```

### Update

**Sequelize:**
```javascript
await Book.update(
  { title: 'New Title' },
  { where: { book_id: 1 } }
);
```

**Prisma:**
```javascript
await prisma.book.update({
  where: { id: 1 },
  data: { title: 'New Title' }
});
```

### Delete

**Sequelize:**
```javascript
await Book.destroy({
  where: { book_id: 1 }
});
```

**Prisma:**
```javascript
await prisma.book.delete({
  where: { id: 1 }
});
```

## Queries

### Filter with WHERE

**Sequelize:**
```javascript
const books = await Book.findAll({
  where: {
    publication_year: {
      [Op.gte]: 2000,
      [Op.lte]: 2024
    }
  }
});
```

**Prisma:**
```javascript
const books = await prisma.book.findMany({
  where: {
    publicationYear: {
      gte: 2000,
      lte: 2024
    }
  }
});
```

### LIKE Search

**Sequelize:**
```javascript
const books = await Book.findAll({
  where: {
    title: {
      [Op.like]: '%Hobbit%'
    }
  }
});
```

**Prisma:**
```javascript
const books = await prisma.book.findMany({
  where: {
    title: {
      contains: 'Hobbit'
    }
  }
});
```

### Ordering

**Sequelize:**
```javascript
const books = await Book.findAll({
  order: [
    ['publication_year', 'DESC'],
    ['title', 'ASC']
  ]
});
```

**Prisma:**
```javascript
const books = await prisma.book.findMany({
  orderBy: [
    { publicationYear: 'desc' },
    { title: 'asc' }
  ]
});
```

### Pagination

**Sequelize:**
```javascript
const books = await Book.findAll({
  limit: 10,
  offset: 20
});
```

**Prisma:**
```javascript
const books = await prisma.book.findMany({
  take: 10,
  skip: 20
});
```

## Migrations

### Sequelize

```bash
# Generate migration
npx sequelize-cli migration:generate --name create-books-table

# Run migrations
npx sequelize-cli db:migrate

# Undo migration
npx sequelize-cli db:migrate:undo
```

Migration file (JavaScript):
```javascript
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('books', {
      book_id: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      }
    });
  },
  down: async (queryInterface) => {
    await queryInterface.dropTable('books');
  }
};
```

### Prisma

```bash
# Create migration
npx prisma migrate dev --name create-books-table

# Run migrations
npx prisma migrate deploy

# Reset database
npx prisma migrate reset
```

Migration file (SQL - auto-generated):
```sql
-- CreateTable
CREATE TABLE `books` (
    `book_id` INTEGER NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`book_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## Error Handling

### Sequelize

```javascript
if (err instanceof ValidationError) {
  return res.status(400).json({
    error: 'Validation error',
    details: err.errors.map(e => e.message)
  });
}

if (err instanceof UniqueConstraintError) {
  return res.status(409).json({
    error: 'Record already exists'
  });
}
```

### Prisma

```javascript
if (err instanceof Prisma.PrismaClientValidationError) {
  return res.status(400).json({
    error: 'Validation error'
  });
}

if (err.code === 'P2002') {  // Unique constraint
  return res.status(409).json({
    error: 'Record already exists'
  });
}
```

## Type Safety

### Sequelize

No built-in type safety (requires @types/sequelize):

```javascript
// No autocomplete, no type checking
const book = await Book.findByPk(1);
console.log(book.title); // No type safety
```

### Prisma

Native TypeScript support:

```typescript
// Full autocomplete and type checking
const book = await prisma.book.findUnique({ where: { id: 1 } });
console.log(book.title); // Type-safe!
```

## Validation

### Sequelize (Built-in)

```javascript
const Book = sequelize.define('Book', {
  title: {
    type: DataTypes.STRING,
    validate: {
      notEmpty: true,
      len: [1, 255]
    }
  },
  isbn: {
    type: DataTypes.STRING,
    validate: {
      is: /^[\d-]+$/i
    }
  }
});
```

### Prisma (Manual in Service)

```javascript
// Schema only defines structure
model Book {
  title String @db.VarChar(255)
  isbn  String?
}

// Validation in service layer
async createBook(data) {
  if (!data.title || data.title.length > 255) {
    throw new Error('Invalid title');
  }
  // ...
}
```

## Performance

### Query Optimization

**Sequelize:**
```javascript
// Select specific fields
const books = await Book.findAll({
  attributes: ['title', 'author']
});

// Raw queries for complex operations
const books = await sequelize.query(
  'SELECT * FROM books WHERE ...',
  { type: QueryTypes.SELECT }
);
```

**Prisma:**
```javascript
// Select specific fields
const books = await prisma.book.findMany({
  select: {
    title: true,
    author: true
  }
});

// Raw queries
const books = await prisma.$queryRaw`
  SELECT * FROM books WHERE ...
`;
```

## Developer Experience

### Sequelize

**Pros:**
- Mature and stable
- Large community
- Extensive documentation
- Flexible model definition

**Cons:**
- More boilerplate code
- No native TypeScript support
- Complex relationship setup
- Manual type definitions needed

### Prisma

**Pros:**
- Type-safe by default
- Auto-completion in IDE
- Prisma Studio (GUI)
- Cleaner syntax
- Auto-generated migrations

**Cons:**
- Newer (less mature)
- Smaller community
- Less flexible (opinionated)
- Schema changes require regeneration

## Feature Comparison Table

| Feature | Sequelize | Prisma |
|---------|-----------|--------|
| **Type Safety** | ❌ (via @types) | ✅ Native |
| **Schema Definition** | Code | Declarative |
| **Migrations** | Manual JS files | Auto-generated SQL |
| **GUI Tool** | ❌ | ✅ Prisma Studio |
| **Auto-completion** | ⚠️ Limited | ✅ Excellent |
| **Learning Curve** | Medium | Easy |
| **Community Size** | Large | Growing |
| **Performance** | Good | Very Good |
| **Raw SQL** | ✅ | ✅ |
| **Validation** | Built-in | Manual |
| **Middleware** | ✅ Hooks | ✅ Middleware |
| **Transactions** | ✅ | ✅ |

## When to Use Each

### Use Sequelize When:
- Working with existing JavaScript projects
- Need extensive built-in validation
- Prefer code-based schema definition
- Working with complex legacy databases
- Team is already familiar with Sequelize

### Use Prisma When:
- Starting a new TypeScript project
- Want excellent IDE support
- Prefer declarative schema
- Need Prisma Studio for development
- Want better type safety
- Working on modern greenfield projects

## Migration Path

### From Sequelize to Prisma

1. **Introspect existing database:**
   ```bash
   npx prisma db pull
   ```

2. **Generate Prisma Client:**
   ```bash
   npx prisma generate
   ```

3. **Migrate services gradually:**
   - Start with read operations
   - Move to write operations
   - Update relationships

### From Prisma to Sequelize

1. **Export schema to SQL:**
   ```bash
   npx prisma migrate dev --create-only
   ```

2. **Create Sequelize models** based on Prisma schema

3. **Set up relationships** in models/index.js

## Conclusion

Both ORMs are excellent choices:

- **Sequelize** is mature, flexible, and has built-in validation
- **Prisma** is modern, type-safe, and has better DX (Developer Experience)

Choose based on:
- Project requirements
- Team expertise
- Type safety needs
- Development speed priorities

For this course, learning both provides valuable insight into different ORM approaches!
