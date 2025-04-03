import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  Order? _order;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    // Get orderId from route arguments
    final orderId = ModalRoute.of(context)!.settings.arguments as int?;

    if (orderId != null) {
      try {
        final order = await _orderRepository.getOrderById(orderId);
        if (mounted) {
          setState(() {
            _order = order;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading order details: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Clear cart after order is placed
    if (mounted) {
      Provider.of<CartProvider>(context, listen: false).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate order ID for display
    final displayOrderId =
        _order?.id != null
            ? 'ORD-${_order!.id.toString().padLeft(4, '0')}'
            : 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSuccessAnimation(),
                        const SizedBox(height: 30),
                        Text(
                          'Order Placed Successfully!',
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your order has been placed successfully. We will deliver your food as soon as possible.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        _buildOrderDetailsCard(context, displayOrderId),
                        const SizedBox(height: 40),
                        _buildDeliveryTimeline(context),
                        const SizedBox(height: 40),
                        // View Details button
                        if (_order?.id != null)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to order details screen
                                Navigator.pushNamed(
                                  context,
                                  '/order-detail',
                                  arguments: _order!.id,
                                );
                              },
                              icon: const Icon(Icons.receipt_long),
                              label: const Text('View Order Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              // Navigate back to home screen and select the Orders tab (index 3)
                              Navigator.pushReplacementNamed(
                                context,
                                '/orders',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'View All Orders',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton(
                            onPressed: () {
                              // Navigate back to home screen
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            child: const Text(
                              'Continue Shopping',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check_circle, size: 100, color: AppTheme.primaryColor),
    );
  }

  Widget _buildOrderDetailsCard(BuildContext context, String orderId) {
    final currentDate = DateTime.now();
    final formattedDate =
        '${currentDate.day}/${currentDate.month}/${currentDate.year}';
    final formattedTime =
        '${currentDate.hour}:${currentDate.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOrderDetailRow(context, title: 'Order ID', value: orderId),
          const Divider(height: 30),
          _buildOrderDetailRow(context, title: 'Date', value: formattedDate),
          const Divider(height: 30),
          _buildOrderDetailRow(context, title: 'Time', value: formattedTime),
          const Divider(height: 30),
          _buildOrderDetailRow(
            context,
            title: 'Payment Method',
            value: 'Visa **** 1234',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDeliveryTimeline(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Delivery Time',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTimelineIcon(
                isCompleted: true,
                isActive: false,
                icon: Icons.receipt,
              ),
              _buildTimelineConnector(isCompleted: true),
              _buildTimelineIcon(
                isCompleted: false,
                isActive: true,
                icon: Icons.restaurant,
              ),
              _buildTimelineConnector(isCompleted: false),
              _buildTimelineIcon(
                isCompleted: false,
                isActive: false,
                icon: Icons.delivery_dining,
              ),
              _buildTimelineConnector(isCompleted: false),
              _buildTimelineIcon(
                isCompleted: false,
                isActive: false,
                icon: Icons.home,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineLabel(context, 'Order\nPlaced'),
              _buildTimelineLabel(context, 'Order\nPreparing'),
              _buildTimelineLabel(context, 'Order\nEnroute'),
              _buildTimelineLabel(context, 'Order\nDelivered'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.green[700]),
                const SizedBox(width: 12),
                Text(
                  'Estimated arrival: 25-35 min',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIcon({
    required bool isCompleted,
    required bool isActive,
    required IconData icon,
  }) {
    Color backgroundColor;
    Color iconColor;

    if (isCompleted) {
      backgroundColor = AppTheme.primaryColor;
      iconColor = Colors.white;
    } else if (isActive) {
      backgroundColor = Colors.white;
      iconColor = AppTheme.primaryColor;
    } else {
      backgroundColor = Colors.grey[200]!;
      iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border:
            isActive
                ? Border.all(color: AppTheme.primaryColor, width: 2)
                : null,
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
                : null,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildTimelineConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 3,
        color: isCompleted ? AppTheme.primaryColor : Colors.grey[300],
      ),
    );
  }

  Widget _buildTimelineLabel(BuildContext context, String label) {
    return SizedBox(
      width: 70,
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }
}
