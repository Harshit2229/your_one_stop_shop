import 'package:equatable/equatable.dart';

import '../../product/model/product.dart';


abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final Product product;
  final int quantity;

  AddToCart({required this.product, this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveFromCart extends CartEvent {
  final int productId;

  RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateCartQuantity extends CartEvent {
  final int productId;
  final int quantity;

  UpdateCartQuantity({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}