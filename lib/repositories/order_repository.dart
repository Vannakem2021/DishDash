import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../utils/database_helper.dart';

class OrderRepository {
  final dbHelper = DatabaseHelper.instance;

  // Orders
  Future<int> createOrder(Order order) async {
    final db = await dbHelper.database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<Order>> getOrdersByUserId(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'orderDate DESC',
    );
    return result.map((map) => Order.fromMap(map)).toList();
  }

  Future<Order?> getOrderById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query('orders', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateOrderStatus(int id, OrderStatus status) async {
    final db = await dbHelper.database;
    return await db.update(
      'orders',
      {'status': status.index},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Order Items
  Future<int> addOrderItem(OrderItem item) async {
    final db = await dbHelper.database;
    return await db.insert('order_items', item.toMap());
  }

  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
    return result.map((map) => OrderItem.fromMap(map)).toList();
  }
}
