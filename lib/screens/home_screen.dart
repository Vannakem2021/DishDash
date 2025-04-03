import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../utils/app_theme.dart';
import '../utils/food_data.dart';
import '../utils/session_manager.dart';
import '../widgets/category_selector.dart';
import '../widgets/food_item_card.dart';
import 'food_detail_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import '../widgets/home_tab_db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  bool _isGuest = false;
  final GlobalKey<ProfileScreenState> _profileKey =
      GlobalKey<ProfileScreenState>();

  // Create new instances to ensure they're properly initialized each time
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _checkIfGuest();
    _initScreens();
  }

  void _initScreens() {
    _screens = [
      const HomeTabDb(),
      const FavoritesScreen(),
      const ChatScreen(),
      ProfileScreen(key: _profileKey),
    ];
  }

  Future<void> _checkIfGuest() async {
    final isGuestUser = await SessionManager.isGuest();

    if (isGuestUser != _isGuest) {
      setState(() {
        _isGuest = isGuestUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedTabIndex,
        onTap: (index) async {
          // If user is a guest and tries to access restricted tabs (Chat or Profile)
          if (_isGuest && (index == 2 || index == 3)) {
            _showLoginRequiredDialog(index == 2 ? 'Chat' : 'Profile');
          } else {
            // Re-check guest status before switching tabs
            await _checkIfGuest();

            // If navigating to profile, trigger reload
            if (index == 3 && _profileKey.currentState != null) {
              _profileKey.currentState!.reloadUserData();
            }

            setState(() {
              _selectedTabIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Required'),
            content: Text(
              'You need to login or create an account to access the $feature feature.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('LOGIN'),
              ),
            ],
          ),
    );
  }
}
