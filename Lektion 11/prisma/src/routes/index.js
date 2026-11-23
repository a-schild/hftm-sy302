/**
 * Route Index
 * Aggregates all route modules
 */

const express = require('express');
const router = express.Router();

const bookRoutes = require('./books');
const authorRoutes = require('./authors');
const categoryRoutes = require('./categories');

// API Routes
router.use('/books', bookRoutes);
router.use('/authors', authorRoutes);
router.use('/categories', categoryRoutes);

// Health Check Endpoint
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'API is running',
    timestamp: new Date().toISOString(),
  });
});

// Root Endpoint with API documentation
router.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Library API with Express & Prisma',
    version: '1.0.0',
    endpoints: {
      books: '/api/books',
      authors: '/api/authors',
      categories: '/api/categories',
      health: '/api/health',
    },
  });
});

module.exports = router;
