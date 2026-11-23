/**
 * Category Routes
 * Defines all routes for category-related endpoints
 */

const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { validateCategory, validateId } = require('../middleware/validator');

// CRUD Routes
router.get('/', categoryController.getAllCategories);
router.get('/:id', validateId, categoryController.getCategoryById);
router.post('/', validateCategory, categoryController.createCategory);
router.put('/:id', validateId, validateCategory, categoryController.updateCategory);
router.delete('/:id', validateId, categoryController.deleteCategory);

module.exports = router;
