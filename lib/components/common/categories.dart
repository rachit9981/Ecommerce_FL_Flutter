import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.icon,
    this.color,
    this.backgroundColor,
    this.onTap,
  });
}

/// Sample categories data that can be used throughout the app
class CategoryData {
  static List<Category> getSampleCategories(BuildContext context) {
    return [
      Category(
        id: '1',
        name: 'Electronics',
        imageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.devices,
        backgroundColor: Colors.blue.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Electronics category tapped')),
          );
        },
      ),
      Category(
        id: '2',
        name: 'Fashion',
        imageUrl: 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.checkroom,
        backgroundColor: Colors.pink.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fashion category tapped')),
          );
        },
      ),
      Category(
        id: '3',
        name: 'Home & Kitchen',
        imageUrl: 'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.chair,
        backgroundColor: Colors.green.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Home & Kitchen category tapped')),
          );
        },
      ),
      Category(
        id: '4',
        name: 'Beauty',
        imageUrl: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.face,
        backgroundColor: Colors.purple.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Beauty category tapped')),
          );
        },
      ),
      Category(
        id: '5',
        name: 'Sports & Outdoors',
        imageUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.sports_basketball,
        backgroundColor: Colors.orange.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sports category tapped')),
          );
        },
      ),
      Category(
        id: '6',
        name: 'Books',
        imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        icon: Icons.menu_book,
        backgroundColor: Colors.brown.shade50,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Books category tapped')),
          );
        },
      ),
      Category(
        id: '7',
        name: 'Toys & Games',
        imageUrl: 'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
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

class CategoryChipsList extends StatefulWidget {
  final List<Category>? categories;
  final ValueChanged<Category>? onCategorySelected;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final bool showScrollbar;

  const CategoryChipsList({
    Key? key,
    this.categories,
    this.onCategorySelected,
    this.spacing = 12.0,
    this.runSpacing = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.physics,
    this.showScrollbar = true,
  }) : super(key: key);

  @override
  State<CategoryChipsList> createState() => _CategoryChipsListState();
}

class _CategoryChipsListState extends State<CategoryChipsList> {
  int selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Category> categories = widget.categories ?? 
        CategoryData.getSampleCategories(context).sublist(0, 5);

    return SizedBox(
      height: 48,
      child: widget.showScrollbar 
        ? Scrollbar(
            controller: _scrollController,
            thumbVisibility: false,
            thickness: 4,
            radius: const Radius.circular(8),
            child: _buildCategoryList(categories),
          )
        : _buildCategoryList(categories),
    );
  }

  Widget _buildCategoryList(List<Category> categories) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      physics: widget.physics ?? const BouncingScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index < categories.length - 1 ? widget.spacing : 0,
          ),
          child: CategoryChip(
            category: categories[index],
            isSelected: selectedIndex == index,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              
              if (widget.onCategorySelected != null) {
                widget.onCategorySelected!(categories[index]);
              }
              
              // Animate to center the selected item
              _scrollToSelectedItem(index, categories.length);
            },
          ),
        );
      },
    );
  }
  
  void _scrollToSelectedItem(int index, int totalItems) {
    if (!_scrollController.hasClients) return;
    
    // Calculate the approximate position to scroll to
    final itemWidth = 100.0 + widget.spacing; // Estimate of item width
    final screenWidth = MediaQuery.of(context).size.width;
    final targetPosition = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    
    // Ensure we don't scroll beyond bounds
    final maxScroll = _scrollController.position.maxScrollExtent;
    final scrollTo = targetPosition.clamp(0.0, maxScroll);
    
    _scrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color defaultColor = theme.colorScheme.onSurface;
    final Color defaultBgColor = theme.colorScheme.surface;
    
    final Color selectedBgColor = category.backgroundColor ?? 
        theme.colorScheme.primary.withOpacity(0.15);
    final Color selectedColor = category.color ?? theme.colorScheme.primary;
    
    final Color chipColor = isSelected ? selectedColor : defaultColor;
    final Color chipBgColor = isSelected ? selectedBgColor : defaultBgColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: chipBgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected ? [
              BoxShadow(
                color: selectedColor.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
            border: Border.all(
              color: isSelected 
                ? selectedColor.withOpacity(0.3) 
                : theme.dividerColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category.icon != null) ...[
                Icon(
                  category.icon,
                  color: chipColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                category.name,
                style: TextStyle(
                  color: chipColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryGridView extends StatelessWidget {
  final List<Category> categories;
  final ValueChanged<Category>? onCategoryTap;
  final int crossAxisCount;
  final double spacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;
  final bool addAnimation;

  const CategoryGridView({
    Key? key,
    required this.categories,
    this.onCategoryTap,
    this.crossAxisCount = 4,
    this.spacing = 16.0,
    this.childAspectRatio = 0.85,
    this.padding = const EdgeInsets.all(16.0),
    this.addAnimation = true,
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
          return addAnimation
            ? _buildAnimatedItem(context, index)
            : CategoryGridItem(
                category: categories[index],
                onTap: () => _handleTap(index),
              );
        },
      ),
    );
  }
  
  Widget _buildAnimatedItem(BuildContext context, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: CategoryGridItem(
        category: categories[index],
        onTap: () => _handleTap(index),
      ),
    );
  }
  
  void _handleTap(int index) {
    if (onCategoryTap != null) {
      onCategoryTap!(categories[index]);
    }
  }
}

class CategoryGridItem extends StatelessWidget {
  final Category category;
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
                      color: category.color ?? defaultColor,
                      size: 26, // Reduced size
                    ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Flexible( // Wrap in Flexible to prevent overflow
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    category.name,
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
            color: category.color ?? Theme.of(context).colorScheme.primary,
            size: 26, // Match icon size
          );
        },
      ),
    );
  }
}

