import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildCartItemImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.foodItem.name,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${cartItem.foodItem.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () {
                    cartProvider.decreaseQuantity(cartItem.foodItem.id);
                  },
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30),
                ),
                Text(
                  cartItem.quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () {
                    cartProvider.addItem(cartItem.foodItem);
                  },
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemImage() {
    final fallbackIcon = Container(
      color: Colors.grey[200],
      width: 80,
      height: 80,
      child: const Icon(Icons.restaurant, size: 40, color: Colors.grey),
    );

    // Define reliable Unsplash image URLs for each category
    final Map<int, String> categoryImages = {
      1: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=120&h=120&fit=crop', // Burger
      2: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=120&h=120&fit=crop', // Pizza
      3: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=120&h=120&fit=crop', // Dessert
      4: 'https://images.unsplash.com/photo-1538584596828-329f44686c1c?w=120&h=120&fit=crop', // Drink
      5: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=120&h=120&fit=crop', // Salad
    };

    // Determine best image URL to use
    String imageUrl =
        categoryImages[cartItem.foodItem.categoryId] ??
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=120&h=120&fit=crop';

    // Only use the item's URL if it appears to be a valid HTTP URL
    if (cartItem.foodItem.imageUrl != null &&
        cartItem.foodItem.imageUrl!.startsWith('http') &&
        !cartItem.foodItem.imageUrl!.contains('example.com') &&
        !cartItem.foodItem.imageUrl!.contains('?')) {
      imageUrl = cartItem.foodItem.imageUrl!;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget: (context, url, error) {
        print('Error loading cart image: $url - $error');
        // Fall back to category image if the specific image fails
        if (url != categoryImages[cartItem.foodItem.categoryId] &&
            categoryImages.containsKey(cartItem.foodItem.categoryId)) {
          return CachedNetworkImage(
            imageUrl: categoryImages[cartItem.foodItem.categoryId]!,
            width: 80,
            height: 80,
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
