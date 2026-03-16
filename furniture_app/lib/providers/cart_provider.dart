import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get(ApiConfig.cart, auth: true);
      final data = res['data'];
      if (data != null && data['items'] != null) {
        _items =
            (data['items'] as List).map((e) => CartItem.fromJson(e)).toList();
      } else {
        _items = [];
      }
    } catch (_) {
      _items = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToCart(String productId, {int quantity = 1}) async {
    try {
      await ApiService.post(ApiConfig.cart, {
        'productId': productId,
        'quantity': quantity,
      }, auth: true);
      await fetchCart();
      return true;
    } catch (_) {
      return false;
    }
  }

  void addItem(CartItem newItem) {
    final index = items.indexWhere(
      (item) => item.productId == newItem.productId,
    );

    if (index >= 0) {
      items[index].quantity += 1;
    } else {
      items.add(newItem);
    }

    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      await ApiService.put('${ApiConfig.cart}/$productId', {
        'quantity': quantity,
      }, auth: true);
      await fetchCart();
    } catch (_) {}
  }

  Future<void> removeItem(String productId) async {
    try {
      await ApiService.delete('${ApiConfig.cart}/$productId', auth: true);
      await fetchCart();
    } catch (_) {}
  }

  Future<void> clearCart() async {
    try {
      await ApiService.delete(ApiConfig.cart, auth: true);
      _items = [];
      notifyListeners();
    } catch (_) {}
  }
}
