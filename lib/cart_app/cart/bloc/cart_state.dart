import 'package:equatable/equatable.dart';

import '../cart_item.dart';

abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;

  CartLoaded({
    required this.items,
    required this.total,
  });

  @override
  List<Object?> get props => [items, total];
}

class CartError extends CartState {
  final String message;

  CartError(this.message);

  @override
  List<Object?> get props => [message];
}