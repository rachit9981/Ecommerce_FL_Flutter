import 'dart:convert';
import 'package:http/http.dart' as http;
import './config.dart'; // Assuming config.dart is in the same directory (lib/services/)
import './products.dart'; // For Review class, assuming products.dart is in lib/services/

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is int) return value.toDouble();
  if (value is double) return value.isFinite ? value : defaultValue;
  if (value is String) {
    final parsed = double.tryParse(value);
    return (parsed != null && parsed.isFinite) ? parsed : defaultValue;
  }
  return defaultValue;
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) {
    if (value.isFinite && value == value.truncateToDouble()) {
      return value.toInt();
    }
    return defaultValue;
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed ?? defaultValue;
  }
  return defaultValue;
}

// --- Data Models ---

class ValidOption {
  final String id;
  final int stock;
  final double discountedPrice;
  final double price;
  // Stores other dynamic attributes like ram, storage, color, size, and custom ones
  final Map<String, String> attributes;

  ValidOption({
    required this.id,
    required this.stock,
    required this.discountedPrice,
    required this.price,
    required this.attributes,
  });

  factory ValidOption.fromJson(Map<String, dynamic> json) {
    Map<String, String> attrs = {};
    json.forEach((key, value) {
      if (key != 'id' &&
          key != 'stock' &&
          key != 'discounted_price' &&
          key != 'price') {
        final k = key.toString(); // Corrected: key is non-null in forEach from Map
        attrs[k] = value?.toString() ?? '';
      }
    });
    return ValidOption(
      id: json['id']?.toString() ?? '', // Ensure id is string and not null
      stock: _parseInt(json['stock']),
      discountedPrice: _parseDouble(json['discounted_price']),
      price: _parseDouble(json['price']),
      attributes: attrs,
    );
  }
}

class DetailedProduct {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price; // Base price from product object
  final double discountPrice; // Base discount_price from product object
  final String? discount;
  final int stock; // Base stock from product object
  final double rating;
  final List<Review> reviews; // List of Review objects
  final List<String> images;
  final List<String> features;
  final Map<String, dynamic> specifications;
  final bool? featured;
  final List<String> videos;
  final Map<String, dynamic> productLevelAttributes; // "attributes" field in JSON product object
  final int totalReviews;
  final List<ValidOption> validOptions;
  final Map<String, List<String>> variants; // Reconstructed variants

  DetailedProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.discountPrice,
    this.discount,
    required this.stock,
    required this.rating,
    required this.reviews,
    required this.images,
    required this.features,
    required this.specifications,
    this.featured,
    required this.videos,
    required this.productLevelAttributes,
    required this.totalReviews,
    required this.validOptions,
    required this.variants,
  });

  factory DetailedProduct.fromJson(Map<String, dynamic> jsonProduct) {
    List<ValidOption> options = [];
    if (jsonProduct['valid_options'] != null && jsonProduct['valid_options'] is List) {
        options = (jsonProduct['valid_options'] as List<dynamic>)
            .where((optJson) => optJson is Map<String, dynamic>) // Ensure item is a map
            .map((optJson) => ValidOption.fromJson(optJson as Map<String, dynamic>))
            .toList();
    } else if (jsonProduct['valid_options'] != null) {
        print("Warning: 'valid_options' was not a List, received: \${jsonProduct['valid_options'].runtimeType}");
    }


    Map<String, Set<String>> tempVariantsCollector = {};
    for (var option in options) { // options is now safely an empty list or list of ValidOption
      option.attributes.forEach((key, value) { // key and value in attributes are already strings from ValidOption.fromJson
        if (!tempVariantsCollector.containsKey(key)) {
          tempVariantsCollector[key] = <String>{};
        }
        tempVariantsCollector[key]!.add(value);
      });
    }

    Map<String, List<String>> finalVariants = {};
    tempVariantsCollector.forEach((key, valueSet) {
      finalVariants[key] = valueSet.toList();
    });
    
    List<Review> parsedReviews = [];
    if (jsonProduct['reviews'] != null && jsonProduct['reviews'] is List) {
        parsedReviews = (jsonProduct['reviews'] as List<dynamic>)
            .where((revJson) => revJson is Map<String, dynamic>) // Ensure item is a map
            .map((revJson) => Review.fromJson(revJson as Map<String, dynamic>)) // Assumes Review.fromJson is also safe
            .toList();
    } else if (jsonProduct['reviews'] != null) {
        print("Warning: 'reviews' was not a List, received: \${jsonProduct['reviews'].runtimeType}");
    }

    return DetailedProduct(
      id: jsonProduct['id']?.toString() ?? '',
      name: jsonProduct['name']?.toString() ?? '',
      brand: jsonProduct['brand']?.toString() ?? '',
      category: jsonProduct['category']?.toString() ?? '',
      description: jsonProduct['description']?.toString() ?? '',
      price: _parseDouble(jsonProduct['price']),
      discountPrice: _parseDouble(jsonProduct['discount_price']),
      discount: jsonProduct['discount']?.toString(), // Handles null by becoming null
      stock: _parseInt(jsonProduct['stock']),
      rating: _parseDouble(jsonProduct['rating']),
      reviews: parsedReviews, // Safely an empty list or list of Review
      images: (jsonProduct['images'] is List) 
          ? (jsonProduct['images'] as List<dynamic>).map((e) => e?.toString() ?? '').toList() 
          : <String>[],
      features: (jsonProduct['features'] is List) 
          ? (jsonProduct['features'] as List<dynamic>).map((e) => e?.toString() ?? '').toList() 
          : <String>[],
      specifications: (jsonProduct['specifications'] is Map) 
          ? Map<String, dynamic>.from(jsonProduct['specifications'] as Map<String, dynamic>) 
          : <String, dynamic>{}, // Default to empty map
      featured: jsonProduct['featured'] as bool?, // bool? handles null, true, false correctly
      videos: (jsonProduct['videos'] is List) 
          ? (jsonProduct['videos'] as List<dynamic>).map((e) => e?.toString() ?? '').toList() 
          : <String>[],
      productLevelAttributes: (jsonProduct['attributes'] is Map) 
          ? Map<String, dynamic>.from(jsonProduct['attributes'] as Map<String, dynamic>) 
          : <String, dynamic>{}, // Default to empty map
      totalReviews: _parseInt(jsonProduct['total_reviews']),
      validOptions: options, // Safely an empty list or list of ValidOption
      variants: finalVariants,
    );
  }
}

// --- Service Class ---

class DetailedProductService {
  Future<DetailedProduct> getDetailedProduct(String productId) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/products/products/$productId/'));
      
      if (response.statusCode == 200) {
        // The response is expected to be {"product": {...}}
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('product') && responseData['product'] is Map<String, dynamic>) {
          final Map<String, dynamic> productJson = responseData['product'] as Map<String, dynamic>;
          return DetailedProduct.fromJson(productJson);
        } else {
          throw Exception('Failed to load detailed product: "product" key not found or is not a map. Body: ${response.body}');
        }
      } else {
        throw Exception('Failed to load detailed product: Status Code ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      // It's good practice to log the error or handle it more gracefully
      print('Error fetching detailed product for ID $productId: $e');
      // Re-throw the exception to allow calling code to handle it
      throw Exception('Failed to load detailed product: $e');
    }
  }
}
