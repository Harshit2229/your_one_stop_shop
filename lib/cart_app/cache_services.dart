import 'dart:convert';
import 'package:crud/cart_app/product/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;
  static const String _categoriesKey = 'categories_cache';
  static const String _productsKey = 'products_cache';
  static const Duration _cacheDuration = Duration(hours: 24);

  CacheService(this._prefs);

  Future<void> cacheCategories(List<String> categories) async {
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': categories,
    };
    await _prefs.setString(_categoriesKey, jsonEncode(data));
  }

  Future<List<String>?> getCachedCategories() async {
    final cached = _prefs.getString(_categoriesKey);
    if (cached != null) {
      final data = jsonDecode(cached);
      final timestamp = DateTime.parse(data['timestamp']);
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return List<String>.from(data['data']);
      }
    }
    return null;
  }

  Future<void> cacheProducts(String category, List<Product> products) async {
    final key = '${_productsKey}_$category';
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'data': products.map((p) => p.toJson()).toList(),
    };
    await _prefs.setString(key, jsonEncode(data));
  }

  Future<List<Product>?> getCachedProducts(String category) async {
    final key = '${_productsKey}_$category';
    final cached = _prefs.getString(key);
    if (cached != null) {
      final data = jsonDecode(cached);
      final timestamp = DateTime.parse(data['timestamp']);
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return (data['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      }
    }
    return null;
  }

  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where((key) =>
    key.startsWith(_categoriesKey) || key.startsWith(_productsKey));
    for (var key in keys) {
      await _prefs.remove(key);
    }
  }
}