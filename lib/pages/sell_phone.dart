import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/components/sell_phone/search_feature.dart';

class SellPhonePage extends StatefulWidget {
  const SellPhonePage({Key? key}) : super(key: key);

  @override
  State<SellPhonePage> createState() => _SellPhonePageState();
}

class _SellPhonePageState extends State<SellPhonePage> {
  final TextEditingController _searchController = TextEditingController();
  List<PhoneBrand> _brands = [];
  List<PhoneModel> _allModels = [];
  List<PhoneModel> _searchResults = [];
  PhoneModel? _selectedModel;
  String? _selectedStorage;
  String? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load brands and models (in a real app, this might come from an API)
    _brands = PhoneBrandsData.getAllBrands();
    _allModels = PhoneBrandsData.getPopularModels();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allModels
            .where((model) =>
                model.name.toLowerCase().contains(query.toLowerCase()) ||
                model.brandId.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onModelSelected(PhoneModel model) {
    setState(() {
      _selectedModel = model;
      _selectedStorage = model.storageOptions.isNotEmpty ? model.storageOptions.first : null;
      _selectedCondition = model.conditions.isNotEmpty ? model.conditions.first : null;
    });
    
    // Show the model details modal
    _showModelDetailsModal(model);
  }

  void _onBrandSelected(PhoneBrand brand) {
    // Filter models by brand
    final brandModels = _allModels.where((model) => model.brandId == brand.id).toList();
    
    if (brandModels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No models available for ${brand.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _searchResults = brandModels;
      });
    }
  }

  void _showModelDetailsModal(PhoneModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Model header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Model image
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            model.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.smartphone, size: 50, color: Colors.grey)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Model info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Brand: ${_brands.firstWhere((b) => b.id == model.brandId, orElse: () => PhoneBrand(id: '', name: 'Unknown', logoUrl: '')).name}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${model.storageOptions.length} storage options',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Storage options
                  if (model.storageOptions.isNotEmpty) ...[
                    const Text(
                      'Select Storage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: model.storageOptions.map((storage) {
                        final isSelected = _selectedStorage == storage;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              _selectedStorage = storage;
                            });
                            setState(() {
                              _selectedStorage = storage;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              storage,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Condition options
                  if (model.conditions.isNotEmpty) ...[
                    const Text(
                      'Select Condition',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: model.conditions.map((condition) {
                        final isSelected = _selectedCondition == condition;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              _selectedCondition = condition;
                            });
                            setState(() {
                              _selectedCondition = condition;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              condition,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Price estimate
                  if (_selectedStorage != null && _selectedCondition != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estimated Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your ${model.name}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '₹${model.getEstimatedPrice(_selectedStorage!, _selectedCondition!).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // In a real app, this would navigate to the next step
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Proceeding to sell your phone'),
                            duration: Duration(seconds: 2),
                          ),
                        );
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
                        'Proceed to Sell',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Safe area padding for bottom sheet
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredBrands = PhoneBrandsData.getFeaturedBrands();
    final popularModels = PhoneBrandsData.getPopularModels();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Your Phone'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  _buildStepItem(
                    icon: Icons.search,
                    title: 'Find',
                    description: 'Your phone model',
                  ),
                  _buildStepArrow(),
                  _buildStepItem(
                    icon: Icons.check_circle_outline,
                    title: 'Select',
                    description: 'Storage & condition',
                  ),
                  _buildStepArrow(),
                  _buildStepItem(
                    icon: Icons.attach_money,
                    title: 'Get',
                    description: 'Instant quote',
                  ),
                ],
              ),
            ),
            
            // Search section
            PhoneSearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              onModelSelected: _onModelSelected,
              allModels: _allModels,
            ),
            
            // Popular models section if no search results
            if (_searchResults.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Models',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SearchResultsGrid(
                models: popularModels,
                onModelSelected: _onModelSelected,
              ),
              
              // Brands section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: const Text(
                  'Browse by Brand',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FeaturedBrandsRow(
                brands: featuredBrands,
                onBrandSelected: _onBrandSelected,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: const Text(
                  'All Brands',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              BrandsGrid(
                brands: _brands,
                onBrandSelected: _onBrandSelected,
              ),
            ] else ...[
              // Search results
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Search Results (${_searchResults.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SearchResultsGrid(
                models: _searchResults,
                onModelSelected: _onModelSelected,
              ),
            ],
            
            // Bottom padding
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepArrow() {
    return const Icon(
      Icons.arrow_forward,
      color: Colors.grey,
      size: 20,
    );
  }
}
