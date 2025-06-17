import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/search/search_comps.dart';
import 'package:ecom/pages/product_page.dart';
import 'package:ecom/providers/product_provider.dart';
import 'package:ecom/services/products.dart';
import 'dart:async';
import 'dart:math'; // Import for Random

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLiveSearching = false;
  List<Product> _liveSearchResults = [];
  Timer? _searchTimer;
  static const int _randomSuggestionCount = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure products are loaded before trying to show suggestions
      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty && productProvider.isLoading == false && productProvider.error == null) {
        // If products are not loaded and not currently loading, try to load them.
        // This is a fallback, ideally products are loaded before reaching search.
        productProvider.loadProducts().then((_) {
          if (mounted) { // Check if the widget is still in the tree
            _initializeSearchState();
          }
        });
      } else {
         _initializeSearchState();
      }
    });
  }

  void _initializeSearchState() {
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _onSearchChanged(widget.initialQuery!); 
    } else {
      _loadRandomSuggestions(); 
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _loadRandomSuggestions() {
    final productProvider = context.read<ProductProvider>();
    final allProducts = productProvider.products;

    if (allProducts.isEmpty) {
      if (mounted) {
        setState(() {
          _liveSearchResults = [];
          _isLiveSearching = false;
        });
      }
      return;
    }

    final random = Random();
    final shuffledProducts = List<Product>.from(allProducts)..shuffle(random);
    final randomSuggestions = shuffledProducts.take(_randomSuggestionCount).toList();
    
    if (mounted) {
      setState(() {
        _liveSearchResults = randomSuggestions;
        _isLiveSearching = false; 
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    
    if (query.isEmpty) {
      _loadRandomSuggestions(); // Load random suggestions when query is cleared
      return;
    }

    if (mounted) {
      setState(() {
        _isLiveSearching = true;
      });
    }

    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _performLiveSearch(query);
    });
  }

  void _performLiveSearch(String query) {
    if (!mounted) return; // Check if widget is still mounted

    final productProvider = context.read<ProductProvider>();
    final allProducts = productProvider.products;

    if (query.isEmpty) { // Should ideally be handled by _onSearchChanged
      _loadRandomSuggestions();
      return;
    }

    final liveResults = allProducts.where((product) {
      final lowerQuery = query.toLowerCase();
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.brand.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery);
    }).take(_randomSuggestionCount).toList(); // Keep taking top 5 for quick results

    if (mounted) {
      setState(() {
        _isLiveSearching = false;
        _liveSearchResults = liveResults;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _loadRandomSuggestions(); // Load random suggestions after clearing
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
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
              onSubmitted: _onSearchChanged, 
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          // This handles initial loading state of products for the whole page
          if (productProvider.isLoading && productProvider.products.isEmpty && _liveSearchResults.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }          if (productProvider.error != null && productProvider.products.isEmpty && _liveSearchResults.isEmpty) {
            print('Error loading products: ${productProvider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Failed to load products. Please try again.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productProvider.loadProducts().then((_) {
                       if(mounted) _initializeSearchState();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return _buildLiveSearchResults();
        },
      ),
    );
  }

  Widget _buildLiveSearchResults() {
    final bool isSearchActive = _searchController.text.isNotEmpty;

    if (!isSearchActive && _liveSearchResults.isEmpty && !_isLiveSearching) {
      return const Center(
        child: Text(
          'Type to search products.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        if (_liveSearchResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Text(
              isSearchActive ? 'Quick Results' : 'Suggestions for you',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8), 
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
                          heroTag: '${isSearchActive ? "live_search" : "random_suggestion"}_${product.id}',
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
        ] else if (isSearchActive && _liveSearchResults.isEmpty) ...[
           Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No results found for "', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                     _searchController.text + "\"",
                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                     textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text('Try a different search term.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
