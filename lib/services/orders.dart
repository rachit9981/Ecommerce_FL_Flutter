import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class OrderService {
  // Helper method to get auth headers with token
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
  // Create a Razorpay order
  Future<Map<String, dynamic>> createRazorpayOrder({
    required int amount,
    required List<String> productIds,
    required String addressId,
    String currency = 'INR',
    bool isSingleProductOrder = false,
    Map<String, dynamic>? productDetails,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Create request body - amount should be in paise
      final requestBody = {
        'amount': amount, // Amount in paise
        'product_ids': productIds,
        'address_id': addressId,
        'currency': currency,
        'single_product_order': isSingleProductOrder,
        if (productDetails != null) 'product_details': productDetails,
      };
      
      // Log request details
      final apiEndpoint = '$apiUrl/users/order/razorpay/create/';
      debugPrint('Creating Razorpay order with:');
      debugPrint('URL: $apiEndpoint');
      debugPrint('Request body: $requestBody');
      
      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: headers,
        body: json.encode(requestBody),
      );
      
      // Log response details
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        // Try to parse response even for error statuses
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          debugPrint('Failed to parse error response: $e');
        }
        
        final errorMsg = errorData['error'] ?? errorData['message'] ?? 'Server error ${response.statusCode}';
        debugPrint('Error creating order: $errorMsg');
        throw Exception('Error creating order: $errorMsg');
      }
    } catch (e) {
      debugPrint('Failed to create order: $e');
      rethrow;
    }
  }

  // Helper method to get the minimum of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Complete order creation flow
  Future<Map<String, dynamic>> createOrderAndInitiatePayment({
    required double amountInRupees,
    required List<String> productIds,
    required String addressId,
    String currency = 'INR',
    bool isSingleProductOrder = false,
    Map<String, dynamic>? productDetails,
  }) async {
    try {
      // Convert rupees to paise for Razorpay
      final amountInPaise = (amountInRupees * 100).toInt();
      
      debugPrint('Creating order with amount: ₹$amountInRupees ($amountInPaise paise)');
      
      final result = await createRazorpayOrder(
        amount: amountInPaise,
        productIds: productIds,
        addressId: addressId,
        currency: currency,
        isSingleProductOrder: isSingleProductOrder,
        productDetails: productDetails,
      );
      
      return result;
    } catch (e) {
      debugPrint('Error in complete order flow: $e');
      rethrow;
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
      
      debugPrint('Verifying payment with:');
      debugPrint('Razorpay Order ID: $razorpayOrderId');
      debugPrint('Razorpay Payment ID: $razorpayPaymentId');
      debugPrint('App Order ID: $orderId');
      
      final response = await http.post(
        Uri.parse('$apiUrl/users/order/razorpay/verify/'),
        headers: headers,
        body: json.encode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
          'order_id': orderId, // App order ID
        }),
      );
      
      debugPrint('Payment verification response status: ${response.statusCode}');
      debugPrint('Payment verification response body: ${response.body}');
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Failed to verify payment');
      }
    } catch (e) {
      debugPrint('Payment verification error: $e');
      throw Exception('Failed to verify payment: $e');
    }
  }
  // Get all orders for the current user
  Future<List<Order>> getUserOrders() async {
    try {
      final headers = await _getAuthHeaders();
      
      debugPrint('Fetching user orders from: $apiUrl/users/orders/');
      
      final response = await http.get(
        Uri.parse('$apiUrl/users/orders/'),
        headers: headers,
      );
      
      debugPrint('Get orders response status: ${response.statusCode}');
      debugPrint('Get orders response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> ordersJson = data['orders'];
        
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load orders');
      }
    } catch (e) {
      debugPrint('Failed to load orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }  // Get details for a specific order
  Future<OrderDetail> getOrderDetails(String orderId) async {
    try {
      final headers = await _getAuthHeaders();
      
      debugPrint('Fetching order details for: $orderId');
      
      final response = await http.get(
        Uri.parse('$apiUrl/users/orders/$orderId/'),
        headers: headers,
      );
      
      debugPrint('Get order details response status: ${response.statusCode}');
      debugPrint('Get order details response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('Parsed order details data: $data');
        return OrderDetail.fromJson(data['order_details']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load order details');
      }
    } catch (e) {
      debugPrint('Failed to load order details: $e');
      throw Exception('Failed to load order details: $e');
    }
  }

  // Utility method to format order status for display
  String getOrderStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending_payment':
        return 'Pending Payment';
      case 'payment_successful':
        return 'Payment Successful';
      case 'payment_failed':
        return 'Payment Failed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status.toUpperCase().replaceAll('_', ' ');
    }
  }

  // Utility method to get order status color
  String getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_payment':
        return '#FFA500'; // Orange
      case 'payment_successful':
      case 'processing':
        return '#007BFF'; // Blue
      case 'shipped':
        return '#17A2B8'; // Teal
      case 'delivered':
        return '#28A745'; // Green
      case 'payment_failed':
      case 'cancelled':
        return '#DC3545'; // Red
      case 'refunded':
        return '#6C757D'; // Gray
      default:
        return '#6C757D'; // Gray
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
    // Safe parsing for total_amount
    double parseTotalAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    // Safe parsing for item_count
    int parseItemCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    return Order(
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? '',
      totalAmount: parseTotalAmount(json['total_amount']),
      currency: json['currency'] ?? 'INR',
      createdAt: json['created_at'],
      itemCount: parseItemCount(json['item_count']),
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
  final double? totalAmountCalculated;
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
  final Map<String, dynamic>? invoice;

  OrderDetail({
    this.orderId,
    required this.status,
    required this.totalAmount,
    this.totalAmountCalculated,
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
    this.invoice,
  });  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    // Safe parsing for amounts
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    List<OrderItem> items = [];
    if (json['order_items'] != null) {
      try {
        debugPrint('Parsing ${(json['order_items'] as List).length} order items');
        items = (json['order_items'] as List)
            .map((item) {
              debugPrint('Parsing order item: $item');
              return OrderItem.fromJson(item);
            })
            .toList();
        debugPrint('Successfully parsed ${items.length} order items');
      } catch (e) {
        debugPrint('Error parsing order items: $e');
        items = [];
      }
    }

    final orderDetail = OrderDetail(
      orderId: json['order_id'],
      status: json['status'] ?? 'unknown',
      totalAmount: parseAmount(json['total_amount']),
      totalAmountCalculated: parseAmount(json['total_amount_calculated']),
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
      invoice: json['invoice'],
    );
    
    debugPrint('Created OrderDetail: totalAmount=${orderDetail.totalAmount}, itemsCount=${orderDetail.orderItems.length}');
    return orderDetail;
  }
}

// Order item model
class OrderItem {
  final String productId;
  final String? variantId;
  final String name;
  final int quantity;
  final double priceAtPurchase;
  final double totalItemPrice;
  final String? imageUrl;
  final String? brand;
  final Map<String, dynamic>? variantDetails;

  OrderItem({
    required this.productId,
    this.variantId,
    required this.name,
    required this.quantity,
    required this.priceAtPurchase,
    required this.totalItemPrice,
    this.imageUrl,
    this.brand,
    this.variantDetails,
  });  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Debug: Print the raw JSON for this item
    debugPrint('=== OrderItem JSON Analysis ===');
    debugPrint('Full JSON: $json');
    debugPrint('Available keys: ${json.keys.toList()}');
    
    // Safe parsing for amounts
    double parseAmount(dynamic value) {
      debugPrint('Parsing amount from: $value (type: ${value.runtimeType})');
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          debugPrint('Failed to parse amount from string: $value, error: $e');
          return 0.0;
        }
      }
      debugPrint('Unknown amount type: $value (${value.runtimeType})');
      return 0.0;
    }

    // Safe parsing for quantity
    int parseQuantity(dynamic value) {
      debugPrint('Parsing quantity from: $value (type: ${value.runtimeType})');
      if (value == null) return 1;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          debugPrint('Failed to parse quantity from string: $value, error: $e');
          return 1;
        }
      }
      debugPrint('Unknown quantity type: $value (${value.runtimeType})');
      return 1;
    }    final quantity = parseQuantity(json['quantity']);
    debugPrint('Raw price_at_purchase: ${json['price_at_purchase']}');
    final priceAtPurchase = parseAmount(json['price_at_purchase']);
    debugPrint('Parsed price_at_purchase: $priceAtPurchase');
    
    debugPrint('Raw total_item_price: ${json['total_item_price']}');
    final totalFromJson = parseAmount(json['total_item_price']);
    debugPrint('Parsed total_item_price: $totalFromJson');
    
    // Try different possible field names for total_item_price
    double totalItemPrice = totalFromJson;
    if (totalItemPrice <= 0) {
      debugPrint('Trying total_price: ${json['total_price']}');
      totalItemPrice = parseAmount(json['total_price']);
    }
    if (totalItemPrice <= 0) {
      debugPrint('Trying item_total: ${json['item_total']}');
      totalItemPrice = parseAmount(json['item_total']);
    }
    if (totalItemPrice <= 0) {
      debugPrint('Trying line_total: ${json['line_total']}');
      totalItemPrice = parseAmount(json['line_total']);
    }
    if (totalItemPrice <= 0) {
      debugPrint('Trying subtotal: ${json['subtotal']}');
      totalItemPrice = parseAmount(json['subtotal']);
    }
    
    // Calculate from price and quantity if still zero
    if (totalItemPrice <= 0) {
      totalItemPrice = priceAtPurchase * quantity;
      debugPrint('Calculated total from price * quantity: $totalItemPrice');
    }
    
    // If price_at_purchase is zero but we have a total, calculate unit price
    double finalPriceAtPurchase = priceAtPurchase;
    if (finalPriceAtPurchase <= 0 && totalItemPrice > 0 && quantity > 0) {
      finalPriceAtPurchase = totalItemPrice / quantity;
      debugPrint('Calculated unit price from total/quantity: $finalPriceAtPurchase');
    }
    
    // Try to get price from variant details if still zero
    if (finalPriceAtPurchase <= 0 && json['variant_details'] != null) {
      debugPrint('Checking variant_details: ${json['variant_details']}');
      final variantDetails = json['variant_details'] as Map<String, dynamic>;
      final variantPrice = parseAmount(variantDetails['price']) > 0 
          ? parseAmount(variantDetails['price'])
          : parseAmount(variantDetails['discounted_price']);
      if (variantPrice > 0) {
        finalPriceAtPurchase = variantPrice;
        debugPrint('Using variant price: $finalPriceAtPurchase');
        if (totalItemPrice <= 0) {
          totalItemPrice = finalPriceAtPurchase * quantity;
          debugPrint('Recalculated total from variant price: $totalItemPrice');
        }
      }
    }
    
    // Try to get price from product details if still zero
    if (finalPriceAtPurchase <= 0 && json['product'] != null) {
      debugPrint('Checking product details: ${json['product']}');
      final productDetails = json['product'] as Map<String, dynamic>;
      final productPrice = parseAmount(productDetails['price']) > 0 
          ? parseAmount(productDetails['price'])
          : parseAmount(productDetails['discounted_price']);
      if (productPrice > 0) {
        finalPriceAtPurchase = productPrice;
        debugPrint('Using product price: $finalPriceAtPurchase');
        if (totalItemPrice <= 0) {
          totalItemPrice = finalPriceAtPurchase * quantity;
          debugPrint('Recalculated total from product price: $totalItemPrice');
        }
      }
    }
    
    debugPrint('=== Final OrderItem Values ===');
    debugPrint('Name: ${json['name']}');
    debugPrint('Quantity: $quantity');
    debugPrint('Final Price At Purchase: $finalPriceAtPurchase');
    debugPrint('Final Total Item Price: $totalItemPrice');
    debugPrint('================================');

    return OrderItem(
      productId: json['product_id'] ?? '',
      variantId: json['variant_id'],
      name: json['name'] ?? 'Unknown Product',      quantity: quantity,
      priceAtPurchase: finalPriceAtPurchase,
      totalItemPrice: totalItemPrice,
      imageUrl: json['image_url'],
      brand: json['brand'],
      variantDetails: json['variant_details'],
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
