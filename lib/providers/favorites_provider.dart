import 'package:flutter/foundation.dart';
import '../repositories/favorite_repository.dart';
import '../utils/session_manager.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  // Store favorite food item IDs
  final Set<int> _favoriteIds = {};
  // Track if this is a guest session
  bool _isGuest = false;
  // Track if the favorites have been loaded
  bool _initialized = false;

  // Getter for favorites
  Set<int> get favoriteIds => _favoriteIds;

  // Getter to check if initialization is complete
  bool get isInitialized => _initialized;

  // Initialize favorites
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get current user ID from session
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        _isGuest = true;
        _initialized = true;
        notifyListeners();
        return;
      }

      // Check if this is a guest user
      final userEmail = await SessionManager.getUserEmail();
      _isGuest = userEmail == 'guest@example.com';

      // Load favorites from database
      final favoriteIds = await _favoriteRepository.getUserFavoriteIds(userId);
      _favoriteIds.clear();
      _favoriteIds.addAll(favoriteIds);

      _initialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing favorites: $e');
      _initialized = true;
      notifyListeners();
    }
  }

  // Check if an item is favorited
  bool isFavorite(int foodItemId) {
    return _favoriteIds.contains(foodItemId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(int foodItemId) async {
    // Get current user ID from session
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    if (_favoriteIds.contains(foodItemId)) {
      // Remove from favorites
      _favoriteIds.remove(foodItemId);
      notifyListeners();

      if (!_isGuest) {
        // Persist changes for registered users
        await _favoriteRepository.removeFromFavorites(userId, foodItemId);
      }
    } else {
      // Add to favorites
      _favoriteIds.add(foodItemId);
      notifyListeners();

      if (!_isGuest) {
        // Persist changes for registered users
        await _favoriteRepository.addToFavorites(userId, foodItemId);
      }
    }
  }

  // Clear all favorites
  Future<void> clearFavorites() async {
    _favoriteIds.clear();
    notifyListeners();

    if (!_isGuest) {
      // Get current user ID from session
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        await _favoriteRepository.clearUserFavorites(userId);
      }
    }
  }

  // Reset favorites when user logs out
  void resetGuestFavorites() {
    if (_isGuest) {
      _favoriteIds.clear();
      notifyListeners();
    }
  }
}
