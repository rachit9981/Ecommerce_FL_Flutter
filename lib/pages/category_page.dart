import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/common/categories.dart';
import 'package:ecom/providers/product_provider.dart';
import 'package:ecom/services/products.dart';
import 'package:ecom/pages/product_page.dart';

class CategoryPage extends StatefulWidget {
  final CategoryItem category;

  const CategoryPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _sortOption = 'Recommended';
  // Set initial price range with conservative values
  // RangeValues _priceRange = const RangeValues(0, 100000);
  double _maxPrice = 500000;
  // Set initial price range to maximum range
  RangeValues _priceRange = const RangeValues(0, 500000);
  bool _isFiltersVisible = false;
  bool _isLoading = true;
  List<Product> _filteredProducts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      try {
        // If products are already loaded, filter them
        if (productProvider.products.isNotEmpty) {
          _filterProducts(productProvider.products);
        } else {
          // Otherwise load them first
          productProvider.loadProducts().then((_) {
            if (mounted) {
              _filterProducts(productProvider.products);
            }
          }).catchError((error) {
            if (mounted) {
              setState(() {
                _error = error.toString();
                _isLoading = false;
              });
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
        }
      }
    });
  }

  void _filterProducts(List<Product> allProducts) {
    if (!mounted) return;

    try {
      // Filter products by category
      final categoryName = widget.category.id.toLowerCase();
      final filteredByCategory = allProducts.where((product) {
        final productCategory = product.category.toLowerCase();
        final productBrand = product.brand.toLowerCase();
        
        // Check if product matches the category
        bool categoryMatch = productCategory.contains(categoryName) || 
                            categoryName.contains(productCategory);
                            
        // For brand categories, also check brand match
        bool brandMatch = productBrand.contains(categoryName) || 
                          categoryName.contains(productBrand);
                          
        return categoryMatch || brandMatch;
      }).toList();

      // Calculate max price for range slider before applying price filter
      double newMaxPrice = 10000; // Default fallback value
      if (filteredByCategory.isNotEmpty) {
        try {
          final maxProductPrice = filteredByCategory
              .map((product) => product.discountPrice)
              .reduce((value, element) => value > element ? value : element);
          
          newMaxPrice = maxProductPrice + 10000; // Add buffer for slider
        } catch (e) {
          // If reduce throws an error, fall back to default max price
          print('Error calculating max price: $e');
        }
      }
      
      // Update price range to be valid with the new max price
      RangeValues newPriceRange = _priceRange;
      if (_priceRange.end > newMaxPrice) {
        // If current end is higher than new max, adjust it
        newPriceRange = RangeValues(_priceRange.start, newMaxPrice);
      }
      
      // Apply price filter with adjusted price range
      final filteredByPrice = filteredByCategory.where((product) {
        return product.discountPrice >= newPriceRange.start && 
               product.discountPrice <= newPriceRange.end;
      }).toList();

      // Apply sort
      switch (_sortOption) {
        case 'Price: Low to High':
          filteredByPrice.sort((a, b) => a.discountPrice.compareTo(b.discountPrice));
          break;
        case 'Price: High to Low':
          filteredByPrice.sort((a, b) => b.discountPrice.compareTo(a.discountPrice));
          break;
        case 'Newest First':
          // Since we don't have a date field, we'll just use the ID for demo
          filteredByPrice.sort((a, b) => b.id.compareTo(a.id));
          break;
        case 'Popularity':
          filteredByPrice.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Recommended':
        default:
          // For recommended, we might use a combination of rating and reviews
          filteredByPrice.sort((a, b) => 
            (b.rating * b.reviews).compareTo(a.rating * a.reviews));
          break;
      }

      setState(() {
        _maxPrice = newMaxPrice;
        _priceRange = newPriceRange;
        _filteredProducts = filteredByPrice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleFilters() {
    setState(() {
      _isFiltersVisible = !_isFiltersVisible;
    });
  }

  void _resetFilters() {
    setState(() {
      _sortOption = 'Recommended';
      // Make sure the range is valid
      _priceRange = RangeValues(0, _maxPrice);
    });
    
    // Re-filter products with reset filters
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    _filterProducts(productProvider.products);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _toggleFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters panel (collapsible)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isFiltersVisible ? 220 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: _isFiltersVisible 
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
            ),
            child: SingleChildScrollView(
              // physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sort & Filter',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Recommended',
                        'Price: Low to High',
                        'Price: High to Low',
                        'Newest First',
                        'Popularity',
                      ].map((option) => ChoiceChip(
                        label: Text(option),
                        selected: _sortOption == option,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _sortOption = option;
                            });
                            
                            // Re-filter products with new sort option
                            final productProvider = Provider.of<ProductProvider>(
                              context, 
                              listen: false
                            );
                            _filterProducts(productProvider.products);
                          }
                        },
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price Range:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Safety check to ensure values are within valid range
                    if (_maxPrice > 0 && _priceRange.end <= _maxPrice && _priceRange.start >= 0)
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: _maxPrice,
                        divisions: 20,
                        labels: RangeLabels(
                          '₹${_priceRange.start.toInt()}',
                          '₹${_priceRange.end.toInt()}',
                        ),
                        onChanged: (values) {
                          // Additional safety check
                          if (values.end <= _maxPrice && values.start >= 0) {
                            setState(() {
                              _priceRange = values;
                            });
                          }
                        },
                        onChangeEnd: (values) {
                          // Re-filter products with new price range
                          final productProvider = Provider.of<ProductProvider>(
                            context, 
                            listen: false
                          );
                          _filterProducts(productProvider.products);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Results count and filter info
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredProducts.length} products',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_isFiltersVisible)
                    Text(
                      'Sort: $_sortOption',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          
          // Main content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or check out other categories',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetFilters,
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      );
    }
    
    // Show product grid with results
    return RefreshIndicator(
      onRefresh: () async {
        _loadProducts();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    final heroTag = 'category_${widget.category.id}_${product.id}';
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(
              productId: product.id,
              heroTag: heroTag,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Hero(
                        tag: heroTag,
                        child: Image.network(
                          product.images.isNotEmpty ? product.images.first : '',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => 
                              const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                  
                  // Discount badge if available
                  if (product.price > product.discountPrice)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${(((product.price - product.discountPrice) / product.price) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  
                  // Rating badge
                  if (product.rating > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${product.discountPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (product.price > product.discountPrice)
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
