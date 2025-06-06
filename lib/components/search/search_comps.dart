import 'package:flutter/material.dart';

// Active search bar for the search page
class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final Function(String) onChanged; // Add real-time search callback
  final VoidCallback onClear;
  final bool autofocus;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    required this.onChanged, // Add this parameter
    required this.onClear,
    this.autofocus = true,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  void initState() {
    super.initState();
    // Listen to text changes for real-time search
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Trigger real-time search when text changes
    widget.onChanged(widget.controller.text);
    setState(() {}); // Update UI to show/hide clear button
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: widget.autofocus,
              decoration: const InputDecoration(
                hintText: 'Search products, brands and more',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: widget.onSubmitted,
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                widget.controller.clear();
                widget.onClear();
              },
            ),
        ],
      ),
    );
  }
}

// Live search suggestions widget
class LiveSearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final bool isLoading;

  const LiveSearchSuggestions({
    Key? key,
    required this.suggestions,
    required this.onSuggestionTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.search, size: 18, color: Colors.grey),
            title: Text(
              suggestions[index],
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () => onSuggestionTap(suggestions[index]),
          );
        },
      ),
    );
  }
}

// Compact search result item for live search
class CompactSearchResultItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String brand;
  final String category;
  final VoidCallback onTap;

  const CompactSearchResultItem({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.brand,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discount = originalPrice != null
        ? ((originalPrice! - price) / originalPrice! * 100).round()
        : 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Product image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$brand • $category',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${originalPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '$discount% OFF',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter chip for search refinement
class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Recent search item
class RecentSearchItem extends StatelessWidget {
  final String searchText;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const RecentSearchItem({
    Key? key,
    required this.searchText,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(searchText),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }
}

// Search suggestion item
class SearchSuggestionItem extends StatelessWidget {
  final String suggestion;
  final VoidCallback onTap;

  const SearchSuggestionItem({
    Key? key,
    required this.suggestion,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text(suggestion),
      onTap: onTap,
    );
  }
}

// Search result item
class SearchResultItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final String id;
  final String brand;
  final String category;

  const SearchResultItem({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
    required this.onAddToCart,
    required this.id,
    required this.brand,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discount = originalPrice != null
        ? ((originalPrice! - price) / originalPrice! * 100).round()
        : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with discount badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Hero(
                    tag: 'search_product_$id',
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$brand • $category',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '$rating ($reviewCount)',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹${originalPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const Spacer(),
                      InkWell(
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Filter section
class SearchFilters extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final List<String> brands;
  final String? selectedBrand;
  final Function(String?) onBrandChanged;
  final RangeValues priceRange;
  final RangeValues selectedPriceRange;
  final Function(RangeValues) onPriceRangeChanged;
  final double? minRating;
  final Function(double?) onRatingChanged;

  const SearchFilters({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.brands,
    required this.selectedBrand,
    required this.onBrandChanged,
    required this.priceRange,
    required this.selectedPriceRange,
    required this.onPriceRangeChanged,
    required this.minRating,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    onCategoryChanged(null);
                    onBrandChanged(null);
                    onPriceRangeChanged(priceRange);
                    onRatingChanged(null);
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Categories section
            const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) => CustomFilterChip(
                label: category,
                isSelected: selectedCategory == category,
                onTap: () => onCategoryChanged(selectedCategory == category ? null : category),
              )).toList(),
            ),
            const SizedBox(height: 16),
            
            // Brands section
            const Text('Brands', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: brands.take(10).map((brand) => CustomFilterChip(
                label: brand,
                isSelected: selectedBrand == brand,
                onTap: () => onBrandChanged(selectedBrand == brand ? null : brand),
              )).toList(),
            ),
            const SizedBox(height: 16),
            
            // Price range section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '₹${selectedPriceRange.start.round()} - ₹${selectedPriceRange.end.round()}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: selectedPriceRange,
              min: priceRange.start,
              max: priceRange.end,
              divisions: 20,
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                '₹${selectedPriceRange.start.round()}',
                '₹${selectedPriceRange.end.round()}',
              ),
              onChanged: onPriceRangeChanged,
            ),
            const SizedBox(height: 16),
            
            // Rating section
            const Text('Minimum Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => onRatingChanged(minRating == (index + 1).toDouble()
                      ? null
                      : (index + 1).toDouble()),
                  child: Icon(
                    Icons.star,
                    size: 32,
                    color: (minRating ?? 0) >= (index + 1)
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
