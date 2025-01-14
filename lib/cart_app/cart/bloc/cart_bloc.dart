import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api_services.dart';
import '../cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';


class CartBloc extends Bloc<CartEvent, CartState> {
  final ApiService _apiService;

  CartBloc({required ApiService apiService})
      : _apiService = apiService,
        super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      try {
        await _apiService.addToCart(
          userId: 1, // In a real app, get this from user session
          productId: event.product.id,
          quantity: event.quantity,
        );

        final updatedItems = List<CartItem>.from(currentState.items);
        final existingItemIndex = updatedItems
            .indexWhere((item) => item.product.id == event.product.id);

        if (existingItemIndex >= 0) {
          updatedItems[existingItemIndex] = CartItem(
            product: event.product,
            quantity: updatedItems[existingItemIndex].quantity + event.quantity,
          );
        } else {
          updatedItems.add(CartItem(
            product: event.product,
            quantity: event.quantity,
          ));
        }

        emit(CartLoaded(
          items: updatedItems,
          total: _calculateTotal(updatedItems),
        ));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    } else {
      try {
        await _apiService.addToCart(
          userId: 1,
          productId: event.product.id,
          quantity: event.quantity,
        );

        emit(CartLoaded(
          items: [CartItem(product: event.product, quantity: event.quantity)],
          total: event.product.price * event.quantity,
        ));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event,
      Emitter<CartState> emit,
      ) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      try {
        await _apiService.removeFromCart(
          cartId: 1,
          productId: event.productId,
        );

        final updatedItems = currentState.items
            .where((item) => item.product.id != event.productId)
            .toList();

        emit(CartLoaded(
          items: updatedItems,
          total: _calculateTotal(updatedItems),
        ));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateCartQuantity(
      UpdateCartQuantity event,
      Emitter<CartState> emit,
      ) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      try {
        await _apiService.updateCartQuantity(
          cartId: 1,
          productId: event.productId,
          quantity: event.quantity,
        );

        final updatedItems = currentState.items.map((item) {
          if (item.product.id == event.productId) {
            return CartItem(
              product: item.product,
              quantity: event.quantity,
            );
          }
          return item;
        }).toList();

        emit(CartLoaded(
          items: updatedItems,
          total: _calculateTotal(updatedItems),
        ));
      } catch (e) {
        emit(CartError(e.toString()));
      }
    }
  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold(
      0,
          (total, item) => total + (item.product.price * item.quantity),
    );
  }
}