import '../models/category_model.dart';
import '../models/food_item.dart';
import '../repositories/food_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/food_data.dart';
import '../models/user_model.dart';

class DataMigration {
  final FoodRepository _foodRepository = FoodRepository();
  final UserRepository _userRepository = UserRepository();

  Future<void> migrateData() async {
    // Check if data already exists before migrating
    final hasData = await _checkIfDataExists();
    if (hasData) {
      print('Data already exists, skipping migration');
      return;
    }

    await _migrateCategories();
    await _migrateFoodItems();
    await _createDefaultUser();
  }

  Future<bool> _checkIfDataExists() async {
    // Check if any food items exist
    final foodItems = await _foodRepository.getAllFoodItems();
    if (foodItems.isNotEmpty) {
      return true;
    }

    // Check if any categories exist
    final categories = await _foodRepository.getAllCategories();
    if (categories.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<void> _migrateCategories() async {
    // Create categories from FoodData
    final List<Category> categories = [];

    // Skip the "All" category at index 0
    for (int i = 1; i < FoodData.categories.length; i++) {
      categories.add(
        Category(
          name: FoodData.categories[i],
          imageUrl:
              'https://example.com/${FoodData.categories[i].toLowerCase()}.jpg',
        ),
      );
    }

    // Insert categories into the database
    for (var category in categories) {
      await _foodRepository.insertCategory(category);
    }
  }

  Future<void> _migrateFoodItems() async {
    // Insert food items from FoodData into the database
    for (var foodItem in FoodData.allItems) {
      try {
        await _foodRepository.insertFoodItem(foodItem);
      } catch (e) {
        print('Error inserting food item ${foodItem.id}: ${e.toString()}');
        // Continue with next item if one fails
      }
    }
  }

  Future<void> _createDefaultUser() async {
    // Create a default user if none exists
    final defaultUser = User(
      name: 'Demo User',
      email: 'demo@example.com',
      password: 'password123',
      phoneNumber: '+1234567890',
      address: '123 Main St, City, Country',
    );

    // Check if user already exists
    final existingUser = await _userRepository.getUserByEmail(
      defaultUser.email,
    );
    if (existingUser == null) {
      await _userRepository.insert(defaultUser);
    }
  }
}
