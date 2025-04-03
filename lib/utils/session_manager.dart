import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Save user session
  static Future<void> saveSession(int userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setBool(_isLoggedInKey, true);
    print('Session saved: userId=$userId, email=$email, isLoggedIn=true');
  }

  // Get current user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // Get current user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Check if user is a guest
  static Future<bool> isGuest() async {
    final userEmail = await getUserEmail();
    return userEmail == 'guest@example.com';
  }

  // Check if user is authenticated (logged in and not a guest)
  static Future<bool> isAuthenticated() async {
    final isUserLoggedIn = await isLoggedIn();
    final isGuestUser = await isGuest();
    return isUserLoggedIn && !isGuestUser;
  }

  // Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.setBool(_isLoggedInKey, false);
    print('Session cleared');
  }

  // Validate the session has all required data
  static Future<bool> validateSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final userEmail = prefs.getString(_userEmailKey);
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    final isValid = userId != null && userEmail != null && isLoggedIn;
    print(
      'Session validation: userId=$userId, email=$userEmail, isLoggedIn=$isLoggedIn, isValid=$isValid',
    );
    return isValid;
  }

  // Debug method to print current session state
  static Future<void> debugPrintSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final userEmail = prefs.getString(_userEmailKey);
    final isLoggedIn = prefs.getBool(_isLoggedInKey);

    print(
      'Session debug: userId=$userId, email=$userEmail, isLoggedIn=$isLoggedIn',
    );
  }
}
