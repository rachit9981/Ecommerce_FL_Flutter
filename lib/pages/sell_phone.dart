import 'package:flutter/material.dart';
import 'package:ecom/components/sell_phone/phones_brands.dart';
import 'package:ecom/components/sell_phone/selling_comp.dart';
import 'package:ecom/services/sell_phone.dart';
import 'package:ecom/pages/search_phone.dart';
import 'package:ecom/pages/sell_phone_requests.dart';
import 'package:ecom/pages/sell_phone_by_brand.dart';
import 'package:ecom/pages/sell_phone_details.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../components/common/login_required.dart';

class SellPhonePage extends StatefulWidget {
  const SellPhonePage({Key? key}) : super(key: key);

  @override
  State<SellPhonePage> createState() => _SellPhonePageState();
}

class _SellPhonePageState extends State<SellPhonePage> {
  List<PhoneBrandUI> _brands = [];
  List<PhoneModelUI> _allModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _allModels = [];
    });
    
    print('Loading sell phone data from catalog API...');
    
    try {
      final sellPhoneService = SellPhoneService();
      
      // Load brands from catalog API
      print('Calling getPhoneBrands()...');
      _brands = await sellPhoneService.getPhoneBrands();
      print('Loaded ${_brands.length} phone brands');
      
      // Load all models from catalog API
      print('Calling getPopularModels()...');
      _allModels = await sellPhoneService.getPopularModels(limit: 50);
      print('Loaded ${_allModels.length} phone models');
      
    } catch (e) {
      print('Error loading data from catalog API: $e');
      // Keep empty lists on error
      _brands = [];
      _allModels = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSearch() async {
    // Navigate to the search page and wait for a result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPhonePage(
          allModels: _convertToPhoneModels(_allModels),
        ),
      ),
    );
    
    // If a model was selected, handle it
    if (result != null && result is PhoneModel) {
      _onModelSelected(result);
    }
  }

  void _onModelSelected(dynamic model) {
    // Handle both PhoneModel and PhoneModelUI
    if (model is PhoneModelUI) {
      // Navigate to the details page with new model type
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellPhoneDetailsPage(
            modelUI: model,
          ),
        ),
      );
    } else if (model is PhoneModel) {
      // Navigate to the details page with legacy model type
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellPhoneDetailsPage(
            model: model,
          ),
        ),
      );
    }
  }

  void _onBrandSelected(dynamic brand) async {
    // Handle both PhoneBrand and PhoneBrandUI
    String brandId;
    String brandName;
    String logoUrl = '';
    
    if (brand is PhoneBrandUI) {
      brandId = brand.id;
      brandName = brand.name;
      logoUrl = brand.logoUrl;
    } else {
      brandId = (brand as PhoneBrand).id;
      brandName = brand.name;
    }
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Get full brand data from API
      final sellPhoneService = SellPhoneService();
      final brandData = await sellPhoneService.getBrandData(brandId);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (brandData == null || brandData.phoneSeries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No phone series available for $brandName'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Navigate directly to the series/models page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellPhoneBySeriesPage(
              brandId: brandId,
              brandName: brandName,
              brandLogoUrl: logoUrl,
              brandData: brandData,
              onModelSelected: _onModelSelected,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading $brandName data. Please try again.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Convert PhoneModelUI to PhoneModel for backward compatibility
  PhoneModel _convertUIModelToPhoneModel(PhoneModelUI uiModel) {
    return PhoneModel(
      id: uiModel.id,
      brandId: uiModel.brandId,
      name: uiModel.name,
      imageUrl: uiModel.imageUrl,
      storageOptions: uiModel.storageOptions,
      conditions: uiModel.ramOptions.isNotEmpty ? uiModel.ramOptions : ['Good'],
      variantPrices: uiModel.variantPrices,
    );
  }

  // Convert list of PhoneModelUI to PhoneModel
  List<PhoneModel> _convertToPhoneModels(List<PhoneModelUI> uiModels) {
    return uiModels.map((uiModel) => _convertUIModelToPhoneModel(uiModel)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final featuredBrands = _brands.take(6).toList(); // Use first 6 brands from API
    
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
      ),      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          print('SellPhonePage: User authentication state: ${userProvider.isAuthenticated}');
          // Check if user is not authenticated
          if (!userProvider.isAuthenticated) {
            return LoginRequired(
              title: 'Login to Sell Your Phone',
              message: 'Please login to sell your old phone and get instant quotes',
              icon: Icons.smartphone_outlined,
            );
          }
          
          // If authenticated, show the sell phone content
          return Container(
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Use the shared steps widget
                  const SellingSteps(),
                  
                  // Use the shared search bar widget
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SearchBarWidget(onTap: _navigateToSearch),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Brands section
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.smartphone,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Browse by Brand',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Show loading or brands
                        _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _brands.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: Icon(
                                          Icons.smartphone_outlined, 
                                          size: 40, 
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Unable to load phone brands',
                                        style: TextStyle(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Please check your internet connection',
                                        style: TextStyle(
                                          fontSize: 14, 
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        onPressed: _loadData,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.0,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: featuredBrands.length,
                                itemBuilder: (context, index) {
                                  final brand = featuredBrands[index];
                                  return InkWell(
                                    onTap: () => _onBrandSelected(brand),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey.shade200),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Image.network(
                                              brand.logoUrl.isNotEmpty ? brand.logoUrl : 'https://via.placeholder.com/50',
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => 
                                                  Icon(Icons.smartphone, size: 24, color: Colors.grey.shade600),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            brand.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
