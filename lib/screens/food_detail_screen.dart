import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import '../utils/food_data.dart';
import '../utils/session_manager.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({Key? key, required this.foodItem}) : super(key: key);

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkIfGuest();
  }

  Future<void> _checkIfGuest() async {
    final isGuestUser = await SessionManager.isGuest();
    setState(() {
      _isGuest = isGuestUser;
    });
  }

  void _addToCart() {
    if (_isGuest) {
      _showLoginRequiredDialog();
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(widget.foodItem, _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_quantity}x ${widget.foodItem.name} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text(
              'Please login or create an account to add items to your cart.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/login', arguments: 'fromCart');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('LOGIN'),
              ),
            ],
          ),
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodItem = widget.foodItem;
    final categoryName = FoodData.getCategoryName(foodItem.categoryId);
    final totalPrice = foodItem.price * _quantity;
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(foodItem.id);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    leading: IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.black,
                          ),
                        ),
                        onPressed: () => _toggleFavorite(context, foodItem),
                      ),
                      const SizedBox(width: 10),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeroImage(foodItem),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  foodItem.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '\$${foodItem.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categoryName,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                foodItem.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.access_time,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${foodItem.prepTimeMinutes} min',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            foodItem.description ?? 'No description available.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: _decrementQuantity,
                                    ),
                                    Text(
                                      _quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: _incrementQuantity,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, FoodItem foodItem) async {
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );

    favoritesProvider.toggleFavorite(foodItem.id);

    // Show a snackbar message
    final message =
        favoritesProvider.isFavorite(foodItem.id)
            ? '${foodItem.name} added to favorites'
            : '${foodItem.name} removed from favorites';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW FAVORITES',
          onPressed: () {
            Navigator.of(context).pushNamed('/favorites');
          },
        ),
      ),
    );
  }

  Widget _buildHeroImage(FoodItem foodItem) {
    final fallbackIcon = Container(
      color: Colors.grey[200],
      child: Icon(Icons.restaurant, size: 60, color: Colors.grey[400]),
    );

    // If image URL is null or empty, show a placeholder
    if (foodItem.imageUrl == null || foodItem.imageUrl!.isEmpty) {
      return fallbackIcon;
    }

    // Define reliable Unsplash image URLs for each category
    final Map<int, String> categoryImages = {
      1: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=1200&h=800&fit=crop', // Burger
      2: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=1200&h=800&fit=crop', // Pizza
      3: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=1200&h=800&fit=crop', // Dessert
      4: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=1200&h=800&fit=crop', // Drink
      5: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200&h=800&fit=crop', // Salad
    };

    // Determine the image URL to use, prioritizing the item's URL but with a fallback
    String imageUrl = foodItem.imageUrl!;

    // Verify the URL is valid (starts with http/https)
    if (!imageUrl.startsWith('http')) {
      // Use category fallback if URL is invalid
      imageUrl =
          categoryImages[foodItem.categoryId] ??
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200&h=800&fit=crop';
    }

    return Hero(
      tag: 'food-image-${foodItem.id}',
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget: (context, url, error) {
          print('Error loading image: $url - $error');
          // Fall back to category image if the specific image fails
          final fallbackUrl = categoryImages[foodItem.categoryId];
          if (url != fallbackUrl && fallbackUrl != null) {
            return CachedNetworkImage(
              imageUrl: fallbackUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget: (context, url, error) => fallbackIcon,
            );
          }
          return fallbackIcon;
        },
      ),
    );
  }
}
