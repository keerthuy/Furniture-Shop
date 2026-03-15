import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user');
      final token = prefs.getString('token');
      if (userData != null && userData.isNotEmpty && token != null && token.isNotEmpty) {
        _user = User.fromJson(jsonDecode(userData));
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('token');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password, String phone, String address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiConfig.authRegister, {
        'name': name, 'email': email, 'password': password,
        'phone': phone, 'address': address,
      });
      final data = res['data'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      _user = User.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.post(ApiConfig.authLogin, {
        'email': email, 'password': password,
      });
      final data = res['data'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      _user = User.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String phone, String address) async {
    try {
      final res = await ApiService.put(ApiConfig.authProfile, {
        'name': name, 'phone': phone, 'address': address,
      }, auth: true);
      final data = res['data'];
      _user = User.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(data));
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
