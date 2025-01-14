import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bloc = context.read<ProductsBloc>();
        if (bloc.state is CategoriesLoaded) {
          return true;
        }
        bloc.add(LoadCategories());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state is ProductsInitial) {
              context.read<ProductsBloc>().add(LoadCategories());
            }

            if (state is ProductsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoriesLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        state.categories[index].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        final category = state.categories[index];
                        context.read<ProductsBloc>().add(
                          LoadProductsByCategory(category),
                        );
                        Navigator.pushNamed(
                          context,
                          '/products',
                          arguments: category,
                        );
                      },
                    ),
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductsBloc>().add(LoadCategories());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is ProductsInitial) {
              context.read<ProductsBloc>().add(LoadCategories());
            }

            return const Center(child: Text('No categories available'));
          },
        ),
      ),
    );
  }
}