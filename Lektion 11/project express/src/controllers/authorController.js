const authorService = require('../services/authorService');

class AuthorController {
    /**
     * GET /api/authors
     * Get all authors
     */
    async getAllAuthors(req, res, next) {
        try {
            const authors = await authorService.getAllAuthors(req.query);
            res.json({
                success: true,
                count: authors.length,
                data: authors
            });
        } catch (error) {
            next(error);
        }
    }

    /**
     * GET /api/authors/:id
     * Get an author
     */
    async getAuthorById(req, res, next) {
        try {
            const author = await authorService.getAuthorById(req.params.id);
            res.json({
                success: true,
                data: author
            });
        } catch (error) {
            if (error.message === 'Author not found') {
                return res.status(404).json({
                    success: false,
                    error: error.message
                });
            }
            next(error);
        }
    }

    /**
     * POST /api/authors
     * Create new author
     */
    async createAuthor(req, res, next) {
        try {
            const author = await authorService.createAuthor(req.body);
            res.status(201).json({
                success: true,
                message: 'Author successfully created',
                data: author
            });
        } catch (error) {
            if (error.message.includes('existiert bereits') ||
                error.message.includes('erforderlich')) {
                return res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
            next(error);
        }
    }

    /**
     * PUT /api/authors/:id
     * Update author
     */
    async updateAuthor(req, res, next) {
        try {
            const author = await authorService.updateAuthor(req.params.id, req.body);
            res.json({
                success: true,
                message: 'Author successfully updated',
                data: author
            });
        } catch (error) {
            if (error.message === 'Author not found') {
                return res.status(404).json({
                    success: false,
                    error: error.message
                });
            }
            if (error.message.includes('existiert bereits')) {
                return res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
            next(error);
        }
    }

    /**
     * DELETE /api/authors/:id
     * Delete author
     */
    async deleteAuthor(req, res, next) {
        try {
            await authorService.deleteAuthor(req.params.id);
            res.status(204).send();
        } catch (error) {
            if (error.message === 'Author not found') {
                return res.status(404).json({
                    success: false,
                    error: error.message
                });
            }
            if (error.message.includes('hat noch')) {
                return res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
            next(error);
        }
    }

    /**
     * GET /api/authors/:id/books
     * Get all books by an author
     */
    async getAuthorBooks(req, res, next) {
        try {
            const books = await authorService.getAuthorBooks(req.params.id);
            res.json({
                success: true,
                count: books.length,
                data: books
            });
        } catch (error) {
            if (error.message === 'Author not found') {
                return res.status(404).json({
                    success: false,
                    error: error.message
                });
            }
            next(error);
        }
    }
}

module.exports = new AuthorController();
