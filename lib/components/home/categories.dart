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
    
    print('HomeCategoriesSection: Loaded ${categories.length} categories from API');
    
    final List<Color> colorOptions = [
      Colors.grey.shade700, Colors.grey.shade600, Colors.grey.shade800, 
      Colors.blueGrey.shade700, Colors.blueGrey.shade600, Colors.blueGrey.shade800,
      Colors.grey.shade500, Colors.blueGrey.shade500, Colors.grey.shade400, 
      Colors.blueGrey.shade400,
    ];
    
    List<CategoryItem> categoryItems = [];
    int colorIndex = 0;
    
    for (var category in categories) {
      // Use the category name (lowercased) as the ID for matching with products
      // This ensures consistency with how products store their category field
      final categoryId = category.name.toLowerCase().trim();
      
      final item = CategoryItem(
        id: categoryId, // Use normalized name for matching
        title: category.name,
        imageUrl: category.imageUrl,
        backgroundColor: colorOptions[colorIndex % colorOptions.length].withOpacity(0.1),
      );
      
      print('HomeCategoriesSection: API Category - ID: "${item.id}", Title: "${item.title}", ImageUrl: "${item.imageUrl}"');
      
      categoryItems.add(
        item.copyWith(onTap: () {
          print('HomeCategoriesSection: API Category tapped: "${item.id}" (${item.title})');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryPage(category: item)),
          );
        }),
      );
      colorIndex++;
    }
    
    print('HomeCategoriesSection: Created ${categoryItems.length} API category items');
    return categoryItems;
  } catch (e) {
    print('HomeCategoriesSection: API categories failed: $e');
    // If API fails, return empty list or fallback to dynamic categories
    return [];
  }
}

// Method to get dynamic categories from product data
List<CategoryItem> getDynamicCategories(BuildContext context, List<Product> products) {
  final Map<String, String> uniqueCategories = {};
  
  // Collect all unique categories from products
  for (var product in products) {
    final categoryKey = product.category.toLowerCase().trim();
    if (categoryKey.isNotEmpty && !uniqueCategories.containsKey(categoryKey)) {
      uniqueCategories[categoryKey] = product.category.trim();
    }
  }
  
  print('HomeCategoriesSection: Found ${uniqueCategories.length} unique categories from ${products.length} products');
  print('HomeCategoriesSection: Categories found: ${uniqueCategories.keys.toList()}');
  
  final List<Color> colorOptions = [
    Colors.grey.shade700, Colors.grey.shade600, Colors.grey.shade800, 
    Colors.blueGrey.shade700, Colors.blueGrey.shade600, Colors.blueGrey.shade800,
    Colors.grey.shade500, Colors.blueGrey.shade500, Colors.grey.shade400, 
    Colors.blueGrey.shade400,
  ];

  List<CategoryItem> categoryItems = [];
  int colorIndex = 0;

  for (var entry in uniqueCategories.entries) {
    final categoryKey = entry.key; // lowercase version for ID
    final originalCategory = entry.value; // original case for display

    final item = CategoryItem(
      id: categoryKey, // Use lowercase version as ID for consistent matching
      title: originalCategory.substring(0, 1).toUpperCase() + originalCategory.substring(1),
      backgroundColor: colorOptions[colorIndex % colorOptions.length].withOpacity(0.1),
    );
    
    print('HomeCategoriesSection: Creating category item with ID: "${item.id}" and title: "${item.title}"');
    
    categoryItems.add(
      item.copyWith(onTap: () { // Use copyWith to set onTap
        print('HomeCategoriesSection: Category tapped: "${item.id}" (${item.title})');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryPage(category: item)), // Pass the CategoryItem object
        );
      }),
    );
    colorIndex++;
  }
  
  print('HomeCategoriesSection: Created ${categoryItems.length} category items');
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
          );        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Fallback to dynamic categories from products if API fails
          print('HomeCategoriesSection: API failed or empty, using dynamic categories from ${products.length} products');
          if (snapshot.hasError) {
            print('HomeCategoriesSection: API error: ${snapshot.error}');
          }
          categories = getDynamicCategories(context, products);
        } else {
          // Use API data
          print('HomeCategoriesSection: Using API categories: ${snapshot.data!.length}');
          categories = snapshot.data!;
        }
        
        print('HomeCategoriesSection: Final categories count: ${categories.length}');
        
        if (categories.isEmpty) {
          print('HomeCategoriesSection: No categories to display');
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
