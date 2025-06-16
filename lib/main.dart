import 'package:ecom/providers/product_provider.dart';
import 'package:ecom/providers/banner_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'pages/login_page.dart';
import 'pages/cart_page.dart';
import 'pages/home_page.dart';
import 'services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFe76b23);
    const Color secondaryColor = Color(0xFFFFD701);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Anand Mobile',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
          ),
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
            secondary: secondaryColor,
          ),
        ),
        home: AppInitializer(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/cart': (context) => const CartPage(),
        },
      ),
    );
  }
}

// New app initializer that handles optional authentication
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
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
          final authService = AuthService();
          await authService.restoreUserSession(context);
          // Don't call setAuthenticationState here as restoreUserSession should handle it
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
    }    // Always show the home page - authentication will be handled per feature
    return HomePageBase();
  }
}