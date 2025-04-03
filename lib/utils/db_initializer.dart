import 'database_helper.dart';

class DbInitializer {
  static Future<void> initialize() async {
    try {
      // Get database instance to trigger initialization
      final db = await DatabaseHelper.instance.database;
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }
}
