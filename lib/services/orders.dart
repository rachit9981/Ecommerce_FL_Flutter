import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class OrderService {
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
  }

  // Create a Razorpay order
  Future<Map<String, dynamic>> createRazorpayOrder({
    required int amount,
    required List<String> productIds,
    required String addressId,
    String currency = 'INR',
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Print request details for debugging
      print('Creating Razorpay order with:');
      print('Amount: $amount');
      print('Products: $productIds');
      print('Address ID: $addressId');
      
      final response = await http.post(
        Uri.parse('$apiUrl/api/users/order/razorpay/create/'), // Updated endpoint path
        headers: headers,
        body: json.encode({
          'amount': amount,
          'product_ids': productIds,
          'address_id': addressId,
          'currency': currency,
        }),
      );
      
      // Print response for debugging
      print('Razorpay order creation response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      print('Order creation error: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  // Verify Razorpay payment
  Future<Map<String, dynamic>> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String orderId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiUrl/users/order/razorpay/verify/'),
        headers: headers,
        body: json.encode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'order_id': orderId,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to verify payment');
      }
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Get all orders for the current user
  Future<List<Order>> getUserOrders() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/users/orders/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> ordersJson = data['orders'];
        
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load orders');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  // Get details for a specific order
  Future<OrderDetail> getOrderDetails(String orderId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/users/orders/$orderId/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OrderDetail.fromJson(data['order_details']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load order details');
      }
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }
}

// Order summary model for order list
class Order {
  final String orderId;
  final String status;
  final double totalAmount;
  final String currency;
  final String? createdAt;
  final int itemCount;
  final String? previewImage;
  final TrackingInfo? trackingInfo;
  final String? estimatedDelivery;

  Order({
    required this.orderId,
    required this.status,
    required this.totalAmount,
    this.currency = 'INR',
    this.createdAt,
    required this.itemCount,
    this.previewImage,
    this.trackingInfo,
    this.estimatedDelivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      status: json['status'],
      totalAmount: json['total_amount'] is int 
          ? (json['total_amount'] as int).toDouble() 
          : json['total_amount'],
      currency: json['currency'] ?? 'INR',
      createdAt: json['created_at'],
      itemCount: json['item_count'],
      previewImage: json['preview_image'],
      trackingInfo: json['tracking_info'] != null 
          ? TrackingInfo.fromJson(json['tracking_info']) 
          : null,
      estimatedDelivery: json['estimated_delivery'],
    );
  }
}

// Detailed order model
class OrderDetail {
  final String? orderId;
  final String status;
  final double totalAmount;
  final String currency;
  final String? createdAt;
  final String? createdAtFormatted;
  final List<OrderItem> orderItems;
  final Map<String, dynamic>? address;
  final String? addressId;
  final TrackingInfo? trackingInfo;
  final PaymentDetail? paymentDetails;
  final String? estimatedDelivery;
  final String? estimatedDeliveryFormatted;

  OrderDetail({
    this.orderId,
    required this.status,
    required this.totalAmount,
    this.currency = 'INR',
    this.createdAt,
    this.createdAtFormatted,
    required this.orderItems,
    this.address,
    this.addressId,
    this.trackingInfo,
    this.paymentDetails,
    this.estimatedDelivery,
    this.estimatedDeliveryFormatted,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['order_items'] != null) {
      items = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return OrderDetail(
      orderId: json['order_id'],
      status: json['status'],
      totalAmount: json['total_amount'] is int 
          ? (json['total_amount'] as int).toDouble() 
          : json['total_amount'],
      currency: json['currency'] ?? 'INR',
      createdAt: json['created_at'],
      createdAtFormatted: json['created_at_formatted'],
      orderItems: items,
      address: json['address'],
      addressId: json['address_id'],
      trackingInfo: json['tracking_info'] != null 
          ? TrackingInfo.fromJson(json['tracking_info']) 
          : null,
      paymentDetails: json['payment_details'] != null 
          ? PaymentDetail.fromJson(json['payment_details']) 
          : null,
      estimatedDelivery: json['estimated_delivery'],
      estimatedDeliveryFormatted: json['estimated_delivery_formatted'],
    );
  }
}

// Order item model
class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double priceAtPurchase;
  final double totalItemPrice;
  final String? imageUrl;
  final String? brand;
  final String? color;
  final String? model;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.priceAtPurchase,
    required this.totalItemPrice,
    this.imageUrl,
    this.brand,
    this.color,
    this.model,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      name: json['name'],
      quantity: json['quantity'],
      priceAtPurchase: json['price_at_purchase'] is int 
          ? (json['price_at_purchase'] as int).toDouble() 
          : json['price_at_purchase'],
      totalItemPrice: json['total_item_price'] is int 
          ? (json['total_item_price'] as int).toDouble() 
          : json['total_item_price'],
      imageUrl: json['image_url'],
      brand: json['brand'],
      color: json['color'],
      model: json['model'],
    );
  }
}

// Tracking info model
class TrackingInfo {
  final String? carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final List<StatusHistory> statusHistory;

  TrackingInfo({
    this.carrier,
    this.trackingNumber,
    this.trackingUrl,
    required this.statusHistory,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    List<StatusHistory> history = [];
    if (json['status_history'] != null) {
      history = (json['status_history'] as List)
          .map((status) => StatusHistory.fromJson(status))
          .toList();
    }

    return TrackingInfo(
      carrier: json['carrier'],
      trackingNumber: json['tracking_number'],
      trackingUrl: json['tracking_url'],
      statusHistory: history,
    );
  }
}

// Status history model
class StatusHistory {
  final String status;
  final String? timestamp;
  final String? timestampFormatted;
  final String description;

  StatusHistory({
    required this.status,
    this.timestamp,
    this.timestampFormatted,
    required this.description,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'],
      timestamp: json['timestamp'],
      timestampFormatted: json['timestamp_formatted'],
      description: json['description'],
    );
  }
}

// Payment detail model
class PaymentDetail {
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? method;
  final String? status;
  final String? capturedAt;
  final String? capturedAtFormatted;
  final String? cardNetwork;
  final String? cardLast4;
  final String? errorMessage;

  PaymentDetail({
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.method,
    this.status,
    this.capturedAt,
    this.capturedAtFormatted,
    this.cardNetwork,
    this.cardLast4,
    this.errorMessage,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      razorpayPaymentId: json['razorpay_payment_id'],
      razorpaySignature: json['razorpay_signature'],
      method: json['method'],
      status: json['status'],
      capturedAt: json['captured_at'],
      capturedAtFormatted: json['captured_at_formatted'],
      cardNetwork: json['card_network'],
      cardLast4: json['card_last4'],
      errorMessage: json['error_message'],
    );
  }
}
