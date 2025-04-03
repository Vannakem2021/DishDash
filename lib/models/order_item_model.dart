class OrderItem {
  final int? id;
  final int orderId;
  final int foodItemId;
  final int quantity;
  final double price;

  OrderItem({
    this.id,
    required this.orderId,
    required this.foodItemId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'foodItemId': foodItemId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['orderId'],
      foodItemId: map['foodItemId'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
