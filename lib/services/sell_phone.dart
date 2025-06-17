import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// API endpoints - Updated to use top-level API routes with consistent naming
const String sellMobileBaseUrl = '$apiUrl/sell-mobile';

// Catalog endpoints
const String catalogUrl = '$sellMobileBaseUrl/catalog/all/';

// Inquiry endpoints
const String submitInquiryUrl = '$sellMobileBaseUrl/inquiries/submit/';
const String userInquiriesUrl = '$sellMobileBaseUrl/inquiries/user/';

// New data models for the updated API structure
class PhoneBrandData {
  final String id;
  final String logoUrl;
  final Map<String, PhoneSeriesData> phoneSeries;

  PhoneBrandData({
    required this.id,
    required this.logoUrl,
    required this.phoneSeries,
  });

  factory PhoneBrandData.fromJson(String brandId, Map<String, dynamic> json) {
    Map<String, PhoneSeriesData> series = {};
    
    if (json['phone_series'] != null) {
      (json['phone_series'] as Map<String, dynamic>).forEach((seriesId, seriesData) {
        series[seriesId] = PhoneSeriesData.fromJson(seriesId, seriesData);
      });
    }
    
    return PhoneBrandData(
      id: brandId,
      logoUrl: json['logo_url'] ?? '',
      phoneSeries: series,
    );
  }
}

class PhoneSeriesData {
  final String id;
  final String displayName;
  final Map<String, PhoneModelData> phones;

  PhoneSeriesData({
    required this.id,
    required this.displayName,
    required this.phones,
  });

  factory PhoneSeriesData.fromJson(String seriesId, Map<String, dynamic> json) {
    Map<String, PhoneModelData> phones = {};
    
    if (json['phones'] != null) {
      (json['phones'] as Map<String, dynamic>).forEach((phoneId, phoneData) {
        phones[phoneId] = PhoneModelData.fromJson(phoneId, phoneData);
      });
    }
    
    return PhoneSeriesData(
      id: seriesId,
      displayName: json['display_name'] ?? seriesId,
      phones: phones,
    );
  }
}

class PhoneModelData {
  final String id;
  final String displayName;
  final String imageUrl;
  final int launchYear;
  final Map<String, Map<String, int>> variantPrices;
  final Map<String, List<String>> variantOptions;
  final int demandScore;
  final Map<String, QuestionGroup> questionGroups;