class HorizontalCategoryList extends StatelessWidget {
  final List<Category> categories;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool showShadow;
  final bool addAnimation;
  
  const HorizontalCategoryList({
    Key? key,
    required this.categories,
    this.itemWidth = 100.0,
    this.itemHeight = 120.0,
    this.spacing = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.showShadow = true,
    this.addAnimation = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();
    
    return SizedBox(
      height: itemHeight,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: padding,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return addAnimation 
            ? _buildAnimatedItem(context, index)
            : _buildItem(context, index);
        },
      ),
    );
  }
  
  Widget _buildAnimatedItem(BuildContext context, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index * 40)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildItem(context, index),
    );
  }
  
  Widget _buildItem(BuildContext context, int index) {
    final item = categories[index];
    return Padding(
      padding: EdgeInsets.only(right: index < categories.length - 1 ? spacing : 0),
      child: Container(
        width: itemWidth,
        decoration: BoxDecoration(
          color: item.backgroundColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Set to min to prevent overflow
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.imageUrl != null)
                    _buildImageContainer(context, item)
                  else
                    _buildIconContainer(context, item),
                    
                  const SizedBox(height: 6), // Reduced spacing
                  
                  Flexible(  // Wrap text in Flexible to prevent overflow
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11, // Reduced font size
                        color: item.color ?? Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.1, // Reduced letter spacing
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImageContainer(BuildContext context, Category item) {
    return Container(
      padding: const EdgeInsets.all(4), // Reduced padding to save space
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          width: 40, // Reduced size
          height: 40, // Reduced size
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorIcon(context, item);
          },
        ),
      ),
    );
  }
  
  Widget _buildIconContainer(BuildContext context, Category item) {
    return Container(
      padding: const EdgeInsets.all(10), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        item.icon ?? Icons.category,
        color: item.color ?? Theme.of(context).colorScheme.primary,
        size: 22, // Reduced size
      ),
    );
  }
  
  Widget _buildErrorIcon(BuildContext context, Category item) {
    return Container(
      width: 40, // Match image size
      height: 40, // Match image size
      color: Colors.grey.shade200,
      child: Icon(
        item.icon ?? Icons.category,
        color: Colors.grey.shade400,
        size: 22, // Reduced size
      ),
    );
  }
}