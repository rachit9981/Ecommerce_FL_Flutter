import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class CategoriesService {
  static const String _cacheKey = 'cached_categories';
  static const String _cacheTimeKey = 'categories_cache_time';
  static const Duration _cacheValidDuration = Duration(hours: 1); // Cache for 1 hour
  
  // Get all categories from the API with caching
  Future<List<Category>> getCategories() async {
    try {
      // Check if we have cached data that's still valid
      final cachedCategories = await _getCachedCategories();
      if (cachedCategories != null) {
        debugPrint('Using cached categories data');
        return cachedCategories;
      }
      
      // Fetch from API
      final response = await http.get(
        Uri.parse('$apiUrl/products/categories/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      debugPrint('Categories API Response status: ${response.statusCode}');
      debugPrint('Categories API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> categoriesJson = data['categories'];
        
        List<Category> categories = categoriesJson
            .map((json) => Category.fromJson(json))
            .toList();
        
        // Sort categories by order field
        categories.sort((a, b) => a.order.compareTo(b.order));
        
        // Cache the categories
        await _cacheCategories(categories);
        
        return categories;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load categories');
      }
    } catch (e) {
      debugPrint('Failed to load categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
  
  // Get cached categories if they exist and are still valid
  Future<List<Category>?> _getCachedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final cacheTimeString = prefs.getString(_cacheTimeKey);
      
      if (cachedData != null && cacheTimeString != null) {
        final cacheTime = DateTime.parse(cacheTimeString);
        final now = DateTime.now();
        
        // Check if cache is still valid
        if (now.difference(cacheTime) < _cacheValidDuration) {
          final List<dynamic> categoriesJson = json.decode(cachedData);
          return categoriesJson.map((json) => Category.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error reading cached categories: $e');
    }
    
    return null;
  }
  
  // Cache categories data
  Future<void> _cacheCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories.map((cat) => cat.toJson()).toList();
      
      await prefs.setString(_cacheKey, json.encode(categoriesJson));
      await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());
      
      debugPrint('Categories cached successfully');
    } catch (e) {
      debugPrint('Error caching categories: $e');
    }
  }
  
  // Clear cached categories
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
      debugPrint('Categories cache cleared');
    } catch (e) {
      debugPrint('Error clearing categories cache: $e');
    }
  }
}

// Category model
class Category {
  final String id;
  final String name;
  final String? imageUrl;
  final String? redirectUrl;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.redirectUrl,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      redirectUrl: json['redirect_url'],
      order: json['order'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'redirect_url': redirectUrl,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}