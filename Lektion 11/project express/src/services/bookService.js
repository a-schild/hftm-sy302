const { Book, Author, Category } = require('../models');
const { Op } = require('sequelize');

class BookService {
    /**
     * Get all books with optional filters
     */
    async getAllBooks(filters = {}) {
        const { author, year, category, search, limit = 50, offset = 0 } = filters;

        const where = {};
        const include = [];

        // Filter by publication year
        if (year) {
            where.publication_year = year;
        }

        // Full-text search in title
        if (search) {
            where.title = { [Op.like]: `%${search}%` };
        }

        // Always include Author
        const authorInclude = {
            model: Author,
            as: 'author',
            attributes: ['author_id', 'name', 'country']
        };

        // Filter by Author name
        if (author) {
            authorInclude.where = {
                name: { [Op.like]: `%${author}%` }
            };
        }

        include.push(authorInclude);

        // Include categories
        include.push({
            model: Category,
            as: 'categories',
            attributes: ['category_id', 'name'],
            through: { attributes: [] } // Hide junction table
        });

        return await Book.findAll({
            where,
            include,
            limit: parseInt(limit),
            offset: parseInt(offset),
            order: [['title', 'ASC']]
        });
    }

    /**
     * Get a book with all relationships
     */
    async getBookById(bookId) {
        const book = await Book.findByPk(bookId, {
            include: [
                {
                    model: Author,
                    as: 'author',
                    attributes: ['author_id', 'name', 'country', 'birth_year']
                },
                {
                    model: Category,
                    as: 'categories',
                    attributes: ['category_id', 'name', 'description'],
                    through: { attributes: [] }
                }
            ]
        });

        if (!book) {
            throw new Error('Book not found');
        }

        return book;
    }

    /**
     * Create new book with validation
     */
    async createBook(bookData) {
        const { title, author_id, isbn, publication_year, pages, categories } = bookData;

        // Validation: Required fields
        if (!title) {
            throw new Error('Title is required');
        }

        // Check if ISBN already exists
        if (isbn) {
            const existingBook = await Book.findOne({ where: { isbn } });
            if (existingBook) {
                throw new Error(`Book with ISBN ${isbn} already exists`);
            }
        }

        // Check if Author exists
        if (author_id) {
            const author = await Author.findByPk(author_id);
            if (!author) {
                throw new Error('Author not found');
            }
        }

        // Create book
        const book = await Book.create({
            title,
            author_id,
            isbn,
            publication_year,
            pages
        });

        // Add categories
        if (categories && categories.length > 0) {
            await this.addCategoriesToBook(book.book_id, categories);
        }

        // Return book with relationships
        return await this.getBookById(book.book_id);
    }

    /**
     * Update book
     */
    async updateBook(bookId, bookData) {
        const book = await Book.findByPk(bookId);

        if (!book) {
            throw new Error('Book not found');
        }

        const { title, author_id, isbn, publication_year, pages, categories } = bookData;

        // Check if ISBN is already used by another book
        if (isbn && isbn !== book.isbn) {
            const existingBook = await Book.findOne({
                where: {
                    isbn,
                    book_id: { [Op.ne]: bookId }
                }
            });
            if (existingBook) {
                throw new Error(`Book with ISBN ${isbn} already exists`);
            }
        }

        // Check if Author exists
        if (author_id) {
            const author = await Author.findByPk(author_id);
            if (!author) {
                throw new Error('Author not found');
            }
        }

        // Update book
        await book.update({
            title: title || book.title,
            author_id: author_id !== undefined ? author_id : book.author_id,
            isbn: isbn !== undefined ? isbn : book.isbn,
            publication_year: publication_year !== undefined ? publication_year : book.publication_year,
            pages: pages !== undefined ? pages : book.pages
        });

        // Update categories
        if (categories !== undefined) {
            await this.updateBookCategories(bookId, categories);
        }

        return await this.getBookById(bookId);
    }

    /**
     * Delete book
     */
    async deleteBook(bookId) {
        const book = await Book.findByPk(bookId);

        if (!book) {
            throw new Error('Book not found');
        }

        await book.destroy();
        return true;
    }

    /**
     * Add categories to book
     */
    async addCategoriesToBook(bookId, categoryIds) {
        const book = await Book.findByPk(bookId);
        if (!book) {
            throw new Error('Book not found');
        }

        await book.addCategories(categoryIds);
        return true;
    }

    /**
     * Update book categories
     */
    async updateBookCategories(bookId, categoryIds) {
        const book = await Book.findByPk(bookId);
        if (!book) {
            throw new Error('Book not found');
        }

        await book.setCategories(categoryIds);
        return true;
    }

    /**
     * Get statistics
     */
    async getStatistics() {
        const totalBooks = await Book.count();
        const totalAuthors = await Author.count();
        const totalCategories = await Category.count();

        return {
            totalBooks,
            totalAuthors,
            totalCategories
        };
    }
}

module.exports = new BookService();
