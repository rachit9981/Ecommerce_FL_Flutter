import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';

class SearchPhonePage extends StatefulWidget {
  final List<PhoneModel> allModels;

  const SearchPhonePage({
    Key? key,
    required this.allModels,
  }) : super(key: key);

  @override
  State<SearchPhonePage> createState() => _SearchPhonePageState();
}

class _SearchPhonePageState extends State<SearchPhonePage> {
  final TextEditingController _searchController = TextEditingController();
  List<PhoneModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = widget.allModels
            .where((model) =>
                model.name.toLowerCase().contains(query.toLowerCase()) ||
                model.brandId.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _onSearch(String query) {
    // This is called when the search is submitted via keyboard
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
        _searchResults = widget.allModels
            .where((model) =>
                model.name.toLowerCase().contains(query.toLowerCase()) ||
                model.brandId.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
    // Close keyboard
    FocusScope.of(context).unfocus();
  }

  void _onModelSelected(PhoneModel model) {
    // Return the selected model to the previous page
    Navigator.pop(context, model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Phone Model'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(16),
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
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search your phone model...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: _onSearch,
            ),
          ),

          // Search Results or Placeholder
          Expanded(
            child: _searchController.text.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for your phone model',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _isSearching && _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No matching models found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final model = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    model.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.smartphone, color: Colors.grey),
                                  ),
                                ),
                              ),
                              title: Text(
                                model.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(model.brandId.toUpperCase()),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${model.storageOptions.length} storage options',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                _getHighestPrice(model),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () => _onModelSelected(model),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Helper method to get the highest price from variantPrices
  String _getHighestPrice(PhoneModel model) {
    if (model.variantPrices.isEmpty) {
      return "₹0";
    }
    
    int highestPrice = 0;
    
    // Find the highest price across all storage and condition combinations
    model.variantPrices.forEach((storage, conditions) {
      conditions.forEach((condition, price) {
        if (price > highestPrice) {
          highestPrice = price;
        }
      });
    });
    
    return "₹$highestPrice";
  }
}
