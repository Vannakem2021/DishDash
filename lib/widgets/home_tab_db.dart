import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/category_model.dart';
import '../repositories/food_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/category_selector.dart';
import '../widgets/food_item_card.dart';
import '../screens/food_detail_screen.dart';
import '../utils/food_data.dart';

class HomeTabDb extends StatefulWidget {
  const HomeTabDb({Key? key}) : super(key: key);

  @override
  State<HomeTabDb> createState() => _HomeTabDbState();
}

class _HomeTabDbState extends State<HomeTabDb> {
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
      // Load data from database
      final categories = await _foodRepository.getAllCategories();
      final foodItems = await _foodRepository.getAllFoodItems();

      // If database is empty, use mock data
      if (foodItems.isEmpty) {
        print('No food items in database, using mock data');
        _loadMockData();
        return;
      }

      // Add "All" category at the beginning
      final allCategories = [
        Category(id: 0, name: "All", imageUrl: null),
        ...categories,
      ];

      setState(() {
        _categories = allCategories;
        _foodItems = foodItems;
        _filteredFoodItems = foodItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Fall back to mock data if database fails
      print('Error loading data from database: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    // Fallback to mock data
    final foodItems = FoodData.allItems;
    final mockCategories = [Category(id: 0, name: "All", imageUrl: null)];

    // Add category objects from FoodData categories
    for (int i = 1; i < FoodData.categories.length; i++) {
      mockCategories.add(
        Category(id: i, name: FoodData.categories[i], imageUrl: null),
      );
    }

    setState(() {
      _categories = mockCategories;
      _foodItems = foodItems;
      _filteredFoodItems = foodItems;
      _isLoading = false;
    });
  }

  void _filterFoodItems() {
    setState(() {
      if (_selectedCategoryIndex == 0) {
        _filteredFoodItems =
            _foodItems
                .where(
                  (item) => item.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();
      } else {
        // Use category ID for filtering if available
        final selectedCategory = _categories[_selectedCategoryIndex];

        _filteredFoodItems =
            _foodItems
                .where(
                  (item) =>
                      item.categoryId == selectedCategory.id &&
                      item.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get category names from the database categories
    List<String> categoryNames =
        _categories.isEmpty
            ? FoodData
                .categories // fallback to mock data
            : _categories.map((c) => c.name).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivering to',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Current Location',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Navigate to cart
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for foods...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterFoodItems();
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          CategorySelector(
            categories: categoryNames,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategoryIndex = categoryNames.indexOf(category);
                _filterFoodItems();
              });
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategoryIndex == 0
                      ? 'All Foods'
                      : categoryNames[_selectedCategoryIndex],
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                if (_filteredFoodItems.isNotEmpty)
                  Text(
                    '${_filteredFoodItems.length} items',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredFoodItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items found',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search or category',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(15),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemCount: _filteredFoodItems.length,
                      itemBuilder: (context, index) {
                        final foodItem = _filteredFoodItems[index];
                        return FoodItemCard(
                          foodItem: foodItem,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        FoodDetailScreen(foodItem: foodItem),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
