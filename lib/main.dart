// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'app/crud/bloc/bloc.dart';
// import 'app/crud/repo/posts_api_service.dart';
// import 'app/splash_screens.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => PostsBloc(PostsApiService())..add(LoadPosts()),
//       child: const MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Posts App',
//         // theme: AppTheme.lightTheme,
//         // darkTheme: AppTheme.darkTheme,
//         home: SplashScreen(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_app/api_services.dart';
import 'cart_app/auth/bloc/auth_bloc.dart';
import 'cart_app/auth/bloc/auth_event.dart';
import 'cart_app/auth/bloc/auth_state.dart';
import 'cart_app/auth/screens/login_screen.dart';
import 'cart_app/cache_services.dart';
import 'cart_app/cart/bloc/cart_bloc.dart';
import 'cart_app/cart/screens/cart_screen.dart';
import 'cart_app/constant/networking/networking_services.dart';
import 'cart_app/product/bloc/product_bloc.dart';
import 'cart_app/product/bloc/product_event.dart';
import 'cart_app/product/repo/product_repository.dart';
import 'cart_app/product/screens/categories_screen.dart';
import 'cart_app/product/screens/product_details_screen.dart';
import 'cart_app/product/screens/product_screen.dart';
import 'cart_app/splash_screen.dart';
import 'cart_app/storage/storage_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final cacheService = CacheService(prefs);
  final networkService = NetworkService(baseUrl: 'https://fakestoreapi.com');
  final apiService = ApiService(networkService: networkService);
  final productRepository = ProductRepository(apiService, cacheService);

  runApp(MyApp(productRepository: productRepository));
}

class MyApp extends StatelessWidget {
  final ProductRepository productRepository;
  final networkService = NetworkService(baseUrl: 'https://fakestoreapi.com');
  late final apiService = ApiService(networkService: networkService);
  final storageService = StorageService();

  MyApp({
    super.key,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            apiService: apiService,
            storageService: storageService,
          )..add(CheckAuthStatus()),
        ),
        BlocProvider(
          create: (context) => ProductsBloc(
            apiService: apiService,
          )..add(LoadCategories()),
        ),
        BlocProvider(
          create: (context) => CartBloc(
            apiService: apiService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Fake Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/': (context) => _handleAuthState(context),
          '/login': (context) => LoginScreen(),
          '/categories': (context) => const CategoriesScreen(),
          '/products': (context) => const ProductsScreen(),
          '/product-details': (context) => const ProductDetailsScreen(),
          '/cart': (context) => const CartScreen(),
        },
      ),
    );
  }

  Widget _handleAuthState(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is Authenticated) {
          return const CategoriesScreen();
        }
        return LoginScreen();
      },
    );
  }
}