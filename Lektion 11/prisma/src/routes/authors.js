/**
 * Author Routes
 * Defines all routes for author-related endpoints
 */

const express = require('express');
const router = express.Router();
const authorController = require('../controllers/authorController');
const { validateAuthor, validateId } = require('../middleware/validator');

// CRUD Routes
router.get('/', authorController.getAllAuthors);
router.get('/:id', validateId, authorController.getAuthorById);
router.post('/', validateAuthor, authorController.createAuthor);
router.put('/:id', validateId, validateAuthor, authorController.updateAuthor);
router.delete('/:id', validateId, authorController.deleteAuthor);

// Get all books by an author
router.get('/:id/books', validateId, authorController.getAuthorBooks);

module.exports = router;
