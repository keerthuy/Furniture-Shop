import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featured = [];
  List<String> _categories = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  int _page = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _selectedCategory = '';
  String _sortBy = 'newest';

  List<Product> get products => _products;
  List<Product> get featured => _featured;
  List<String> get categories => _categories;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  int get page => _page;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Future<void> fetchFeatured() async {
    try {
      print('Fetching featured from: ${ApiConfig.productsFeatured}');
      final res = await ApiService.get(ApiConfig.productsFeatured);
      print('Featured response: $res');
      _featured =
          (res['data'] as List).map((e) => Product.fromJson(e)).toList();
      print('Featured loaded: ${_featured.length} items');
      notifyListeners();
    } catch (e) {
      print('Featured fetch error: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await ApiService.get(ApiConfig.productsCategories);
      _categories = List<String>.from(res['data']);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (loadMore) {
      if (_page >= _totalPages) return;
      _page++;
    } else {
      _page = 1;
      _products = [];
    }

    _isLoading = true;
    notifyListeners();

    try {
      String endpoint =
          '${ApiConfig.products}?page=$_page&limit=12&sort=$_sortBy';
      if (_searchQuery.isNotEmpty) endpoint += '&search=$_searchQuery';
      if (_selectedCategory.isNotEmpty)
        endpoint += '&category=$_selectedCategory';

      final res = await ApiService.get(endpoint);
      final data = res['data'];
      final newProducts =
          (data['products'] as List).map((e) => Product.fromJson(e)).toList();

      if (loadMore) {
        _products.addAll(newProducts);
      } else {
        _products = newProducts;
      }

      _totalPages = data['pagination']['pages'] ?? 1;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProductById(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('${ApiConfig.products}/$id');
      _selectedProduct = Product.fromJson(res['data']);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    fetchProducts();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    fetchProducts();
  }

  void setSort(String sort) {
    _sortBy = sort;
    fetchProducts();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _sortBy = 'newest';
    fetchProducts();
  }
}
