# DishDash System Patterns

## Architecture

DishDash follows a layered architecture with clear separation of concerns:

1. **Presentation Layer (UI)**

   - Screen components
   - UI widgets
   - Theme definitions
   - Navigation

2. **Business Logic Layer**

   - Providers (state management)
   - Services (business operations)
   - Validation logic

3. **Data Layer**
   - Repositories (data access)
   - Models (data structures)
   - Database helpers
   - Session management

## Design Patterns

1. **Repository Pattern**

   - Abstracts data sources (SQLite)
   - Provides clean interfaces for data access
   - Centralizes data validation logic
   - Example: `FoodRepository`, `UserRepository`, `OrderRepository`

2. **Provider Pattern**

   - Manages application state
   - Facilitates communication between UI and data layers
   - Reduces widget rebuilds for performance
   - Example: `CartProvider`

3. **Singleton Pattern**

   - Used for database helper to ensure single instance
   - Manages shared resources efficiently
   - Example: `DatabaseHelper.instance`

4. **Factory Pattern**
   - Used in model constructors for data mapping
   - Creates objects from database records
   - Example: `FoodItem.fromMap()`, `User.fromMap()`

## Database Structure

DishDash uses SQLite for local data storage with the following tables:

1. **users**

   - Stores user account information
   - Manages authentication data
   - Includes profile information

2. **categories**

   - Food categories for organization
   - Category images
   - Navigation structure

3. **food_items**

   - Detailed food information
   - Connected to categories
   - Contains pricing and ingredients

4. **orders**

   - Order header information
   - Status tracking
   - Delivery details

5. **order_items**
   - Line items for each order
   - Quantities and prices
   - Links to food items

## Component Relationships

1. **User Authentication Flow**

   - `SplashScreen` → `SessionManager` → `LoginScreen` or `HomeScreen`
   - Authentication state persisted with `shared_preferences`

2. **Food Browsing Flow**

   - `HomeScreen` → `CategoryTabs` → `FoodItemCards`
   - Data provided through repositories to UI components

3. **Order Processing Flow**

   - `FoodDetailScreen` → `CartProvider` → `CartScreen` → `CheckoutScreen` → `OrderConfirmationScreen`
   - Each step updates cart state and validates user actions

4. **Profile Management Flow**
   - `ProfileScreen` → `UserRepository` → Database operations
   - Session management handled by `SessionManager`

## Key Technical Decisions

1. **SQLite for Local Storage**

   - Provides robust, structured data storage
   - Enables offline functionality
   - Simplifies data relationships

2. **Provider for State Management**

   - Lightweight solution appropriate for app complexity
   - Efficient widget rebuilding
   - Straightforward integration with Flutter

3. **Shared Preferences for Session Management**

   - Simple, persistent storage for authentication tokens
   - Low overhead for simple key-value data
   - Built-in Flutter support

4. **Cached Network Image**
   - Efficient image loading and caching
   - Reduces network requests
   - Handles image loading errors gracefully
