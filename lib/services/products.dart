import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

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
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      category: json['category'],
      description: json['description'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'],
      discountPrice: (json['discount_price'] is int) ? (json['discount_price'] as int).toDouble() : json['discount_price'],
      discount: json['discount'],
      stock: json['stock'],
      rating: (json['rating'] is int) ? (json['rating'] as int).toDouble() : json['rating'],
      reviews: json['reviews'],
      images: List<String>.from(json['images']),
      features: List<String>.from(json['features']),
      specifications: json['specifications'],
      variant: Map<String, List<String>>.from(
        json['variant'].map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      featured: json['featured'],
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
      id: json['id'],
      userName: json['user_name'],
      rating: (json['rating'] is int) ? (json['rating'] as int).toDouble() : json['rating'],
      comment: json['comment'],
      date: DateTime.parse(json['date']),
      helpfulCount: json['helpful_count'] ?? 0,
    );
  }
}
