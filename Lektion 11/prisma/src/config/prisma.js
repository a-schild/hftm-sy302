/**
 * Prisma Client Configuration
 * Singleton instance of Prisma Client for database operations
 */

const { PrismaClient } = require('@prisma/client');

// Create Prisma Client instance with logging configuration
const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development'
    ? ['query', 'info', 'warn', 'error']
    : ['warn', 'error'],
});

/**
 * Test database connection
 * Attempts to connect to the database and logs the result
 */
const testConnection = async () => {
  try {
    await prisma.$connect();
    console.log('✓ Database connection established successfully');
  } catch (error) {
    console.error('✗ Database connection error:', error.message);
    process.exit(1);
  }
};

/**
 * Disconnect from database
 * Gracefully closes the database connection
 */
const disconnect = async () => {
  await prisma.$disconnect();
  console.log('Database connection closed');
};

module.exports = { prisma, testConnection, disconnect };
