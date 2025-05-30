import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class CartWishlistService {
  // Cart API calls
  Future<Map<String, dynamic>> addToCart(String productId, {int quantity = 1}) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/cart/add/$productId/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'quantity': quantity}),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to add to cart');
      }
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<List<CartItem>> getCart() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/cart/'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> cartJson = data['cart'];
        
        return cartJson.map((json) => CartItem.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load cart');
      }
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  Future<Map<String, dynamic>> removeFromCart(String itemId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/cart/remove/$itemId/'));
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to remove from cart');
      }
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  // Wishlist API calls
  Future<Map<String, dynamic>> addToWishlist(String productId) async {
    try {
      final response = await http.post(Uri.parse('$apiUrl/wishlist/add/$productId/'));
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to add to wishlist');
      }
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/wishlist/'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> wishlistJson = data['wishlist'];
        
        return wishlistJson.map((json) => WishlistItem.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load wishlist');
      }
    } catch (e) {
      throw Exception('Failed to load wishlist: $e');
    }
  }

  Future<Map<String, dynamic>> removeFromWishlist(String itemId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/wishlist/remove/$itemId/'));
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to remove from wishlist');
      }
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }
}

class CartItem {
  final String itemId;
  final String productId;
  final String name;
  final double? price;
  final String? imageUrl;
  final int quantity;
  final DateTime? addedAt;
  final String? error;

  CartItem({
    required this.itemId,
    required this.productId,
    required this.name,
    this.price,
    this.imageUrl,
    required this.quantity,
    this.addedAt,
    this.error,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['item_id'],
      productId: json['product_id'],
      name: json['name'],
      price: json['price'] != null
          ? (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price']
          : null,
      imageUrl: json['image_url'],
      quantity: json['quantity'],
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
      error: json['error'],
    );
  }
}

class WishlistItem {
  final String itemId;
  final String productId;
  final String name;
  final double? price;
  final String? imageUrl;
  final DateTime? addedAt;
  final String? error;

  WishlistItem({
    required this.itemId,
    required this.productId,
    required this.name,
    this.price,
    this.imageUrl,
    this.addedAt,
    this.error,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      itemId: json['item_id'],
      productId: json['product_id'],
      name: json['name'],
      price: json['price'] != null
          ? (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price']
          : null,
      imageUrl: json['image_url'],
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
      error: json['error'],
    );
  }
}