  PhoneModelData({
    required this.id,
    required this.displayName,
    required this.imageUrl,
    required this.launchYear,
    required this.variantPrices,
    required this.variantOptions,
    required this.demandScore,
    required this.questionGroups,
  });
  factory PhoneModelData.fromJson(String phoneId, Map<String, dynamic> json) {
    Map<String, Map<String, int>> variantPrices = {};
    if (json['variant_prices'] != null) {
      (json['variant_prices'] as Map<String, dynamic>).forEach((storage, ramPrices) {
        variantPrices[storage] = {};
        if (ramPrices is Map<String, dynamic>) {
          ramPrices.forEach((ram, price) {
            // Handle both int and double values
            if (price is int) {
              variantPrices[storage]![ram] = price;
            } else if (price is double) {
              variantPrices[storage]![ram] = price.toInt();
            } else {
              variantPrices[storage]![ram] = int.tryParse(price.toString()) ?? 0;
            }
          });
        }
      });
    }

    Map<String, List<String>> variantOptions = {};
    if (json['variant_options'] != null) {
      (json['variant_options'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          variantOptions[key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    Map<String, QuestionGroup> questionGroups = {};
    if (json['question_groups'] != null) {
      (json['question_groups'] as Map<String, dynamic>).forEach((groupId, groupData) {
        questionGroups[groupId] = QuestionGroup.fromJson(groupId, groupData);
      });
    }

    // Handle numeric conversions safely
    int launchYear = 0;
    if (json['launch_year'] is int) {
      launchYear = json['launch_year'];
    } else if (json['launch_year'] is double) {
      launchYear = (json['launch_year'] as double).toInt();
    } else if (json['launch_year'] != null) {
      launchYear = int.tryParse(json['launch_year'].toString()) ?? 0;
    }

    int demandScore = 0;
    if (json['demand_score'] is int) {
      demandScore = json['demand_score'];
    } else if (json['demand_score'] is double) {
      demandScore = (json['demand_score'] as double).toInt();
    } else if (json['demand_score'] != null) {
      demandScore = int.tryParse(json['demand_score'].toString()) ?? 0;
    }

    return PhoneModelData(
      id: phoneId,
      displayName: json['display_name'] ?? phoneId,
      imageUrl: json['image_url'] ?? '',
      launchYear: launchYear,
      variantPrices: variantPrices,
      variantOptions: variantOptions,
      demandScore: demandScore,
      questionGroups: questionGroups,
    );
  }
}

class QuestionGroup {
  final String id;
  final String displayName;
  final List<Question> questions;

  QuestionGroup({
    required this.id,
    required this.displayName,
    required this.questions,
  });

  factory QuestionGroup.fromJson(String groupId, Map<String, dynamic> json) {
    List<Question> questions = [];
    if (json['questions'] != null) {
      questions = (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    }

    return QuestionGroup(
      id: groupId,
      displayName: json['display_name'] ?? groupId,
      questions: questions,
    );
  }
}

class Question {
  final String id;
  final String type;
  final String questionText;
  final List<QuestionOption> options;

  Question({
    required this.id,
    required this.type,
    required this.questionText,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<QuestionOption> options = [];
    if (json['options'] != null) {
      options = (json['options'] as List)
          .map((o) => QuestionOption.fromJson(o))
          .toList();
    }

    return Question(
      id: json['id'] ?? '',
      type: json['type'] ?? 'single_choice',
      questionText: json['question_text'] ?? '',
      options: options,
    );
  }
}

class QuestionOption {
  final String label;
  final String imageUrl;
  final int priceModifier;
  final String? kind;

  QuestionOption({
    required this.label,
    required this.imageUrl,
    required this.priceModifier,
    this.kind,
  });
  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    // Handle price_modifier which might be int or double
    int priceModifier = 0;
    if (json['price_modifier'] is int) {
      priceModifier = json['price_modifier'];
    } else if (json['price_modifier'] is double) {
      priceModifier = (json['price_modifier'] as double).toInt();
    } else if (json['price_modifier'] != null) {
      priceModifier = int.tryParse(json['price_modifier'].toString()) ?? 0;
    }

    return QuestionOption(
      label: json['label'] ?? '',
      imageUrl: json['image_url'] ?? '',
      priceModifier: priceModifier,
      kind: json['kind'],
    );
  }
}

// UI Model classes for displaying phone data
class PhoneBrandUI {
  final String id;
  final String name;
  final String logoUrl;
  final int totalModels;

  PhoneBrandUI({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.totalModels,
  });
}

class PhoneModelUI {
  final String id;
  final String brandId;
  final String seriesId;
  final String phoneId;
  final String name;
  final String imageUrl;
  final int launchYear;
  final Map<String, Map<String, int>> variantPrices;
  final Map<String, List<String>> variantOptions;
  final int demandScore;
  final Map<String, QuestionGroup> questionGroups;

  PhoneModelUI({
    required this.id,
    required this.brandId,
    required this.seriesId,
    required this.phoneId,
    required this.name,
    required this.imageUrl,
    required this.launchYear,
    required this.variantPrices,
    required this.variantOptions,
    required this.demandScore,
    required this.questionGroups,
  });

  // Convert PhoneModelData to PhoneModelUI for compatibility
  static PhoneModelUI fromPhoneModelData(
    PhoneModelData modelData, 
    String brandId, 
    String seriesId
  ) {
    return PhoneModelUI(
      id: modelData.id,
      brandId: brandId,
      seriesId: seriesId,
      phoneId: modelData.id,
      name: modelData.displayName,
      imageUrl: modelData.imageUrl,
      launchYear: modelData.launchYear,
      variantPrices: modelData.variantPrices,
      variantOptions: modelData.variantOptions,
      demandScore: modelData.demandScore,
      questionGroups: modelData.questionGroups,
    );
  }

  // Get the highest price variant for this model
  int getMaxPrice() {
    int maxPrice = 0;
    variantPrices.forEach((storage, ramPrices) {
      ramPrices.forEach((ram, price) {
        if (price > maxPrice) maxPrice = price;
      });
    });
    return maxPrice;
  }

  // Get the lowest price variant for this model
  int getMinPrice() {
    int minPrice = 999999999;
    variantPrices.forEach((storage, ramPrices) {
      ramPrices.forEach((ram, price) {
        if (price < minPrice) minPrice = price;
      });
    });
    return minPrice == 999999999 ? 0 : minPrice;
  }

  // Get price for specific variant
  int getPriceForVariant(String storage, String ram) {
    return variantPrices[storage]?[ram] ?? 0;
  }

  // Get available storage options
  List<String> get storageOptions {
    return variantOptions['storage'] ?? variantPrices.keys.toList();
  }

  // Get available RAM options
  List<String> get ramOptions {
    return variantOptions['ram'] ?? [];
  }

  // Get available color options
  List<String> get colorOptions {
    return variantOptions['color'] ?? [];
  }
}

class SellPhoneService {
  // Fetch all mobile catalog with brands, series, and models using new API structure
  Future<Map<String, PhoneBrandData>> getMobileCatalog() async {
    try {
      final response = await http.get(Uri.parse(catalogUrl));

      if (response.statusCode == 200) {
        return _parseCatalogResponse(response);
      } else {
        print('API Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load catalog from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception with catalog API: $e');
      throw Exception('Failed to load mobile catalog: $e');
    }
  }
  
  // Parse the new catalog response format
  Map<String, PhoneBrandData> _parseCatalogResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['status'] == 'success' && data['data'] != null && data['data']['brands'] != null) {
        Map<String, PhoneBrandData> brands = {};
        
        (data['data']['brands'] as Map<String, dynamic>).forEach((brandId, brandData) {
          brands[brandId] = PhoneBrandData.fromJson(brandId, brandData);
        });
        
        return brands;
      } else {
        throw Exception('Invalid catalog response format');
      }
    } catch (e) {
      print('Error parsing catalog response: $e');
      throw Exception('Failed to parse catalog response: $e');
    }
  }

  // Get phone brands for UI display
  Future<List<PhoneBrandUI>> getPhoneBrands() async {
    try {
      final catalog = await getMobileCatalog();
      List<PhoneBrandUI> brands = [];
      
      catalog.forEach((brandId, brandData) {
        brands.add(PhoneBrandUI(
          id: brandId,
          name: _formatBrandName(brandId),
          logoUrl: brandData.logoUrl,
          totalModels: _getTotalModelsCount(brandData),
        ));
      });
      
      return brands;
    } catch (e) {
      print('Error getting phone brands: $e');
      return [];
    }
  }

  // Get phone models for a specific brand
  Future<List<PhoneModelUI>> getPhoneModelsByBrand(String brandId) async {
    try {
      final catalog = await getMobileCatalog();
      List<PhoneModelUI> models = [];
      
      if (catalog.containsKey(brandId)) {
        final brandData = catalog[brandId]!;
        
        brandData.phoneSeries.forEach((seriesId, seriesData) {
          seriesData.phones.forEach((phoneId, phoneData) {
            models.add(PhoneModelUI(
              id: '${brandId}_${seriesId}_$phoneId',
              brandId: brandId,
              seriesId: seriesId,
              phoneId: phoneId,
              name: phoneData.displayName,
              imageUrl: phoneData.imageUrl,
              launchYear: phoneData.launchYear,
              variantPrices: phoneData.variantPrices,
              variantOptions: phoneData.variantOptions,
              demandScore: phoneData.demandScore,
              questionGroups: phoneData.questionGroups,
            ));
          });
        });
        
        // Sort by demand score (higher first) and then by launch year (newer first)
        models.sort((a, b) {
          if (a.demandScore != b.demandScore) {
            return b.demandScore.compareTo(a.demandScore);
          }
          return b.launchYear.compareTo(a.launchYear);
        });
      }
      
      return models;
    } catch (e) {
      print('Error getting phone models for brand $brandId: $e');
      return [];
    }
  }

  // Search phone models by name
  Future<List<PhoneModelUI>> searchPhoneModels(String query) async {
    try {
      final catalog = await getMobileCatalog();
      List<PhoneModelUI> allModels = [];
      
      catalog.forEach((brandId, brandData) {
        brandData.phoneSeries.forEach((seriesId, seriesData) {
          seriesData.phones.forEach((phoneId, phoneData) {
            allModels.add(PhoneModelUI(
              id: '${brandId}_${seriesId}_$phoneId',
              brandId: brandId,
              seriesId: seriesId,
              phoneId: phoneId,
              name: phoneData.displayName,
              imageUrl: phoneData.imageUrl,
              launchYear: phoneData.launchYear,
              variantPrices: phoneData.variantPrices,
              variantOptions: phoneData.variantOptions,
              demandScore: phoneData.demandScore,
              questionGroups: phoneData.questionGroups,
            ));
          });
        });
      });
      
      // Filter by search query
      final filteredModels = allModels.where((model) =>
          model.name.toLowerCase().contains(query.toLowerCase()) ||
          _formatBrandName(model.brandId).toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      // Sort by relevance (demand score and launch year)
      filteredModels.sort((a, b) {
        if (a.demandScore != b.demandScore) {
          return b.demandScore.compareTo(a.demandScore);
        }
        return b.launchYear.compareTo(a.launchYear);
      });
      
      return filteredModels;
    } catch (e) {
      print('Error searching phone models: $e');
      return [];
    }
  }

  // Get popular models across all brands
  Future<List<PhoneModelUI>> getPopularModels({int limit = 10}) async {
    try {
      final catalog = await getMobileCatalog();
      List<PhoneModelUI> allModels = [];
      
      catalog.forEach((brandId, brandData) {
        brandData.phoneSeries.forEach((seriesId, seriesData) {
          seriesData.phones.forEach((phoneId, phoneData) {
            allModels.add(PhoneModelUI(
              id: '${brandId}_${seriesId}_$phoneId',
              brandId: brandId,
              seriesId: seriesId,
              phoneId: phoneId,
              name: phoneData.displayName,
              imageUrl: phoneData.imageUrl,
              launchYear: phoneData.launchYear,
              variantPrices: phoneData.variantPrices,
              variantOptions: phoneData.variantOptions,
              demandScore: phoneData.demandScore,
              questionGroups: phoneData.questionGroups,
            ));
          });
        });
      });
      
      // Sort by demand score and launch year
      allModels.sort((a, b) {
        if (a.demandScore != b.demandScore) {
          return b.demandScore.compareTo(a.demandScore);
        }
        return b.launchYear.compareTo(a.launchYear);
      });
      
      return allModels.take(limit).toList();
    } catch (e) {
      print('Error getting popular models: $e');
      return [];
    }
  }

  // Helper methods
  String _formatBrandName(String brandId) {
    switch (brandId.toLowerCase()) {
      case 'apple':
        return 'Apple';
      case 'samsung':
        return 'Samsung';
      case 'oneplus':
        return 'OnePlus';
      case 'xiaomi':
        return 'Xiaomi';
      case 'google':
        return 'Google';
      case 'oppo':
        return 'OPPO';
      case 'vivo':
        return 'Vivo';
      case 'realme':
        return 'Realme';
      case 'huawei':
        return 'Huawei';
      case 'motorola':
        return 'Motorola';
      default:
        return brandId.split('_').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
        ).join(' ');
    }
  }

  int _getTotalModelsCount(PhoneBrandData brandData) {
    int count = 0;
    brandData.phoneSeries.forEach((seriesId, seriesData) {
      count += seriesData.phones.length;
    });
    return count;
  }
  
  @Deprecated('Use getMobileCatalog() instead')
  Future<List<SellPhone>> getSellPhones() async {
    try {
      final catalog = await getMobileCatalog();
      return _convertCatalogToSellPhones(catalog);
    } catch (e) {
      throw Exception('Failed to load sell phones: $e');
    }
  }
  
  // Convert new catalog format to legacy SellPhone format for backward compatibility
  List<SellPhone> _convertCatalogToSellPhones(Map<String, dynamic> catalog) {
    List<SellPhone> phones = [];
    
    if (catalog['brands'] != null) {
      Map<String, dynamic> brands = catalog['brands'];
      
      brands.forEach((brandName, brandData) {
        if (brandData['phone_series'] != null) {
          Map<String, dynamic> phoneSeries = brandData['phone_series'];
          
          phoneSeries.forEach((seriesName, seriesData) {
            if (seriesData['phones'] != null) {
              Map<String, dynamic> phoneModels = seriesData['phones'];
              
              phoneModels.forEach((modelName, modelData) {
                try {
                  // Convert variant_prices to the expected format
                  Map<String, Map<String, int>> variantPrices = {};
                  if (modelData['variant_prices'] != null) {
                    Map<String, dynamic> variants = modelData['variant_prices'];
                    variants.forEach((storage, ramPrices) {
                      variantPrices[storage] = {};
                      if (ramPrices is Map) {
                        ramPrices.forEach((ram, price) {
                          variantPrices[storage]![ram] = price is int ? price : int.tryParse(price.toString()) ?? 0;
                        });
                      }
                    });
                  }
                  
                  final phone = SellPhone(
                    id: '${brandName}_${seriesName}_$modelName',
                    brand: brandName,
                    name: '${seriesData['display_name'] ?? seriesName} - $modelName',
                    description: 'Launch Year: ${modelData['launch_year'] ?? 'Unknown'}',
                    image: brandData['logo_url'] ?? '',
                    variantPrices: variantPrices,
                  );
                  
                  phones.add(phone);
                } catch (e) {
                  print('Error converting phone $brandName $seriesName $modelName: $e');
                }
              });
            }
          });
        }
      });
    }
    
    return phones;  }
  
  // Helper method to get auth headers with token (similar to OrderService)
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      // Debug the token
      if (token != null && token.isNotEmpty) {
        debugPrint('Auth Token: ${token.substring(0, min(10, token.length))}...');
      } else {
        debugPrint('No token found in SharedPreferences');
      }
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }
      
      // The backend explicitly requires the "Bearer " prefix
      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': formattedToken,
      };
      
      debugPrint('Request Headers: $headers');
      return headers;
    } catch (e) {
      debugPrint('Failed to get authentication token: $e');
      throw Exception('Failed to get authentication token: $e');
    }
  }
  // Helper method to get the minimum of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }
    // Submit an inquiry for a sell mobile listing
  Future<Map<String, dynamic>> submitInquiry({
    required String sellMobileId,
    required String userId,
    required String buyerPhone,
    required String selectedVariant,
    required String selectedCondition,
    required Map<String, dynamic> address,
    String? status,
  }) async {
    try {
      // Get auth headers
      final headers = await _getAuthHeaders();
      // Debug the mobile ID
      debugPrint('Submitting inquiry for mobile ID: $sellMobileId');
      
      // Create request body - match exact field names from backend
      final requestBody = {
        'sell_mobile_id': sellMobileId,
        'user_id': userId,
        'buyer_phone': buyerPhone,
        'selected_variant': selectedVariant,
        'selected_condition': selectedCondition,
        'address': address,
      };
      
      // Add status if provided - ensure it's a valid status
      if (status != null) {
        // Validate status against backend's valid options
        final validStatuses = ['pending', 'accepted', 'completed', 'rejected'];
        if (!validStatuses.contains(status)) {
          throw Exception('Invalid status. Valid options: $validStatuses');
        }
        requestBody['status'] = status;
      }
        // Use the consistent endpoint from constants
      final apiEndpoint = submitInquiryUrl;
      debugPrint('Submitting sell phone inquiry:');
      debugPrint('URL: $apiEndpoint');
      debugPrint('Request body: ${json.encode(requestBody)}');
      
      // Send the request
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: headers,
        body: json.encode(requestBody),
      );
      
      // Log response details
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      // Parse response - look for exact fields returned by backend
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': data['status'] ?? 'success',
          'message': data['message'] ?? 'Inquiry submitted successfully',
          'id': data['id'] ?? '',
        };
      } else if (response.statusCode == 404) {
        // Special handling for 404 errors
        throw Exception('Mobile listing not found. Please try a different model.');
      } else {
        final errorMsg = data['message'] ?? 'Failed to submit inquiry';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error submitting inquiry: $e');
      rethrow;
    }  }
    // Submit an inquiry for a sell mobile listing with questionnaire answers
  Future<Map<String, dynamic>> submitInquiryWithAnswers({
    required String phoneModelId,
    required String userId,
    required String buyerPhone,
    required String selectedStorage,
    required String selectedRam,
    required Map<String, List<String>> questionnaireAnswers,
    required Map<String, dynamic> address,
    String? status,
  }) async {
    try {
      // Get auth headers
      final headers = await _getAuthHeaders();
      debugPrint('Submitting inquiry with answers for phone: $phoneModelId');
      
      // Create request body - match backend expected field names
      final requestBody = {
        'phone_model_id': phoneModelId, // Changed from sell_mobile_id to phone_model_id
        'user_id': userId,
        'buyer_phone': buyerPhone,
        'selected_storage': selectedStorage,
        'selected_ram': selectedRam,
        'questionnaire_answers': questionnaireAnswers,
        'address': address, // Address as Map<String, dynamic> to match expected format
      };
      
      if (status != null) {
        requestBody['status'] = status;
      }
      
      debugPrint('Submitting inquiry with answers:');
      debugPrint('URL: $submitInquiryUrl');
      debugPrint('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(submitInquiryUrl),
        headers: headers,
        body: json.encode(requestBody),
      );
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': data['status'] ?? 'success',
          'message': data['message'] ?? 'Inquiry submitted successfully',
          'id': data['id'] ?? '',
          'estimated_price': data['estimated_price'] ?? 0,
        };
      } else {
        final errorMsg = data['message'] ?? 'Failed to submit inquiry';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error submitting inquiry with answers: $e');
      rethrow;
    }
  }
  // Fetch all inquiries made by the current user
  Future<List<SellPhoneInquiry>> getUserInquiries() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(userInquiriesUrl),
        headers: headers,
      );
      
      debugPrint('Fetching user inquiries response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Handle the actual API response format which uses 'inquiries' field
        if (data['inquiries'] != null && data['inquiries'] is List) {
          final List<dynamic> inquiriesJson = data['inquiries'];
          return inquiriesJson.map((json) => SellPhoneInquiry.fromJson(json)).toList();
        } else if (data['status'] == 'success' && data['data'] != null) {
          // Keep original format as fallback
          final List<dynamic> inquiriesJson = data['data'];
          return inquiriesJson.map((json) => SellPhoneInquiry.fromJson(json)).toList();
        } else {
          debugPrint('API returned unexpected format: $data');
          throw Exception('Unexpected API response format');
        }
      } else {
        // Try to extract error message from response
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          debugPrint('Failed to parse error response: $e');
        }
        
        final errorMsg = errorData['message'] ?? 'Server error ${response.statusCode}';
        debugPrint('Error fetching inquiries: $errorMsg');
        throw Exception('Error fetching inquiries: $errorMsg');
      }
    } catch (e) {
      debugPrint('Failed to load user inquiries: $e');
      throw Exception('Failed to load user inquiries: $e');
    }
  }

  // Get specific brand data by ID
  Future<PhoneBrandData?> getBrandData(String brandId) async {
    try {
      final catalog = await getMobileCatalog();
      return catalog[brandId];
    } catch (e) {
      print('Error getting brand data for $brandId: $e');
      return null;
    }
  }
}

