import '../models/food_item.dart';

class FoodData {
  static List<FoodItem> popularItems = [
    FoodItem(
      id: 1,
      name: "Veggie Tomato Mix",
      description:
          "A delicious mix of fresh vegetables and juicy tomatoes served with a special sauce.",
      price: 9.99,
      imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c",
      ingredients: ["Tomato", "Lettuce", "Carrot", "Cucumber", "Special Sauce"],
      prepTimeMinutes: 15,
      rating: 4.5,
      categoryId: 1,
      isPopular: true,
    ),
    FoodItem(
      id: 2,
      name: "Spicy Chicken Burger",
      description:
          "Juicy chicken patty with spicy sauce, fresh lettuce, and tomatoes in a soft bun.",
      price: 12.99,
      imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
      ingredients: [
        "Chicken Patty",
        "Lettuce",
        "Tomato",
        "Spicy Sauce",
        "Cheese",
        "Bun",
      ],
      prepTimeMinutes: 20,
      rating: 4.8,
      categoryId: 2,
      isPopular: true,
    ),
    FoodItem(
      id: 3,
      name: "Classic Margherita Pizza",
      description:
          "Traditional Italian pizza with fresh mozzarella, tomatoes, and basil on a thin crust.",
      price: 14.99,
      imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002",
      ingredients: [
        "Pizza Dough",
        "Tomato Sauce",
        "Fresh Mozzarella",
        "Basil",
        "Olive Oil",
      ],
      prepTimeMinutes: 25,
      rating: 4.7,
      categoryId: 3,
      isPopular: true,
    ),
  ];

  static List<FoodItem> allItems = [
    ...popularItems,
    FoodItem(
      id: 4,
      name: "Mediterranean Salad",
      description:
          "Fresh salad with cucumbers, tomatoes, olives, feta cheese, and olive oil dressing.",
      price: 8.99,
      imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd",
      ingredients: [
        "Cucumber",
        "Tomato",
        "Olives",
        "Feta Cheese",
        "Olive Oil",
        "Lemon",
      ],
      prepTimeMinutes: 10,
      rating: 4.2,
      categoryId: 1,
    ),
    FoodItem(
      id: 5,
      name: "Classic Beef Burger",
      description:
          "Juicy beef patty with cheese, lettuce, tomato, and our secret sauce in a brioche bun.",
      price: 11.99,
      imageUrl: "https://images.unsplash.com/photo-1571091718767-18b5b1457add",
      ingredients: [
        "Beef Patty",
        "Cheese",
        "Lettuce",
        "Tomato",
        "Secret Sauce",
        "Brioche Bun",
      ],
      prepTimeMinutes: 18,
      rating: 4.6,
      categoryId: 2,
    ),
    FoodItem(
      id: 6,
      name: "Pepperoni Pizza",
      description:
          "Classic pizza with tomato sauce, mozzarella cheese and spicy pepperoni slices.",
      price: 13.99,
      imageUrl: "https://images.unsplash.com/photo-1534308983496-4fabb1a015ee",
      ingredients: ["Pizza Dough", "Tomato Sauce", "Mozzarella", "Pepperoni"],
      prepTimeMinutes: 22,
      rating: 4.4,
      categoryId: 3,
    ),
    FoodItem(
      id: 7,
      name: "Grilled Chicken Sandwich",
      description:
          "Tender grilled chicken with avocado, bacon, lettuce, and honey mustard sauce.",
      price: 10.99,
      imageUrl: "https://images.unsplash.com/photo-1521390188846-e2a3a97453a0",
      ingredients: [
        "Grilled Chicken",
        "Avocado",
        "Bacon",
        "Lettuce",
        "Honey Mustard",
        "Bread",
      ],
      prepTimeMinutes: 15,
      rating: 4.3,
      categoryId: 4,
    ),
    FoodItem(
      id: 8,
      name: "Chocolate Brownie Sundae",
      description:
          "Warm chocolate brownie topped with vanilla ice cream, chocolate sauce, and whipped cream.",
      price: 7.99,
      imageUrl: "https://images.unsplash.com/photo-1563805042-7684c019e1cb",
      ingredients: [
        "Brownie",
        "Vanilla Ice Cream",
        "Chocolate Sauce",
        "Whipped Cream",
        "Cherry",
      ],
      prepTimeMinutes: 8,
      rating: 4.9,
      categoryId: 5,
    ),
  ];

  // Map category IDs to names for backward compatibility
  static String getCategoryName(int? categoryId) {
    if (categoryId == null) return "Other";

    switch (categoryId) {
      case 1:
        return "Burgers";
      case 2:
        return "Pizza";
      case 3:
        return "Desserts";
      case 4:
        return "Drinks";
      case 5:
        return "Salads";
      default:
        return "Other";
    }
  }

  static List<String> categories = [
    "All",
    "Burgers",
    "Pizza",
    "Desserts",
    "Drinks",
    "Salads",
  ];
}
