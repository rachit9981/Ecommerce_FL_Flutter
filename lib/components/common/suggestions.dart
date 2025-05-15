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
  final String? description; // Only used for products

  SuggestionItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isProduct = false,
    this.price,
    this.description,
  });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(
              left: padding.horizontal / 2,
              right: padding.horizontal / 2,
              top: padding.vertical,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (showMore)
                  TextButton(
                    onPressed: onMoreTap,
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: itemHeight,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            padding: padding,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index < items.length - 1 ? spacing : 0),
                child: items[index].isProduct
                    ? _buildProductItem(context, items[index])
                    : _buildCategoryItem(context, items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, SuggestionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: itemWidth,
        decoration: BoxDecoration(
          color: item.backgroundColor ?? 
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.imageUrl != null)
              Expanded(
                flex: 3, // Increased from 2 to give more space to image
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0), // Reduced from 12.0
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      width: itemWidth * 0.6,
                      height: itemWidth * 0.6,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: itemWidth * 0.6,
                          height: itemWidth * 0.6,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Reduced padding
                child: Center(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11, // Reduced font size
                      color: item.textColor ?? Theme.of(context).colorScheme.primary,
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

  Widget _buildProductItem(BuildContext context, SuggestionItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: itemWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              Expanded(
                flex: 3, // Increased from 2 to give more space to image
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(6.0), // Reduced from 8.0
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Added to ensure minimum height
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Reduced from 12
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 9, // Reduced from 10
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (item.price != null)
                      Text(
                        '\$${item.price!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12, // Reduced from 14
                        ),
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