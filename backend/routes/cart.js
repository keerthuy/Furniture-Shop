const express = require('express');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const { protect } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/cart
// @desc    Get user's cart
// @access  Private
router.get('/', protect, async (req, res, next) => {
  try {
    let cart = await Cart.findOne({ userId: req.user._id }).populate(
      'items.productId',
      'name price images stock'
    );

    if (!cart) {
      cart = { userId: req.user._id, items: [] };
    }

    res.status(200).json({
      success: true,
      message: 'Cart fetched successfully',
      data: cart,
    });
  } catch (error) {
    next(error);
  }
});

// @route   POST /api/cart
// @desc    Add item to cart
// @access  Private
router.post('/', protect, async (req, res, next) => {
  try {
    const { productId, quantity } = req.body;

    if (!productId || !quantity || quantity < 1) {
      return res.status(400).json({
        success: false,
        message: 'Please provide valid productId and quantity',
        data: null,
      });
    }

    // Check if product exists and has stock
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
        data: null,
      });
    }

    if (product.stock < quantity) {
      return res.status(400).json({
        success: false,
        message: `Only ${product.stock} items available in stock`,
        data: null,
      });
    }

    let cart = await Cart.findOne({ userId: req.user._id });

    if (!cart) {
      cart = new Cart({ userId: req.user._id, items: [] });
    }

    // Check if product already in cart
    const existingItem = cart.items.find(
      (item) => item.productId.toString() === productId
    );

    if (existingItem) {
      existingItem.quantity += quantity;
      existingItem.price = product.price;
    } else {
      cart.items.push({
        productId,
        quantity,
        price: product.price,
      });
    }

    await cart.save();

    // Populate product details for response
    cart = await Cart.findOne({ userId: req.user._id }).populate(
      'items.productId',
      'name price images stock'
    );

    res.status(200).json({
      success: true,
      message: 'Item added to cart',
      data: cart,
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/cart/:productId
// @desc    Update item quantity in cart
// @access  Private
router.put('/:productId', protect, async (req, res, next) => {
  try {
    const { quantity } = req.body;

    if (!quantity || quantity < 1) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a valid quantity',
        data: null,
      });
    }

    const cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found',
        data: null,
      });
    }

    const item = cart.items.find(
      (item) => item.productId.toString() === req.params.productId
    );

    if (!item) {
      return res.status(404).json({
        success: false,
        message: 'Item not found in cart',
        data: null,
      });
    }

    // Check stock
    const product = await Product.findById(req.params.productId);
    if (product.stock < quantity) {
      return res.status(400).json({
        success: false,
        message: `Only ${product.stock} items available in stock`,
        data: null,
      });
    }

    item.quantity = quantity;
    await cart.save();

    const updatedCart = await Cart.findOne({ userId: req.user._id }).populate(
      'items.productId',
      'name price images stock'
    );

    res.status(200).json({
      success: true,
      message: 'Cart updated successfully',
      data: updatedCart,
    });
  } catch (error) {
    next(error);
  }
});

// @route   DELETE /api/cart/:productId
// @desc    Remove item from cart
// @access  Private
router.delete('/:productId', protect, async (req, res, next) => {
  try {
    const cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found',
        data: null,
      });
    }

    cart.items = cart.items.filter(
      (item) => item.productId.toString() !== req.params.productId
    );

    await cart.save();

    const updatedCart = await Cart.findOne({ userId: req.user._id }).populate(
      'items.productId',
      'name price images stock'
    );

    res.status(200).json({
      success: true,
      message: 'Item removed from cart',
      data: updatedCart,
    });
  } catch (error) {
    next(error);
  }
});

// @route   DELETE /api/cart
// @desc    Clear entire cart
// @access  Private
router.delete('/', protect, async (req, res, next) => {
  try {
    await Cart.findOneAndDelete({ userId: req.user._id });

    res.status(200).json({
      success: true,
      message: 'Cart cleared',
      data: null,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
