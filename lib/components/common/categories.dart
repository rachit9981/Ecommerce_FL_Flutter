import 'package:flutter/material.dart';

/// Standard category model used throughout the app
class CategoryItem {
  final String id;
  final String title;
  final String? imageUrl;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  CategoryItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.icon,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });
}

/// Utility class with sample categories for testing
class CategoryData {
  static List<CategoryItem> getSampleCategories(BuildContext context) {
    return [
      CategoryItem(
        id: 'electronics',
        title: 'Electronics',
        imageUrl:
            'https://images.unsplash.com/photo-1498049794561-7780e7231661?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.devices,
        backgroundColor: Colors.blue.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Electronics category tapped')),
          );
        },
      ),
      CategoryItem(
        id: 'fashion',
        title: 'Fashion',
        imageUrl:
            'https://images.unsplash.com/photo-1551232864-3f0890e580d9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.checkroom,
        backgroundColor: Colors.pink.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fashion category tapped')),
          );
        },
      ),
      CategoryItem(
        id: 'home',
        title: 'Home & Kitchen',
        imageUrl:
            'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.chair,
        backgroundColor: Colors.green.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Home & Kitchen category tapped')),
          );
        },
      ),
      CategoryItem(
        id: 'beauty',
        title: 'Beauty',
        imageUrl:
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.face,
        backgroundColor: Colors.purple.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Beauty category tapped')),
          );
        },
      ),
      CategoryItem(
        id: 'sports',
        title: 'Sports & Outdoors',
        imageUrl:
            'https://images.unsplash.com/photo-1530549387789-4c1017266635?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.sports_basketball,
        backgroundColor: Colors.orange.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sports category tapped')),
          );
        },
      ),
      CategoryItem(
        id: 'books',
        title: 'Books',
        imageUrl:
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.menu_book,
        backgroundColor: Colors.brown.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Books category tapped')),
          );
        },
      ),
      CategoryItem(
        id: 'toys',
        title: 'Toys & Games',
        imageUrl:
            'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.toys,
        backgroundColor: Colors.red.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Toys & Games category tapped')),
          );
        },
      ),
    ];
  }
}

class CategoryGridView extends StatelessWidget {
  final List<CategoryItem> categories;
  final ValueChanged<CategoryItem>? onCategoryTap;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const CategoryGridView({
    Key? key,
    required this.categories,
    this.onCategoryTap,
    this.crossAxisCount = 4,
    this.spacing = 16.0,
    this.childAspectRatio = 0.85,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double gridItemHeight = MediaQuery.of(context).size.width / crossAxisCount / childAspectRatio;
    final double totalHeight = (categories.length / crossAxisCount).ceil() * 
        (gridItemHeight + spacing);
    
    return SizedBox(
      height: totalHeight > 0 ? totalHeight : 200,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryGridItem(
            category: categories[index],
            onTap: () => _handleTap(index),
          );
        },
      ),
    );
  }
  
  void _handleTap(int index) {
    if (onCategoryTap != null) {
      onCategoryTap!(categories[index]);
    }
  }
}

/// Individual grid item for categories
class CategoryGridItem extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const CategoryGridItem({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.primary;
    final bgColor = category.backgroundColor ?? 
        theme.colorScheme.primary.withOpacity(0.1);
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor,
                Color.lerp(bgColor, Colors.white, 0.2) ?? bgColor,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevent overflow
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: defaultColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: category.imageUrl != null 
                  ? _buildCategoryImage(context)
                  : Icon(
                      category.icon ?? Icons.category,
                      color: category.iconColor ?? defaultColor,
                      size: 26, // Reduced size
                    ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Flexible( // Wrap in Flexible to prevent overflow
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11, // Reduced font size
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.network(
        category.imageUrl!,
        width: 32, // Reduced size
        height: 32, // Reduced size
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            category.icon ?? Icons.category,
            color: category.iconColor ?? Theme.of(context).colorScheme.primary,
            size: 26, // Match icon size
          );
        },
      ),
    );
  }
}

/// Horizontal list of category items
class HorizontalCategoryList extends StatelessWidget {
  final List<CategoryItem> categories;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final bool showShadow;
  final bool brandMode; // Flag for brand styling

  const HorizontalCategoryList({
    Key? key,
    required this.categories,
    this.itemWidth = 100,
    this.itemHeight = 120,
    this.spacing = 16,
    this.showShadow = false,
    this.brandMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(
            context,
            categories[index],
            index,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryItem item, int index) {
    return Container(
      width: itemWidth,
      height: itemHeight,
      margin: EdgeInsets.only(right: spacing, bottom: showShadow ? 4 : 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.imageUrl != null) ...[
                    Expanded(
                      child: brandMode 
                          ? _buildBrandLogo(item.imageUrl!)
                          : _buildCategoryImage(item.imageUrl!),
                    ),
                  ] else if (item.icon != null) ...[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.backgroundColor ??
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor ?? Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  // Specialized widget for brand logos
  Widget _buildBrandLogo(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
      ),
    );
  }
}