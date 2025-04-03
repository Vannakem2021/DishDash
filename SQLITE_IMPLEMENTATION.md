# DishDash SQLite Implementation Plan

## Overview

This document outlines the implementation of SQLite database for the DishDash food ordering application, covering everything from database setup to UI integration.

## Table of Contents

1. [Dependencies Setup](#1-dependencies-setup)
2. [Database Models](#2-database-models)
3. [Database Helper](#3-database-helper)
4. [Data Repositories](#4-data-repositories)
5. [UI Integration](#5-ui-integration)
6. [Implementation Timeline](#6-implementation-timeline)

## 1. Dependencies Setup

Add the required dependencies to `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies
  flutter:
    sdk: flutter

  # Database dependencies
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
```

Run `flutter pub get` to install the dependencies.

## 2. Database Models

### User Model

```dart
// lib/models/user_model.dart
class User {
  final int? id;
  final String name;
  final String email;
  final String? password; // Store securely or use Firebase Auth
  final String? phoneNumber;
  final String? address;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.phoneNumber,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
    );
  }
}
```

### Food Category Model

```dart
// lib/models/category_model.dart
class Category {
  final int? id;
  final String name;
  final String? imageUrl;

  Category({
    this.id,
    required this.name,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
    );
  }
}
```

### Food Item Model (Update Existing)

```dart
// lib/models/food_item.dart
class FoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final int prepTimeMinutes;
  final double rating;
  final int categoryId;  // Add category reference
  final bool isPopular;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.ingredients,
    required this.prepTimeMinutes,
    required this.rating,
    required this.categoryId,
    this.isPopular = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients.join(','),
      'prepTimeMinutes': prepTimeMinutes,
      'rating': rating,
      'categoryId': categoryId,
      'isPopular': isPopular ? 1 : 0,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      ingredients: map['ingredients'].split(','),
      prepTimeMinutes: map['prepTimeMinutes'],
      rating: map['rating'],
      categoryId: map['categoryId'],
      isPopular: map['isPopular'] == 1,
    );
  }
}
```

### Order Model

```dart
// lib/models/order_model.dart
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
```

### Order Item Model

```dart
// lib/models/order_item_model.dart
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
```

## 3. Database Helper

Create a database helper class to manage database operations:

```dart
// lib/utils/database_helper.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dishdash.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullableType = 'INTEGER';
    const realType = 'REAL NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType,
        password $textNullableType,
        phoneNumber $textNullableType,
        address $textNullableType
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        imageUrl $textNullableType
      )
    ''');

    // Food items table
    await db.execute('''
      CREATE TABLE food_items (
        id $idType,
        name $textType,
        description $textType,
        price $realType,
        imageUrl $textType,
        ingredients $textType,
        prepTimeMinutes $integerType,
        rating $realType,
        categoryId $integerType,
        isPopular $integerType
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id $idType,
        userId $integerType,
        orderDate $textType,
        totalAmount $realType,
        deliveryAddress $textType,
        status $integerType,
        paymentMethod $textNullableType
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id $idType,
        orderId $integerType,
        foodItemId $integerType,
        quantity $integerType,
        price $realType
      )
    ''');

    // Insert initial data
    _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Insert initial categories
    await db.insert('categories', {'name': 'Burgers', 'imageUrl': 'https://example.com/burgers.jpg'});
    await db.insert('categories', {'name': 'Pizza', 'imageUrl': 'https://example.com/pizza.jpg'});
    await db.insert('categories', {'name': 'Desserts', 'imageUrl': 'https://example.com/desserts.jpg'});

    // Insert sample food items
    await db.insert('food_items', {
      'name': 'Classic Burger',
      'description': 'Juicy beef patty with fresh vegetables',
      'price': 8.99,
      'imageUrl': 'https://example.com/classic_burger.jpg',
      'ingredients': 'Beef,Lettuce,Tomato,Cheese,Onion',
      'prepTimeMinutes': 15,
      'rating': 4.5,
      'categoryId': 1,
      'isPopular': 1
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
```

## 4. Data Repositories

Create repository classes for each model:

### User Repository

```dart
// lib/repositories/user_repository.dart
import '../models/user_model.dart';
import '../utils/database_helper.dart';

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(User user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserById(int id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(User user) async {
    final db = await dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### Food Repository

```dart
// lib/repositories/food_repository.dart
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
    final maps = await db.query(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );

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
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

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
```

### Order Repository

```dart
// lib/repositories/order_repository.dart
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
    final maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );

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
```

## 5. UI Integration

### Update CartProvider to Use SQLite

```dart
// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../repositories/order_repository.dart';
import '../repositories/food_repository.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final OrderRepository _orderRepository = OrderRepository();
  final FoodRepository _foodRepository = FoodRepository();

  List<CartItem> get items => [..._items];

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(FoodItem foodItem) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );

    if (existingItemIndex >= 0) {
      _items[existingItemIndex].quantity += 1;
    } else {
      _items.add(CartItem(foodItem: foodItem));
    }
    notifyListeners();
  }

  void removeItem(int foodItemId) {
    _items.removeWhere((item) => item.foodItem.id == foodItemId);
    notifyListeners();
  }

  void decreaseQuantity(int foodItemId) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.foodItem.id == foodItemId,
    );

    if (existingItemIndex >= 0) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity -= 1;
      } else {
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  Future<int> checkout(int userId, String deliveryAddress, String paymentMethod) async {
    // Create order
    final order = Order(
      userId: userId,
      orderDate: DateTime.now(),
      totalAmount: totalAmount + 2.99, // Add delivery fee
      deliveryAddress: deliveryAddress,
      status: OrderStatus.pending,
      paymentMethod: paymentMethod,
    );

    final orderId = await _orderRepository.createOrder(order);

    // Create order items
    for (var item in _items) {
      final orderItem = OrderItem(
        orderId: orderId,
        foodItemId: item.foodItem.id,
        quantity: item.quantity,
        price: item.foodItem.price,
      );
      await _orderRepository.addOrderItem(orderItem);
    }

    // Clear cart
    clear();

    return orderId;
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
```

### Update HomeScreen to Load Food Items from SQLite

```dart
// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/category_model.dart';
import '../repositories/food_repository.dart';

class HomeScreen extends StatefulWidget {
  // Existing code...
}

class _HomeScreenState extends State<HomeScreen> {
  final FoodRepository _foodRepository = FoodRepository();
  List<Category> _categories = [];
  List<FoodItem> _foodItems = [];
  List<FoodItem> _filteredFoodItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _foodRepository.getAllCategories();
      final foodItems = await _foodRepository.getAllFoodItems();

      setState(() {
        _categories = categories;
        _foodItems = foodItems;
        _filteredFoodItems = foodItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _filterFoodItems() {
    setState(() {
      if (_selectedCategoryIndex == 0) {
        _filteredFoodItems = _foodItems.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      } else {
        final categoryId = _categories[_selectedCategoryIndex - 1].id;
        _filteredFoodItems = _foodItems.where((item) =>
          item.categoryId == categoryId &&
          item.name.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }
    });
  }

  // Rest of the existing code...
}
```

### Update Profile Screen to Use SQLite

```dart
// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/order_repository.dart';
import '../utils/app_theme.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  final OrderRepository _orderRepository = OrderRepository();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID from shared preferences or auth service
      final userId = 1; // Placeholder, replace with actual ID
      final user = await _userRepository.getUserById(userId);

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  // Rest of the existing code...
}
```

## 6. Implementation Timeline

1. **Week 1: Setup and Models**

   - Add SQLite dependencies
   - Define data models
   - Create database helper

2. **Week 2: Repository Implementation**

   - User repository
   - Food repository
   - Order repository
   - Initial data

3. **Week 3: UI Integration**

   - Update providers to use repositories
   - Modify screens to load data from SQLite
   - Test database operations

4. **Week 4: Testing and Refinement**
   - End-to-end testing
   - Performance optimization
   - Bug fixes
   - Documentation
