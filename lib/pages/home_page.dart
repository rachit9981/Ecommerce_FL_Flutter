import 'package:flutter/material.dart';
import 'package:ecom/pages/home_page_main.dart';
import 'package:ecom/pages/profile_page.dart';
import 'package:ecom/pages/sell_phone.dart';
import 'package:provider/provider.dart';
import 'package:ecom/providers/user_provider.dart';

class HomePageBase extends StatefulWidget {
  const HomePageBase({Key? key}) : super(key: key);

  @override
  State<HomePageBase> createState() => _HomePageBaseState();
}

class _HomePageBaseState extends State<HomePageBase> {
  int _selectedIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Check if user data is already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserData();
    });
  }

  Future<void> _checkUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // If user data isn't loaded yet, try to load it
    if (!userProvider.hasUserData) {
      await userProvider.refreshUserData();
    }
    
    setState(() {
      _isInitialized = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Check if user data is still loading
    final userProvider = Provider.of<UserProvider>(context);
    
    // Show loading indicator while user data is being initialized
    if (!_isInitialized || userProvider.isProfileLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading your profile...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    // If authentication failed or user not authenticated, redirect will happen through provider
    if (!userProvider.isAuthenticated) {
      // This will only show briefly before the auth_gate redirects
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Authentication error. Redirecting...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home page
          _selectedIndex == 0 
              ? const HomePage() 
              : const SizedBox.shrink(),
          
          // Sell Phone page
          _selectedIndex == 1 
              ? const SellPhonePage() 
              : const SizedBox.shrink(),
          
          // Profile page
          _selectedIndex == 2 
              ? const ProfilePage()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
          color: Colors.white,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: _selectedIndex,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey.shade600,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                elevation: 0,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sell_outlined),
                    activeIcon: Icon(Icons.sell),
                    label: 'Sell Phone',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
