import 'package:flutter/material.dart';
import 'package:ecom/pages/search_page.dart';

class HomeSearchBarComponent extends StatelessWidget {
  const HomeSearchBarComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      },      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600], size: 22),
            const SizedBox(width: 12),
            Text(
              'Search products...',
              style: TextStyle(
                color: Colors.grey[600], 
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}