class SellPhone {
  final String id;
  final String brand;
  final String name;
  final String description;
  final String image;
  final Map<String, Map<String, int>> variantPrices;

  SellPhone({
    required this.id,
    required this.brand,
    required this.name,
    this.description = '',
    this.image = '',
    required this.variantPrices,
  });  factory SellPhone.fromJson(Map<String, dynamic> json) {
      
    // Parse variant_prices map
    Map<String, Map<String, int>> variantPrices = {};
    
    // Handle different variant price formats that the API might return
    if (json['variant_prices'] != null) {
      try {
        Map<String, dynamic> variants = json['variant_prices'];
        variants.forEach((storage, conditions) {
          try {
            Map<String, dynamic> conditionsMap = conditions as Map<String, dynamic>;
            variantPrices[storage] = {};
            conditionsMap.forEach((condition, price) {
              try {
                // Handle different price formats (int, double, or string)
                if (price is int) {
                  variantPrices[storage]![condition] = price;
                } else if (price is double) {
                  variantPrices[storage]![condition] = price.toInt();
                } else if (price is String) {
                  variantPrices[storage]![condition] = int.tryParse(price) ?? 0;
                } else {
                  variantPrices[storage]![condition] = 0;
                }
              } catch (e) {
                print('Error parsing price for $storage/$condition: $e');
                variantPrices[storage]![condition] = 0;
              }
            });
          } catch (e) {
            print('Error parsing conditions for $storage: $e');
          }
        });
      } catch (e) {
        print('Error parsing variant_prices: $e');
      }
    } else if (json['prices'] != null) {
      // Fallback for alternative API format
      try {
        Map<String, dynamic> pricesMap = json['prices'];
        // Assuming a flat structure, create a single storage option
        variantPrices['Default'] = {};
        pricesMap.forEach((condition, price) {
          variantPrices['Default']![condition] = price is int ? price : int.tryParse(price.toString()) ?? 0;
        });
      } catch (e) {
        print('Error parsing prices: $e');
      }
    }
      // Ensure we have at least one storage/condition option if nothing was parsed
    if (variantPrices.isEmpty) {
      variantPrices = {
        'Default': {
          'Good': 0
        }
      };
    }
    
    // Get ID from various possible fields
    String id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['_id'] != null) {
      id = json['_id'].toString();
    } else {
      // Generate a unique ID if none exists
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    final phone = SellPhone(
      id: id,
      brand: json['brand'] ?? json['manufacturer'] ?? '',
      name: json['name'] ?? json['model'] ?? json['title'] ?? '', // Support multiple possible keys
      image: json['image'] ?? json['img_url'] ?? json['thumbnail'] ?? '',
      description: json['description'] ?? json['details'] ?? '',
      variantPrices: variantPrices,
    );
    
    return phone;
  }
}

