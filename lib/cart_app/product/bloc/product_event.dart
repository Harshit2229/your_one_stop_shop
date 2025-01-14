import 'package:equatable/equatable.dart';

abstract class ProductsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCategories extends ProductsEvent {}

class LoadProductsByCategory extends ProductsEvent {
  final String category;

  LoadProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadProductDetails extends ProductsEvent {
  final int productId;

  LoadProductDetails(this.productId);

  @override
  List<Object?> get props => [productId];
}