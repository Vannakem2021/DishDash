import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/food_item.dart';
import '../repositories/food_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/food_item_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FoodRepository _foodRepository = FoodRepository();
  List<FoodItem> _favoriteFoodItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get favorites provider
      final favoritesProvider = Provider.of<FavoritesProvider>(
        context,
        listen: false,
      );

      // Make sure favorites are initialized
      if (!favoritesProvider.isInitialized) {
        await favoritesProvider.initialize();
      }

      // Get list of favorite IDs
      final favoriteIds = favoritesProvider.favoriteIds;

      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteFoodItems = [];
          _isLoading = false;
        });
        return;
      }

      // Load all food items
      final allFoodItems = await _foodRepository.getAllFoodItems();

      // Filter by favorite IDs
      _favoriteFoodItems =
          allFoodItems.where((item) => favoriteIds.contains(item.id)).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (_favoriteFoodItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _confirmClearFavorites,
              tooltip: 'Clear all favorites',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildFavoritesList(),
    );
  }

  Widget _buildFavoritesList() {
    // Listen to changes in favorites
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    if (_favoriteFoodItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Your favorite items will appear here',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Browse Foods'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _favoriteFoodItems.length,
      itemBuilder: (context, index) {
        final foodItem = _favoriteFoodItems[index];
        return FoodItemCard(
          foodItem: foodItem,
          onTap: () {
            Navigator.pushNamed(context, '/food-detail', arguments: foodItem);
          },
        );
      },
    );
  }

  void _confirmClearFavorites() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Favorites'),
            content: const Text(
              'Are you sure you want to remove all items from your favorites?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearFavorites();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('CLEAR ALL'),
              ),
            ],
          ),
    );
  }

  Future<void> _clearFavorites() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );
    await favoritesProvider.clearFavorites();

    // Reload favorites list
    _loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All favorites have been cleared'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
