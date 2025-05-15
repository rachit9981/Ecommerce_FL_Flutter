import 'package:flutter/material.dart';
import 'package:ecom/components/app_bar/home.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: Center(
        child: Text('Welcome to our E-commerce Store!'),
      ),
    );
  }
}
