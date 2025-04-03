import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/order_repository.dart';
import 'dart:async';
import '../utils/session_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final UserRepository _userRepository = UserRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  User? _currentUser;
  bool _isLoading = true;
  bool _isGuest = false;
  bool _isLoggedIn = false;
  bool _obscurePassword = true;
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Add observer to detect when app resumes from background
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures we reload data when returning to this screen
    _loadUserData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload user data when app is resumed
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Debug print session state
      await SessionManager.debugPrintSession();

      // Validate the session first
      final isSessionValid = await SessionManager.validateSession();

      // Get current user ID from session manager
      final userId = await SessionManager.getUserId();
      final isLoggedIn = await SessionManager.isLoggedIn();
      _isLoggedIn = isLoggedIn;

      // Check if user is a guest
      final isGuestUser = await SessionManager.isGuest();
      _isGuest = isGuestUser;

      print(
        'ProfileScreen state: sessionValid=$isSessionValid, userId=$userId, isLoggedIn=$isLoggedIn, isGuest=$isGuestUser',
      );

      // If user is a guest or not logged in, show login form
      if (isGuestUser || !isLoggedIn || !isSessionValid) {
        setState(() {
          _isLoading = false;
          _isGuest = true;
          _currentUser = null;
        });
        return;
      }

      if (userId != null) {
        final user = await _userRepository.getUserById(userId);

        if (user != null) {
          // Get order count for this user
          final orders = await _orderRepository.getOrdersByUserId(userId);

          setState(() {
            _currentUser = user;
            _orderCount = orders.length;
            _isLoading = false;
            _isGuest = false;
          });
          print('User data loaded: ${user.name}, ${user.email}');
          return;
        }
      }

      // If no user found in database
      setState(() {
        _isLoading = false;
        _isGuest = true;
        _currentUser = null;
      });
      print('No user found in database');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isGuest = true;
        _currentUser = null;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Get user from database
      final user = await _userRepository.getUserByEmail(email);

      if (user != null && user.password == password) {
        // Successful login - save user session with proper user information
        if (user.id != null) {
          await SessionManager.saveSession(user.id!, email);
          print('User logged in successfully: ${user.name}');

          // Reload user data
          await _loadUserData();
        } else {
          _showErrorSnackBar(
            'User account is invalid. Please contact support.',
          );
        }
      } else {
        // Failed login
        _showErrorSnackBar('Invalid email or password');
      }
    } catch (e) {
      print('Login error: $e');
      _showErrorSnackBar('An error occurred during login. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register', arguments: 'fromProfile');
  }

  Future<void> _logout() async {
    try {
      await SessionManager.clearSession();

      // Create a guest session
      await _createGuestSession();

      if (!mounted) return;
      // Reset UI to guest mode and reload the HomeScreen
      setState(() {
        _isGuest = true;
        _isLoggedIn = false;
        _currentUser = null;
      });

      // Reset to home screen
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<void> _createGuestSession() async {
    try {
      // Create a new guest user
      final guestUser = User(
        name: 'Guest User',
        email: 'guest@example.com',
        password: 'guest123',
        phoneNumber: '',
        address: '',
      );

      // Insert or get existing guest user
      int? userId;
      final existingUser = await _userRepository.getUserByEmail(
        guestUser.email,
      );

      if (existingUser != null) {
        userId = existingUser.id;
      } else {
        userId = await _userRepository.insert(guestUser);
      }

      if (userId != null) {
        // Save guest session
        await SessionManager.saveSession(userId, guestUser.email);
        print('Guest session created with ID: $userId');
      }
    } catch (e) {
      print('Error creating guest session: $e');
    }
  }

  // Public method that can be called to force a reload
  void reloadUserData() {
    if (mounted) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: const Text('My Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isGuest && _isLoggedIn)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // Navigate to settings
              },
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isGuest || !_isLoggedIn
              ? _buildLoginForm()
              : _buildProfileContent(),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section text
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Account Required',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You need to create an account or login to access your profile.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Email Field
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'your.email@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password Field
            _buildTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: '••••••••',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),

            // Login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            // Register button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _navigateToRegister,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Register New Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        // Header with profile picture
        Container(
          color: AppTheme.primaryColor,
          height: 130,
          width: double.infinity,
          child: Column(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Profile form fields
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoField('Name', _currentUser?.name ?? 'Guest User'),
                const SizedBox(height: 15),
                _buildInfoField(
                  'Email',
                  _currentUser?.email ?? 'guest@example.com',
                ),
                const SizedBox(height: 15),
                _buildInfoField(
                  'Delivery address',
                  _currentUser?.address ?? 'No address provided',
                ),
                const SizedBox(height: 15),
                _buildInfoField(
                  'Phone',
                  _currentUser?.phoneNumber ?? 'Not provided',
                ),
                const SizedBox(height: 15),
                _buildPasswordField('Password', '••••••••'),
                const SizedBox(height: 30),

                // Payment details and Order history sections
                _buildNavigationItem(
                  context,
                  'Payment Details',
                  Icons.credit_card,
                  () {
                    // Navigate to payment details
                  },
                ),
                const SizedBox(height: 15),
                _buildNavigationItem(
                  context,
                  'Order history ($_orderCount)',
                  Icons.receipt_long,
                  () {
                    // Navigate to order history
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
                const SizedBox(height: 40),

                // Bottom buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Edit Profile',
                        Icons.edit,
                        AppTheme.textColor,
                        Colors.white,
                        _navigateToEditProfile,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildActionButton(
                        'Log out',
                        Icons.logout,
                        Colors.white,
                        AppTheme.primaryColor,
                        _logout,
                        outline: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: Colors.grey),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.lock, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color textColor,
    Color backgroundColor,
    VoidCallback onPressed, {
    bool outline = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side:
              outline
                  ? BorderSide(color: AppTheme.primaryColor, width: 2)
                  : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    if (_currentUser == null) return;

    // Navigate to Edit Profile screen and wait for result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _currentUser!),
      ),
    );

    // If we got a result (updated user), update the UI
    if (result != null && result is User) {
      setState(() {
        _currentUser = result;
      });
    }
  }
}
