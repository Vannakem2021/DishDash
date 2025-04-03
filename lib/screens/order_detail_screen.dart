import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/food_item.dart';
import '../repositories/order_repository.dart';
import '../repositories/food_repository.dart';
import '../utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({Key? key}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final FoodRepository _foodRepository = FoodRepository();

  Order? _order;
  List<OrderItem> _orderItems = [];
  Map<int, FoodItem> _foodItems = {};
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get order ID from route arguments
      final orderId = ModalRoute.of(context)!.settings.arguments as int;

      // Load order
      final order = await _orderRepository.getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      // Load order items
      final orderItems = await _orderRepository.getOrderItemsByOrderId(orderId);

      // Load food items for each order item
      final Map<int, FoodItem> foodItems = {};
      for (final item in orderItems) {
        final foodItem = await _foodRepository.getFoodItemById(item.foodItemId);
        if (foodItem != null) {
          foodItems[item.foodItemId] = foodItem;
        }
      }

      setState(() {
        _order = order;
        _orderItems = orderItems;
        _foodItems = foodItems;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading order details: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load order details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.canceled:
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.canceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          if (_order != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showUpdateStatusDialog,
              tooltip: 'Update Order Status',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(),
                    const SizedBox(height: 24),
                    _buildOrderTracking(),
                    const SizedBox(height: 24),
                    _buildOrderItems(),
                    const SizedBox(height: 24),
                    _buildOrderSummary(),
                  ],
                ),
              ),
    );
  }

  Widget _buildOrderHeader() {
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(_order!.orderDate);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${_order!.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_order!.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(_order!.status),
                    style: TextStyle(
                      color: _getStatusColor(_order!.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Order Date',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(formattedDate, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              'Delivery Address',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(_order!.deliveryAddress, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            if (_order!.paymentMethod != null) ...[
              Text(
                'Payment Method',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                _order!.paymentMethod!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTracking() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_order!.status != OrderStatus.delivered &&
                    _order!.status != OrderStatus.canceled)
                  Text(
                    _getEstimatedDeliveryTime(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildOrderTrackingTimeline(),
          ],
        ),
      ),
    );
  }

  String _getEstimatedDeliveryTime() {
    // Calculate based on order date and current status
    // In a real app, this would be more sophisticated
    final now = DateTime.now();
    final orderDateTime = _order!.orderDate;

    // Simple estimation logic
    if (_order!.status == OrderStatus.pending) {
      // Expect delivery in 40-50 minutes from order time
      final estimatedDelivery = orderDateTime.add(const Duration(minutes: 45));
      final remaining = estimatedDelivery.difference(now);

      if (remaining.isNegative) {
        return "Arriving soon";
      }

      final minutes = remaining.inMinutes;
      return "ETA: ~$minutes min";
    } else if (_order!.status == OrderStatus.processing) {
      // Expect delivery in 20-30 minutes from now
      return "ETA: ~25 min";
    }

    return "Arriving soon";
  }

  Widget _buildOrderTrackingTimeline() {
    final currentStatus = _order!.status;

    // Define all possible order states in sequence
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.delivered,
    ];

    // Skip the entire timeline for canceled orders
    if (currentStatus == OrderStatus.canceled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Canceled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'This order has been canceled',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < allStatuses.length; i++)
          _buildTrackingStep(
            status: allStatuses[i],
            isActive: allStatuses[i].index <= currentStatus.index,
            isFirst: i == 0,
            isLast: i == allStatuses.length - 1,
          ),
      ],
    );
  }

  Widget _buildTrackingStep({
    required OrderStatus status,
    required bool isActive,
    required bool isFirst,
    required bool isLast,
  }) {
    final statusInfo = _getStatusInfo(status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? statusInfo.color : Colors.grey[300],
                border: Border.all(
                  color: isActive ? statusInfo.color : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child:
                  isActive
                      ? Icon(statusInfo.icon, color: Colors.white, size: 14)
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? statusInfo.color : Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusInfo.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? statusInfo.color : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusInfo.description,
                style: TextStyle(
                  color: isActive ? Colors.grey[800] : Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  StatusInfo _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return StatusInfo(
          title: 'Order Confirmed',
          description: 'Your order has been received',
          icon: Icons.receipt,
          color: Colors.blue,
        );
      case OrderStatus.processing:
        return StatusInfo(
          title: 'Preparing',
          description: 'Your food is being prepared',
          icon: Icons.restaurant,
          color: Colors.orange,
        );
      case OrderStatus.delivered:
        return StatusInfo(
          title: 'Delivered',
          description: 'Enjoy your meal!',
          icon: Icons.check_circle,
          color: Colors.green,
        );
      case OrderStatus.canceled:
        return StatusInfo(
          title: 'Canceled',
          description: 'Order has been canceled',
          icon: Icons.cancel,
          color: Colors.red,
        );
      default:
        return StatusInfo(
          title: 'Unknown',
          description: 'Status unknown',
          icon: Icons.help,
          color: Colors.grey,
        );
    }
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_orderItems.isEmpty)
          const Center(child: Text('No items in this order'))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _orderItems.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = _orderItems[index];
              final foodItem = _foodItems[item.foodItemId];

              if (foodItem == null) {
                return ListTile(
                  title: Text('Unknown Item (ID: ${item.foodItemId})'),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Text('\$${item.price.toStringAsFixed(2)}'),
                );
              }

              return _buildOrderItemCard(item, foodItem);
            },
          ),
      ],
    );
  }

  Widget _buildOrderItemCard(OrderItem item, FoodItem foodItem) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 70,
                height: 70,
                child: _buildFoodImage(foodItem),
              ),
            ),
            const SizedBox(width: 12),
            // Food details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Price
            Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage(FoodItem foodItem) {
    // Define fallback icon
    final fallbackIcon = Container(
      color: Colors.grey[200],
      child: Icon(Icons.restaurant, size: 30, color: Colors.grey[400]),
    );

    // If image URL is null or empty, show a placeholder
    if (foodItem.imageUrl == null || foodItem.imageUrl!.isEmpty) {
      return fallbackIcon;
    }

    // Define reliable Unsplash image URLs for each category
    final Map<int, String> categoryImages = {
      1: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=200&h=200&fit=crop', // Burger
      2: 'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=200&h=200&fit=crop', // Pizza
      3: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=200&h=200&fit=crop', // Dessert
      4: 'https://images.unsplash.com/photo-1538584596828-329f44686c1c?w=200&h=200&fit=crop', // Drink
      5: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&h=200&fit=crop', // Salad
    };

    // Determine the image URL to use
    String imageUrl =
        categoryImages[foodItem.categoryId] ??
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&h=200&fit=crop';

    // Use CachedNetworkImage with error handling
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget: (context, url, error) => fallbackIcon,
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  '\$${(_order!.totalAmount - 2.99).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Fee',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Text('\$2.99', style: TextStyle(fontSize: 14)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_order!.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog() {
    OrderStatus? selectedStatus = _order!.status;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Update Order Status'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select the new status:'),
                    const SizedBox(height: 16),
                    ...OrderStatus.values
                        .map(
                          (status) => RadioListTile<OrderStatus>(
                            title: Text(_getStatusInfo(status).title),
                            subtitle: Text(_getStatusInfo(status).description),
                            value: status,
                            groupValue: selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  _updateOrderStatus(selectedStatus!);
                  Navigator.of(context).pop();
                },
                child: const Text('UPDATE'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    if (_order == null || newStatus == _order!.status) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final orderRepository = OrderRepository();
      // Fix: Ensure the order ID is not null
      if (_order!.id == null) {
        throw Exception('Order ID is null');
      }
      await orderRepository.updateOrderStatus(_order!.id!, newStatus);

      // Reload the order with updated status
      await _loadOrderDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order status updated to ${_getStatusInfo(newStatus).title}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class StatusInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  StatusInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
