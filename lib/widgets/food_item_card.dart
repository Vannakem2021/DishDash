import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/app_theme.dart';
import '../utils/food_data.dart';
import '../utils/session_manager.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback? onTap;

  const FoodItemCard({Key? key, required this.foodItem, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get category name
    final categoryName = FoodData.getCategoryName(foodItem.categoryId);
    // Get favorites provider
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    // Check if this item is a favorite
    final isFavorite = favoritesProvider.isFavorite(foodItem.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Hero(
                      tag: 'food-image-${foodItem.id}',
                      child: _buildFoodImage(),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () => _toggleFavorite(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (foodItem.isPopular)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        foodItem.rating.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.access_time,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${foodItem.prepTimeMinutes} min',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${foodItem.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => _handleAddToCart(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddToCart(BuildContext context) async {
    // Check if user is authenticated (not a guest)
    final isAuthenticated = await SessionManager.isAuthenticated();

    if (isAuthenticated) {
      // User is logged in with a regular account, add to cart
      Provider.of<CartProvider>(context, listen: false).addItem(foodItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${foodItem.name} added to cart'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ),
      );
    } else {
      // User is a guest or not logged in, show login dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text(
                'You need to login or create an account to add items to your cart.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(
                      context,
                    ).pushNamed('/login', arguments: 'fromCart');
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
  }

  Future<void> _toggleFavorite(BuildContext context) async {
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
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildFoodImage() {
    // Use placeholders for missing images
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
      1: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=480&h=360&fit=crop', // Burger
      2: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=480&h=360&fit=crop', // Pizza
      3: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=480&h=360&fit=crop', // Dessert
      4: 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=480&h=360&fit=crop', // Drink
      5: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=480&h=360&fit=crop', // Salad
    };

    // Determine the image URL to use, prioritizing the item's URL but with a fallback
    String imageUrl = foodItem.imageUrl!;

    // Verify the URL is valid (starts with http/https)
    if (!imageUrl.startsWith('http')) {
      // Use category fallback if URL is invalid
      imageUrl =
          categoryImages[foodItem.categoryId] ??
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=480&h=360&fit=crop';
    }

    // Use CachedNetworkImage with robust error handling
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
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
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
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
    );
  }
}
