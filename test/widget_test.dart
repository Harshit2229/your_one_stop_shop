import 'package:crud/cart_app/api_services.dart';
import 'package:crud/cart_app/cache_services.dart';
import 'package:crud/cart_app/constant/networking/networking_services.dart';
import 'package:crud/cart_app/product/repo/product_repository.dart';
import 'package:crud/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cacheService = CacheService(prefs);
    final networkService = NetworkService(baseUrl: 'https://fakestoreapi.com');
    final apiService = ApiService(networkService: networkService);
    final productRepository = ProductRepository(apiService, cacheService);

    await tester.pumpWidget(MyApp(productRepository: productRepository));

    // Basic test to verify app builds
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}