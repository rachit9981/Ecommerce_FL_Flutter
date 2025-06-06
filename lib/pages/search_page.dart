import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/search/search_comps.dart';
import 'package:ecom/pages/product_page.dart';
import 'package:ecom/providers/product_provider.dart';
import 'package:ecom/services/products.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;
  String _currentQuery = '';
  
  // Real-time search state
  bool _isLiveSearching = false;
  List<Product> _liveSearchResults = [];
  List<String> _searchSuggestions = [];
  Timer? _searchTimer;
  
  // Filter state
  RangeValues _priceRange = const RangeValues(0, 100000);
  RangeValues _selectedPriceRange = const RangeValues(0, 100000);
  double? _minRating;
  String? _selectedCategory;
  String? _selectedBrand;

  List<Product> _filteredProducts = [];
  List<String> _popularSearches = [];
  List<String> _availableCategories = [];
  List<String> _availableBrands = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _searchController.text = widget.initialQuery!;
        _performSearch(widget.initialQuery!);
      }
    });
  }

  void _initializeData() {
    final productProvider = context.read<ProductProvider>();
    final products = productProvider.products;

    if (products.isNotEmpty) {
      // Extract categories and brands
      _availableCategories = products.map((p) => p.category).toSet().toList();
      _availableBrands = products.map((p) => p.brand).toSet().toList();

      // Set price range based on actual product prices
      final prices = products.map((p) => p.discountPrice).toList();
      final minPrice = prices.reduce((a, b) => a < b ? a : b);
      final maxPrice = prices.reduce((a, b) => a > b ? a : b);
      
      _priceRange = RangeValues(minPrice, maxPrice);
      _selectedPriceRange = RangeValues(minPrice, maxPrice);

      // Generate popular searches from product names and categories
      _popularSearches = [
        ..._availableCategories.take(4),
        ...products.take(4).map((p) => p.name.split(' ').first),
      ].toSet().toList();

      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  // Real-time search with debouncing
  void _onSearchChanged(String query) {
    // Cancel previous timer
    _searchTimer?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _hasSearched = false;
        _isLiveSearching = false;
        _liveSearchResults = [];
        _searchSuggestions = [];
      });
      return;
    }

    // Show that we're searching
    setState(() {
      _isLiveSearching = true;
    });

    // Set up new timer for debounced search
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performLiveSearch(query);
    });
  }

  void _performLiveSearch(String query) {
    final productProvider = context.read<ProductProvider>();
    final allProducts = productProvider.products;

    if (query.isEmpty) {
      setState(() {
        _isLiveSearching = false;
        _liveSearchResults = [];
        _searchSuggestions = [];
      });
      return;
    }

    // Generate search suggestions
    Set<String> suggestions = {};
    
    // Add matching product names
    for (var product in allProducts) {
      if (product.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.name);
      }
      if (product.brand.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.brand);
      }
      if (product.category.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.category);
      }
    }

    // Get live search results (top 5 matching products)
    final liveResults = allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.brand.toLowerCase().contains(query.toLowerCase()) ||
             product.category.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase());
    }).take(5).toList();

    setState(() {
      _isLiveSearching = false;
      _liveSearchResults = liveResults;
      _searchSuggestions = suggestions.take(5).toList();
    });
  }

  void _performSearch(String query) {
    final productProvider = context.read<ProductProvider>();
    final allProducts = productProvider.products;

    setState(() {
      _currentQuery = query;
      _hasSearched = true;
      _liveSearchResults = []; // Clear live results when performing full search
      _searchSuggestions = [];

      _filteredProducts = allProducts.where((product) {
        // Text search
        final matchesQuery = query.isEmpty || 
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.brand.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase());

        // Category filter
        final matchesCategory = _selectedCategory == null || 
            product.category.toLowerCase() == _selectedCategory!.toLowerCase();

        // Brand filter
        final matchesBrand = _selectedBrand == null ||
            product.brand.toLowerCase() == _selectedBrand!.toLowerCase();

        // Price filter
        final matchesPrice = product.discountPrice >= _selectedPriceRange.start &&
            product.discountPrice <= _selectedPriceRange.end;

        // Rating filter
        final matchesRating = _minRating == null || product.rating >= _minRating!;

        return matchesQuery && matchesCategory && matchesBrand && matchesPrice && matchesRating;
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _hasSearched = false;
      _currentQuery = '';
      _selectedCategory = null;
      _selectedBrand = null;
      _minRating = null;
      _selectedPriceRange = _priceRange;
      _liveSearchResults = [];
      _searchSuggestions = [];
    });
    _searchController.clear();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return SearchFilters(
                categories: _availableCategories,
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) {
                  setModalState(() {
                    _selectedCategory = category;
                  });
                  setState(() {
                    _selectedCategory = category;
                  });
                  if (_hasSearched) {
                    _performSearch(_currentQuery);
                  }
                },
                brands: _availableBrands,
                selectedBrand: _selectedBrand,
                onBrandChanged: (brand) {
                  setModalState(() {
                    _selectedBrand = brand;
                  });
                  setState(() {
                    _selectedBrand = brand;
                  });
                  if (_hasSearched) {
                    _performSearch(_currentQuery);
                  }
                },
                priceRange: _priceRange,
                selectedPriceRange: _selectedPriceRange,
                onPriceRangeChanged: (range) {
                  setModalState(() {
                    _selectedPriceRange = range;
                  });
                  setState(() {
                    _selectedPriceRange = range;
                  });
                  if (_hasSearched) {
                    _performSearch(_currentQuery);
                  }
                },
                minRating: _minRating,
                onRatingChanged: (rating) {
                  setModalState(() {
                    _minRating = rating;
                  });
                  setState(() {
                    _minRating = rating;
                  });
                  if (_hasSearched) {
                    _performSearch(_currentQuery);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomSearchBar(
              controller: _searchController,
              onSubmitted: _performSearch,
              onChanged: _onSearchChanged, // Add real-time search callback
              onClear: _clearSearch,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedCategory != null || _selectedBrand != null || _minRating != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.error != null && productProvider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Error loading products: ${productProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.reloadProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show live search results while typing
          if (!_hasSearched && _searchController.text.isNotEmpty) {
            return _buildLiveSearchResults();
          }

          return _hasSearched ? _buildSearchResults() : _buildSearchSuggestions();
        },
      ),
    );
  }

  Widget _buildLiveSearchResults() {
    return Column(
      children: [
        // Search suggestions
        if (_searchSuggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          LiveSearchSuggestions(
            suggestions: _searchSuggestions,
            isLoading: _isLiveSearching,
            onSuggestionTap: (suggestion) {
              _searchController.text = suggestion;
              _performSearch(suggestion);
            },
          ),
          const SizedBox(height: 16),
        ],
        
        // Live search results
        if (_liveSearchResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Quick Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _performSearch(_searchController.text),
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _liveSearchResults.length,
              itemBuilder: (context, index) {
                final product = _liveSearchResults[index];
                return CompactSearchResultItem(
                  title: product.name,
                  imageUrl: product.images.isNotEmpty ? product.images.first : '',
                  price: product.discountPrice,
                  originalPrice: product.price != product.discountPrice ? product.price : null,
                  brand: product.brand,
                  category: product.category,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          productId: product.id,
                          heroTag: 'live_search_${product.id}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ] else if (_isLiveSearching) ...[
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ] else ...[
          const Expanded(
            child: Center(
              child: Text(
                'Type to search products...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Searches',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: _popularSearches
                .map((search) => SearchSuggestionItem(
                      suggestion: search,
                      onTap: () {
                        _searchController.text = search;
                        _performSearch(search);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Browse by Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableCategories
                .map((category) => CustomFilterChip(
                      label: category,
                      isSelected: false,
                      onTap: () {
                        _selectedCategory = category;
                        _performSearch('');
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No results found${_currentQuery.isNotEmpty ? ' for "$_currentQuery"' : ''}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Try a different search term or filter', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Active filters
        if (_selectedCategory != null || _selectedBrand != null || _minRating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Filters: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (_selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedCategory!),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() => _selectedCategory = null);
                          _performSearch(_currentQuery);
                        },
                      ),
                    ),
                  if (_selectedBrand != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedBrand!),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() => _selectedBrand = null);
                          _performSearch(_currentQuery);
                        },
                      ),
                    ),
                  if (_minRating != null)
                    Chip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text('${_minRating!.toInt()}+'),
                        ],
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() => _minRating = null);
                        _performSearch(_currentQuery);
                      },
                    ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_filteredProducts.length} products found'),
              // Add sort option here if needed
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return SearchResultItem(
                id: product.id,
                title: product.name,
                imageUrl: product.images.isNotEmpty ? product.images.first : '',
                price: product.discountPrice,
                originalPrice: product.price != product.discountPrice ? product.price : null,
                rating: product.rating,
                reviewCount: product.reviews,
                brand: product.brand,
                category: product.category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductPage(
                        productId: product.id,
                        heroTag: 'search_product_${product.id}',
                      ),
                    ),
                  );
                },
                onAddToCart: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to cart: ${product.name}')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
