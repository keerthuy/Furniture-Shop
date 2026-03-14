const express = require('express');
const User = require('../models/User');
const Product = require('../models/Product');
const Order = require('../models/Order');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/admin/stats
// @desc    Get dashboard statistics
// @access  Private (seller/admin)
router.get('/stats', protect, authorize('seller', 'admin'), async (req, res, next) => {
  try {
    const totalProducts = await Product.countDocuments();
    const totalOrders = await Order.countDocuments();
    const totalCustomers = await User.countDocuments({ role: 'customer' });

    // Revenue
    const revenueResult = await Order.aggregate([
      { $match: { status: { $ne: 'Cancelled' } } },
      { $group: { _id: null, totalRevenue: { $sum: '$totalPrice' } } },
    ]);
    const totalRevenue = revenueResult.length > 0 ? revenueResult[0].totalRevenue : 0;

    // Orders today
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const ordersToday = await Order.countDocuments({
      createdAt: { $gte: today },
    });

    // Orders by status
    const ordersByStatus = await Order.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } },
    ]);

    // Recent orders
    const recentOrders = await Order.find()
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .limit(5);

    res.status(200).json({
      success: true,
      message: 'Dashboard stats fetched',
      data: {
        totalProducts,
        totalOrders,
        totalCustomers,
        totalRevenue,
        ordersToday,
        ordersByStatus,
        recentOrders,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @route   GET /api/admin/sellers
// @desc    Get all sellers (super admin)
// @access  Private (admin)
router.get('/sellers', protect, authorize('admin'), async (req, res, next) => {
  try {
    const sellers = await User.find({ role: 'seller' }).select('-password');

    res.status(200).json({
      success: true,
      message: 'Sellers fetched successfully',
      data: sellers,
    });
  } catch (error) {
    next(error);
  }
});

// @route   POST /api/admin/sellers
// @desc    Create a seller account (super admin)
// @access  Private (admin)
router.post('/sellers', protect, authorize('admin'), async (req, res, next) => {
  try {
    const { name, email, password, phone, address } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'User with this email already exists',
        data: null,
      });
    }

    const seller = await User.create({
      name,
      email,
      password,
      phone,
      address,
      role: 'seller',
    });

    res.status(201).json({
      success: true,
      message: 'Seller account created successfully',
      data: {
        id: seller._id,
        name: seller.name,
        email: seller.email,
        role: seller.role,
      },
    });
  } catch (error) {
    next(error);
  }
});

// @route   PUT /api/admin/sellers/:id/toggle
// @desc    Activate/deactivate a seller (super admin)
// @access  Private (admin)
router.put('/sellers/:id/toggle', protect, authorize('admin'), async (req, res, next) => {
  try {
    const seller = await User.findById(req.params.id);

    if (!seller || seller.role !== 'seller') {
      return res.status(404).json({
        success: false,
        message: 'Seller not found',
        data: null,
      });
    }

    // Toggle role between seller and customer (effectively blocking)
    seller.role = seller.role === 'seller' ? 'customer' : 'seller';
    await seller.save();

    res.status(200).json({
      success: true,
      message: `Seller ${seller.role === 'seller' ? 'activated' : 'blocked'} successfully`,
      data: seller,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
