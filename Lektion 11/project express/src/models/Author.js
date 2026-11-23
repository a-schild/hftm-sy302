const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Author = sequelize.define('Author', {
    author_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        field: 'author_id'
    },
    name: {
        type: DataTypes.STRING(255),
        allowNull: false,
        validate: {
            notEmpty: {
                msg: 'Name must not be empty'
            },
            len: {
                args: [2, 255],
                msg: 'Name must be between 2 and 255 characters long'
            }
        }
    },
    country: {
        type: DataTypes.STRING(100),
        allowNull: true
    },
    birth_year: {
        type: DataTypes.INTEGER,
        allowNull: true,
        validate: {
            min: {
                args: [1000],
                msg: 'Birth year must be after 1000'
            },
            max: {
                args: [new Date().getFullYear()],
                msg: 'Birth year cannot be in the future'
            }
        }
    }
}, {
    tableName: 'authors',
    timestamps: true,
    underscored: true
});

module.exports = Author;
