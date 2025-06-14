import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

// --- Helper Functions for Safe Parsing (copied from detailed_product.dart or define globally) ---
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
    if (value.isFinite && value == value.truncateToDouble()) { // Check if it's a whole number
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

class ProductService {
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/products/products/'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final double discountPrice;
  final String? discount;
  final int stock;
  final double rating;
  final int reviews;
  final List<String> images;
  final List<String> features;
  final Map<String, dynamic> specifications;
  final Map<String, List<String>> variant;
  final bool? featured;

  Product({
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
    required this.variant,
    this.featured,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _parseDouble(json['price']), // Updated
      discountPrice: _parseDouble(json['discount_price']), // Updated
      discount: json['discount'] as String?,
      stock: _parseInt(json['stock']), // Updated
      rating: _parseDouble(json['rating']), // Updated
      reviews: _parseInt(json['reviews']), // Updated
      images: List<String>.from(json['images'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      variant: (json['variant'] is Map)
          ? Map<String, List<String>>.from(
              (json['variant'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value is List) ? List<String>.from(value.map((e) => e.toString())) : <String>[],
                ),
              ),
            )
          : {},
      featured: json['featured'] as bool?,
    );
  }
}

class Review {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;
  final int helpfulCount;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    this.helpfulCount = 0,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '', // Added null check and default
      userName: json['user_name'] as String? ?? 'Anonymous', // Added null check and default
      rating: _parseDouble(json['rating']), // Updated
      comment: json['comment'] as String? ?? '', // Added null check and default
      date: (json['date'] is String) ? DateTime.tryParse(json['date']) ?? DateTime.now() : DateTime.now(), // Safer date parsing
      helpfulCount: _parseInt(json['helpful_count'], defaultValue: 0), // Updated and ensured default
    );
  }
}
