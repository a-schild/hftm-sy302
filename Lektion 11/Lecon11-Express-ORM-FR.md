# Leçon 11: Frameworks Express & ORM

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Comprendre les ORM (Object-Relational Mapping)
- Utiliser Sequelize avec Node.js
- Effectuer des migrations de bases de données
- Comparer SQL brut vs ORM

## Qu'est-ce qu'un ORM?

**ORM** = Object-Relational Mapping

Traduit entre objets (code) et tables (base de données).

### Avantages des ORM

✅ **Code plus lisible**
✅ **Abstraction de la base de données**
✅ **Protection contre SQL injection**
✅ **Migrations gérées**
✅ **Validation intégrée**

### Inconvénients des ORM

❌ **Courbe d'apprentissage**
❌ **Performance overhead**
❌ **Requêtes complexes difficiles**
❌ **Moins de contrôle**

## Sequelize

Le plus populaire ORM pour Node.js.

### Installation

```bash
npm install sequelize mysql2
npm install --save-dev sequelize-cli
```

### Configuration

```javascript
// config/database.js
const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASSWORD,
    {
        host: process.env.DB_HOST,
        dialect: 'mysql',
        logging: console.log,
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000
        }
    }
);

module.exports = sequelize;
```

### Définir des modèles

```javascript
// models/Book.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Book = sequelize.define('Book', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    title: {
        type: DataTypes.STRING(255),
        allowNull: false,
        validate: {
            notEmpty: true,
            len: [3, 255]
        }
    },
    isbn: {
        type: DataTypes.STRING(20),
        unique: true
    },
    publishedDate: {
        type: DataTypes.DATE
    },
    price: {
        type: DataTypes.DECIMAL(10, 2),
        validate: {
            min: 0
        }
    },
    inStock: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    }
}, {
    tableName: 'books',
    timestamps: true
});

module.exports = Book;
```

### Associations

```javascript
// models/associations.js
const Book = require('./Book');
const Author = require('./Author');
const Publisher = require('./Publisher');
const Category = require('./Category');

// 1:N - Un auteur a plusieurs livres
Author.hasMany(Book, { 
    foreignKey: 'authorId',
    as: 'books'
});

Book.belongsTo(Author, { 
    foreignKey: 'authorId',
    as: 'author'
});

// 1:N - Un éditeur a plusieurs livres
Publisher.hasMany(Book, { foreignKey: 'publisherId' });
Book.belongsTo(Publisher, { foreignKey: 'publisherId' });

// N:M - Livres et Catégories
Book.belongsToMany(Category, { 
    through: 'BookCategories',
    foreignKey: 'bookId'
});

Category.belongsToMany(Book, { 
    through: 'BookCategories',
    foreignKey: 'categoryId'
});

module.exports = { Book, Author, Publisher, Category };
```

### CRUD avec Sequelize

```javascript
// CREATE
const book = await Book.create({
    title: 'New Book',
    isbn: '978-1234567890',
    price: 29.99,
    authorId: 1
});

// READ
const books = await Book.findAll();

const book = await Book.findByPk(1);

const books = await Book.findAll({
    where: {
        price: {
            [Op.gte]: 20
        }
    },
    include: [{
        model: Author,
        as: 'author'
    }]
});

// UPDATE
await book.update({ price: 24.99 });

// Ou
await Book.update(
    { price: 24.99 },
    { where: { id: 1 } }
);

// DELETE
await book.destroy();

// Ou
await Book.destroy({
    where: { id: 1 }
});
```

### Requêtes avancées

```javascript
// Opérateurs
const { Op } = require('sequelize');

// AND
const books = await Book.findAll({
    where: {
        [Op.and]: [
            { price: { [Op.gte]: 20 } },
            { inStock: true }
        ]
    }
});

// OR
const books = await Book.findAll({
    where: {
        [Op.or]: [
            { authorId: 1 },
            { price: { [Op.lt]: 10 } }
        ]
    }
});

// LIKE
const books = await Book.findAll({
    where: {
        title: {
            [Op.like]: '%Harry%'
        }
    }
});

// IN
const books = await Book.findAll({
    where: {
        authorId: {
            [Op.in]: [1, 2, 3]
        }
    }
});
```

