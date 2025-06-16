import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import 'home_page.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check if user has authentication data stored
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('user_id');
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (token != null && token.isNotEmpty && userId != null && userId.isNotEmpty) {
        // User has stored auth data, try to auto-login
        try {
          userProvider.setAuthenticationState(true);
          await userProvider.initializeUserData();
          print('Auto-login successful');
        } catch (e) {
          // If auto-login fails, clear stored data and continue as guest
          print('Auto-login failed: $e');
          await _clearStoredAuth();
          userProvider.setAuthenticationState(false);
        }
      } else {
        // No stored auth data, continue as guest
        userProvider.setAuthenticationState(false);
      }
    } catch (e) {
      print('Error during app initialization: $e');
      // If there's any error, continue as guest
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setAuthenticationState(false);
    } finally {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _clearStoredAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_first_name');
    await prefs.remove('user_last_name');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initializing app...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Always show the home page - authentication will be handled per feature
    return HomePageBase();
  }
}
