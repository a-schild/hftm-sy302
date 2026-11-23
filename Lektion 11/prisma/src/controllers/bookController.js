/**
 * Book Controller
 * Handles HTTP requests for book-related endpoints
 */

const bookService = require('../services/bookService');

class BookController {
  /**
   * GET /api/books
   * Get all books with optional filters
   */
  async getAllBooks(req, res, next) {
    try {
      const books = await bookService.getAllBooks(req.query);
      res.json({
        success: true,
        count: books.length,
        data: books,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/books/:id
   * Get a single book
   */
  async getBookById(req, res, next) {
    try {
      const book = await bookService.getBookById(req.params.id);
      res.json({
        success: true,
        data: book,
      });
    } catch (error) {
      if (error.message === 'Book not found') {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * POST /api/books
   * Create a new book
   */
  async createBook(req, res, next) {
    try {
      const book = await bookService.createBook(req.body);
      res.status(201).json({
        success: true,
        message: 'Book created successfully',
        data: book,
      });
    } catch (error) {
      if (
        error.message.includes('already exists') ||
        error.message.includes('required') ||
        error.message.includes('not found')
      ) {
        return res.status(400).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * PUT /api/books/:id
   * Update a book
   */
  async updateBook(req, res, next) {
    try {
      const book = await bookService.updateBook(req.params.id, req.body);
      res.json({
        success: true,
        message: 'Book updated successfully',
        data: book,
      });
    } catch (error) {
      if (error.message === 'Book not found') {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      if (
        error.message.includes('already exists') ||
        error.message.includes('not found')
      ) {
        return res.status(400).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * DELETE /api/books/:id
   * Delete a book
   */
  async deleteBook(req, res, next) {
    try {
      await bookService.deleteBook(req.params.id);
      res.status(204).send();
    } catch (error) {
      if (error.message === 'Book not found') {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * POST /api/books/:id/categories
   * Add categories to a book
   */
  async addCategories(req, res, next) {
    try {
      const { categoryIds } = req.body;

      if (!Array.isArray(categoryIds) || categoryIds.length === 0) {
        return res.status(400).json({
          success: false,
          error: 'categoryIds must be an array with at least one entry',
        });
      }

      await bookService.addCategoriesToBook(req.params.id, categoryIds);
      const book = await bookService.getBookById(req.params.id);

      res.json({
        success: true,
        message: 'Categories added successfully',
        data: book,
      });
    } catch (error) {
      if (error.message === 'Book not found') {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * GET /api/books/statistics
   * Get statistics
   */
  async getStatistics(req, res, next) {
    try {
      const stats = await bookService.getStatistics();
      res.json({
        success: true,
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new BookController();
