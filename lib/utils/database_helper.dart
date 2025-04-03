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
      version: 5, // Increment version to add chat_messages table
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
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

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id $idType,
        userId $integerType,
        foodItemId $integerType,
        addedDate $textType,
        UNIQUE(userId, foodItemId)
      )
    ''');

    // Chat messages table
    await db.execute('''
      CREATE TABLE chat_messages (
        id $idType,
        userId $integerType,
        message $textType,
        isFromUser $integerType,
        timestamp $textType
      )
    ''');

    // Insert initial data
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Create default guest user
    await db.insert('users', {
      'name': 'Demo User',
      'email': 'demo@example.com',
      'password': 'password123',
      'phoneNumber': '+1234567890',
      'address': '123 Main St, City, Country',
    });

    // Create guest user
    await db.insert('users', {
      'name': 'Guest User',
      'email': 'guest@example.com',
      'password': 'guest123',
      'phoneNumber': '',
      'address': 'No address provided',
    });

    // Insert initial categories with Unsplash images
    await db.insert('categories', {
      'name': 'Burgers',
      'imageUrl':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=480&h=360&fit=crop',
    });
    await db.insert('categories', {
      'name': 'Pizza',
      'imageUrl':
          'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=480&h=360&fit=crop',
    });
    await db.insert('categories', {
      'name': 'Desserts',
      'imageUrl':
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=480&h=360&fit=crop',
    });
    await db.insert('categories', {
      'name': 'Drinks',
      'imageUrl':
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=480&h=360&fit=crop',
    });
    await db.insert('categories', {
      'name': 'Salads',
      'imageUrl':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=480&h=360&fit=crop',
    });

    // Insert sample food items
    await db.insert('food_items', {
      'name': 'Classic Burger',
      'description':
          'Juicy beef patty with fresh vegetables and our special sauce',
      'price': 8.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=480&h=360&fit=crop',
      'ingredients': 'Beef,Lettuce,Tomato,Cheese,Onion,Mayo',
      'prepTimeMinutes': 15,
      'rating': 4.5,
      'categoryId': 1,
      'isPopular': 1,
    });

    // Add more sample food items
    await db.insert('food_items', {
      'name': 'Cheese Pizza',
      'description': 'Classic cheese pizza with our special tomato sauce',
      'price': 12.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1593560708920-61dd98c46a4e?w=480&h=360&fit=crop',
      'ingredients': 'Dough,Tomato Sauce,Mozzarella,Basil',
      'prepTimeMinutes': 20,
      'rating': 4.3,
      'categoryId': 2,
      'isPopular': 1,
    });

    await db.insert('food_items', {
      'name': 'Chocolate Cake',
      'description': 'Rich chocolate cake with chocolate ganache',
      'price': 6.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=480&h=360&fit=crop',
      'ingredients': 'Flour,Sugar,Chocolate,Butter,Eggs',
      'prepTimeMinutes': 10,
      'rating': 4.8,
      'categoryId': 3,
      'isPopular': 1,
    });

    await db.insert('food_items', {
      'name': 'Caesar Salad',
      'description': 'Fresh romaine lettuce with Caesar dressing and croutons',
      'price': 7.49,
      'imageUrl':
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=480&h=360&fit=crop',
      'ingredients': 'Romaine Lettuce,Croutons,Caesar Dressing,Parmesan',
      'prepTimeMinutes': 8,
      'rating': 4.2,
      'categoryId': 5,
      'isPopular': 0,
    });

    await db.insert('food_items', {
      'name': 'Iced Coffee',
      'description': 'Cold brewed coffee with milk and ice',
      'price': 3.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=480&h=360&fit=crop',
      'ingredients': 'Coffee,Milk,Ice,Sugar',
      'prepTimeMinutes': 5,
      'rating': 4.6,
      'categoryId': 4,
      'isPopular': 0,
    });

    // Add 3 more burgers
    await db.insert('food_items', {
      'name': 'Double Cheeseburger',
      'description': 'Double patty burger with extra cheese and bacon',
      'price': 10.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1607013251379-e6eecfffe234?w=480&h=360&fit=crop',
      'ingredients':
          'Double Beef Patty,Double Cheese,Bacon,Lettuce,Mayo,Ketchup',
      'prepTimeMinutes': 18,
      'rating': 4.7,
      'categoryId': 1,
      'isPopular': 1,
    });

    await db.insert('food_items', {
      'name': 'Veggie Burger',
      'description': 'Plant-based patty with avocado and vegan mayo',
      'price': 9.49,
      'imageUrl':
          'https://images.unsplash.com/photo-1585238342024-78d387f4a707?w=480&h=360&fit=crop',
      'ingredients': 'Plant Patty,Avocado,Lettuce,Tomato,Vegan Mayo',
      'prepTimeMinutes': 12,
      'rating': 4.3,
      'categoryId': 1,
      'isPopular': 0,
    });

    await db.insert('food_items', {
      'name': 'Chicken Burger',
      'description': 'Crispy chicken fillet with spicy sauce and pickles',
      'price': 8.79,
      'imageUrl':
          'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=480&h=360&fit=crop',
      'ingredients': 'Fried Chicken,Spicy Sauce,Pickles,Lettuce',
      'prepTimeMinutes': 14,
      'rating': 4.4,
      'categoryId': 1,
      'isPopular': 0,
    });

    // Add 3 more pizzas
    await db.insert('food_items', {
      'name': 'Pepperoni Pizza',
      'description': 'Classic pepperoni pizza with extra cheese',
      'price': 13.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=480&h=360&fit=crop',
      'ingredients': 'Dough,Tomato Sauce,Mozzarella,Pepperoni',
      'prepTimeMinutes': 22,
      'rating': 4.6,
      'categoryId': 2,
      'isPopular': 1,
    });

    await db.insert('food_items', {
      'name': 'Vegetarian Pizza',
      'description': 'Fresh garden vegetables on a thin crust',
      'price': 14.49,
      'imageUrl':
          'https://images.unsplash.com/photo-1589187151053-5ec8818e661b?w=480&h=360&fit=crop',
      'ingredients':
          'Dough,Tomato Sauce,Mozzarella,Bell Peppers,Mushrooms,Olives,Onions',
      'prepTimeMinutes': 20,
      'rating': 4.2,
      'categoryId': 2,
      'isPopular': 0,
    });

    await db.insert('food_items', {
      'name': 'Supreme Pizza',
      'description': 'Loaded with toppings - a meat lover\'s dream',
      'price': 15.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=480&h=360&fit=crop',
      'ingredients':
          'Dough,Tomato Sauce,Mozzarella,Pepperoni,Sausage,Ham,Bell Peppers,Onions,Olives',
      'prepTimeMinutes': 25,
      'rating': 4.7,
      'categoryId': 2,
      'isPopular': 0,
    });

    // Add 3 more desserts
    await db.insert('food_items', {
      'name': 'Strawberry Cheesecake',
      'description': 'Creamy cheesecake with fresh strawberry topping',
      'price': 7.49,
      'imageUrl':
          'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=480&h=360&fit=crop',
      'ingredients':
          'Cream Cheese,Sugar,Eggs,Butter,Graham Cracker,Strawberries',
      'prepTimeMinutes': 8,
      'rating': 4.7,
      'categoryId': 3,
      'isPopular': 0,
    });

    await db.insert('food_items', {
      'name': 'Tiramisu',
      'description': 'Italian coffee-flavored dessert with mascarpone',
      'price': 6.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=480&h=360&fit=crop',
      'ingredients': 'Ladyfingers,Espresso,Mascarpone,Cocoa Powder,Sugar',
      'prepTimeMinutes': 12,
      'rating': 4.6,
      'categoryId': 3,
      'isPopular': 0,
    });

    await db.insert('food_items', {
      'name': 'Apple Pie',
      'description': 'Warm apple pie with cinnamon and vanilla ice cream',
      'price': 5.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1535920527002-b35e96722eb9?w=480&h=360&fit=crop',
      'ingredients': 'Flour,Butter,Sugar,Apples,Cinnamon,Vanilla Ice Cream',
      'prepTimeMinutes': 15,
      'rating': 4.5,
      'categoryId': 3,
      'isPopular': 0,
    });

    // Add 3 more drinks
    await db.insert('food_items', {
      'name': 'Fruit Smoothie',
      'description': 'Blend of fresh fruits with yogurt and honey',
      'price': 4.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=480&h=360&fit=crop',
      'ingredients': 'Banana,Strawberry,Blueberry,Yogurt,Honey',
      'prepTimeMinutes': 6,
      'rating': 4.5,
      'categoryId': 4,
      'isPopular': 0,
    });

    await db.insert('food_items', {
      'name': 'Fresh Lemonade',
      'description': 'Refreshing lemonade with mint and ice',
      'price': 3.49,
      'imageUrl':
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=480&h=360&fit=crop',
      'ingredients': 'Lemons,Sugar,Mint,Ice,Water',
      'prepTimeMinutes': 4,
      'rating': 4.3,
      'categoryId': 4,
      'isPopular': 1,
    });

    await db.insert('food_items', {
      'name': 'Hot Chocolate',
      'description': 'Rich hot chocolate topped with whipped cream',
      'price': 4.49,
      'imageUrl':
          'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=480&h=360&fit=crop',
      'ingredients': 'Milk,Chocolate,Sugar,Whipped Cream',
      'prepTimeMinutes': 7,
      'rating': 4.8,
      'categoryId': 4,
      'isPopular': 0,
    });

    // Add 3 more salads
    await db.insert('food_items', {
      'name': 'Greek Salad',
      'description': 'Fresh veggies with feta cheese and olives',
      'price': 8.49,
      'imageUrl':
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=480&h=360&fit=crop',
      'ingredients':
          'Cucumber,Tomato,Red Onion,Feta Cheese,Kalamata Olives,Olive Oil',
      'prepTimeMinutes': 7,
      'rating': 4.4,
      'categoryId': 5,
      'isPopular': 0,
    });

    await db.insert('food_items', {
      'name': 'Cobb Salad',
      'description': 'Chicken, bacon, egg, and avocado on fresh greens',
      'price': 9.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1551248429-40975aa4de74?w=480&h=360&fit=crop',
      'ingredients': 'Chicken,Bacon,Egg,Avocado,Lettuce,Tomato,Blue Cheese',
      'prepTimeMinutes': 10,
      'rating': 4.7,
      'categoryId': 5,
      'isPopular': 1,
    });

    await db.insert('food_items', {
      'name': 'Quinoa Salad',
      'description': 'Healthy quinoa with roasted vegetables',
      'price': 8.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=480&h=360&fit=crop',
      'ingredients': 'Quinoa,Roasted Vegetables,Feta,Olive Oil,Lemon Juice',
      'prepTimeMinutes': 9,
      'rating': 4.5,
      'categoryId': 5,
      'isPopular': 0,
    });
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Drop existing tables and recreate them for version 3
      await db.execute("DROP TABLE IF EXISTS users");
      await db.execute("DROP TABLE IF EXISTS categories");
      await db.execute("DROP TABLE IF EXISTS food_items");
      await db.execute("DROP TABLE IF EXISTS orders");
      await db.execute("DROP TABLE IF EXISTS order_items");

      // Recreate tables
      await _createDB(db, newVersion);
    } else if (oldVersion == 3 && newVersion >= 4) {
      // Add favorites table only for version 4 upgrade
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const integerType = 'INTEGER NOT NULL';
      const textType = 'TEXT NOT NULL';

      // Create favorites table
      await db.execute('''
        CREATE TABLE favorites (
          id $idType,
          userId $integerType,
          foodItemId $integerType,
          addedDate $textType,
          UNIQUE(userId, foodItemId)
        )
      ''');

      // Continue with version 5 upgrade if needed
      if (newVersion >= 5 && oldVersion < 5) {
        // Add chat messages table for version 5
        await db.execute('''
          CREATE TABLE chat_messages (
            id $idType,
            userId $integerType,
            message $textType,
            isFromUser $integerType,
            timestamp $textType
          )
        ''');
      }
    } else if (oldVersion == 4 && newVersion == 5) {
      // Only add chat messages table if upgrading from 4 to 5
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const integerType = 'INTEGER NOT NULL';
      const textType = 'TEXT NOT NULL';

      await db.execute('''
        CREATE TABLE chat_messages (
          id $idType,
          userId $integerType,
          message $textType,
          isFromUser $integerType,
          timestamp $textType
        )
      ''');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
