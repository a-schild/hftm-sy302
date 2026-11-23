const { Category, Book } = require('../models');
const { Op } = require('sequelize');

class CategoryService {
    /**
     * Get all categories
     */
    async getAllCategories(filters = {}) {
        const { withBooks = false, limit = 50, offset = 0 } = filters;

        const include = [];

        if (withBooks === 'true' || withBooks === true) {
            include.push({
                model: Book,
                as: 'books',
                attributes: ['book_id', 'title', 'author_id'],
                through: { attributes: [] }
            });
        }

        return await Category.findAll({
            include,
            limit: parseInt(limit),
            offset: parseInt(offset),
            order: [['name', 'ASC']]
        });
    }

    /**
     * Get a category with all books
     */
    async getCategoryById(categoryId) {
        const category = await Category.findByPk(categoryId, {
            include: [{
                model: Book,
                as: 'books',
                attributes: ['book_id', 'title', 'author_id', 'publication_year'],
                through: { attributes: [] }
            }]
        });

        if (!category) {
            throw new Error('Category not found');
        }

        return category;
    }

    /**
     * Create new category
     */
    async createCategory(categoryData) {
        const { name, description } = categoryData;

        if (!name) {
            throw new Error('Name is required');
        }

        // Check if category already exists
        const existingCategory = await Category.findOne({ where: { name } });
        if (existingCategory) {
            throw new Error(`Category "${name}" already exists`);
        }

        return await Category.create({
            name,
            description
        });
    }

    /**
     * Update category
     */
    async updateCategory(categoryId, categoryData) {
        const category = await Category.findByPk(categoryId);

        if (!category) {
            throw new Error('Category not found');
        }

        const { name, description } = categoryData;

        // Check if name is already used by another category
        if (name && name !== category.name) {
            const existingCategory = await Category.findOne({
                where: {
                    name,
                    category_id: { [Op.ne]: categoryId }
                }
            });
            if (existingCategory) {
                throw new Error(`Category "${name}" already exists`);
            }
        }

        await category.update({
            name: name || category.name,
            description: description !== undefined ? description : category.description
        });

        return category;
    }

    /**
     * Delete category
     */
    async deleteCategory(categoryId) {
        const category = await Category.findByPk(categoryId);

        if (!category) {
            throw new Error('Category not found');
        }

        await category.destroy();
        return true;
    }
}

module.exports = new CategoryService();
