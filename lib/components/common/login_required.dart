import 'package:flutter/material.dart';
import 'package:ecom/pages/login_page.dart';

class LoginRequired extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onLoginPressed;

  const LoginRequired({
    Key? key,
    this.title = 'Login Required',
    this.message = 'Please login to access this feature',
    this.buttonText = 'Login',
    this.icon = Icons.login,
    this.iconColor,
    this.onLoginPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 64, 
              color: iconColor ?? primaryColor
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onLoginPressed ?? () {
                // Navigate to login page
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
