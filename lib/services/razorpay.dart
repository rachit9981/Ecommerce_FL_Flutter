/*
Razorpay Service for Flutter

Usage Example:
```dart
// 1. Create order and get Razorpay order details
final orderService = OrderService();
final razorpayService = RazorpayService();

// Set up payment callbacks
razorpayService.setPaymentSuccessCallback((response) {
  // Handle successful payment
  print('Payment successful: ${response.paymentId}');
});

razorpayService.setPaymentErrorCallback((response) {
  // Handle payment failure
  print('Payment failed: ${response.message}');
});

// Create order with backend
final orderResult = await orderService.createOrderAndInitiatePayment(
  amountInRupees: 1500.0, // Amount in rupees
  productIds: ['product_1', 'product_2'],
  addressId: 'address_123',
  currency: 'INR',
);

// Initiate Razorpay payment
await razorpayService.initiatePayment(
  razorpayKeyId: orderResult['key_id'],
  razorpayOrderId: orderResult['razorpay_order_id'],
  appOrderId: orderResult['app_order_id'],
  amount: orderResult['amount'] / 100, // Convert paise to rupees
  currency: orderResult['currency'],
  userEmail: 'user@example.com',
  userPhone: '+919876543210',
  userName: 'John Doe',
);

// Don't forget to dispose
razorpayService.dispose();
```
*/

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'orders.dart';
import 'cart_wishlist.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class RazorpayService {
  late Razorpay _razorpay;
  final OrderService _orderService = OrderService();
  final CartWishlistService _cartService = CartWishlistService();
  
  // Callbacks for payment events
  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentError;
  Function()? onExternalWallet;

  // Store order details for payment verification
  String? _currentAppOrderId;
  
  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  // Initialize payment with order details
  Future<void> initiatePayment({
    required String razorpayKeyId,
    required String razorpayOrderId,
    required String appOrderId,
    required double amount,
    required String currency,
    required String userEmail,
    required String userPhone,
    required String userName,
    String? description,
  }) async {
    try {
      // Store the order ID for payment verification
      setCurrentOrderId(appOrderId);
      
      var options = {
        'key': razorpayKeyId,
        'order_id': razorpayOrderId,
        'amount': (amount * 100).toInt(), // Amount in paise
        'currency': currency,
        'name': 'Your App Name',
        'description': description ?? 'Payment for Order #$appOrderId',
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': userName,
        },
        'notes': {
          'app_order_id': appOrderId,
        },
        'theme': {
          'color': '#3399cc'
        }
      };

      debugPrint('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error initiating payment: $e');
      Fluttertoast.showToast(
        msg: "Error initiating payment: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.toString()}');
    
    // Extract app order ID from notes or use stored order ID
    String appOrderId = '';
    
    // Try to get from response notes first
    if (response.data != null && response.data!['notes'] != null) {
      appOrderId = response.data!['notes']['app_order_id'] ?? '';
    }
    
    // Fallback to stored order ID
    if (appOrderId.isEmpty && _currentAppOrderId != null) {
      appOrderId = _currentAppOrderId!;
    }
    
    if (appOrderId.isEmpty) {
      debugPrint('Error: No app order ID found for payment verification');
      Fluttertoast.showToast(
        msg: "Error: Order ID not found for verification",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }
    
    // Verify payment with backend
    _verifyPaymentWithBackend(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
      appOrderId: appOrderId,
    );

    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.toString()}');
    
    Fluttertoast.showToast(
      msg: "Payment failed: ${response.message}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );

    if (onPaymentError != null) {
      onPaymentError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.toString()}');
    
    Fluttertoast.showToast(
      msg: "External wallet selected: ${response.walletName}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    if (onExternalWallet != null) {
      onExternalWallet!();
    }
  }
  Future<void> _verifyPaymentWithBackend({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String appOrderId,
  }) async {
    try {
      final result = await _orderService.verifyRazorpayPayment(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        orderId: appOrderId,
      );

      debugPrint('Payment verification result: $result');
      
      // Clear cart after successful payment verification
      try {
        await _cartService.clearCart();
        debugPrint('Cart cleared successfully after payment');
      } catch (cartError) {
        debugPrint('Warning: Failed to clear cart after payment: $cartError');
        // Don't fail the whole payment process if cart clearing fails
      }
      
      Fluttertoast.showToast(
        msg: "Payment verified successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Payment verification failed: $e');
      
      Fluttertoast.showToast(
        msg: "Payment verification failed: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Set callback functions
  void setPaymentSuccessCallback(Function(PaymentSuccessResponse) callback) {
    onPaymentSuccess = callback;
  }

  void setPaymentErrorCallback(Function(PaymentFailureResponse) callback) {
    onPaymentError = callback;
  }

  void setExternalWalletCallback(Function() callback) {
    onExternalWallet = callback;
  }
  // Clean up resources
  void dispose() {
    _razorpay.clear();
    clearCurrentOrderId();
  }

  void setCurrentOrderId(String orderId) {
    _currentAppOrderId = orderId;
  }
  
  String? getCurrentOrderId() {
    return _currentAppOrderId;
  }
  
  void clearCurrentOrderId() {
    _currentAppOrderId = null;
  }
}
