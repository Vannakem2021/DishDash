import '../models/food_item.dart';
import '../models/category_model.dart';
import '../utils/database_helper.dart';

class FoodRepository {
  final dbHelper = DatabaseHelper.instance;

  // Food Items
  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await dbHelper.database;
    final result = await db.query('food_items');
    return result.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> getFoodItemsByCategory(int categoryId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'food_items',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return result.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<List<FoodItem>> getPopularItems() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'food_items',
      where: 'isPopular = ?',
      whereArgs: [1],
    );
    return result.map((map) => FoodItem.fromMap(map)).toList();
  }

  Future<FoodItem?> getFoodItemById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query('food_items', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return FoodItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertFoodItem(FoodItem item) async {
    final db = await dbHelper.database;
    return await db.insert('food_items', item.toMap());
  }

  // Categories
  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    final result = await db.query('categories');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCategory(Category category) async {
    final db = await dbHelper.database;
    return await db.insert('categories', category.toMap());
  }
}