class SellPhoneReview {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final int helpfulCount;

  SellPhoneReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.helpfulCount = 0,
  });

  factory SellPhoneReview.fromJson(Map<String, dynamic> json) {
    return SellPhoneReview(
      id: json['id'].toString(),
      userName: json['user_name'] ?? '',
      rating: (json['rating'] is int) ? (json['rating'] as int).toDouble() : (json['rating'] ?? 0.0),
      comment: json['comment'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      helpfulCount: json['helpful_count'] ?? 0,
    );
  }
}

// Model class for sell phone inquiries
class SellPhoneInquiry {
  final String id;
  final String sellMobileId;
  final String userId;
  final String buyerPhone;
  final String selectedVariant;
  final String selectedCondition;
  final Map<String, dynamic> address;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final SellPhone? phoneDetails;
  final int? price; // Add price field

  SellPhoneInquiry({
    required this.id,
    required this.sellMobileId,
    required this.userId,
    required this.buyerPhone,
    required this.selectedVariant,
    required this.selectedCondition,
    required this.address,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.phoneDetails,
    this.price, // Include price in constructor
  });

  factory SellPhoneInquiry.fromJson(Map<String, dynamic> json) {
    // Parse address which might be a string or a map
    Map<String, dynamic> addressMap = {};
    if (json['address'] is String) {
      try {
        addressMap = Map<String, dynamic>.from(jsonDecode(json['address']));
      } catch (e) {
        debugPrint('Failed to parse address string: $e');
      }
    } else if (json['address'] is Map) {
      addressMap = Map<String, dynamic>.from(json['address']);
    }

    // Create phone details object if available
    SellPhone? phoneDetails;
    if (json['phone_details'] != null) {
      try {
        phoneDetails = SellPhone.fromJson(json['phone_details']);
      } catch (e) {
        debugPrint('Failed to parse phone details: $e');
      }
    }

    // Handle both 'id' and 'inquiry_id' field names
    String id = '';
    if (json['inquiry_id'] != null) {
      id = json['inquiry_id'].toString();
    } else if (json['id'] != null) {
      id = json['id'].toString();
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Parse price field with fallback
    int? price;
    if (json['price'] != null) {
      if (json['price'] is int) {
        price = json['price'];
      } else if (json['price'] is double) {
        price = json['price'].toInt();
      } else if (json['price'] is String) {
        price = int.tryParse(json['price']);
      }
    }

    return SellPhoneInquiry(
      id: id,
      sellMobileId: json['sell_mobile_id'] ?? '',
      userId: json['user_id'] ?? '',
      buyerPhone: json['buyer_phone'] ?? '',
      selectedVariant: json['selected_variant'] ?? '',
      selectedCondition: json['selected_condition'] ?? '',
      address: addressMap,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? json['timestamp'],
      updatedAt: json['updated_at'],
      phoneDetails: phoneDetails,
      price: price, // Include parsed price
    );
  }
}