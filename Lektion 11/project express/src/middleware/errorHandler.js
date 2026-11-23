const { ValidationError, UniqueConstraintError, ForeignKeyConstraintError } = require('sequelize');

/**
 * Central error handler for all errors
 */
const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);

    // Sequelize Validation Error
    if (err instanceof ValidationError) {
        return res.status(400).json({
            success: false,
            error: 'Validation error',
            details: err.errors.map(e => ({
                field: e.path,
                message: e.message
            }))
        });
    }

    // Sequelize Unique Constraint Error
    if (err instanceof UniqueConstraintError) {
        const field = err.errors[0]?.path || 'unknown field';
        return res.status(409).json({
            success: false,
            error: 'Record already exists',
            field: field
        });
    }

    // Sequelize Foreign Key Constraint Error
    if (err instanceof ForeignKeyConstraintError) {
        return res.status(400).json({
            success: false,
            error: 'Reference error: Linked record does not exist'
        });
    }

    // Custom Application Errors
    if (err.message) {
        // If it's a known error, it has already been handled in the controller
        // This handler only catches unexpected errors
    }

    // Default: Internal server error
    res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
};

module.exports = errorHandler;
