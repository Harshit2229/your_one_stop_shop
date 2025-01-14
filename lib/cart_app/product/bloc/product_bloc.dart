import 'package:crud/cart_app/product/bloc/product_event.dart';
import 'package:crud/cart_app/product/bloc/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api_services.dart';
import '../model/product.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ApiService _apiService;
  List<String> _categories = [];
  Map<String, List<Product>> _productsByCategory = {};
  String? _currentCategory; // This will store the current category

  ProductsBloc({required ApiService apiService})
      : _apiService = apiService,
        super(ProductsInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<LoadProductDetails>(_onLoadProductDetails);
  }

  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<ProductsState> emit,
      ) async {
    if (_categories.isNotEmpty) {
      emit(CategoriesLoaded(_categories));
      return;
    }

    emit(ProductsLoading());
    try {
      _categories = await _apiService.getCategories();
      emit(CategoriesLoaded(_categories));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onLoadProductsByCategory(
      LoadProductsByCategory event,
      Emitter<ProductsState> emit,
      ) async {
    _currentCategory = event.category; // Store current category

    // Check if we have cached products
    if (_productsByCategory.containsKey(event.category)) {
      emit(ProductsLoaded(
        products: _productsByCategory[event.category]!,
        category: event.category,
      ));
      return;
    }

    emit(ProductsLoading(category: event.category));
    try {
      final products = await _apiService.getProductsByCategory(event.category);
      _productsByCategory[event.category] = products;
      emit(ProductsLoaded(products: products, category: event.category));
    } catch (e) {
      emit(ProductsError(e.toString(), category: event.category));
    }
  }

  Future<void> _onLoadProductDetails(
      LoadProductDetails event,
      Emitter<ProductsState> emit,
      ) async {
    Product? cachedProduct;

    // First try to find the product in the current category
    if (_currentCategory != null && _productsByCategory.containsKey(_currentCategory)) {
      try {
        cachedProduct = _productsByCategory[_currentCategory]!.firstWhere(
              (p) => p.id == event.productId,
        );
      } catch (_) {
        // Product not found in current category
      }
    }

    // If not found in current category, search all categories
    if (cachedProduct == null) {
      for (var products in _productsByCategory.values) {
        try {
          cachedProduct = products.firstWhere(
                (p) => p.id == event.productId,
          );
          break;
        } catch (_) {
          continue;
        }
      }
    }

    if (cachedProduct != null) {
      emit(ProductDetailsLoaded(cachedProduct));
      return;
    }

    emit(ProductsLoading());
    try {
      final product = await _apiService.getProductDetails(event.productId);
      emit(ProductDetailsLoaded(product));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  // Updated getCurrentCategory method
  String? getCurrentCategory() {
    return _currentCategory; // Return the stored current category
  }

  // Method to reload current category products
  void reloadCurrentCategory() {
    if (_currentCategory != null) {
      add(LoadProductsByCategory(_currentCategory!));
    }
  }

  void clearCache() {
    _categories = [];
    _productsByCategory = {};
    _currentCategory = null;
  }
}