const { Author, Book } = require('../models');
const { Op } = require('sequelize');

class AuthorService {
    /**
     * Get all authors with optional filters
     */
    async getAllAuthors(filters = {}) {
        const { country, search, withBooks = false, limit = 50, offset = 0 } = filters;

        const where = {};
        const include = [];

        // Filter by country
        if (country) {
            where.country = { [Op.like]: `%${country}%` };
        }

        // Full-text search in name
        if (search) {
            where.name = { [Op.like]: `%${search}%` };
        }

        // Include books
        if (withBooks === 'true' || withBooks === true) {
            include.push({
                model: Book,
                as: 'books',
                attributes: ['book_id', 'title', 'isbn', 'publication_year']
            });
        }

        return await Author.findAll({
            where,
            include,
            limit: parseInt(limit),
            offset: parseInt(offset),
            order: [['name', 'ASC']]
        });
    }

    /**
     * Get an author with all books
     */
    async getAuthorById(authorId) {
        const author = await Author.findByPk(authorId, {
            include: [{
                model: Book,
                as: 'books',
                attributes: ['book_id', 'title', 'isbn', 'publication_year', 'pages']
            }]
        });

        if (!author) {
            throw new Error('Author not found');
        }

        return author;
    }

    /**
     * Create new author
     */
    async createAuthor(authorData) {
        const { name, country, birth_year } = authorData;

        if (!name) {
            throw new Error('Name is required');
        }

        // Check if author already exists
        const existingAuthor = await Author.findOne({ where: { name } });
        if (existingAuthor) {
            throw new Error(`Author "${name}" already exists`);
        }

        return await Author.create({
            name,
            country,
            birth_year
        });
    }

    /**
     * Update author
     */
    async updateAuthor(authorId, authorData) {
        const author = await Author.findByPk(authorId);

        if (!author) {
            throw new Error('Author not found');
        }

        const { name, country, birth_year } = authorData;

        // Check if name is already used by another author
        if (name && name !== author.name) {
            const existingAuthor = await Author.findOne({
                where: {
                    name,
                    author_id: { [Op.ne]: authorId }
                }
            });
            if (existingAuthor) {
                throw new Error(`Author "${name}" already exists`);
            }
        }

        await author.update({
            name: name || author.name,
            country: country !== undefined ? country : author.country,
            birth_year: birth_year !== undefined ? birth_year : author.birth_year
        });

        return author;
    }

    /**
     * Delete author
     */
    async deleteAuthor(authorId) {
        const author = await Author.findByPk(authorId, {
            include: [{ model: Book, as: 'books' }]
        });

        if (!author) {
            throw new Error('Author not found');
        }

        // Warning if author has books
        if (author.books && author.books.length > 0) {
            throw new Error(`Author still has ${author.books.length} books. Please delete books first or remove author reference.`);
        }

        await author.destroy();
        return true;
    }

    /**
     * Get books by an author
     */
    async getAuthorBooks(authorId) {
        const author = await Author.findByPk(authorId);
        if (!author) {
            throw new Error('Author not found');
        }

        return await Book.findAll({
            where: { author_id: authorId },
            order: [['publication_year', 'DESC']]
        });
    }
}

module.exports = new AuthorService();
