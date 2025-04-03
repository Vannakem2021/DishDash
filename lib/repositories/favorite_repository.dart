import 'package:sqflite/sqflite.dart';
import '../models/favorite_model.dart';
import '../utils/database_helper.dart';

class FavoriteRepository {
  final dbHelper = DatabaseHelper.instance;

  // Add a food item to favorites
  Future<int> addToFavorites(int userId, int foodItemId) async {
    final db = await dbHelper.database;

    try {
      // Check if it already exists
      final existing = await db.query(
        'favorites',
        where: 'userId = ? AND foodItemId = ?',
        whereArgs: [userId, foodItemId],
      );

      if (existing.isNotEmpty) {
        // Already a favorite, return the existing ID
        return existing.first['id'] as int;
      }

      // Create new favorite
      final favorite = Favorite(
        userId: userId,
        foodItemId: foodItemId,
        addedDate: DateTime.now(),
      );

      return await db.insert('favorites', favorite.toMap());
    } catch (e) {
      print('Error adding to favorites: $e');
      return -1;
    }
  }

  // Remove a food item from favorites
  Future<int> removeFromFavorites(int userId, int foodItemId) async {
    final db = await dbHelper.database;

    return await db.delete(
      'favorites',
      where: 'userId = ? AND foodItemId = ?',
      whereArgs: [userId, foodItemId],
    );
  }

  // Check if a food item is in user's favorites
  Future<bool> isFavorite(int userId, int foodItemId) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'favorites',
      where: 'userId = ? AND foodItemId = ?',
      whereArgs: [userId, foodItemId],
    );

    return result.isNotEmpty;
  }

  // Get all favorites for a user
  Future<List<int>> getUserFavoriteIds(int userId) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'favorites',
      columns: ['foodItemId'],
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((item) => item['foodItemId'] as int).toList();
  }

  // Delete all favorites for a user
  Future<int> clearUserFavorites(int userId) async {
    final db = await dbHelper.database;

    return await db.delete(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
