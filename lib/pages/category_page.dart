import 'package:flutter/material.dart';
import 'package:ecom/components/common/categories.dart';
import 'package:ecom/components/common/suggestions.dart';
// import 'package:ecom/components/common/infity_scroll_suggestions.dart';
import 'package:ecom/pages/product_page.dart';
import 'package:ecom/services/products.dart'; // Import the ProductService

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
  // Active filter options
  String? _selectedSubcategory;
  RangeValues _priceRange = const RangeValues(0, 100000);
  String? _sortOption;
  
  // API integration variables
  final ProductService _productService = ProductService();
  List<Product> _allProducts = [];
  List<SuggestionItem> _displayedProducts = [];
  bool _isLoading = true;
  String? _error;
  
  // List of possible sorting options
  final List<String> _sortOptions = [
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Newest First',
    'Discount',
    'Rating'
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _productService.getProducts();
      
      setState(() {
        _allProducts = products;
        _isLoading = false;
        _applyFilters(); // Apply any filters and update displayed products
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Get subcategories based on available products for this category
  List<String> _getSubcategories() {
    if (_allProducts.isEmpty) {
      return ['All']; // Default if no products are loaded yet
    }

    // Check if the category is a brand
    final bool isBrand = !['electronics', 'fashion', 'home', 'beauty', 'sports'].contains(widget.category.id);

    if (isBrand) {
      // For a brand, subcategories are product categories
      return _allProducts
          .where((product) => product.brand.toLowerCase() == widget.category.id.toLowerCase())
          .map((product) => product.category)
          .toSet()
          .toList();
    } else {
      // For a product category, find appropriate subcategories
      // This could be derived from product data or predefined
      switch (widget.category.id) {
        case 'electronics':
          return ['All', 'Smartphones', 'Laptops', 'Audio', 'Wearables', 'Cameras'];
        case 'fashion':
          return ['All', 'Men', 'Women', 'Kids', 'Footwear', 'Accessories'];
        case 'home':
          return ['All', 'Kitchen', 'Furniture', 'Decor', 'Bedding', 'Appliances'];
        case 'beauty':
          return ['All', 'Skincare', 'Makeup', 'Haircare', 'Fragrance', 'Tools'];
        case 'sports':
          return ['All', 'Fitness', 'Outdoor', 'Team Sports', 'Swimwear', 'Equipment'];
        default:
          return ['All'];
      }
    }
  }
  // Convert Product to SuggestionItem
  SuggestionItem _convertProductToSuggestionItem(Product product) {
    return SuggestionItem(
      id: product.id,
      title: product.name,
      imageUrl: product.images.isNotEmpty ? product.images.first : '',
      price: product.discountPrice,
      originalPrice: product.price != product.discountPrice ? product.price : null,
      description: product.description,
      isProduct: true,
      isNew: product.featured == true,
      rating: product.rating,
      reviewCount: product.reviews,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(
              productId: product.id,
              heroTag: 'category_${widget.category.id}_${product.id}',
            ),
          ),
        );
      },
    );
  }

  // Apply filters and update displayed products
  void _applyFilters() {    if (_allProducts.isEmpty) {
      // Use fallback products when API data is not available
      _displayedProducts = _getCategoryProducts();
      return;
    }

    // Start with all products
    List<Product> filteredProducts = List<Product>.from(_allProducts);

    // Filter by category ID (if not a brand)
    if (!['electronics', 'fashion', 'home', 'beauty', 'sports'].contains(widget.category.id)) {
      // This is a brand - filter by brand name
      filteredProducts = filteredProducts
          .where((product) => product.brand.toLowerCase() == widget.category.id.toLowerCase())
          .toList();
    } else {
      // This is a category - filter by category name
      filteredProducts = filteredProducts
          .where((product) => product.category.toLowerCase() == widget.category.id.toLowerCase())
          .toList();
    }

    // Apply subcategory filter if selected
    if (_selectedSubcategory != null && _selectedSubcategory != 'All') {
      filteredProducts = filteredProducts
          .where((product) {
            // Try to match against category or description
            return product.category.toLowerCase().contains(_selectedSubcategory!.toLowerCase()) ||
                   product.description.toLowerCase().contains(_selectedSubcategory!.toLowerCase());
          })
          .toList();
    }

    // Apply price range filter
    filteredProducts = filteredProducts
        .where((product) => 
            product.discountPrice >= _priceRange.start && 
            product.discountPrice <= _priceRange.end)
        .toList();

    // Convert to SuggestionItems
    List<SuggestionItem> items = filteredProducts
        .map((product) => _convertProductToSuggestionItem(product))
        .toList();

    // Apply sorting
    if (_sortOption != null) {
      switch (_sortOption) {
        case 'Price: Low to High':
          items.sort((a, b) => (a.price ?? 0.0).compareTo(b.price ?? 0.0));
          break;
        case 'Price: High to Low':
          items.sort((a, b) => (b.price ?? 0.0).compareTo(a.price ?? 0.0));
          break;
        case 'Rating':
          items.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
          break;
        case 'Discount':
          items.sort((a, b) {
            final discountA = a.originalPrice != null ? (a.originalPrice! - (a.price ?? 0.0)) : 0.0;
            final discountB = b.originalPrice != null ? (b.originalPrice! - (b.price ?? 0.0)) : 0.0;
            return discountB.compareTo(discountA);
          });
          break;
        // For other options like 'Popularity' or 'Newest First', we'd need additional data
        // For now, these fall back to default sorting
      }
    }

    setState(() {
      _displayedProducts = items;
    });  }

  // Fallback method to get category products (for when API fails)
  List<SuggestionItem> _getCategoryProducts() {
    List<SuggestionItem> products = [];
    
    if (widget.category.id == 'electronics') {
      products = [
        SuggestionItem(
          id: 'e2',
          title: 'Wireless Earbuds Pro',
          imageUrl: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 5999.00,
          originalPrice: 7999.00,
          description: 'Active Noise Cancellation',
          isProduct: true,
          rating: 4.5,
          reviewCount: 256,
          onTap: () {
            _navigateToProductDetail('e2');
          },
        ),
        SuggestionItem(
          id: 'e3',
          title: 'Smart Watch Series 3',
          imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 12999.00,
          originalPrice: 15999.00,
          description: 'Fitness tracking, ECG',
          isProduct: true,
          rating: 4.3,
          reviewCount: 128,
          onTap: () {
            _navigateToProductDetail('e3');
          },
        ),
        SuggestionItem(
          id: 'e4',
          title: 'Ultra HD Smart TV 55"',
          imageUrl: 'https://images.unsplash.com/photo-1593784991095-a205069470b6?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 42999.00,
          originalPrice: 54999.00,
          description: '4K HDR, Dolby Vision',
          isProduct: true,
          rating: 4.6,
          reviewCount: 532,
          onTap: () {
            _navigateToProductDetail('e4');
          },
        ),
        SuggestionItem(
          id: 'e5',
          title: 'Professional Gaming Laptop',
          imageUrl: 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 89999.00,
          originalPrice: 104999.00,
          description: 'RTX 3060, 16GB RAM',
          isProduct: true,
          rating: 4.5,
          reviewCount: 328,
          onTap: () {
            _navigateToProductDetail('e5');
          },
        ),
        SuggestionItem(
          id: 'e6',
          title: 'Bluetooth Portable Speaker',
          imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 3999.00,
          description: 'Waterproof, 20hr battery',
          isProduct: true,
          rating: 4.4,
          reviewCount: 95,
          onTap: () {
            _navigateToProductDetail('e6');
          },
        ),
        SuggestionItem(
          id: 'e7',
          title: 'Digital Camera DSLR',
          imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 35999.00,
          originalPrice: 41999.00,
          description: '24MP, 4K Video',
          isProduct: true,
          rating: 4.6,
          reviewCount: 213,
          onTap: () {
            _navigateToProductDetail('e7');
          },
        ),
        SuggestionItem(
          id: 'e8',
          title: 'Noise-Canceling Headphones',
          imageUrl: 'https://images.unsplash.com/photo-1578319439584-104c94d37305?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 24999.00,
          originalPrice: 32999.00,
          description: 'Wireless, 30h Battery',
          isProduct: true,
          rating: 4.7,
          reviewCount: 894,
          onTap: () {
            _navigateToProductDetail('e8');
          },
        ),
      ];
    } else if (widget.category.id == 'fashion') {
      products = [
        SuggestionItem(
          id: 'f1',
          title: 'Men\'s Casual T-Shirt',
          imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 899.00,
          originalPrice: 1299.00,
          description: 'Pure Cotton, Comfort Fit',
          isProduct: true,
          rating: 4.3,
          reviewCount: 152,
          onTap: () {
            _navigateToProductDetail('f1');
          },
        ),
        SuggestionItem(
          id: 'f2',
          title: 'Women\'s Floral Maxi Dress',
          imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 1499.00,
          originalPrice: 2499.00,
          description: 'Summer Collection',
          isProduct: true,
          rating: 4.5,
          reviewCount: 86,
          onTap: () {
            _navigateToProductDetail('f2');
          },
        ),
      ];
    } else if (widget.category.id == 'home') {
      products = [
        SuggestionItem(
          id: 'h1',
          title: 'Stainless Steel Cookware Set',
          imageUrl: 'https://images.unsplash.com/photo-1551978129-b73f45d132eb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 4999.00,
          originalPrice: 7999.00,
          description: '10 Piece Set, Non-stick',
          isProduct: true,
          rating: 4.7,
          reviewCount: 203,
          onTap: () {
            _navigateToProductDetail('h1');
          },
        ),
      ];
    } else {
      products = [
        SuggestionItem(
          id: 'd1',
          title: 'Product 1',
          imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
          price: 2999.00,
          description: 'Product description',
          isProduct: true,
          rating: 4.2,
          reviewCount: 45,
          onTap: () {
            _navigateToProductDetail('d1');
          },
        ),
      ];
    }
    
    return products;
  }
  
  void _navigateToProductDetail(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductPage(
          productId: productId,
          heroTag: 'category_${widget.category.id}_product_$productId',
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedSubcategory = null;
                            _priceRange = const RangeValues(0, 100000);
                            _sortOption = null;
                          });
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Subcategories
                  const Text(
                    'Subcategories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _getSubcategories().map((subcategory) {
                      return FilterChip(
                        label: Text(subcategory),
                        selected: _selectedSubcategory == subcategory,
                        onSelected: (selected) {
                          setModalState(() {                          _selectedSubcategory = selected ? subcategory : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Price Range
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${_priceRange.start.round()} - ₹${_priceRange.end.round()}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 100000,
                    divisions: 20,
                    labels: RangeLabels(
                      '₹${_priceRange.start.round()}',
                      '₹${_priceRange.end.round()}',
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        _priceRange = values;
                      });
                    },                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 20),
                  
                  // Sort By
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions.map((option) {
                      return ChoiceChip(
                        label: Text(option),
                        selected: _sortOption == option,
                        onSelected: (selected) {
                          setModalState(() {                          _sortOption = selected ? option : null;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      );
                    }).toList(),
                  ),
                  
                  const Spacer(),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search page with pre-filled category
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedSubcategory != null || _sortOption != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  const Text(
                    'Active Filters: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_selectedSubcategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedSubcategory!),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedSubcategory = null;
                          });
                        },
                      ),
                    ),
                  if (_sortOption != null)
                    Chip(
                      label: Text(_sortOption!),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _sortOption = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          
          // Product grid
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              size: 80,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading products',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Retry loading products
                                _loadProducts();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _displayedProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No products found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try adjusting your filters',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _displayedProducts.length,
                            itemBuilder: (context, index) {
                              final product = _displayedProducts[index];
                              return Hero(
                                tag: 'category_${widget.category.id}_product_${product.id}',
                                child: SuggestionItemCard(
                                  item: product,
                                  width: double.infinity,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

// Simple card to display a product from a SuggestionItem
class SuggestionItemCard extends StatelessWidget {
  final SuggestionItem item;
  final double width;
  
  const SuggestionItemCard({
    Key? key,
    required this.item,
    required this.width,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: item.imageUrl != null
                            ? Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    ),
                    
                    // Discount badge
                    if (item.originalPrice != null && item.price != null && item.originalPrice! > item.price!)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "-${((1 - item.price! / item.originalPrice!) * 100).round()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    
                    // New badge
                    if (item.isNew)
                      Positioned(
                        top: item.originalPrice != null && item.price != null && item.originalPrice! > item.price! ? 40 : 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      ),
                  ],
                ),
              ),
              
              // Product info - Adjusted to handle overflow better
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title - Increased max lines to 2
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2, // Increased from 1 to 2
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Description - Reduced top padding
                      if (item.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2), // Reduced from 4
                          child: Text(
                            item.description!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11, // Reduced from 12
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      // Star rating - Reduced top padding
                      if (item.rating != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2), // Reduced from 4
                          child: Row(
                            children: [
                              for (int i = 0; i < 5; i++)
                                Icon(
                                  i < item.rating!.floor()
                                      ? Icons.star
                                      : (i < item.rating!.ceil() && i >= item.rating!.floor())
                                          ? Icons.star_half
                                          : Icons.star_border,
                                  size: 12, // Reduced from 14
                                  color: Colors.amber,
                                ),
                              if (item.reviewCount != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 2), // Reduced from 4
                                  child: Text(
                                    "(${item.reviewCount})",
                                    style: TextStyle(
                                      fontSize: 9, // Reduced from 10
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Price section - Condensed
                      if (item.price != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${item.price!.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15, // Reduced from 16
                              ),
                            ),
                            if (item.originalPrice != null && item.originalPrice! > item.price!)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  "₹${item.originalPrice!.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11, // Reduced from 12
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
