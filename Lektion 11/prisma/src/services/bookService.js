/**
 * Book Service
 * Business logic for book-related operations
 */

const { prisma } = require('../config/prisma');

class BookService {
  /**
   * Get all books with optional filters
   * @param {Object} filters - Filter options (author, year, category, search, limit, offset)
   * @returns {Promise<Array>} List of books
   */
  async getAllBooks(filters = {}) {
    const { author, year, category, search, limit = 50, offset = 0 } = filters;

    const where = {};

    // Filter by publication year
    if (year) {
      where.publicationYear = parseInt(year);
    }

    // Full-text search in title
    if (search) {
      where.title = {
        contains: search,
      };
    }

    // Filter by author name
    if (author) {
      where.author = {
        name: {
          contains: author,
        },
      };
    }

    // Filter by category
    if (category) {
      where.categories = {
        some: {
          category: {
            name: {
              contains: category,
            },
          },
        },
      };
    }

    return await prisma.book.findMany({
      where,
      include: {
        author: {
          select: {
            id: true,
            name: true,
            country: true,
          },
        },
        categories: {
          select: {
            category: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
      },
      take: parseInt(limit),
      skip: parseInt(offset),
      orderBy: {
        title: 'asc',
      },
    });
  }

  /**
   * Get a single book by ID with all relationships
   * @param {number} bookId - Book ID
   * @returns {Promise<Object>} Book object
   */
  async getBookById(bookId) {
    const book = await prisma.book.findUnique({
      where: { id: parseInt(bookId) },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            country: true,
            birthYear: true,
          },
        },
        categories: {
          select: {
            category: {
              select: {
                id: true,
                name: true,
                description: true,
              },
            },
          },
        },
      },
    });

    if (!book) {
      throw new Error('Book not found');
    }

    // Transform categories for cleaner response
    const transformedBook = {
      ...book,
      categories: book.categories.map(bc => bc.category),
    };

    return transformedBook;
  }

  /**
   * Create a new book with validation
   * @param {Object} bookData - Book data
   * @returns {Promise<Object>} Created book
   */
  async createBook(bookData) {
    const { title, authorId, isbn, publicationYear, pages, categories } = bookData;

    // Validation: Required fields
    if (!title) {
      throw new Error('Title is required');
    }

    // Check if ISBN already exists
    if (isbn) {
      const existingBook = await prisma.book.findUnique({
        where: { isbn },
      });
      if (existingBook) {
        throw new Error(`Book with ISBN ${isbn} already exists`);
      }
    }

    // Check if author exists
    if (authorId) {
      const author = await prisma.author.findUnique({
        where: { id: parseInt(authorId) },
      });
      if (!author) {
        throw new Error('Author not found');
      }
    }

    // Create book with categories
    const book = await prisma.book.create({
      data: {
        title,
        authorId: authorId ? parseInt(authorId) : null,
        isbn,
        publicationYear: publicationYear ? parseInt(publicationYear) : null,
        pages: pages ? parseInt(pages) : null,
        categories: categories && categories.length > 0 ? {
          create: categories.map(catId => ({
            categoryId: parseInt(catId),
          })),
        } : undefined,
      },
    });

    // Return book with relationships
    return await this.getBookById(book.id);
  }

  /**
   * Update a book
   * @param {number} bookId - Book ID
   * @param {Object} bookData - Updated book data
   * @returns {Promise<Object>} Updated book
   */
  async updateBook(bookId, bookData) {
    const { title, authorId, isbn, publicationYear, pages, categories } = bookData;

    // Check if book exists
    const existingBook = await prisma.book.findUnique({
      where: { id: parseInt(bookId) },
    });

    if (!existingBook) {
      throw new Error('Book not found');
    }

    // Check if ISBN is already used by another book
    if (isbn && isbn !== existingBook.isbn) {
      const duplicateBook = await prisma.book.findUnique({
        where: { isbn },
      });
      if (duplicateBook && duplicateBook.id !== parseInt(bookId)) {
        throw new Error(`Book with ISBN ${isbn} already exists`);
      }
    }

    // Check if author exists
    if (authorId) {
      const author = await prisma.author.findUnique({
        where: { id: parseInt(authorId) },
      });
      if (!author) {
        throw new Error('Author not found');
      }
    }

    // Update book
    await prisma.book.update({
      where: { id: parseInt(bookId) },
      data: {
        title: title || existingBook.title,
        authorId: authorId !== undefined ? (authorId ? parseInt(authorId) : null) : existingBook.authorId,
        isbn: isbn !== undefined ? isbn : existingBook.isbn,
        publicationYear: publicationYear !== undefined ? (publicationYear ? parseInt(publicationYear) : null) : existingBook.publicationYear,
        pages: pages !== undefined ? (pages ? parseInt(pages) : null) : existingBook.pages,
      },
    });

    // Update categories if provided
    if (categories !== undefined) {
      await this.updateBookCategories(bookId, categories);
    }

    return await this.getBookById(bookId);
  }

  /**
   * Delete a book
   * @param {number} bookId - Book ID
   * @returns {Promise<boolean>} Success status
   */
  async deleteBook(bookId) {
    const book = await prisma.book.findUnique({
      where: { id: parseInt(bookId) },
    });

    if (!book) {
      throw new Error('Book not found');
    }

    await prisma.book.delete({
      where: { id: parseInt(bookId) },
    });

    return true;
  }

  /**
   * Add categories to a book
   * @param {number} bookId - Book ID
   * @param {Array<number>} categoryIds - Array of category IDs
   * @returns {Promise<boolean>} Success status
   */
  async addCategoriesToBook(bookId, categoryIds) {
    const book = await prisma.book.findUnique({
      where: { id: parseInt(bookId) },
    });

    if (!book) {
      throw new Error('Book not found');
    }

    // Add categories (avoid duplicates)
    for (const catId of categoryIds) {
      await prisma.bookCategory.upsert({
        where: {
          bookId_categoryId: {
            bookId: parseInt(bookId),
            categoryId: parseInt(catId),
          },
        },
        update: {},
        create: {
          bookId: parseInt(bookId),
          categoryId: parseInt(catId),
        },
      });
    }

    return true;
  }

  /**
   * Update book categories (replaces all existing categories)
   * @param {number} bookId - Book ID
   * @param {Array<number>} categoryIds - Array of category IDs
   * @returns {Promise<boolean>} Success status
   */
  async updateBookCategories(bookId, categoryIds) {
    const book = await prisma.book.findUnique({
      where: { id: parseInt(bookId) },
    });

    if (!book) {
      throw new Error('Book not found');
    }

    // Delete existing categories
    await prisma.bookCategory.deleteMany({
      where: { bookId: parseInt(bookId) },
    });

    // Add new categories
    if (categoryIds && categoryIds.length > 0) {
      await prisma.bookCategory.createMany({
        data: categoryIds.map(catId => ({
          bookId: parseInt(bookId),
          categoryId: parseInt(catId),
        })),
      });
    }

    return true;
  }

  /**
   * Get statistics
   * @returns {Promise<Object>} Statistics object
   */
  async getStatistics() {
    const [totalBooks, totalAuthors, totalCategories] = await Promise.all([
      prisma.book.count(),
      prisma.author.count(),
      prisma.category.count(),
    ]);

    return {
      totalBooks,
      totalAuthors,
      totalCategories,
    };
  }
}

module.exports = new BookService();
