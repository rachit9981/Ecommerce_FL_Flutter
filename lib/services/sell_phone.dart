import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

// Main API URL from config
const String sellPhoneApiUrl = '$apiUrl/sell-mobile/catalog/';

// Fallback API URL (mockable endpoint with sample data)
const String fallbackSellPhoneApiUrl = 'https://run.mocky.io/v3/3a964087-f5b2-4f2e-af14-7550afc8f1d8';

class SellPhoneService {  Future<List<SellPhone>> getSellPhones() async {
    // Try primary API endpoint first
    try {
      print('Fetching phones from primary API: $sellPhoneApiUrl');
      final response = await http.get(Uri.parse(sellPhoneApiUrl));
      print('Primary API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parsePhoneResponse(response);
      } else {
        print('Primary API Error: ${response.statusCode}, Body: ${response.body}');
        // Will try fallback API next
      }
    } catch (e) {
      print('Exception with primary API: $e');
      // Will try fallback API next
    }
    
    // If primary API fails, try fallback API
    try {
      print('Trying fallback API: $fallbackSellPhoneApiUrl');
      final response = await http.get(Uri.parse(fallbackSellPhoneApiUrl));
      print('Fallback API Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return _parsePhoneResponse(response);
      } else {
        print('Fallback API Error: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load from both primary and fallback APIs');
      }
    } catch (e) {
      print('Exception with fallback API: $e');
      throw Exception('Failed to load sell phones from all sources: $e');
    }
  }
  
  List<SellPhone> _parsePhoneResponse(http.Response response) {
    try {
      print('API Response body: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
      
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
      
      print('Found ${phonesJson.length} phones in response');
      
      // If we still have no phones but have something else in the response,
      // try to create at least one phone from the response data
      if (phonesJson.isEmpty && data.isNotEmpty) {
        print('No phone list found, trying to use response data directly');
        // Create a single phone from the response if possible
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
    print('Parsing SellPhone: ${json.keys.join(', ')}');
      
    // Parse variant_prices map
    Map<String, Map<String, int>> variantPrices = {};
    
    // Handle different variant price formats that the API might return
    if (json['variant_prices'] != null) {
      print('Found variant_prices in JSON');
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
      print('Found prices in JSON instead of variant_prices');
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
      print('No variant prices found, creating a default entry');
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
    
    print('Created SellPhone: ${phone.name}, ${phone.brand}, ${phone.variantPrices.keys.length} storage options');
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