/**
 * Validation middleware for books
 */
const validateBook = (req, res, next) => {
    const { title, isbn, publication_year, pages } = req.body;

    const errors = [];

    // Validate title
    if (req.method === 'POST' && !title) {
        errors.push({ field: 'title', message: 'Title is required' });
    }

    if (title && (title.length < 1 || title.length > 255)) {
        errors.push({ field: 'title', message: 'Title must be between 1 and 255 characters long' });
    }

    // Validate ISBN
    if (isbn && !/^[\d-]+$/.test(isbn)) {
        errors.push({ field: 'isbn', message: 'ISBN may only contain numbers and hyphens' });
    }

    // Validate publication year
    if (publication_year) {
        const year = parseInt(publication_year);
        if (isNaN(year) || year < 1000 || year > new Date().getFullYear() + 1) {
            errors.push({
                field: 'publication_year',
                message: 'Publication year must be between 1000 and ' + (new Date().getFullYear() + 1)
            });
        }
    }

    // Validate page count
    if (pages) {
        const pageCount = parseInt(pages);
        if (isNaN(pageCount) || pageCount < 1) {
            errors.push({ field: 'pages', message: 'Page count must be at least 1' });
        }
    }

    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            error: 'Validation error',
            details: errors
        });
    }

    next();
};

/**
 * Validation middleware for authors
 */
const validateAuthor = (req, res, next) => {
    const { name, birth_year } = req.body;

    const errors = [];

    // Validate name
    if (req.method === 'POST' && !name) {
        errors.push({ field: 'name', message: 'Name is required' });
    }

    if (name && (name.length < 2 || name.length > 255)) {
        errors.push({ field: 'name', message: 'Name must be between 2 and 255 characters long' });
    }

    // Validate birth year
    if (birth_year) {
        const year = parseInt(birth_year);
        if (isNaN(year) || year < 1000 || year > new Date().getFullYear()) {
            errors.push({
                field: 'birth_year',
                message: 'Birth year must be between 1000 and ' + new Date().getFullYear()
            });
        }
    }

    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            error: 'Validation error',
            details: errors
        });
    }

    next();
};

/**
 * Validation middleware for categories
 */
const validateCategory = (req, res, next) => {
    const { name } = req.body;

    const errors = [];

    // Validate name
    if (req.method === 'POST' && !name) {
        errors.push({ field: 'name', message: 'Name is required' });
    }

    if (name && (name.length < 1 || name.length > 100)) {
        errors.push({ field: 'name', message: 'Name must be between 1 and 100 characters long' });
    }

    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            error: 'Validation error',
            details: errors
        });
    }

    next();
};

/**
 * Validation middleware for ID parameters
 */
const validateId = (req, res, next) => {
    const id = parseInt(req.params.id);

    if (isNaN(id) || id < 1) {
        return res.status(400).json({
            success: false,
            error: 'Invalid ID: Must be a positive number'
        });
    }

    next();
};

module.exports = {
    validateBook,
    validateAuthor,
    validateCategory,
    validateId
};
