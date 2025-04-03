import 'package:sqflite/sqflite.dart';
import '../models/chat_message.dart';
import '../utils/database_helper.dart';

class ChatRepository {
  final dbHelper = DatabaseHelper.instance;

  // Save a new chat message
  Future<int> saveMessage(ChatMessage message) async {
    final db = await dbHelper.database;
    return await db.insert('chat_messages', message.toMap());
  }

  // Get all messages for a specific user
  Future<List<ChatMessage>> getMessagesForUser(int userId) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'chat_messages',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp ASC', // Oldest messages first
    );

    return result.map((map) => ChatMessage.fromMap(map)).toList();
  }

  // Delete all messages for a user
  Future<int> clearUserMessages(int userId) async {
    final db = await dbHelper.database;
    return await db.delete(
      'chat_messages',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Get initial welcome messages for a new user
  List<ChatMessage> getInitialMessages(int userId) {
    final now = DateTime.now();

    return [
      ChatMessage(
        userId: userId,
        message:
            "👋 Hi there! I'm your DishDash robot assistant. How can I help you today?",
        isFromUser: false,
        timestamp: now.subtract(const Duration(seconds: 1)),
      ),
    ];
  }

  // Generate automated responses based on user messages
  Future<ChatMessage> generateResponse(int userId, String userMessage) async {
    // Simple mapping of keywords to responses
    final message = userMessage.toLowerCase();
    String response;

    if (message.contains('order') &&
        (message.contains('track') || message.contains('status'))) {
      response =
          "You can check your order status in the Orders tab. Would you like me to help you navigate there?";
    } else if (message.contains('order') && message.contains('cancel')) {
      response =
          "To cancel an order, please go to your order details and use the 'Cancel Order' option if the order hasn't been prepared yet.";
    } else if (message.contains('time') ||
        message.contains('long') ||
        message.contains('minutes') ||
        message.contains('when')) {
      response =
          "Your order should arrive in approximately 25-30 minutes. Our delivery partners always try to deliver as quickly as possible!";
    } else if (message.contains('payment') || message.contains('pay')) {
      response =
          "We accept credit cards, debit cards, and cash on delivery. All payment information is securely processed.";
    } else if (message.contains('menu') ||
        message.contains('special') ||
        message.contains('offer')) {
      response =
          "Check out our Home tab for all menu items and special offers. We update our specials every week!";
    } else if (message.contains('thank') || message.contains('thanks')) {
      response =
          "You're welcome! I'm happy to help. Is there anything else you'd like to know?";
    } else if (message.contains('help') || message.contains('support')) {
      response =
          "I'm here to help! You can ask about your orders, our menu, delivery times, or payment options.";
    } else if (message.contains('hi') ||
        message.contains('hello') ||
        message.contains('hey')) {
      response =
          "Hello there! How can I assist you with your DishDash experience today?";
    } else {
      response =
          "Thanks for your message. I'll process that information and get back to you shortly. For immediate assistance with complex issues, you can reach our human support team at support@dishdash.com";
    }

    return ChatMessage(
      userId: userId,
      message: response,
      isFromUser: false,
      timestamp: DateTime.now(),
    );
  }
}
