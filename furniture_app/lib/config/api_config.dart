class ApiConfig {
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  static const String baseUrl = 'http://10.91.35.162:5000/api'; // Physical device
  // static const String baseUrl = 'http://YOUR_IP:5000/api'; // Physical device

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authProfile = '/auth/profile';

  static const String products = '/products';
  static const String productsFeatured = '/products/featured';
  static const String productsCategories = '/products/categories';

  static const String cart = '/cart';
  static const String orders = '/orders';
}
