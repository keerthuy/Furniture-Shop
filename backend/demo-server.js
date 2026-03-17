/**
 * DEMO SERVER — No MongoDB required!
 * Uses in-memory data with pre-seeded demo accounts.
 *
 * Demo Credentials:
 *   Admin:    admin@furnshop.com    / admin123
 *   Seller:   seller@furnshop.com   / seller123
 *   Customer: user@furnshop.com     / user123
 */

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const app = express();
const JWT_SECRET = 'demo_jwt_secret_key_2026';
const PORT = 5000;

app.use(cors({ origin: '*', credentials: true }));
app.use(express.json({ limit: '10mb' }));

// ── In-Memory Database ──────────────────────────────────────────────
const salt = bcrypt.genSaltSync(10);

const users = [
  { _id: 'u1', name: 'Admin User', email: 'admin@furnshop.com', password: bcrypt.hashSync('admin123', salt), phone: '+91 9876543210', address: '123 Admin Street, Mumbai', role: 'admin', createdAt: new Date() },
  { _id: 'u2', name: 'Seller One', email: 'seller@furnshop.com', password: bcrypt.hashSync('seller123', salt), phone: '+91 9876543211', address: '456 Seller Ave, Delhi', role: 'seller', createdAt: new Date() },
  { _id: 'u3', name: 'John Customer', email: 'user@furnshop.com', password: bcrypt.hashSync('user123', salt), phone: '+91 9876543212', address: '789 Customer Lane, Bangalore', role: 'customer', createdAt: new Date() },
];


