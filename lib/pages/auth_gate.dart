import 'package:ecom/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom/pages/login_page.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:ecom/providers/user_provider.dart'; // Add this import

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('user_id');
      
      // Check if user has valid authentication data
      if (token != null && token.isNotEmpty && userId != null && userId.isNotEmpty) {
        // Load user data before proceeding
        await _loadUserData();
        
        // Optional: Validate token with backend
        // bool isTokenValid = await _validateToken(token);
        // For now, we'll assume token is valid if it exists
        setState(() {
          _isLoggedIn = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If there's an error checking auth status, default to not logged in
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  // Add method to load user data
  Future<void> _loadUserData() async {
    try {
      // Get the UserProvider and initialize user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Set authentication state to true before loading data
      userProvider.setAuthenticationState(true);
      
      // Load user profile and addresses
      await userProvider.initializeUserData();
      
      print('User data loaded successfully in AuthGate');
    } catch (e) {
      print('Error loading user data in AuthGate: $e');
      // Even if we fail to load user data, we can still proceed
      // The user provider will handle authentication failures
    }
  }

  // Optional: Method to validate token with backend
  // Future<bool> _validateToken(String token) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$apiUrl/auth/validate/'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Checking authentication...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Route based on authentication status
    if (_isLoggedIn) {
      return HomePageBase();
    } else {
      return const LoginPage();
    }
  }
}
