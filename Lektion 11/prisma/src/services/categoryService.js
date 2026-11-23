/**
 * Category Service
 * Business logic for category-related operations
 */

const { prisma } = require('../config/prisma');

class CategoryService {
  /**
   * Get all categories
   * @param {Object} filters - Filter options (withBooks, limit, offset)
   * @returns {Promise<Array>} List of categories
   */
  async getAllCategories(filters = {}) {
    const { withBooks = false, limit = 50, offset = 0 } = filters;

    const include = {};

    if (withBooks === 'true' || withBooks === true) {
      include.books = {
        select: {
          book: {
            select: {
              id: true,
              title: true,
              authorId: true,
            },
          },
        },
      };
    }

    const categories = await prisma.category.findMany({
      include,
      take: parseInt(limit),
      skip: parseInt(offset),
      orderBy: {
        name: 'asc',
      },
    });

    // Transform books for cleaner response
    if (withBooks === 'true' || withBooks === true) {
      return categories.map(cat => ({
        ...cat,
        books: cat.books?.map(bc => bc.book) || [],
      }));
    }

    return categories;
  }

  /**
   * Get a single category by ID with all books
   * @param {number} categoryId - Category ID
   * @returns {Promise<Object>} Category object
   */
  async getCategoryById(categoryId) {
    const category = await prisma.category.findUnique({
      where: { id: parseInt(categoryId) },
      include: {
        books: {
          select: {
            book: {
              select: {
                id: true,
                title: true,
                authorId: true,
                publicationYear: true,
              },
            },
          },
        },
      },
    });

    if (!category) {
      throw new Error('Category not found');
    }

    // Transform books for cleaner response
    return {
      ...category,
      books: category.books.map(bc => bc.book),
    };
  }

  /**
   * Create a new category
   * @param {Object} categoryData - Category data
   * @returns {Promise<Object>} Created category
   */
  async createCategory(categoryData) {
    const { name, description } = categoryData;

    if (!name) {
      throw new Error('Name is required');
    }

    // Check if category already exists
    const existingCategory = await prisma.category.findUnique({
      where: { name },
    });

    if (existingCategory) {
      throw new Error(`Category "${name}" already exists`);
    }

    return await prisma.category.create({
      data: {
        name,
        description,
      },
    });
  }

  /**
   * Update a category
   * @param {number} categoryId - Category ID
   * @param {Object} categoryData - Updated category data
   * @returns {Promise<Object>} Updated category
   */
  async updateCategory(categoryId, categoryData) {
    const { name, description } = categoryData;

    // Check if category exists
    const existingCategory = await prisma.category.findUnique({
      where: { id: parseInt(categoryId) },
    });

    if (!existingCategory) {
      throw new Error('Category not found');
    }

    // Check if name is already used by another category
    if (name && name !== existingCategory.name) {
      const duplicateCategory = await prisma.category.findUnique({
        where: { name },
      });

      if (duplicateCategory && duplicateCategory.id !== parseInt(categoryId)) {
        throw new Error(`Category "${name}" already exists`);
      }
    }

    return await prisma.category.update({
      where: { id: parseInt(categoryId) },
      data: {
        name: name || existingCategory.name,
        description: description !== undefined ? description : existingCategory.description,
      },
    });
  }

  /**
   * Delete a category
   * @param {number} categoryId - Category ID
   * @returns {Promise<boolean>} Success status
   */
  async deleteCategory(categoryId) {
    const category = await prisma.category.findUnique({
      where: { id: parseInt(categoryId) },
    });

    if (!category) {
      throw new Error('Category not found');
    }

    // Prisma will automatically delete associated book_categories due to CASCADE
    await prisma.category.delete({
      where: { id: parseInt(categoryId) },
    });

    return true;
  }
}

module.exports = new CategoryService();
