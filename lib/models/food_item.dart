class FoodItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final int prepTimeMinutes;
  final double rating;
  final int categoryId;
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
