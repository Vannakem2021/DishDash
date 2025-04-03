import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../repositories/order_repository.dart';
import '../repositories/food_repository.dart';
import '../utils/session_manager.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final OrderRepository _orderRepository = OrderRepository();
  final FoodRepository _foodRepository = FoodRepository();

  List<CartItem> get items => [..._items];

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(FoodItem foodItem, [int quantity = 1]) {
    final existingCartItemIndex = _items.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );

    if (existingCartItemIndex >= 0) {
      // If item exists, increase quantity
      _items[existingCartItemIndex] = CartItem(
        foodItem: foodItem,
        quantity: _items[existingCartItemIndex].quantity + quantity,
      );
    } else {
      // If item doesn't exist, add new item
      _items.add(CartItem(foodItem: foodItem, quantity: quantity));
    }

    notifyListeners();
  }

  void removeItem(int foodItemId) {
    _items.removeWhere((item) => item.foodItem.id == foodItemId);
    notifyListeners();
  }

  void decreaseQuantity(int foodItemId) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.foodItem.id == foodItemId,
    );

    if (existingItemIndex >= 0) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity -= 1;
      } else {
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  Future<int> checkout(String deliveryAddress, String paymentMethod) async {
    // Get current user ID from session
    int userId = 1; // Default to 1 for demo
    final sessionUserId = await SessionManager.getUserId();
    if (sessionUserId != null) {
      userId = sessionUserId;
    }

    // Create order
    final order = Order(
      userId: userId,
      orderDate: DateTime.now(),
      totalAmount: totalAmount + 2.99, // Add delivery fee
      deliveryAddress: deliveryAddress,
      status: OrderStatus.pending,
      paymentMethod: paymentMethod,
    );

    final orderId = await _orderRepository.createOrder(order);

    // Create order items
    for (var item in _items) {
      final orderItem = OrderItem(
        orderId: orderId,
        foodItemId: item.foodItem.id,
        quantity: item.quantity,
        price: item.foodItem.price,
      );
      await _orderRepository.addOrderItem(orderItem);
    }

    // Clear cart
    clear();

    return orderId;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
