import 'package:flutter/material.dart';
import 'package:ecom/components/common/categories.dart' show CategoryItem, HorizontalCategoryList;
import 'package:ecom/services/products.dart' show Product;
import 'package:ecom/services/categories.dart';
import 'package:ecom/pages/category_page.dart';

// Method to get categories from API service
Future<List<CategoryItem>> getApiCategories(BuildContext context) async {
  try {
    final categoriesService = CategoriesService();
    final categories = await categoriesService.getCategories();
    
    final List<Color> colorOptions = [
      Colors.grey.shade700, Colors.grey.shade600, Colors.grey.shade800, 
      Colors.blueGrey.shade700, Colors.blueGrey.shade600, Colors.blueGrey.shade800,
      Colors.grey.shade500, Colors.blueGrey.shade500, Colors.grey.shade400, 
      Colors.blueGrey.shade400,
    ];
    
    List<CategoryItem> categoryItems = [];
    int colorIndex = 0;
    
    for (var category in categories) {
      final item = CategoryItem(
        id: category.id,
        title: category.name,
        imageUrl: category.imageUrl,
        backgroundColor: colorOptions[colorIndex % colorOptions.length].withOpacity(0.1),
      );
      
      categoryItems.add(
        item.copyWith(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryPage(category: item)),
          );
        }),
      );
      colorIndex++;
    }
    
    return categoryItems;
  } catch (e) {
    // If API fails, return empty list or fallback to dynamic categories
    return [];
  }
}

// Method to get dynamic categories from product data
List<CategoryItem> getDynamicCategories(BuildContext context, List<Product> products) {
  final Map<String, String> uniqueCategories = {};
  for (var product in products) {
    final categoryKey = product.category.toLowerCase().trim();
    if (!uniqueCategories.containsKey(categoryKey)) {
      uniqueCategories[categoryKey] = product.category;
    }
  }
  final List<Color> colorOptions = [
    Colors.grey.shade700, Colors.grey.shade600, Colors.grey.shade800, 
    Colors.blueGrey.shade700, Colors.blueGrey.shade600, Colors.blueGrey.shade800,
    Colors.grey.shade500, Colors.blueGrey.shade500, Colors.grey.shade400, 
    Colors.blueGrey.shade400,
  ];

  List<CategoryItem> categoryItems = [];
  int colorIndex = 0;

  for (var entry in uniqueCategories.entries) {
    final originalCategory = entry.value;

    final item = CategoryItem(
      id: originalCategory,
      title: originalCategory.substring(0, 1).toUpperCase() + originalCategory.substring(1),
      backgroundColor: colorOptions[colorIndex % colorOptions.length].withOpacity(0.1),
    );
    
    categoryItems.add(
      item.copyWith(onTap: () { // Use copyWith to set onTap
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryPage(category: item)), // Pass the CategoryItem object
        );
      }),
    );
    colorIndex++;
  }
  return categoryItems;
}

class HomeCategoriesSection extends StatelessWidget {
  final List<Product> products;
  const HomeCategoriesSection({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoryItem>>(
      future: getApiCategories(context),
      builder: (context, snapshot) {
        List<CategoryItem> categories = [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading state
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: Text('Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                )),
              ),
              const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 12),
            ],
          );
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Fallback to dynamic categories from products if API fails
          categories = getDynamicCategories(context, products);
        } else {
          // Use API data
          categories = snapshot.data!;
        }
        
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text('Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: Colors.black87,
              )),
            ),
            HorizontalCategoryList(categories: categories, itemHeight: 100, itemWidth: 85, spacing: 12),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
