/**
 * Author Service
 * Business logic for author-related operations
 */

const { prisma } = require('../config/prisma');

class AuthorService {
  /**
   * Get all authors with optional filters
   * @param {Object} filters - Filter options (country, search, withBooks, limit, offset)
   * @returns {Promise<Array>} List of authors
   */
  async getAllAuthors(filters = {}) {
    const { country, search, withBooks = false, limit = 50, offset = 0 } = filters;

    const where = {};

    // Filter by country
    if (country) {
      where.country = {
        contains: country,
      };
    }

    // Full-text search in name
    if (search) {
      where.name = {
        contains: search,
      };
    }

    const include = {};

    // Include books if requested
    if (withBooks === 'true' || withBooks === true) {
      include.books = {
        select: {
          id: true,
          title: true,
          isbn: true,
          publicationYear: true,
        },
      };
    }

    return await prisma.author.findMany({
      where,
      include,
      take: parseInt(limit),
      skip: parseInt(offset),
      orderBy: {
        name: 'asc',
      },
    });
  }

  /**
   * Get a single author by ID with all books
   * @param {number} authorId - Author ID
   * @returns {Promise<Object>} Author object
   */
  async getAuthorById(authorId) {
    const author = await prisma.author.findUnique({
      where: { id: parseInt(authorId) },
      include: {
        books: {
          select: {
            id: true,
            title: true,
            isbn: true,
            publicationYear: true,
            pages: true,
          },
        },
      },
    });

    if (!author) {
      throw new Error('Author not found');
    }

    return author;
  }

  /**
   * Create a new author
   * @param {Object} authorData - Author data
   * @returns {Promise<Object>} Created author
   */
  async createAuthor(authorData) {
    const { name, country, birthYear } = authorData;

    if (!name) {
      throw new Error('Name is required');
    }

    // Check if author already exists
    const existingAuthor = await prisma.author.findFirst({
      where: { name },
    });

    if (existingAuthor) {
      throw new Error(`Author "${name}" already exists`);
    }

    return await prisma.author.create({
      data: {
        name,
        country,
        birthYear: birthYear ? parseInt(birthYear) : null,
      },
    });
  }

  /**
   * Update an author
   * @param {number} authorId - Author ID
   * @param {Object} authorData - Updated author data
   * @returns {Promise<Object>} Updated author
   */
  async updateAuthor(authorId, authorData) {
    const { name, country, birthYear } = authorData;

    // Check if author exists
    const existingAuthor = await prisma.author.findUnique({
      where: { id: parseInt(authorId) },
    });

    if (!existingAuthor) {
      throw new Error('Author not found');
    }

    // Check if name is already used by another author
    if (name && name !== existingAuthor.name) {
      const duplicateAuthor = await prisma.author.findFirst({
        where: {
          name,
          NOT: {
            id: parseInt(authorId),
          },
        },
      });

      if (duplicateAuthor) {
        throw new Error(`Author "${name}" already exists`);
      }
    }

    return await prisma.author.update({
      where: { id: parseInt(authorId) },
      data: {
        name: name || existingAuthor.name,
        country: country !== undefined ? country : existingAuthor.country,
        birthYear: birthYear !== undefined ? (birthYear ? parseInt(birthYear) : null) : existingAuthor.birthYear,
      },
    });
  }

  /**
   * Delete an author
   * @param {number} authorId - Author ID
   * @returns {Promise<boolean>} Success status
   */
  async deleteAuthor(authorId) {
    const author = await prisma.author.findUnique({
      where: { id: parseInt(authorId) },
      include: {
        books: true,
      },
    });

    if (!author) {
      throw new Error('Author not found');
    }

    // Check if author has books
    if (author.books && author.books.length > 0) {
      throw new Error(`Author has ${author.books.length} books. Please delete books first or remove author reference.`);
    }

    await prisma.author.delete({
      where: { id: parseInt(authorId) },
    });

    return true;
  }

  /**
   * Get all books by an author
   * @param {number} authorId - Author ID
   * @returns {Promise<Array>} List of books
   */
  async getAuthorBooks(authorId) {
    const author = await prisma.author.findUnique({
      where: { id: parseInt(authorId) },
    });

    if (!author) {
      throw new Error('Author not found');
    }

    return await prisma.book.findMany({
      where: { authorId: parseInt(authorId) },
      orderBy: {
        publicationYear: 'desc',
      },
    });
  }
}

module.exports = new AuthorService();
