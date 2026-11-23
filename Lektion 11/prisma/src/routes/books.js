/**
 * Book Routes
 * Defines all routes for book-related endpoints
 */

const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');
const { validateBook, validateId } = require('../middleware/validator');

// Statistics (must be before /:id to avoid "statistics" being interpreted as ID)
router.get('/statistics', bookController.getStatistics);

// CRUD Routes
router.get('/', bookController.getAllBooks);
router.get('/:id', validateId, bookController.getBookById);
router.post('/', validateBook, bookController.createBook);
router.put('/:id', validateId, validateBook, bookController.updateBook);
router.delete('/:id', validateId, bookController.deleteBook);

// Add categories to book
router.post('/:id/categories', validateId, bookController.addCategories);

module.exports = router;
