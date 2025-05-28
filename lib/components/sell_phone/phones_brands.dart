import 'package:flutter/material.dart';
import '../../services/sell_phone.dart';

class PhoneBrand {
  final String id;
  final String name;
  final String logoUrl;
  final List<PhoneModel> popularModels;

  PhoneBrand({
    required this.id,
    required this.name,
    required this.logoUrl, 
    this.popularModels = const [],
  });
}

class PhoneModel {
  final String id;
  final String brandId;
  final String name;
  final String imageUrl;
  final List<String> storageOptions;
  final List<String> conditions;
  final Map<String, Map<String, int>> variantPrices; // Based on storage and condition

  PhoneModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.imageUrl,
    this.storageOptions = const [],
    this.conditions = const [],
    this.variantPrices = const {},
  });
  
  // Factory method to create from SellPhone
  factory PhoneModel.fromSellPhone(String brandId, dynamic sellPhone) {
    // Extract storage options from variantPrices
    List<String> storageOptions = [];
    List<String> conditions = [];
    
    if (sellPhone.variantPrices.isNotEmpty) {
      storageOptions = sellPhone.variantPrices.keys.toList();
      
      // Get conditions from the first storage option
      if (storageOptions.isNotEmpty) {
        conditions = sellPhone.variantPrices[storageOptions.first]?.keys.toList() ?? [];
      }
    }
    
    return PhoneModel(
      id: sellPhone.id,
      brandId: brandId,
      name: sellPhone.name,
      imageUrl: sellPhone.image,
      storageOptions: storageOptions,
      conditions: conditions,
      variantPrices: sellPhone.variantPrices,
    );
  }

  int getEstimatedPrice(String storage, String condition) {
    if (variantPrices.containsKey(storage) && 
        variantPrices[storage]!.containsKey(condition)) {
      return variantPrices[storage]![condition] ?? 0;
    }
    return 0;
  }
}

class BrandsGrid extends StatelessWidget {
  final List<PhoneBrand> brands;
  final Function(PhoneBrand) onBrandSelected;

  const BrandsGrid({
    Key? key, 
    required this.brands,
    required this.onBrandSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        return BrandItem(
          brand: brands[index],
          onTap: () => onBrandSelected(brands[index]),
        );
      },
    );
  }
}

class BrandItem extends StatelessWidget {
  final PhoneBrand brand;
  final VoidCallback onTap;

  const BrandItem({
    Key? key,
    required this.brand,
    required this.onTap,
  }) : super(key: key);

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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand logo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  brand.logoUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Brand name
            Text(
              brand.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedBrandsRow extends StatelessWidget {
  final List<PhoneBrand> brands;
  final Function(PhoneBrand) onBrandSelected;

  const FeaturedBrandsRow({
    Key? key,
    required this.brands,
    required this.onBrandSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: BrandItem(
              brand: brands[index],
              onTap: () => onBrandSelected(brands[index]),
            ),
          );
        },
      ),
    );
  }
}

class PhoneBrandsData {
  static List<PhoneBrand> getAllBrands() {
    return [
      PhoneBrand(
        id: 'apple',
        name: 'Apple',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
      ),
      PhoneBrand(
        id: 'samsung',
        name: 'Samsung',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
      ),
      PhoneBrand(
        id: 'oneplus',
        name: 'OnePlus',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
      ),
      PhoneBrand(
        id: 'xiaomi',
        name: 'Xiaomi',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
      ),
      PhoneBrand(
        id: 'vivo',
        name: 'Vivo',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Vivo_logo.svg/1024px-Vivo_logo.svg.png',
      ),
      PhoneBrand(
        id: 'oppo',
        name: 'OPPO',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/OPPO_LOGO_2019.svg/2560px-OPPO_LOGO_2019.svg.png',
      ),
      PhoneBrand(
        id: 'realme',
        name: 'Realme',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Realme_logo.svg/2560px-Realme_logo.svg.png',
      ),
      PhoneBrand(
        id: 'google',
        name: 'Google',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/1200px-Google_2015_logo.svg.png',
      ),
      PhoneBrand(
        id: 'nokia',
        name: 'Nokia',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Nokia_wordmark.svg/1200px-Nokia_wordmark.svg.png',
      ),
      PhoneBrand(
        id: 'motorola',
        name: 'Motorola',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Motorola_logo.svg/1200px-Motorola_logo.svg.png',
      ),
      PhoneBrand(
        id: 'asus',
        name: 'Asus',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/ASUS_Logo.svg/1280px-ASUS_Logo.svg.png',
      ),
      PhoneBrand(
        id: 'htc',
        name: 'HTC',
        logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/HTC_logo_2017.svg/1000px-HTC_logo_2017.svg.png',
      ),
    ];
  }
  
  static List<PhoneBrand> getFeaturedBrands() {
    // Just return the top 5 brands as featured
    return getAllBrands().take(5).toList();
  }
  
