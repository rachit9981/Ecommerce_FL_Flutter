import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class CartWishlistService {
  // Helper method to get auth headers with token
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }
      
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      throw Exception('Failed to get authentication token: $e');
    }
  }  // Cart API calls
  Future<Map<String, dynamic>> addToCart(String productId, {int quantity = 1, String? variantId}) async {
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{'quantity': quantity};
      if (variantId != null) {
        body['variant_id'] = variantId;
      }
      
      final response = await http.post(
        Uri.parse('$apiUrl/users/cart/add/$productId/'),
        headers: headers,
        body: json.encode(body),
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
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/users/cart/'),
        headers: headers
      );
      
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
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiUrl/users/cart/remove/$itemId/'),
        headers: headers
      );
      
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

  Future<Map<String, dynamic>> updateCartQuantity(String itemId, int quantity) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$apiUrl/users/cart/update/$itemId/'),
        headers: headers,
        body: json.encode({'quantity': quantity}),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to update cart quantity');
      }
    } catch (e) {
      throw Exception('Failed to update cart quantity: $e');
    }
  }

  Future<Map<String, dynamic>> clearCart() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiUrl/users/cart/clear/'),
        headers: headers
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Wishlist API calls
  Future<Map<String, dynamic>> addToWishlist(String productId, {String? variantId}) async {
    try {
      final headers = await _getAuthHeaders();
      final body = <String, dynamic>{};
      if (variantId != null) {
        body['variant_id'] = variantId;
      }
      
      final response = await http.post(
        Uri.parse('$apiUrl/users/wishlist/add/$productId/'),
        headers: headers,
        body: json.encode(body),
      );
      
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
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/users/wishlist/'),
        headers: headers
      );
      
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
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiUrl/users/wishlist/remove/$itemId/'),
        headers: headers
      );
      
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

  // Helper methods for getting counts
  Future<int> getCartItemCount() async {
    try {
      final cartItems = await getCart();
      return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      return 0;
    }
  }

  Future<int> getWishlistItemCount() async {
    try {
      final wishlistItems = await getWishlist();
      return wishlistItems.length;
    } catch (e) {
      return 0;
    }
  }

  // Helper method to check if product is in cart
  Future<bool> isInCart(String productId, {String? variantId}) async {
    try {
      final cartItems = await getCart();
      return cartItems.any((item) => 
        item.productId == productId && 
        (variantId == null || item.variantId == variantId)
      );
    } catch (e) {
      return false;
    }
  }

  // Helper method to check if product is in wishlist
  Future<bool> isInWishlist(String productId, {String? variantId}) async {
    try {
      final wishlistItems = await getWishlist();
      return wishlistItems.any((item) => 
        item.productId == productId && 
        (variantId == null || item.variantId == variantId)
      );
    } catch (e) {
      return false;
    }
  }
}

class CartItem {
  final String itemId;
  final String productId;
  final String? variantId;
  final String name;
  final double? price;
  final String? imageUrl;
  final String? image;
  final int quantity;
  final int? stock;
  final String? category;
  final String? brand;
  final Map<String, dynamic>? variant;
  final DateTime? addedAt;
  final String? error;

  CartItem({
    required this.itemId,
    required this.productId,
    this.variantId,
    required this.name,
    this.price,
    this.imageUrl,
    this.image,
    required this.quantity,
    this.stock,
    this.category,
    this.brand,
    this.variant,
    this.addedAt,
    this.error,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      itemId: json['item_id'] ?? '',
      productId: json['product_id'] ?? '',
      variantId: json['variant_id'],
      name: json['name'] ?? 'Unknown Product',
      price: json['price'] != null
          ? (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price']
          : null,
      imageUrl: json['image_url'],
      image: json['image'],
      quantity: json['quantity'] ?? 1,
      stock: json['stock'],
      category: json['category'],
      brand: json['brand'],
      variant: json['variant'] != null ? Map<String, dynamic>.from(json['variant']) : null,
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
      error: json['error'],
    );
  }
}

class WishlistItem {
  final String itemId;
  final String productId;
  final String? variantId;
  final String name;
  final double? price;
  final String? imageUrl;
  final String? image;
  final int? stock;
  final String? category;
  final String? brand;
  final Map<String, dynamic>? variant;
  final DateTime? addedAt;
  final String? error;

  WishlistItem({
    required this.itemId,
    required this.productId,
    this.variantId,
    required this.name,
    this.price,
    this.imageUrl,
    this.image,
    this.stock,
    this.category,
    this.brand,
    this.variant,
    this.addedAt,
    this.error,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      itemId: json['item_id'] ?? '',
      productId: json['product_id'] ?? '',
      variantId: json['variant_id'],
      name: json['name'] ?? 'Unknown Product',
      price: json['price'] != null
          ? (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price']
          : null,
      imageUrl: json['image_url'],
      image: json['image'],
      stock: json['stock'],
      category: json['category'],
      brand: json['brand'],
      variant: json['variant'] != null ? Map<String, dynamic>.from(json['variant']) : null,
      addedAt: json['added_at'] != null ? DateTime.parse(json['added_at']) : null,
      error: json['error'],
    );
  }
}
