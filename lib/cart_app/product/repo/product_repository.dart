

import '../../api_services.dart';
import '../../cache_services.dart';
import '../model/product.dart';

class ProductRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  ProductRepository(this._apiService, this._cacheService);

  Future<List<String>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cacheService.getCachedCategories();
      if (cached != null) return cached;
    }

    final categories = await _apiService.getCategories();
    await _cacheService.cacheCategories(categories);
    return categories;
  }

  Future<List<Product>> getProductsByCategory(
      String category, {
        bool forceRefresh = false,
      }) async {
    if (!forceRefresh) {
      final cached = await _cacheService.getCachedProducts(category);
      if (cached != null) return cached;
    }

    final products = await _apiService.getProductsByCategory(category);
    await _cacheService.cacheProducts(category, products);
    return products;
  }

  Future<Product> getProductDetails(int productId) async {
    return await _apiService.getProductDetails(productId);
  }
}