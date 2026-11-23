const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Book = sequelize.define('Book', {
    book_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        field: 'book_id'
    },
    title: {
        type: DataTypes.STRING(255),
        allowNull: false,
        validate: {
            notEmpty: {
                msg: 'Title must not be empty'
            }
        }
    },
    author_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'authors',
            key: 'author_id'
        }
    },
    isbn: {
        type: DataTypes.STRING(20),
        unique: true,
        allowNull: true,
        validate: {
            is: {
                args: /^[\d-]+$/i,
                msg: 'ISBN may only contain numbers and hyphens'
            }
        }
    },
    publication_year: {
        type: DataTypes.INTEGER,
        allowNull: true,
        validate: {
            min: {
                args: [1000],
                msg: 'Publication year must be after 1000'
            },
            max: {
                args: [new Date().getFullYear() + 1],
                msg: 'Publication year cannot be more than 1 year in the future'
            }
        }
    },
    pages: {
        type: DataTypes.INTEGER,
        allowNull: true,
        validate: {
            min: {
                args: [1],
                msg: 'Page count must be at least 1'
            }
        }
    }
}, {
    tableName: 'books',
    timestamps: true,
    underscored: true
});

module.exports = Book;
