import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// Main API URL from config
const String sellPhoneApiUrl = '$apiUrl/sell-mobile/catalog/';

class SellPhoneService {
  Future<List<SellPhone>> getSellPhones() async {
    // Try primary API endpoint first
    try {
      final response = await http.get(Uri.parse(sellPhoneApiUrl));

      if (response.statusCode == 200) {
        return _parsePhoneResponse(response);
      } else {
        print('API Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception with API: $e');
      throw Exception('Failed to load sell phones: $e');
    }
  }
  
  List<SellPhone> _parsePhoneResponse(http.Response response) {
    try {
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Try various possible response structures
      List<dynamic> phonesJson = [];
      
      if (data['phones'] != null && data['phones'] is List) {
        phonesJson = data['phones'];
      } else if (data['results'] != null && data['results'] is List) {
        phonesJson = data['results']; 
      } else if (data['catalog'] != null && data['catalog'] is List) {
        phonesJson = data['catalog'];
      } else if (data['data'] != null && data['data'] is List) {
        phonesJson = data['data'];
      } else {
        // As a last resort, try to see if the response itself is a list
        if (response.body.startsWith('[') && response.body.endsWith(']')) {
          phonesJson = json.decode(response.body);
        }
      }
      if (phonesJson.isEmpty && data.isNotEmpty) {
        try {
          final dummyPhone = SellPhone.fromJson(data);
          return [dummyPhone];
        } catch (e) {
          print('Could not create phone from direct data: $e');
        }
      }
      
      final result = phonesJson.map((json) => SellPhone.fromJson(json)).toList();
      print('Converted ${result.length} SellPhone objects');
      return result;
    } catch (e) {
      print('Error parsing phone response: $e');
      throw Exception('Failed to parse sell phones response: $e');
    }
  }
  
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
    required Map<String, String> address,
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
      
      // Ensure endpoint is correct - check documentation for exact path
      final apiEndpoint = '$apiUrl/sell-mobile/submit_inquiry/';
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
    }
  }
  
  // Fetch all inquiries made by the current user
  Future<List<SellPhoneInquiry>> getUserInquiries() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/sell-mobile/user_inquires/'),
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