### Agrégations

```javascript
// COUNT
const count = await Book.count();

const count = await Book.count({
    where: { inStock: true }
});

// SUM
const total = await Book.sum('price');

// MAX, MIN, AVG
const maxPrice = await Book.max('price');
const minPrice = await Book.min('price');
const avgPrice = await Book.avg('price');

// GROUP BY
const result = await Book.findAll({
    attributes: [
        'authorId',
        [sequelize.fn('COUNT', sequelize.col('id')), 'bookCount']
    ],
    group: ['authorId']
});
```

### Transactions

```javascript
const t = await sequelize.transaction();

try {
    const book = await Book.create({
        title: 'New Book',
        price: 29.99
    }, { transaction: t });
    
    await Author.update(
        { bookCount: sequelize.literal('bookCount + 1') },
        { where: { id: book.authorId }, transaction: t }
    );
    
    await t.commit();
    
} catch (err) {
    await t.rollback();
    throw err;
}
```

## Migrations

### Initialisation

```bash
# Initialiser Sequelize
npx sequelize-cli init
```

Structure créée:
```
project/
├── config/
│   └── config.json
├── migrations/
├── models/
└── seeders/
```

### Créer une migration

```bash
npx sequelize-cli migration:generate --name create-books-table
```

### Fichier de migration

```javascript
// migrations/20240101-create-books.js
module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.createTable('books', {
            id: {
                type: Sequelize.INTEGER,
                primaryKey: true,
                autoIncrement: true
            },
            title: {
                type: Sequelize.STRING(255),
                allowNull: false
            },
            isbn: {
                type: Sequelize.STRING(20),
                unique: true
            },
            authorId: {
                type: Sequelize.INTEGER,
                references: {
                    model: 'authors',
                    key: 'id'
                },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            publishedDate: {
                type: Sequelize.DATE
            },
            price: {
                type: Sequelize.DECIMAL(10, 2)
            },
            inStock: {
                type: Sequelize.BOOLEAN,
                defaultValue: true
            },
            createdAt: {
                type: Sequelize.DATE,
                allowNull: false
            },
            updatedAt: {
                type: Sequelize.DATE,
                allowNull: false
            }
        });
        
        // Ajouter un index
        await queryInterface.addIndex('books', ['title']);
        await queryInterface.addIndex('books', ['authorId']);
    },
    
    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('books');
    }
};
```

### Exécuter les migrations

```bash
# Exécuter toutes les migrations
npx sequelize-cli db:migrate

# Annuler la dernière migration
npx sequelize-cli db:migrate:undo

# Annuler toutes les migrations
npx sequelize-cli db:migrate:undo:all
```

## Seeders

### Créer un seeder

```bash
npx sequelize-cli seed:generate --name demo-books
```

### Fichier seeder

```javascript
// seeders/20240101-demo-books.js
module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.bulkInsert('books', [
            {
                title: 'The Hobbit',
                isbn: '978-0547928227',
                price: 14.99,
                authorId: 1,
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                title: '1984',
                isbn: '978-0451524935',
                price: 13.99,
                authorId: 2,
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ]);
    },
    
    down: async (queryInterface, Sequelize) => {
        await queryInterface.bulkDelete('books', null, {});
    }
};
```

### Exécuter les seeders

```bash
# Exécuter tous les seeders
npx sequelize-cli db:seed:all

# Annuler tous les seeders
npx sequelize-cli db:seed:undo:all
```

## Comparaison: SQL brut vs ORM

### SQL brut

```javascript
// Avantages
✅ Contrôle total
✅ Performance optimale
✅ Requêtes complexes faciles

// Inconvénients
❌ Risque d'injection SQL
❌ Plus de code
❌ Changements de DB difficiles

const [books] = await pool.query(`
    SELECT b.*, a.name as author_name
    FROM books b
    INNER JOIN authors a ON b.author_id = a.id
    WHERE b.price > ?
    ORDER BY b.title
`, [20]);
```

### ORM (Sequelize)

