/**
 * Category Controller
 * Handles HTTP requests for category-related endpoints
 */

const categoryService = require('../services/categoryService');

class CategoryController {
  /**
   * GET /api/categories
   * Get all categories
   */
  async getAllCategories(req, res, next) {
    try {
      const categories = await categoryService.getAllCategories(req.query);
      res.json({
        success: true,
        count: categories.length,
        data: categories,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/categories/:id
   * Get a single category
   */
  async getCategoryById(req, res, next) {
    try {
      const category = await categoryService.getCategoryById(req.params.id);
      res.json({
        success: true,
        data: category,
      });
    } catch (error) {
      if (error.message === 'Category not found') {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * POST /api/categories
   * Create a new category
   */
  async createCategory(req, res, next) {
    try {
      const category = await categoryService.createCategory(req.body);
      res.status(201).json({
        success: true,
        message: 'Category created successfully',
        data: category,
      });
    } catch (error) {
      if (
        error.message.includes('already exists') ||
        error.message.includes('required')
      ) {
        return res.status(400).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * PUT /api/categories/:id
   * Update a category
   */
  async updateCategory(req, res, next) {
    try {
      const category = await categoryService.updateCategory(
        req.params.id,
        req.body
      );
      res.json({
        success: true,
        message: 'Category updated successfully',
        data: category,
      });
    } catch (error) {
      if (error.message === 'Category not found') {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      if (error.message.includes('already exists')) {
        return res.status(400).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }

  /**
   * DELETE /api/categories/:id
   * Delete a category
   */
  async deleteCategory(req, res, next) {
    try {
      await categoryService.deleteCategory(req.params.id);
      res.status(204).send();
    } catch (error) {
      if (error.message === 'Category not found') {
        return res.status(404).json({
          success: false,
          error: error.message,
        });
      }
      next(error);
    }
  }
}

module.exports = new CategoryController();
