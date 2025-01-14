import 'dart:convert';
import 'package:crud/cart_app/product/model/product.dart';
import 'package:http/http.dart' as http;

import 'constant/networking/networking_services.dart';


class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';
  final String? token;
  final NetworkService networkService;

  ApiService({this.token, required this.networkService});

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/products/categories'));

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$category'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> productsJson = jsonDecode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> getProductDetails(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId'),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product details');
    }
  }

  Future<void> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/carts'),
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'productId': productId, 'quantity': quantity}
        ]
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> removeFromCart({
    required int cartId,
    required int productId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/carts/$cartId/remove'),
    );

    if (response.statusCode != 200) {
      throw Exception('Oops! Your Cart is feeling lonely. Lets fill it up!');
    }
  }

  Future<void> updateCartQuantity({
    required int cartId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/carts/$cartId'),
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart');
    }
  }
}