import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/components/sell_phone/selling_comp.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../components/common/login_required.dart';

class SellPhoneByBrandPage extends StatefulWidget {
  final PhoneBrand brand;
  final List<PhoneModel> brandModels;
  final Function(PhoneModel) onModelSelected;

  const SellPhoneByBrandPage({
    Key? key,
    required this.brand,
    required this.brandModels,
    required this.onModelSelected,
  }) : super(key: key);

  @override
  State<SellPhoneByBrandPage> createState() => _SellPhoneByBrandPageState();
}

class _SellPhoneByBrandPageState extends State<SellPhoneByBrandPage> {
  List<PhoneModel> _displayedModels = [];
  String _sortBy = 'price_high_to_low';
  RangeValues _priceRange = const RangeValues(0, 200000);
  int _minPrice = 0;
  int _maxPrice = 200000;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _displayedModels = List.from(widget.brandModels);
    _initPriceRange();
    _sortModels();
  }

  void _initPriceRange() {
    if (widget.brandModels.isEmpty) return;

    int min = 200000;
    int max = 0;

    for (var model in widget.brandModels) {
      model.variantPrices.forEach((storage, conditions) {
        conditions.forEach((condition, price) {
          if (price < min) min = price;
          if (price > max) max = price;
        });
      });
    }

    // Add some padding to the range
    min = (min * 0.8).round();
    max = (max * 1.2).round();

    setState(() {
      _minPrice = min;
      _maxPrice = max;
      _priceRange = RangeValues(min.toDouble(), max.toDouble());
    });
  }

  void _applyFilters() {
    setState(() {
      _displayedModels = widget.brandModels.where((model) {
        // Check if model price is within the selected range
        bool inPriceRange = false;
        model.variantPrices.forEach((storage, conditions) {
          conditions.forEach((condition, price) {
            if (price >= _priceRange.start && price <= _priceRange.end) {
              inPriceRange = true;
            }
          });
        });
        return inPriceRange;
      }).toList();

      _sortModels();
    });
  }

  void _resetFilters() {
    setState(() {
      _priceRange = RangeValues(_minPrice.toDouble(), _maxPrice.toDouble());
      _displayedModels = List.from(widget.brandModels);
      _sortModels();
    });
  }

  void _sortModels() {
    setState(() {
      switch (_sortBy) {
        case 'price_high_to_low':
          _displayedModels.sort((a, b) {
            int maxPriceA = _findHighestPrice(a);
            int maxPriceB = _findHighestPrice(b);
            return maxPriceB.compareTo(maxPriceA);
          });
          break;
        case 'price_low_to_high':
          _displayedModels.sort((a, b) {
            int maxPriceA = _findHighestPrice(a);
            int maxPriceB = _findHighestPrice(b);
            return maxPriceA.compareTo(maxPriceB);
          });
          break;
        case 'name_a_to_z':
          _displayedModels.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_z_to_a':
          _displayedModels.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
    });
  }

  int _findHighestPrice(PhoneModel model) {
    int highestPrice = 0;
    model.variantPrices.forEach((storage, conditions) {
      conditions.forEach((condition, price) {
        if (price > highestPrice) highestPrice = price;
      });
    });
    return highestPrice;
  }

  // Use the shared component for submitting inquiries
  void _handleQuickInquiry(PhoneModel model, String storage, String condition) {
    // Use the updated SellingComponents method that includes address handling
    SellingComponents.submitInquiry(
      context: context,
      model: model,
      storage: storage,
      condition: condition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${widget.brand.name} Phones'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Check if user is not authenticated
          if (!userProvider.isAuthenticated) {
            return LoginRequired(
              title: 'Login to Sell Your Phone',
              message: 'Please login to sell your old phone and get instant quotes',
              icon: Icons.smartphone_outlined,
            );
          }
          
          // If authenticated, show the brand-specific content
          return Column(
            children: [
              // Brand header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(8),
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
                      child: Image.network(
                        widget.brand.logoUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.brand.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_displayedModels.length} models available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filters section
              if (_showFilters)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price range
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Price Range',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
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
                        min: _minPrice.toDouble(),
                        max: _maxPrice.toDouble(),
                        divisions: 10,
                        labels: RangeLabels(
                          '₹${_priceRange.start.round()}',
                          '₹${_priceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),

                      // Sort options
                      const SizedBox(height: 8),
                      Text(
                        'Sort By',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildSortChip('Price: High to Low', 'price_high_to_low'),
                          _buildSortChip('Price: Low to High', 'price_low_to_high'),
                          _buildSortChip('Name: A to Z', 'name_a_to_z'),
                          _buildSortChip('Name: Z to A', 'name_z_to_a'),
                        ],
                      ),

                      // Filter buttons
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetFilters,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Models grid
              Expanded(
                child: _displayedModels.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${widget.brand.name} models found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing your filters',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
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
                        itemCount: _displayedModels.length,
                        itemBuilder: (context, index) {
                          return PhoneModelItemWithInquiry(
                            model: _displayedModels[index],
                            onTap: widget.onModelSelected,
                            onInquiry: _handleQuickInquiry,
                          );
                        },
                      ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _sortBy = value;
            _sortModels();
          });
        }
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade800,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

// Update the PhoneModelItem widget to include inquiry functionality
class PhoneModelItemWithInquiry extends StatelessWidget {
  final PhoneModel model;
  final Function(PhoneModel) onTap;
  final Function(PhoneModel, String, String) onInquiry;

  const PhoneModelItemWithInquiry({
    Key? key,
    required this.model,
    required this.onTap,
    required this.onInquiry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the highest price for display
    int highestPrice = 0;
    String bestStorage = model.storageOptions.isNotEmpty ? model.storageOptions.first : '';
    String bestCondition = model.conditions.isNotEmpty ? model.conditions.first : '';
    
    model.variantPrices.forEach((storage, conditions) {
      conditions.forEach((condition, price) {
        if (price > highestPrice) {
          highestPrice = price;
          bestStorage = storage;
          bestCondition = condition;
        }
      });
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onTap(model),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Image.network(
                    model.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.smartphone, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            // Phone details
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Up to ₹$highestPrice',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Quick inquiry button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onInquiry(model, bestStorage, bestCondition),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Quick Inquiry',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
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
