import 'package:flutter/material.dart';
import 'package:ecom/pages/home_page_main.dart';
import 'package:ecom/pages/profile_page.dart';

class HomePageBase extends StatefulWidget {
  const HomePageBase({Key? key}) : super(key: key);

  @override
  State<HomePageBase> createState() => _HomePageBaseState();
}

class _HomePageBaseState extends State<HomePageBase> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Fix recursive instantiation by using HomePage instead of HomePageBase
          _selectedIndex == 0 
              ? const HomePage() 
              : const SizedBox.shrink(),
          _selectedIndex == 1 
              ? const ProfilePage(
                  email: 'user@example.com',
                  phoneNumber: '+91 9876543210',
                  address: '123 Main Street, Mumbai',
                  pincode: 400001,
                  firstName: 'Anubhav',
                  lastName: 'Choubey',
                ) 
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
