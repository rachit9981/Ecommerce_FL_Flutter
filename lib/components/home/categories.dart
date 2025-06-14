import 'package:flutter/material.dart';
import 'package:ecom/components/common/categories.dart' show CategoryItem, HorizontalCategoryList;
import 'package:ecom/services/products.dart' show Product;
import 'package:ecom/pages/category_page.dart';

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
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal,
    Colors.pink, Colors.indigo, Colors.amber, Colors.cyan,
  ];

  List<CategoryItem> categoryItems = [];
  int colorIndex = 0;
  for (var entry in uniqueCategories.entries) {
    final originalCategory = entry.value;
    IconData icon = CategoryItem.getBestIconForCategory(originalCategory); // Use helper from CategoryItem

    final item = CategoryItem(
      id: originalCategory,
      title: originalCategory.substring(0, 1).toUpperCase() + originalCategory.substring(1),
      icon: icon,
      backgroundColor: colorOptions[colorIndex % colorOptions.length].withOpacity(0.2),
      iconColor: colorOptions[colorIndex % colorOptions.length],
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

// Method to get dynamic mobile brands from product data
List<CategoryItem> getDynamicBrands(BuildContext context, List<Product> products) {
  final Map<String, String> uniqueBrands = {};
  for (var product in products) {
    final categoryLower = product.category.toLowerCase().trim();
    final brandKey = product.brand.toLowerCase().trim();
    if ((categoryLower.contains('mobile') || categoryLower.contains('smartphone') || categoryLower.contains('phone')) &&
        !uniqueBrands.containsKey(brandKey)) {
      uniqueBrands[brandKey] = product.brand;
    }
  }

  final Map<String, String> brandLogos = {
    'samsung': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
    'apple': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
    'xiaomi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
    'oneplus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
    'oppo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/OPPO_LOGO_2019.svg/2560px-OPPO_LOGO_2019.svg.png',
    'vivo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Vivo_logo.svg/1024px-Vivo_logo.svg.png',
    'google': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png',
    'huawei': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Huawei.svg/1280px-Huawei.svg.png',
    'motorola': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Motorola_logo.svg/2560px-Motorola_logo.svg.png',
    'realme': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Realme_logo.svg/2560px-Realme_logo.svg.png',
    'nokia': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Nokia_wordmark.svg/1280px-Nokia_wordmark.svg.png',
    'sony': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Sony_logo.svg/2560px-Sony_logo.svg.png',
    'asus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/ASUS_Logo.svg/2560px-ASUS_Logo.svg.png',
    'htc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/HTC_logo.svg/1024px-HTC_logo.svg.png',
  };

  List<CategoryItem> brandItems = [];
  for (var entry in uniqueBrands.entries) {
    final brandKey = entry.key;
    final originalBrand = entry.value;
    String logoUrl = '';
    for (var logoEntryKey in brandLogos.keys) {
      if (brandKey.contains(logoEntryKey)) {
        logoUrl = brandLogos[logoEntryKey]!;
        break;
      }
    }
    if (logoUrl.isEmpty) {
      logoUrl = 'https://via.placeholder.com/200x100?text=\${originalBrand.toUpperCase()}';
    }
    final item = CategoryItem(
      id: originalBrand, // ID is the brand name
      title: originalBrand.substring(0, 1).toUpperCase() + originalBrand.substring(1),
      imageUrl: logoUrl,
    );
    brandItems.add(
      item.copyWith(onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryPage(category: item)), // Pass CategoryItem
        );
      }),
    );
  }
  return brandItems;
}

// Fallback method to provide brand items
List<CategoryItem> getFallbackBrandItems(BuildContext context) {
  List<Map<String, String>> fallbackBrandData = [
    {'id': 'Samsung', 'title': 'Samsung', 'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png'},
    {'id': 'Apple', 'title': 'Apple', 'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png'},
    {'id': 'Xiaomi', 'title': 'Xiaomi', 'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png'},
    {'id': 'OnePlus', 'title': 'OnePlus', 'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg'},
  ];

  return fallbackBrandData.map((data) {
    final item = CategoryItem(
      id: data['id']!,
      title: data['title']!,
      imageUrl: data['imageUrl']!,
    );
    return item.copyWith(onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CategoryPage(category: item)), // Pass CategoryItem
      );
    });
  }).toList();
}

class HomeCategoriesSection extends StatelessWidget {
  final List<Product> products;
  const HomeCategoriesSection({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = getDynamicCategories(context, products);
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text('Shop by Category', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: -0.5)),
        ),
        HorizontalCategoryList(categories: categories, itemHeight: 100, itemWidth: 85, spacing: 12),
        const SizedBox(height: 12),
      ],
    );
  }
}

class HomeBrandsSection extends StatelessWidget {
  final List<Product> products;
  const HomeBrandsSection({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mobileBrands = products.isNotEmpty ? getDynamicBrands(context, products) : getFallbackBrandItems(context);
    if (mobileBrands.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          child: Text('Popular Mobile Brands', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: -0.5)),
        ),
        HorizontalCategoryList(categories: mobileBrands, itemWidth: 80, itemHeight: 100, spacing: 12, showShadow: true, brandMode: true),
        const SizedBox(height: 16),
      ],
    );
  }
}
