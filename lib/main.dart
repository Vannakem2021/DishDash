import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'models/food_item.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/food_detail_screen.dart';
import 'utils/app_theme.dart';
import 'utils/db_initializer.dart';
import 'utils/data_migration.dart';
import 'utils/session_manager.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Reset database if needed during development (REMOVE THIS IN PRODUCTION)
    await _resetDatabase();

    // Initialize the database
    await DbInitializer.initialize();

    // Migrate data from mock to database
    await DataMigration().migrateData();
  } catch (e) {
    // Log the error but continue with app startup
    print('Error during database initialization: $e');
  }

  runApp(const MyApp());
}

// Helper method to reset the database during development (REMOVE IN PRODUCTION)
Future<void> _resetDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'dishdash.db');

  // Delete the database file
  if (await databaseExists(path)) {
    print('Resetting database...');
    await deleteDatabase(path);
    print('Database reset complete');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Define providers at the class level
  final CartProvider _cartProvider = CartProvider();
  final FavoritesProvider _favoritesProvider = FavoritesProvider();

  @override
  void initState() {
    super.initState();
    // Initialize the favorites provider
    _favoritesProvider.initialize();
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer when app is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // If app is exited/terminated, clear guest favorites
    if (state == AppLifecycleState.detached) {
      // Check if user is a guest
      final userEmail = await SessionManager.getUserEmail();
      final isGuest = userEmail == 'guest@example.com';

      if (isGuest) {
        // Clear guest favorites
        _favoritesProvider.resetGuestFavorites();
        print('Guest favorites cleared on app exit');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: _cartProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(
          value: _favoritesProvider,
        ),
      ],
      child: MaterialApp(
        title: 'DishDash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData(),
        routes: {
          '/': (ctx) => const SplashScreen(),
          '/login': (ctx) => const LoginScreen(),
          '/home': (ctx) => const HomeScreen(),
          '/register': (ctx) => const RegisterScreen(),
          '/cart': (ctx) => const CartScreen(),
          '/checkout': (ctx) => const CheckoutScreen(),
          '/order-confirmation': (ctx) => const OrderConfirmationScreen(),
          '/chat': (ctx) => const ChatScreen(),
          '/profile': (ctx) => const ProfileScreen(),
          '/orders': (ctx) => const OrderHistoryScreen(),
          '/order-detail': (ctx) => const OrderDetailScreen(),
          '/favorites': (ctx) => const FavoritesScreen(),
          '/food-detail':
              (ctx) => FoodDetailScreen(
                foodItem: ModalRoute.of(ctx)!.settings.arguments as FoodItem,
              ),
        },
      ),
    );
  }
}
