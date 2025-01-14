import 'package:crud/cart_app/product/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/error_view.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
                state is ProductsLoaded
                    ? state.category.toUpperCase()
                    : 'Products'
            ),
            leading: BackButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<ProductsBloc>().add(LoadCategories());
              },
            ),
          ),
          body: _buildBody(context, state), // Pass context here
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    if (state is ProductsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductsLoaded) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              context.read<ProductsBloc>().add(
                LoadProductDetails(product.id),
              );
              Navigator.pushNamed(context, '/product-details');
            },
          );
        },
      );
    }

    if (state is ProductsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            ElevatedButton(
              onPressed: () {
                if (state.category != null) {
                  context.read<ProductsBloc>().add(
                    LoadProductsByCategory(state.category!),
                  );
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('No products available'));
  }
}