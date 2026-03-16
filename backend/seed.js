const mongoose = require('mongoose');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const User = require('./models/User');
const Product = require('./models/Product');

// Load env vars
dotenv.config();

// Connect to database
connectDB();

const users = [
  {
    name: 'Admin User',
    email: 'admin@furnshop.com',
    password: 'admin123',
    phone: '+91 9876543210',
    address: '123 Admin Street, Mumbai',
    role: 'admin',
  },
  {
    name: 'Seller One',
    email: 'seller@furnshop.com',
    password: 'seller123',
    phone: '+91 9876543211',
    address: '456 Seller Ave, Delhi',
    role: 'seller',
  },
  {
    name: 'John Customer',
    email: 'user@furnshop.com',
    password: 'user123',
    phone: '+91 9876543212',
    address: '789 Customer Lane, Bangalore',
    role: 'customer',
  },
];

const seedData = async () => {
  try {
    console.log('Clearing existing users...');
    await User.deleteMany();

    console.log('Injecting seed users...');
    await User.create(users);

    console.log('Database Seeding Completed!');
    console.log('You can now log in with the test credentials.');
    process.exit();
  } catch (err) {
    console.error(`Error with seeding data: ${err.message}`);
    process.exit(1);
  }
};

seedData();
