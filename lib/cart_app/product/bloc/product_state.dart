import 'package:equatable/equatable.dart';

import '../model/product.dart';


abstract class ProductsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {
  final String? category; // Optional category for loading state

  ProductsLoading({this.category});

  @override
  List<Object?> get props => [category];
}

class CategoriesLoaded extends ProductsState {
  final List<String> categories;

  CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final String category;

  ProductsLoaded({
    required this.products,
    required this.category,
  });

  @override
  List<Object?> get props => [products, category];
}

class ProductDetailsLoaded extends ProductsState {
  final Product product;

  ProductDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductsError extends ProductsState {
  final String message;
  final String? category; // Add category to error state

  ProductsError(this.message, {this.category});

  @override
  List<Object?> get props => [message, category];
}