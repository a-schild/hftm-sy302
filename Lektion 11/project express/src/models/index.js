const { sequelize } = require('../config/database');
const Book = require('./Book');
const Author = require('./Author');
const Category = require('./Category');

// 1:N Relationship: One author has many books
Author.hasMany(Book, {
    foreignKey: 'author_id',
    as: 'books',
    onDelete: 'SET NULL',
    onUpdate: 'CASCADE'
});

Book.belongsTo(Author, {
    foreignKey: 'author_id',
    as: 'author'
});

// N:M Relationship: Books have many categories, categories have many books
const BookCategory = sequelize.define('BookCategory', {
    book_id: {
        type: require('sequelize').DataTypes.INTEGER,
        references: {
            model: Book,
            key: 'book_id'
        }
    },
    category_id: {
        type: require('sequelize').DataTypes.INTEGER,
        references: {
            model: Category,
            key: 'category_id'
        }
    }
}, {
    tableName: 'book_categories',
    timestamps: false,
    underscored: true
});

Book.belongsToMany(Category, {
    through: BookCategory,
    foreignKey: 'book_id',
    otherKey: 'category_id',
    as: 'categories'
});

Category.belongsToMany(Book, {
    through: BookCategory,
    foreignKey: 'category_id',
    otherKey: 'book_id',
    as: 'books'
});

// Sync function for Development
const syncDatabase = async (force = false) => {
    try {
        await sequelize.sync({ force, alter: !force });
        console.log('✓ Database models synchronized');
    } catch (error) {
        console.error('✗ Error synchronizing database:', error);
        throw error;
    }
};

module.exports = {
    sequelize,
    Book,
    Author,
    Category,
    BookCategory,
    syncDatabase
};
