import 'package:flutter/material.dart';

/// A model class for suggestion items that can be either categories or products
class SuggestionItem {
  final String id;
  final String title;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isProduct; // True for products, false for categories/navigation
  final double? price; // Only used for products
  final double? originalPrice; // Added for discount display
  final String? description; // Only used for products
  final bool isNew; // Add "New" badge
  final bool isFeatured; // Add "Featured" badge
  final double? rating; // Add rating display
  final int? reviewCount; // Number of reviews

  SuggestionItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isProduct = false,
    this.price,
    this.originalPrice,
    this.description,
    this.isNew = false,
    this.isFeatured = false,
    this.rating,
    this.reviewCount,
  });

  // Calculate discount percentage if both prices available
  int? get discountPercentage {
    if (originalPrice != null && price != null && originalPrice! > price!) {
      return ((1 - price! / originalPrice!) * 100).round();
    }
    return null;
  }
}

/// A horizontal scrollable row of suggestion items for navigation or products display
class ScrollableSuggestionRow extends StatelessWidget {
  final String? title;
  final List<SuggestionItem> items;
  final double itemHeight;
  final double itemWidth;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool showMore;
  final VoidCallback? onMoreTap;
  final ScrollController? scrollController;

  const ScrollableSuggestionRow({
    Key? key,
    this.title,
    required this.items,
    this.itemHeight = 150.0,
    this.itemWidth = 140.0,
    this.spacing = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.showMore = false,
    this.onMoreTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Dynamically adjust item counts and sizes based on screen width
    final bool isSmallScreen = screenWidth < 360;
    
    // Calculate responsive paddings
    final effectivePadding = EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 8.0 : padding.horizontal,
      vertical: padding.vertical,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(
              left: effectivePadding.horizontal / 2,
              right: effectivePadding.horizontal / 2,
              top: effectivePadding.vertical,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : null,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showMore)
                  TextButton(
                    onPressed: onMoreTap,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8.0 : 12.0,
                      ),
                    ),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive item dimensions
            final double availableWidth = constraints.maxWidth;
            final double calculatedItemWidth = isSmallScreen
                ? (availableWidth - (effectivePadding.horizontal * 2)) / 2.5
                : itemWidth;
                
            return SizedBox(
              height: itemHeight,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: effectivePadding,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < items.length - 1 
                          ? isSmallScreen ? spacing / 2 : spacing 
                          : 0
                    ),
                    child: items[index].isProduct
                        ? _buildProductItem(
                            context, 
                            items[index], 
                            calculatedItemWidth,
                            screenWidth
                          )
                        : _buildCategoryItem(
                            context, 
                            items[index], 
                            calculatedItemWidth,
                            screenWidth
                          ),
                  );
                },
              ),
            );
          }
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, 
    SuggestionItem item, 
    double effectiveWidth,
    double screenWidth
  ) {
    final bool isSmallScreen = screenWidth < 360;
    final double imageSize = effectiveWidth * (isSmallScreen ? 0.5 : 0.6);
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: effectiveWidth,
        constraints: BoxConstraints(
          minWidth: 100,
          maxWidth: 160,
        ),
        decoration: BoxDecoration(
          color: item.backgroundColor ?? 
              theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.imageUrl != null)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(top: isSmallScreen ? 4.0 : 8.0),
                  child: Center(
                    // Modified: Removed Hero widget which could cause sizing issues
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          width: imageSize,
                          height: imageSize,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: imageSize,
                              height: imageSize,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.broken_image, 
                                color: Colors.grey.shade400, 
                                size: imageSize * 0.5,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, 
                  vertical: 4.0
                ),
                child: Center(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 10 : 11,
                      color: item.textColor ?? theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context, 
    SuggestionItem item, 
    double effectiveWidth,
    double screenWidth
  ) {
    final bool isSmallScreen = screenWidth < 360;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: effectiveWidth,
        constraints: BoxConstraints(
          minWidth: 110,
          maxWidth: 160,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.broken_image, 
                                color: Colors.grey.shade400,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.discountPercentage != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, 
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "-${item.discountPercentage}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            
                          if (item.isNew)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, 
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite_border,
                            size: isSmallScreen ? 16 : 18,
                            color: theme.colorScheme.primary,
                          ),
                          constraints: BoxConstraints(
                            minWidth: isSmallScreen ? 28 : 32,
                            minHeight: isSmallScreen ? 28 : 32,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // Add to wishlist functionality
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 10 : 11,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (item.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.description!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isSmallScreen ? 8 : 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                    if (item.rating != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: isSmallScreen ? 10 : 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 8 : 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.reviewCount != null) ...[
                              const SizedBox(width: 2),
                              Text(
                                "(${item.reviewCount})",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 8 : 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    
                    const Spacer(flex: 1),
                    
                    if (item.price != null)
                      Row(
                        children: [
                          Text(
                            "₹${item.price!.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                          ),
                          if (item.originalPrice != null && 
                              item.originalPrice! > item.price!) ...[
                            const SizedBox(width: 4),
                            Text(
                              "₹${item.originalPrice!.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isSmallScreen ? 8 : 10,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}