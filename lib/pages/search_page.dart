import 'package:flutter/material.dart';
import 'package:ecom/components/search/search_comps.dart';

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
  List<String> _recentSearches = [
    'wireless earbuds',
    'smartphone',
    'laptop deals',
    'smart watch',
  ];
  List<String> _popularSearches = [
    'headphones',
    'gaming laptop',
    'bluetooth speaker',
    'smart tv',
    'iphone case',
    'wireless charger',
  ];

  // Filter state
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 50000);
  RangeValues _selectedPriceRange = const RangeValues(0, 50000);
  double? _minRating;

  // Sample categories for filtering
  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Home & Kitchen',
    'Beauty',
    'Sports',
    'Toys',
    'Books',
    'Jewelry',
  ];

  // Sample search results with Indian currency values
  final List<Map<String, dynamic>> _allProducts = [
    {
      'title': 'Wireless Bluetooth Earbuds',
      'imageUrl':
          'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 5999.00,
      'originalPrice': 7999.00,
      'rating': 4.5,
      'reviewCount': 256,
      'category': 'Electronics',
    },
    {
      'title': 'Smart Watch with Heart Rate Monitor',
      'imageUrl':
          'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 9999.00,
      'originalPrice': 12499.00,
      'rating': 4.3,
      'reviewCount': 189,
      'category': 'Electronics',
    },
    {
      'title': 'Bluetooth Portable Speaker',
      'imageUrl':
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 3499.00,
      'originalPrice': null,
      'rating': 4.0,
      'reviewCount': 98,
      'category': 'Electronics',
    },
    {
      'title': 'Men\'s Cotton T-Shirt',
      'imageUrl':
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 1299.00,
      'originalPrice': 1999.00,
      'rating': 4.2,
      'reviewCount': 152,
      'category': 'Clothing',
    },
    {
      'title': 'Stainless Steel Water Bottle',
      'imageUrl':
          'https://images.unsplash.com/photo-1602143407151-7111542de6e8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 999.00,
      'originalPrice': null,
      'rating': 4.7,
      'reviewCount': 203,
      'category': 'Home & Kitchen',
    },
    {
      'title': 'Yoga Mat Non-Slip Surface',
      'imageUrl':
          'https://images.unsplash.com/photo-1590432923467-c5469804a8a9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 1599.00,
      'originalPrice': 2499.00,
      'rating': 4.4,
      'reviewCount': 87,
      'category': 'Sports',
    },
    {
      'title': 'LED Desk Lamp with USB Charging Port',
      'imageUrl':
          'https://images.unsplash.com/photo-1534159559673-de7bc89fa998?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 2499.00,
      'originalPrice': 3499.00,
      'rating': 4.1,
      'reviewCount': 112,
      'category': 'Home & Kitchen',
    },
    {
      'title': 'Facial Cleanser Set',
      'imageUrl':
          'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'price': 1799.00,
      'originalPrice': 2499.00,
      'rating': 4.6,
      'reviewCount': 76,
      'category': 'Beauty',
    },
  ];

  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _currentQuery = query;
      _hasSearched = true;

      // Add to recent searches if not already there
      if (query.isNotEmpty && !_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        // Keep only last 5 searches
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      }

      // Filter products based on search query and filters
      _filteredProducts = _allProducts.where((product) {
        // Text search
        final matchesQuery = product['title']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());

        // Category filter
        final matchesCategory = _selectedCategory == null ||
            product['category'] == _selectedCategory;

        // Price filter
        final price = product['price'] as double;
        final matchesPrice = price >= _selectedPriceRange.start &&
            price <= _selectedPriceRange.end;

        // Rating filter
        final rating = product['rating'] as double;
        final matchesRating = _minRating == null || rating >= _minRating!;

        return matchesQuery && matchesCategory && matchesPrice && matchesRating;
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _hasSearched = false;
      _currentQuery = '';
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
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
                categories: _categories,
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
              onClear: _clearSearch,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _hasSearched
          ? _buildSearchResults()
          : _buildSearchSuggestions(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              children: _recentSearches
                  .map(
                    (search) => RecentSearchItem(
                      searchText: search,
                      onTap: () {
                        _searchController.text = search;
                        _performSearch(search);
                      },
                      onRemove: () => _removeRecentSearch(search),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: _popularSearches
                .map(
                  (search) => SearchSuggestionItem(
                    suggestion: search,
                    onTap: () {
                      _searchController.text = search;
                      _performSearch(search);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              return CustomFilterChip(
                label: category,
                isSelected: false,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  // Search with empty query but with category filter
                  _searchController.text = '';
                  _performSearch('');
                },
              );
            }).toList(),
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
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_currentQuery"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term or browse categories',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Active filters
        if (_selectedCategory != null || _minRating != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text(
                  'Filters: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_selectedCategory!),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                        _performSearch(_currentQuery);
                      },
                    ),
                  ),
                if (_minRating != null)
                  Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        Text('${_minRating!.toInt()}+'),
                      ],
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _minRating = null;
                      });
                      _performSearch(_currentQuery);
                    },
                  ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return SearchResultItem(
                title: product['title'],
                imageUrl: product['imageUrl'],
                price: product['price'],
                originalPrice: product['originalPrice'],
                rating: product['rating'],
                reviewCount: product['reviewCount'],
                onTap: () {
                  // Navigate to product detail page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product tapped: ${product['title']}'),
                    ),
                  );
                },
                onAddToCart: () {
                  // Add to cart functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to cart: ${product['title']}'),
                    ),
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
