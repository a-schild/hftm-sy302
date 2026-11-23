/**
 * Error Handler Middleware
 * Centralized error handling for all errors
 */

const { Prisma } = require('@prisma/client');

/**
 * Error handler middleware
 * Catches and formats errors before sending response to client
 */
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Prisma Validation Error
  if (err instanceof Prisma.PrismaClientValidationError) {
    return res.status(400).json({
      success: false,
      error: 'Validation error',
      message: 'Invalid data provided',
    });
  }

  // Prisma Known Request Error (e.g., unique constraint, foreign key)
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    // Unique constraint violation
    if (err.code === 'P2002') {
      const field = err.meta?.target?.[0] || 'unknown field';
      return res.status(409).json({
        success: false,
        error: 'Record already exists',
        field: field,
      });
    }

    // Foreign key constraint violation
    if (err.code === 'P2003') {
      return res.status(400).json({
        success: false,
        error: 'Foreign key constraint failed',
        message: 'Referenced record does not exist',
      });
    }

    // Record not found
    if (err.code === 'P2025') {
      return res.status(404).json({
        success: false,
        error: 'Record not found',
      });
    }
  }

  // Prisma Connection Error
  if (err instanceof Prisma.PrismaClientInitializationError) {
    return res.status(503).json({
      success: false,
      error: 'Database connection error',
      message: 'Could not connect to database',
    });
  }

  // Custom Application Errors
  // These are already handled in controllers, but this catches any that slip through

  // Default: Internal Server Error
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
};

module.exports = errorHandler;