const orders = [
  { _id: 'o1', userId: { _id: 'u3', name: 'John Customer', email: 'user@furnshop.com', phone: '+91 9876543212', address: '789 Customer Lane, Bangalore' }, items: [{ productId: 'p1', name: 'Modern Sofa Set', quantity: 1, price: 45000, image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800' }], totalPrice: 45000, deliveryAddress: '789 Customer Lane, Bangalore', phone: '+91 9876543212', paymentMethod: 'COD', status: 'Delivered', createdAt: new Date(Date.now() - 7 * 86400000) },
  { _id: 'o2', userId: { _id: 'u3', name: 'John Customer', email: 'user@furnshop.com', phone: '+91 9876543212', address: '789 Customer Lane, Bangalore' }, items: [{ productId: 'p4', name: 'Ergonomic Office Chair', quantity: 2, price: 18500, image: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=800' }], totalPrice: 37000, deliveryAddress: '789 Customer Lane, Bangalore', phone: '+91 9876543212', paymentMethod: 'COD', status: 'Shipped', createdAt: new Date(Date.now() - 2 * 86400000) },
  { _id: 'o3', userId: { _id: 'u3', name: 'John Customer', email: 'user@furnshop.com', phone: '+91 9876543212', address: '789 Customer Lane, Bangalore' }, items: [{ productId: 'p8', name: 'Decorative Floor Lamp', quantity: 1, price: 5500, image: 'https://images.unsplash.com/photo-1507473885765-e6ed057ab6fe?w=800' }, { productId: 'p5', name: 'Bookshelf Cabinet', quantity: 1, price: 12000, image: 'https://images.unsplash.com/photo-1594620302200-9a762244a156?w=800' }], totalPrice: 17500, deliveryAddress: '789 Customer Lane, Bangalore', phone: '+91 9876543212', paymentMethod: 'COD', status: 'Pending', createdAt: new Date() },
];

const carts = {};

// ── Auth Helpers ─────────────────────────────────────────────────────
function generateToken(user) {
  return jwt.sign({ id: user._id, role: user.role }, JWT_SECRET, { expiresIn: '7d' });
}

function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) return res.status(401).json({ success: false, message: 'Not authorized', data: null });
  try {
    const decoded = jwt.verify(authHeader.split(' ')[1], JWT_SECRET);
    req.user = users.find(u => u._id === decoded.id);
    if (!req.user) return res.status(401).json({ success: false, message: 'User not found', data: null });
    next();
  } catch { return res.status(401).json({ success: false, message: 'Invalid token', data: null }); }
}

function authorize(...roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) return res.status(403).json({ success: false, message: 'Access denied', data: null });
    next();
  };
}

function sanitizeUser(u) {
  return { id: u._id, _id: u._id, name: u.name, email: u.email, phone: u.phone, address: u.address, role: u.role, createdAt: u.createdAt };
}

// ── AUTH ROUTES ──────────────────────────────────────────────────────
app.post('/api/auth/register', (req, res) => {
  const { name, email, password, phone, address } = req.body;
  if (!name || !email || !password || !phone || !address) return res.status(400).json({ success: false, message: 'All fields are required', data: null });
  if (users.find(u => u.email === email)) return res.status(400).json({ success: false, message: 'Email already exists', data: null });

  const user = { _id: 'u' + (users.length + 1), name, email, password: bcrypt.hashSync(password, salt), phone, address, role: 'customer', createdAt: new Date() };
  users.push(user);
  res.status(201).json({ success: true, message: 'Registration successful', data: { token: generateToken(user), user: sanitizeUser(user) } });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email);
  if (!user || !bcrypt.compareSync(password, user.password)) return res.status(401).json({ success: false, message: 'Invalid email or password', data: null });
  res.json({ success: true, message: 'Login successful', data: { token: generateToken(user), user: sanitizeUser(user) } });
});

app.get('/api/auth/me', authenticateToken, (req, res) => {
  res.json({ success: true, message: 'Profile fetched', data: sanitizeUser(req.user) });
});

app.put('/api/auth/profile', authenticateToken, (req, res) => {
  const { name, phone, address } = req.body;
  if (name) req.user.name = name;
  if (phone) req.user.phone = phone;
  if (address) req.user.address = address;
  res.json({ success: true, message: 'Profile updated', data: sanitizeUser(req.user) });
});

// ── PRODUCT ROUTES ───────────────────────────────────────────────────
app.get('/api/products', (req, res) => {
  let filtered = [...products];
  if (req.query.category) filtered = filtered.filter(p => p.category === req.query.category);
  if (req.query.search) { const s = req.query.search.toLowerCase(); filtered = filtered.filter(p => p.name.toLowerCase().includes(s) || p.description.toLowerCase().includes(s)); }
  if (req.query.minPrice) filtered = filtered.filter(p => p.price >= parseFloat(req.query.minPrice));
  if (req.query.maxPrice) filtered = filtered.filter(p => p.price <= parseFloat(req.query.maxPrice));

  if (req.query.sort === 'price_asc') filtered.sort((a, b) => a.price - b.price);
  else if (req.query.sort === 'price_desc') filtered.sort((a, b) => b.price - a.price);
  else if (req.query.sort === 'popular') filtered.sort((a, b) => b.ratings - a.ratings);
  else filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 12;
  const start = (page - 1) * limit;
  const paginated = filtered.slice(start, start + limit);

  res.json({ success: true, message: 'Products fetched', data: { products: paginated, pagination: { page, limit, total: filtered.length, pages: Math.ceil(filtered.length / limit) } } });
});

app.get('/api/products/categories', (req, res) => {
  res.json({ success: true, message: 'Categories fetched', data: ['Living Room', 'Bedroom', 'Dining', 'Office', 'Outdoor', 'Kitchen', 'Bathroom', 'Kids', 'Storage', 'Decor'] });
});

app.get('/api/products/featured', (req, res) => {
  const featured = [...products].sort((a, b) => b.ratings - a.ratings).slice(0, 10);
  res.json({ success: true, message: 'Featured products', data: featured });
});

app.get('/api/products/:id', (req, res) => {
  const product = products.find(p => p._id === req.params.id);
  if (!product) return res.status(404).json({ success: false, message: 'Product not found', data: null });
  res.json({ success: true, message: 'Product fetched', data: product });
});

app.post('/api/products', authenticateToken, authorize('seller', 'admin'), (req, res) => {
  const { name, description, price, category, stock } = req.body;
  const product = { _id: 'p' + (products.length + 1), name, description, price: parseFloat(price), images: [{ public_id: 'demo', url: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800' }], category, stock: parseInt(stock), sellerId: { _id: req.user._id, name: req.user.name }, ratings: 0, numReviews: 0, createdAt: new Date() };
  products.push(product);
  res.status(201).json({ success: true, message: 'Product created', data: product });
});

app.put('/api/products/:id', authenticateToken, authorize('seller', 'admin'), (req, res) => {
  const product = products.find(p => p._id === req.params.id);
  if (!product) return res.status(404).json({ success: false, message: 'Product not found', data: null });
  Object.assign(product, { ...req.body, price: req.body.price ? parseFloat(req.body.price) : product.price, stock: req.body.stock ? parseInt(req.body.stock) : product.stock });
  res.json({ success: true, message: 'Product updated', data: product });
});

app.delete('/api/products/:id', authenticateToken, authorize('seller', 'admin'), (req, res) => {
  const idx = products.findIndex(p => p._id === req.params.id);
  if (idx === -1) return res.status(404).json({ success: false, message: 'Product not found', data: null });
  products.splice(idx, 1);
  res.json({ success: true, message: 'Product deleted', data: null });
});

// ── CART ROUTES ──────────────────────────────────────────────────────
app.get('/api/cart', authenticateToken, (req, res) => {
  const cart = carts[req.user._id] || { userId: req.user._id, items: [] };
  const populated = { ...cart, items: cart.items.map(item => { const p = products.find(pr => pr._id === item.productId); return { ...item, productId: p ? { _id: p._id, name: p.name, price: p.price, images: p.images, stock: p.stock } : { _id: item.productId, name: 'Unknown', price: item.price, images: [], stock: 0 } }; }) };
  res.json({ success: true, message: 'Cart fetched', data: populated });
});

app.post('/api/cart', authenticateToken, (req, res) => {
  const { productId, quantity } = req.body;
  const product = products.find(p => p._id === productId);
  if (!product) return res.status(404).json({ success: false, message: 'Product not found', data: null });

  if (!carts[req.user._id]) carts[req.user._id] = { userId: req.user._id, items: [] };
  const cart = carts[req.user._id];
  const existing = cart.items.find(i => i.productId === productId);
  if (existing) { existing.quantity += quantity; existing.price = product.price; }
  else cart.items.push({ productId, quantity, price: product.price });

  const populated = { ...cart, items: cart.items.map(item => { const p = products.find(pr => pr._id === item.productId); return { ...item, productId: p ? { _id: p._id, name: p.name, price: p.price, images: p.images, stock: p.stock } : { _id: item.productId, name: 'Unknown', price: item.price, images: [], stock: 0 } }; }) };
  res.json({ success: true, message: 'Item added to cart', data: populated });
});

app.put('/api/cart/:productId', authenticateToken, (req, res) => {
  const cart = carts[req.user._id];
  if (!cart) return res.status(404).json({ success: false, message: 'Cart not found', data: null });
  const item = cart.items.find(i => i.productId === req.params.productId);
  if (!item) return res.status(404).json({ success: false, message: 'Item not found', data: null });
  item.quantity = req.body.quantity;
  res.json({ success: true, message: 'Cart updated', data: cart });
});

app.delete('/api/cart/:productId', authenticateToken, (req, res) => {
  const cart = carts[req.user._id];
  if (cart) cart.items = cart.items.filter(i => i.productId !== req.params.productId);
  res.json({ success: true, message: 'Item removed', data: cart || { items: [] } });
});

app.delete('/api/cart', authenticateToken, (req, res) => {
  delete carts[req.user._id];
  res.json({ success: true, message: 'Cart cleared', data: null });
});

// ── ORDER ROUTES ─────────────────────────────────────────────────────
app.post('/api/orders', authenticateToken, (req, res) => {
  const { items, deliveryAddress, phone } = req.body;
  const orderItems = items.map(item => { const p = products.find(pr => pr._id === item.productId); return { productId: item.productId, name: p?.name || 'Unknown', quantity: item.quantity, price: p?.price || 0, image: p?.images?.[0]?.url || '' }; });
  const totalPrice = orderItems.reduce((sum, i) => sum + i.price * i.quantity, 0);
  const order = { _id: 'o' + (orders.length + 1), userId: { _id: req.user._id, name: req.user.name, email: req.user.email, phone: req.user.phone }, items: orderItems, totalPrice, deliveryAddress, phone, paymentMethod: 'COD', status: 'Pending', createdAt: new Date() };
  orders.push(order);
  delete carts[req.user._id];
  res.status(201).json({ success: true, message: 'Order placed! Payment: Cash on Delivery', data: order });
});

app.get('/api/orders', authenticateToken, (req, res) => {
  let userOrders = orders.filter(o => (o.userId._id || o.userId) === req.user._id);
  const page = parseInt(req.query.page) || 1; const limit = parseInt(req.query.limit) || 10;
  res.json({ success: true, message: 'Orders fetched', data: { orders: userOrders.slice((page-1)*limit, page*limit), pagination: { page, limit, total: userOrders.length, pages: Math.ceil(userOrders.length / limit) } } });
});

app.get('/api/orders/all/admin', authenticateToken, authorize('seller', 'admin'), (req, res) => {
  let filtered = [...orders];
  if (req.query.status) filtered = filtered.filter(o => o.status === req.query.status);
  const page = parseInt(req.query.page) || 1; const limit = parseInt(req.query.limit) || 20;
  res.json({ success: true, message: 'All orders fetched', data: { orders: filtered.slice((page-1)*limit, page*limit), pagination: { page, limit, total: filtered.length, pages: Math.ceil(filtered.length / limit) } } });
});

app.get('/api/orders/:id', authenticateToken, (req, res) => {
  const order = orders.find(o => o._id === req.params.id);
  if (!order) return res.status(404).json({ success: false, message: 'Order not found', data: null });
  res.json({ success: true, message: 'Order fetched', data: order });
});

app.put('/api/orders/:id/status', authenticateToken, authorize('seller', 'admin'), (req, res) => {
  const order = orders.find(o => o._id === req.params.id);
  if (!order) return res.status(404).json({ success: false, message: 'Order not found', data: null });
  order.status = req.body.status;
  res.json({ success: true, message: `Order status updated to ${req.body.status}`, data: order });
});

// ── ADMIN ROUTES ─────────────────────────────────────────────────────
app.get('/api/admin/stats', authenticateToken, authorize('seller', 'admin'), (req, res) => {
  const totalRevenue = orders.filter(o => o.status !== 'Cancelled').reduce((sum, o) => sum + o.totalPrice, 0);
  const today = new Date(); today.setHours(0,0,0,0);
  const ordersByStatus = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map(s => ({ _id: s, count: orders.filter(o => o.status === s).length })).filter(s => s.count > 0);
  res.json({ success: true, message: 'Stats fetched', data: { totalProducts: products.length, totalOrders: orders.length, totalCustomers: users.filter(u => u.role === 'customer').length, totalRevenue, ordersToday: orders.filter(o => new Date(o.createdAt) >= today).length, ordersByStatus, recentOrders: orders.slice(-5).reverse() } });
});

app.get('/api/admin/sellers', authenticateToken, authorize('admin'), (req, res) => {
  res.json({ success: true, message: 'Sellers fetched', data: users.filter(u => u.role === 'seller').map(sanitizeUser) });
});

app.post('/api/admin/sellers', authenticateToken, authorize('admin'), (req, res) => {
  const { name, email, password, phone, address } = req.body;
  if (users.find(u => u.email === email)) return res.status(400).json({ success: false, message: 'Email exists', data: null });
  const seller = { _id: 'u' + (users.length + 1), name, email, password: bcrypt.hashSync(password, salt), phone, address, role: 'seller', createdAt: new Date() };
  users.push(seller);
  res.status(201).json({ success: true, message: 'Seller created', data: sanitizeUser(seller) });
});

app.put('/api/admin/sellers/:id/toggle', authenticateToken, authorize('admin'), (req, res) => {
  const seller = users.find(u => u._id === req.params.id);
  if (!seller) return res.status(404).json({ success: false, message: 'Seller not found', data: null });
  seller.role = seller.role === 'seller' ? 'customer' : 'seller';
  res.json({ success: true, message: `Seller ${seller.role === 'seller' ? 'activated' : 'blocked'}`, data: sanitizeUser(seller) });
});

// ── HEALTH CHECK ─────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'Demo API running (no database required)', data: { timestamp: new Date().toISOString(), mode: 'demo' } });
});

app.use('*', (req, res) => res.status(404).json({ success: false, message: 'Route not found', data: null }));

app.listen(PORT, () => {
  console.log(`\n🪑 FurnShop Demo Server running on http://localhost:${PORT}`);
  console.log(`\n📋 Demo Credentials:`);
  console.log(`   Admin:    admin@furnshop.com    / admin123`);
  console.log(`   Seller:   seller@furnshop.com   / seller123`);
  console.log(`   Customer: user@furnshop.com     / user123`);
  console.log(`\n🛒 ${products.length} products pre-loaded | ${orders.length} sample orders\n`);
});