```javascript
// Avantages
✅ Code plus propre
✅ Protection SQL injection
✅ Migrations gérées
✅ Abstraction DB

// Inconvénients
❌ Overhead de performance
❌ Courbe d'apprentissage
❌ Moins de contrôle

const books = await Book.findAll({
    where: {
        price: { [Op.gt]: 20 }
    },
    include: [{
        model: Author,
        as: 'author'
    }],
    order: [['title', 'ASC']]
});
```

### Quand utiliser quoi?

**Utiliser SQL brut:**
- Requêtes très complexes
- Performance critique
- Équipe expérimentée SQL

**Utiliser ORM:**
- Projet de taille moyenne/grande
- Développement rapide
- Équipe mixte (juniors/seniors)

**Approche hybride:**
```javascript
// Utiliser ORM pour CRUD simple
const book = await Book.findByPk(1);

// Utiliser SQL brut pour requêtes complexes
const stats = await sequelize.query(`
    SELECT 
        g.name,
        COUNT(b.id) as book_count,
        AVG(b.price) as avg_price
    FROM genres g
    LEFT JOIN books b ON g.id = b.genre_id
    GROUP BY g.id
    HAVING book_count > 10
`, { type: QueryTypes.SELECT });
```

## Exercices pratiques

### Exercice 1: Setup Sequelize

1. Installer Sequelize et sequelize-cli
2. Configurer la connexion
3. Créer 3 modèles (Book, Author, Publisher)
4. Définir les associations

### Exercice 2: Migrations

1. Créer des migrations pour toutes les tables
2. Exécuter les migrations
3. Créer des seeders avec données de test
4. Exécuter les seeders

### Exercice 3: API avec Sequelize

Convertir votre API existante pour utiliser Sequelize:
1. Remplacer les requêtes SQL brutes
2. Utiliser les associations
3. Comparer les performances

## Bonnes pratiques

### Modèles

```javascript
// ✅ Bon - Validation au niveau du modèle
const Book = sequelize.define('Book', {
    title: {
        type: DataTypes.STRING,
        allowNull: false,
        validate: {
            notEmpty: true,
            len: [3, 255]
        }
    }
});

// ❌ Éviter - Pas de validation
const Book = sequelize.define('Book', {
    title: DataTypes.STRING
});
```

### Requêtes

```javascript
// ✅ Bon - Inclure seulement les champs nécessaires
const books = await Book.findAll({
    attributes: ['id', 'title', 'price'],
    include: [{
        model: Author,
        attributes: ['name']
    }]
});

// ❌ Éviter - SELECT *
const books = await Book.findAll({
    include: [Author]
});
```

### Indexes

```javascript
// ✅ Ajouter des index pour les colonnes fréquemment recherchées
const Book = sequelize.define('Book', {
    title: {
        type: DataTypes.STRING,
        index: true
    },
    isbn: {
        type: DataTypes.STRING,
        unique: true
    }
});
```

## Résumé

### ORM vs SQL brut

| Aspect | ORM | SQL brut |
|--------|-----|----------|
| Lisibilité | ✅ Meilleure | ⚠️ Moyenne |
| Performance | ⚠️ Overhead | ✅ Optimale |
| Sécurité | ✅ Built-in | ⚠️ Manuel |
| Courbe d'apprentissage | ⚠️ Raide | ✅ Familier |
| Flexibilité | ⚠️ Limitée | ✅ Totale |

### Quand utiliser Sequelize

✅ **Projets moyens/grands**
✅ **Équipes mixtes**
✅ **Développement rapide**
✅ **Migrations fréquentes**

## Devoirs

1. **Convertir votre API** pour utiliser Sequelize
2. **Créer des migrations** pour toutes les tables
3. **Ajouter des seeders** avec données de test
4. **Comparer les performances** SQL vs ORM

## Ressources

- [Sequelize Documentation](https://sequelize.org/)
- [Sequelize CLI](https://github.com/sequelize/cli)
- [TypeORM](https://typeorm.io/) (Alternative)
- [Prisma](https://www.prisma.io/) (Alternative moderne)

## Prochaines étapes

Dans la leçon 12:
- MQTT pour IoT
- Authentification JWT
- Sécurité des API
- Protection contre les attaques
