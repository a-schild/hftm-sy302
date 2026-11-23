require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { testConnection } = require('./src/config/database');
const { syncDatabase } = require('./src/models');
const routes = require('./src/routes');
const errorHandler = require('./src/middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request Logging Middleware (Development)
if (process.env.NODE_ENV === 'development') {
    app.use((req, res, next) => {
        console.log(`${req.method} ${req.path}`);
        next();
    });
}

// API Routes
app.use('/api', routes);

// 404 Handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        error: 'Endpoint not found',
        path: req.path
    });
});

// Error handler (must come last)
app.use(errorHandler);

// Start server
const startServer = async () => {
    try {
        // Test database connection
        await testConnection();

        // Synchronize database (in Development mode)
        if (process.env.NODE_ENV === 'development') {
            await syncDatabase(false); // false = don't delete data
        }

        // Start server
        app.listen(PORT, () => {
            console.log(`\n${'='.repeat(50)}`);
            console.log(`Server running on port ${PORT}`);
            console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
            console.log(`API: http://localhost:${PORT}/api`);
            console.log(`${'='.repeat(50)}\n`);
        });
    } catch (error) {
        console.error('Error starting server:', error);
        process.exit(1);
    }
};

// Start server
startServer();

// Graceful Shutdown
process.on('SIGINT', async () => {
    console.log('\nShutting down server...');
    process.exit(0);
});

module.exports = app;
