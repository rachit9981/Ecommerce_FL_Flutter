import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';

class PhoneSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final Function(PhoneModel) onModelSelected;
  final List<PhoneModel> allModels;

  const PhoneSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onModelSelected,
    required this.allModels,
  }) : super(key: key);

  @override
  State<PhoneSearchBar> createState() => _PhoneSearchBarState();
}

class _PhoneSearchBarState extends State<PhoneSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<PhoneModel> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && widget.controller.text.isNotEmpty;
    });
  }

  void _onTextChanged() {
    final query = widget.controller.text.toLowerCase();
    setState(() {
      _showSuggestions = _focusNode.hasFocus && query.isNotEmpty;
      _filteredModels = widget.allModels
          .where((model) => 
              model.name.toLowerCase().contains(query) ||
              model.brandId.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search your phone model...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onSubmitted: widget.onSearch,
          ),
        ),
        
        // Suggestions
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
            constraints: const BoxConstraints(maxHeight: 300),
            child: _filteredModels.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No models found'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredModels.length,
                    itemBuilder: (context, index) {
                      final model = _filteredModels[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
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
                        title: Text(model.name),
                        subtitle: Text(model.brandId.toUpperCase()),
                        onTap: () {
                          widget.onModelSelected(model);
                          widget.controller.text = model.name;
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _showSuggestions = false;
                          });
                        },
                      );
                    },
                  ),
          ),
      ],
    );
  }
}

class SearchResultsGrid extends StatelessWidget {
  final List<PhoneModel> models;
  final Function(PhoneModel) onModelSelected;

  const SearchResultsGrid({
    Key? key,
    required this.models,
    required this.onModelSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: models.length,
      itemBuilder: (context, index) {
        return PhoneModelItem(
          model: models[index],
          onTap: () => onModelSelected(models[index]),
        );
      },
    );
  }
}

class PhoneModelItem extends StatelessWidget {
  final PhoneModel model;
  final VoidCallback onTap;

  const PhoneModelItem({
    Key? key,
    required this.model,
    required this.onTap,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            // Model image
            Expanded(
              child: Container(
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
                  child: Image.network(
                    model.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        const Center(child: Icon(Icons.smartphone, size: 50, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            
            // Model info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),                  Text(
                    _getHighestPrice(model),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${model.storageOptions.length} variants',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
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
