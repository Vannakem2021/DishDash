enum OrderStatus { pending, processing, delivered, canceled }

class Order {
  final int? id;
  final int userId;
  final DateTime orderDate;
  final double totalAmount;
  final String deliveryAddress;
  final OrderStatus status;
  final String? paymentMethod;

  Order({
    this.id,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderDate': orderDate.toIso8601String(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'status': status.index,
      'paymentMethod': paymentMethod,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      orderDate: DateTime.parse(map['orderDate']),
      totalAmount: map['totalAmount'],
      deliveryAddress: map['deliveryAddress'],
      status: OrderStatus.values[map['status']],
      paymentMethod: map['paymentMethod'],
    );
  }
}
