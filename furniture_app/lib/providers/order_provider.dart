import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.get('${ApiConfig.orders}?limit=50', auth: true);
      final data = res['data'];
      _orders = (data['orders'] as List).map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> placeOrder(List<Map<String, dynamic>> items, String address, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiConfig.orders, {
        'items': items,
        'deliveryAddress': address,
        'phone': phone,
      }, auth: true);
      final order = Order.fromJson(res['data']);
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
