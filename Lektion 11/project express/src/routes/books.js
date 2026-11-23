const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');
const { validateBook, validateId } = require('../middleware/validator');

// Statistics (must be before /:id, otherwise "statistics" will be interpreted as ID)
router.get('/statistics', bookController.getStatistics);

// CRUD Routes
router.get('/', bookController.getAllBooks);
router.get('/:id', validateId, bookController.getBookById);
router.post('/', validateBook, bookController.createBook);
router.put('/:id', validateId, validateBook, bookController.updateBook);
router.delete('/:id', validateId, bookController.deleteBook);

// Add categories
router.post('/:id/categories', validateId, bookController.addCategories);

module.exports = router;