  static Future<List<PhoneModel>> getPopularModels() async {
    // Get actual phone data from the API
    try {
      print('Getting popular models from API');
      final phoneService = SellPhoneService();
      final phones = await phoneService.getSellPhones();
      
      print('Retrieved ${phones.length} phones from API');
      
      // Convert sell phones to phone models
      final phoneModels = convertSellPhonesToPhoneModels(phones);
      print('Converted to ${phoneModels.length} phone models');
      
      // Make sure we have enough models to display, otherwise fallback
      if (phoneModels.isEmpty) {
        print('No phone models from API, using fallback data');
        return getPopularModelSync();
      }
      
      try {
        // First try: Use scoring algorithm to get popular models
        print('Attempting to use scoring algorithm for popular models');
        final result = _findPopularModels(phoneModels);
        
        if (result.isNotEmpty) {
          print('Scoring algorithm returned ${result.length} models');
          return result;
        } else {
          // If scoring returns no models, try random selection
          print('Scoring algorithm returned no models, trying random selection');
          return getRandomModels(phoneModels);
        }
      } catch (algorithmError) {
        // If scoring algorithm fails, use random selection instead
        print('Error in scoring algorithm: $algorithmError');
        print('Falling back to random model selection');
        return getRandomModels(phoneModels);
      }
    } catch (e) {
      print('Error fetching popular models: $e');
      // Return fallback models if API call fails
      return getPopularModelSync();
    }
  }
    // Helper method to find popular models using a scoring algorithm
  static List<PhoneModel> _findPopularModels(List<PhoneModel> models) {
    print('Finding popular models from ${models.length} models');
    if (models.isEmpty) {
      print('No models to find popular ones from');
      return [];
    }

    try {
      // Create a scoring system for popularity
      // Score based on multiple factors:
      // 1. Number of storage options (more options = more popular)
      // 2. Highest price point (higher price might indicate premium/popular model)
      // 3. Number of condition options
      final scoredModels = models.map((model) {
        try {
          // Calculate the highest price across all variants
          int highestPrice = 0;
          
          if (model.variantPrices.isNotEmpty) {
            model.variantPrices.forEach((storage, conditions) {
              if (conditions.isNotEmpty) {
                conditions.forEach((condition, price) {
                  if (price > highestPrice) highestPrice = price;
                });
              }
            });
          }
          
          // Calculate a weighted score
          final storageWeight = 3;
          final priceWeight = 1; 
          final conditionWeight = 2;
          
          final score = 
              (model.storageOptions.length * storageWeight) +
              ((highestPrice / 1000).round() * priceWeight) + // Normalize price impact
              (model.conditions.length * conditionWeight);
              
          return {'model': model, 'score': score};
        } catch (e) {
          print('Error calculating score for model ${model.name}: $e');
          // Return a low score for models with errors
          return {'model': model, 'score': 0};
        }
      }).toList();
      
      // Sort by score in descending order
      scoredModels.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      
      // Return the top N models, or all if we have fewer than that
      const int popularCount = 4;
      final resultCount = scoredModels.length < popularCount ? scoredModels.length : popularCount;
      
      print('Selecting top $resultCount models from ${scoredModels.length} scored models');
      return scoredModels
          .take(resultCount)
          .map((item) => item['model'] as PhoneModel)
          .toList();
    } catch (e) {
      print('Error in _findPopularModels: $e');
      // If the algorithm fails, just return up to 4 models
      return models.take(models.length < 4 ? models.length : 4).toList();
    }
  }
  // Synchronous version for when we can't await
  static List<PhoneModel> getPopularModelSync() {
    print('Using synchronous fallback data for popular models');
    try {
      // Return a diverse set of popular models as fallback data
      return [
        PhoneModel(
          id: 'fallback_iphone_15',
          brandId: 'apple',
          name: 'iPhone 15 Pro',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB', '512GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 85000, 'Good': 75000, 'Fair': 65000},
            '256GB': {'Like new': 95000, 'Good': 85000, 'Fair': 75000},
            '512GB': {'Like new': 105000, 'Good': 95000, 'Fair': 85000},
          },
        ),
        PhoneModel(
          id: 'fallback_galaxy_s23',
          brandId: 'samsung',
          name: 'Galaxy S23 Ultra',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB', '512GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 80000, 'Good': 70000, 'Fair': 60000},
            '256GB': {'Like new': 90000, 'Good': 80000, 'Fair': 70000},
            '512GB': {'Like new': 100000, 'Good': 90000, 'Fair': 80000},
          },
        ),
        PhoneModel(
          id: 'fallback_pixel_7',
          brandId: 'google',
          name: 'Pixel 7 Pro',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 60000, 'Good': 50000, 'Fair': 40000},
            '256GB': {'Like new': 70000, 'Good': 60000, 'Fair': 50000},
          },
        ),
        PhoneModel(
          id: 'fallback_oneplus_11',
          brandId: 'oneplus',
          name: 'OnePlus 11',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 55000, 'Good': 45000, 'Fair': 35000},
            '256GB': {'Like new': 65000, 'Good': 55000, 'Fair': 45000},
          },
        ),
        PhoneModel(
          id: 'fallback_nothing_2',
          brandId: 'nothing',
          name: 'Nothing Phone (2)',
          imageUrl: 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg',
          storageOptions: ['128GB', '256GB'],
          conditions: ['Like new', 'Good', 'Fair'],
          variantPrices: {
            '128GB': {'Like new': 50000, 'Good': 40000, 'Fair': 30000},
            '256GB': {'Like new': 60000, 'Good': 50000, 'Fair': 40000},
          },
        ),
      ];
    } catch (e) {
      print('Error in getPopularModelSync: $e');
      // Return a minimal set if even the above fails
      return [
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
    }
  }  // Method to convert SellPhone list to PhoneModel list
  static List<PhoneModel> convertSellPhonesToPhoneModels(List<SellPhone> sellPhones) {
    print('Converting ${sellPhones.length} sell phones to phone models');
    
    // Brand name normalization map
    Map<String, String> brandMapping = {
      'Apple': 'apple',
      'Samsung': 'samsung',
      'OnePlus': 'oneplus',
      'Xiaomi': 'xiaomi', 
      'Vivo': 'vivo',
      'OPPO': 'oppo',
      'oppo': 'oppo',
      'Realme': 'realme',
      'Google': 'google',
      'Nokia': 'nokia',
      'Motorola': 'motorola',
      'Asus': 'asus',
      'HTC': 'htc',
      'Nothing': 'nothing',
      'iphone': 'apple',
      'iPhone': 'apple',
      'APPLE': 'apple',
      'SAMSUNG': 'samsung',
      'galaxy': 'samsung',
    };
    
    final result = <PhoneModel>[];
    
    try {
      for (var sellPhone in sellPhones) {
        try {
          // Skip phones without necessary data
          if (sellPhone.id.isEmpty && sellPhone.name.isEmpty) {
            print('Skipping phone with no ID and no name');
            continue;
          }
          
          // Determine the brandId from the brand name
          String brandName = sellPhone.brand.trim();
          String brandId = '';
          
          // Try direct mapping first
          if (brandMapping.containsKey(brandName)) {
            brandId = brandMapping[brandName]!;
          } else {
            // Try to match by checking if any known brand is contained in the name
            bool brandFound = false;
            for (var entry in brandMapping.entries) {
              if (sellPhone.name.toLowerCase().contains(entry.key.toLowerCase()) || 
                  brandName.toLowerCase().contains(entry.key.toLowerCase())) {
                brandId = entry.value;
                brandFound = true;
                break;
              }
            }
            
            // If still no match, fallback to lowercase of the brand name
            if (!brandFound) {
              brandId = brandName.toLowerCase().replaceAll(' ', '_');
            }
          }
          
          // Extract storage options from variantPrices
          List<String> storageOptions = [];
          List<String> conditions = [];
          
          if (sellPhone.variantPrices.isNotEmpty) {
            storageOptions = sellPhone.variantPrices.keys.toList();
            
            // Get conditions from the first storage option
            if (storageOptions.isNotEmpty) {
              conditions = sellPhone.variantPrices[storageOptions.first]?.keys.toList() ?? [];
            }
          }
          
          // Ensure we have at least some default values if data is missing
          if (storageOptions.isEmpty) {
            storageOptions = ['128GB'];
          }
          
          if (conditions.isEmpty) {
            conditions = ['Good'];
          }
          
          // Make sure we have a valid image URL
          String imageUrl = sellPhone.image.isNotEmpty
              ? sellPhone.image
              : 'https://img.freepik.com/free-psd/smartphone-mockup_1310-812.jpg';
          
          result.add(PhoneModel(
            id: sellPhone.id,
            brandId: brandId,
            name: sellPhone.name,
            imageUrl: imageUrl,
            storageOptions: storageOptions,
            conditions: conditions,
            variantPrices: sellPhone.variantPrices,
          ));
        } catch (e) {
          print('Error converting individual sellPhone to PhoneModel: $e');
          // Continue to next phone
        }
      }
    } catch (e) {
      print('Error in convertSellPhonesToPhoneModels: $e');
    }
    
    print('Converted ${result.length} phone models');
    return result;
  }

  // Get a list of random phone models from the available models
  static List<PhoneModel> getRandomModels(List<PhoneModel> models, {int count = 6}) {
    print('Selecting $count random models from ${models.length} models');
    
    if (models.isEmpty) {
      print('No models available for random selection');
      return getPopularModelSync(); // Fall back to static data
    }
    
    try {
      // Create a copy of the list to avoid modifying the original
      final List<PhoneModel> modelsCopy = List.from(models);
      
      // Shuffle the list to randomize it
      modelsCopy.shuffle();
      
      // Return up to 'count' models, or all if we have fewer than that
      final resultCount = modelsCopy.length < count ? modelsCopy.length : count;
      print('Returning $resultCount random models');
      return modelsCopy.take(resultCount).toList();
    } catch (e) {
      print('Error in getRandomModels: $e');
      // If there's an error, try to return a subset of the input models without shuffling
      final safeCount = models.length < count ? models.length : count;
      return models.take(safeCount).toList();
    }
  }
}
