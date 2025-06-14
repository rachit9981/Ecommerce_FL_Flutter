import 'package:ecom/pages/auth_gate.dart';
import 'package:ecom/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart'; // Import CartProvider

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
        ChangeNotifierProvider(create: (_) => CartProvider()), // Add CartProvider
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
        home: AuthGate(),
      ),
    );
  }
}