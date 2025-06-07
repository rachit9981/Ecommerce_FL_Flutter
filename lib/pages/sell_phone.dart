import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/components/sell_phone/search_feature.dart';
import 'package:ecom/components/sell_phone/selling_comp.dart';
import 'package:ecom/services/sell_phone.dart';
import 'package:ecom/models/sell_phone_inquiry.dart';
import 'package:ecom/pages/search_phone.dart';
import 'package:ecom/pages/sell_phone_requests.dart';
import 'package:ecom/pages/sell_phone_by_brand.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../components/common/login_required.dart';

class SellPhonePage extends StatefulWidget {
  const SellPhonePage({Key? key}) : super(key: key);

  @override
  State<SellPhonePage> createState() => _SellPhonePageState();
}

class _SellPhonePageState extends State<SellPhonePage> {
  List<PhoneBrand> _brands = [];
  List<PhoneModel> _allModels = [];
  List<PhoneModel> _popularModels = []; // Separate list for popular models
  PhoneModel? _selectedModel;
  String? _selectedStorage;
  String? _selectedCondition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _allModels = []; // Clear existing models
    });
    
    print('Loading sell phone data...');
    
    // Always load brands first - these are static
    _brands = PhoneBrandsData.getAllBrands();
    print('Loaded ${_brands.length} phone brands');
    
    try {
      // First attempt: Load from API
      print('Attempting to load phones from API');
      final sellPhoneService = SellPhoneService();
      final sellPhones = await sellPhoneService.getSellPhones();
      
      if (sellPhones.isNotEmpty) {
        print('API returned ${sellPhones.length} phones');
        // Convert sell phones to phone models
        _allModels = PhoneBrandsData.convertSellPhonesToPhoneModels(sellPhones);
        print('Converted to ${_allModels.length} phone models');
        
        // If conversion didn't work properly
        if (_allModels.isEmpty) {
          print('API returned data but conversion resulted in 0 models. Trying popular models...');
          _allModels = await PhoneBrandsData.getPopularModels();
        }
        
        // Get top 6 popular models for display
        _popularModels = _getTopPopularModels(_allModels, 6);
      } else {
        print('API returned 0 phones. Trying popular models...');
        _allModels = await PhoneBrandsData.getPopularModels();
        _popularModels = _getTopPopularModels(_allModels, 6);
      }
    } catch (e) {
      print('Error loading sell phones from API: $e');
      
      // Second attempt: Try popular models fetch (which has its own API call)
      try {
        print('Attempting to load popular models directly...');
        _allModels = await PhoneBrandsData.getPopularModels();
        _popularModels = _getTopPopularModels(_allModels, 6);
      } catch (fallbackError) {
        print('Error loading popular models: $fallbackError');
        
        // Try random selection of fallback models for more variety
        print('Trying random selection from fallback models');
        final fallbackModels = PhoneBrandsData.getPopularModelSync();
        _allModels = fallbackModels;
        _popularModels = _getTopPopularModels(_allModels, 6);
      }
    } finally {
      // Ensure we always have at least one model to display
      if (_allModels.isEmpty) {
        print('All data loading attempts failed. Using emergency fallback...');
        _allModels = [
          PhoneModel(
            id: 'emergency_fallback',
            brandId: 'apple',
            name: 'iPhone (Generic)',
            imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
            storageOptions: ['128GB'],
            conditions: ['Good'],
            variantPrices: {
              '128GB': {'Good': 50000},
            },
          ),
        ];
        _popularModels = _allModels;
      }
      print('Final model count: ${_allModels.length}');
      print('Popular models to display: ${_popularModels.length}');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Helper method to get top N popular models
  List<PhoneModel> _getTopPopularModels(List<PhoneModel> models, int count) {
    if (models.isEmpty) return [];
    
    // Create a copy to avoid modifying the original list
    final List<PhoneModel> modelsCopy = List.from(models);
    
    // Sort by a popularity metric (here we'll use highest price as a simple metric)
    modelsCopy.sort((a, b) {
      int highestPriceA = 0;
      int highestPriceB = 0;
      
      // Find highest price for model A
      a.variantPrices.forEach((storage, conditions) {
        conditions.forEach((condition, price) {
          if (price > highestPriceA) highestPriceA = price;
        });
      });
      
      // Find highest price for model B
      b.variantPrices.forEach((storage, conditions) {
        conditions.forEach((condition, price) {
          if (price > highestPriceB) highestPriceB = price;
        });
      });
      
      // Sort in descending order
      return highestPriceB.compareTo(highestPriceA);
    });
    
    // Return top N models, or all if we have fewer than that
    return modelsCopy.take(modelsCopy.length < count ? modelsCopy.length : count).toList();
  }

  void _navigateToSearch() async {
    // Navigate to the search page and wait for a result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPhonePage(
          allModels: _allModels,
        ),
      ),
    );
    
    // If a model was selected, handle it
    if (result != null && result is PhoneModel) {
      _onModelSelected(result);
    }
  }

  void _onModelSelected(PhoneModel model) {
    setState(() {
      _selectedModel = model;
      _selectedStorage = model.storageOptions.isNotEmpty ? model.storageOptions.first : null;
      _selectedCondition = model.conditions.isNotEmpty ? model.conditions.first : null;
    });
    
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
      // Navigate to dedicated brand page instead of search
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellPhoneByBrandPage(
            brand: brand,
            brandModels: brandModels,
            onModelSelected: _onModelSelected,
          ),
        ),
      );
    }
  }

  // Update this method to use the shared components
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
                  
                  // Storage options using shared component
                  if (model.storageOptions.isNotEmpty) ...[
                    StorageOptionSelector(
                      options: model.storageOptions,
                      selectedOption: _selectedStorage,
                      onOptionSelected: (storage) {
                        setModalState(() {
                          _selectedStorage = storage;
                        });
                        setState(() {
                          _selectedStorage = storage;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Condition options using shared component
                  if (model.conditions.isNotEmpty) ...[
                    ConditionOptionSelector(
                      options: model.conditions,
                      selectedOption: _selectedCondition,
                      onOptionSelected: (condition) {
                        setModalState(() {
                          _selectedCondition = condition;
                        });
                        setState(() {
                          _selectedCondition = condition;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Price estimate using shared component
                  if (_selectedStorage != null && _selectedCondition != null) ...[
                    PriceEstimateDisplay(
                      modelName: model.name,
                      estimatedPrice: model.getEstimatedPrice(_selectedStorage!, _selectedCondition!),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitModelInquiry(model),
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
  
  // New simplified method using the shared component
  void _submitModelInquiry(PhoneModel model) {
    // Close the current modal first
    Navigator.pop(context);
    
    // Use the shared inquiry submission logic with address handling
    SellingComponents.submitInquiry(
      context: context,
      model: model,
      storage: _selectedStorage ?? model.storageOptions.first,
      condition: _selectedCondition ?? model.conditions.first,
      onSuccess: () {
        // Explicit success callback to ensure we handle the flow properly
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your inquiry was submitted successfully!')),
        );
        
        // Refresh the model list to show updated state
        _loadData();
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final featuredBrands = PhoneBrandsData.getFeaturedBrands();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Old Phones'),
        elevation: 0,
        actions: [
          // Add a button to view sell requests
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Your sell requests',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SellPhoneRequestsPage(),
                ),
              );
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
          
          // If authenticated, show the sell phone content
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use the shared steps widget
                const SellingSteps(),
                
                // Use the shared search bar widget
                SearchBarWidget(onTap: _navigateToSearch),
                
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
                
                // Popular models section
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
                
                // Show loading indicator, empty message, or models grid
                _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _popularModels.isEmpty
                    ? Center(
                        child: Column(
                          children: [
                            const Icon(Icons.phone_android, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No phone models available',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try refreshing the page',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : SearchResultsGrid(
                        models: _popularModels,
                        onModelSelected: _onModelSelected,
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
                
                // Bottom padding
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      ),
    );
  }
}
