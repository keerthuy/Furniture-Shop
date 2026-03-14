const express = require('express');
const { validationResult } = require('express-validator');
const Product = require('../models/Product');
const { protect, authorize } = require('../middleware/auth');
const { productValidation } = require('../middleware/validate');
const upload = require('../utils/upload');
const cloudinary = require('../config/cloudinary');

const router = express.Router();

// @route   GET /api/products
// @desc    Get all products with pagination, search, filter
// @access  Public
router.get('/', async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 12;
    const skip = (page - 1) * limit;

    // Build filter object
    const filter = {};

    // Category filter
    if (req.query.category) {
      filter.category = req.query.category;
    }

    // Price range filter
    if (req.query.minPrice || req.query.maxPrice) {
      filter.price = {};
      if (req.query.minPrice) filter.price.$gte = parseFloat(req.query.minPrice);
      if (req.query.maxPrice) filter.price.$lte = parseFloat(req.query.maxPrice);
    }

    // Search by name/description
    if (req.query.search) {
      filter.$text = { $search: req.query.search };
    }

    // In stock only
    if (req.query.inStock === 'true') {
      filter.stock = { $gt: 0 };
    }

    // Sort
    let sort = { createdAt: -1 };
    if (req.query.sort === 'price_asc') sort = { price: 1 };
    if (req.query.sort === 'price_desc') sort = { price: -1 };
    if (req.query.sort === 'popular') sort = { ratings: -1 };
    if (req.query.sort === 'newest') sort = { createdAt: -1 };

    const total = await Product.countDocuments(filter);
    const products = await Product.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(limit)
      .populate('sellerId', 'name');

    res.status(200).json({
      success: true,
      message: 'Products fetched successfully',
      data: {
        products,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit),
        },
      },
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/products/categories
// @desc    Get all product categories
// @access  Public
router.get('/categories', async (req, res) => {
  const categories = [
    'Living Room',
    'Bedroom',
    'Dining',
    'Office',
    'Outdoor',
    'Kitchen',
    'Bathroom',
    'Kids',
    'Storage',
    'Decor',
  ];
  res.status(200).json({
    success: true,
    message: 'Categories fetched',
    data: categories,
  });
});

// @route   GET /api/products/featured
// @desc    Get featured products (highest rated)
// @access  Public
router.get('/featured', async (req, res, next) => {
  try {
    const products = await Product.find({ stock: { $gt: 0 } })
      .sort({ ratings: -1, createdAt: -1 })
      .limit(10)
      .populate('sellerId', 'name');

    res.status(200).json({
      success: true,
      message: 'Featured products fetched',
      data: products,
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/products/:id
// @desc    Get single product
// @access  Public
router.get('/:id', async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id).populate('sellerId', 'name');

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
        data: null,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Product fetched successfully',
      data: product,
    });
  } catch (error) {
    next(error);
  }
});

// @route   POST /api/products
// @desc    Create a product
// @access  Private (seller/admin)
router.post(
  '/',
  protect,
  authorize('seller', 'admin'),
  upload.array('images', 5),
  productValidation,
  async (req, res, next) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: errors.array().map((e) => e.msg).join(', '),
          data: null,
        });
      }

      const { name, description, price, category, stock } = req.body;

      // Process uploaded images
      const images = req.files
        ? req.files.map((file) => ({
            public_id: file.filename,
            url: file.path,
          }))
        : [];

      const product = await Product.create({
        name,
        description,
        price,
        category,
        stock,
        images,
        sellerId: req.user._id,
      });

      res.status(201).json({
        success: true,
        message: 'Product created successfully',
        data: product,
      });
    } catch (error) {
      next(error);
    }
  }
);

// @route   PUT /api/products/:id
// @desc    Update a product
// @access  Private (seller/admin)
router.put(
  '/:id',
  protect,
  authorize('seller', 'admin'),
  upload.array('images', 5),
  async (req, res, next) => {
    try {
      let product = await Product.findById(req.params.id);

      if (!product) {
        return res.status(404).json({
          success: false,
          message: 'Product not found',
          data: null,
        });
      }

      // Check ownership (sellers can only update their own products)
      if (
        req.user.role === 'seller' &&
        product.sellerId.toString() !== req.user._id.toString()
      ) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to update this product',
          data: null,
        });
      }

      const updateData = { ...req.body };

      // Handle new images
      if (req.files && req.files.length > 0) {
        // Delete old images from Cloudinary
        if (product.images && product.images.length > 0) {
          for (const img of product.images) {
            await cloudinary.uploader.destroy(img.public_id);
          }
        }

        updateData.images = req.files.map((file) => ({
          public_id: file.filename,
          url: file.path,
        }));
      }

      product = await Product.findByIdAndUpdate(req.params.id, updateData, {
        new: true,
        runValidators: true,
      });

      res.status(200).json({
        success: true,
        message: 'Product updated successfully',
        data: product,
      });
    } catch (error) {
      next(error);
    }
  }
);

// @route   DELETE /api/products/:id
// @desc    Delete a product
// @access  Private (seller/admin)
router.delete('/:id', protect, authorize('seller', 'admin'), async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
        data: null,
      });
    }

    // Check ownership
    if (
      req.user.role === 'seller' &&
      product.sellerId.toString() !== req.user._id.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this product',
        data: null,
      });
    }

    // Delete images from Cloudinary
    if (product.images && product.images.length > 0) {
      for (const img of product.images) {
        await cloudinary.uploader.destroy(img.public_id);
      }
    }

    await Product.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Product deleted successfully',
      data: null,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
