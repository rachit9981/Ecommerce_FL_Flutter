import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import '/services/orders.dart'; // Import OrderService

class CheckoutPage extends StatefulWidget {
  final String addressId;
  final List<String> productIds;
  final int amountInPaise; // Total amount for the order

  const CheckoutPage({
    Key? key,
    required this.addressId,
    required this.productIds,
    required this.amountInPaise,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Razorpay _razorpay;
  final OrderService _orderService = OrderService(); // Initialize OrderService
  String? _appOrderId; // To store your backend's order ID
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment success: ${response.paymentId}");
    setState(() {
      _isLoading = true;
    });
    try {
      if (response.orderId == null || response.paymentId == null || response.signature == null || _appOrderId == null) {
        throw Exception("Payment data incomplete for verification.");
      }
      // Verify payment with your backend
      final verificationData = await _orderService.verifyRazorpayPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
        orderId: _appOrderId!, // Your backend's order ID
      );
      print("Payment verification success: $verificationData");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful & Verified! Order ID: ${_appOrderId}')),
      );
      // Navigate to order confirmation page or show success message
    } catch (e) {
      print("Payment verification failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment verification failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment error: ${response.code} - ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External wallet: ${response.walletName}");
    // Do something when an external wallet is selected
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _openCheckout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Creating order with:');
      debugPrint('Address ID: ${widget.addressId}');
      debugPrint('Products: ${widget.productIds}');
      debugPrint('Amount: ${widget.amountInPaise}');
      
      // 1. Create order on your backend using widget properties
      final orderData = await _orderService.createRazorpayOrder(
        amount: widget.amountInPaise,
        productIds: widget.productIds,
        addressId: widget.addressId,
      );

      final String razorpayOrderId = orderData['razorpay_order_id']; 
      _appOrderId = orderData['app_order_id'];
      final int orderAmount = orderData['amount'] ?? widget.amountInPaise;
      final String razorpayKey = orderData['key_id'] ?? 'rzp_test_8qQx2uqUByXwUX';

      if (_appOrderId == null) {
        throw Exception("app_order_id not found in backend response for verification.");
      }
      
      var options = {
        'key': razorpayKey, 
        'amount': orderAmount, 
        'name': 'Acme Corp',
        'order_id': razorpayOrderId,
        'description': 'Test Payment',
        'prefill': {'contact': '8888888888', 'email': 'test@example.com'},
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);

    } catch (e) {
      debugPrint('Error creating order or opening checkout: $e');
      
      // Show a more user-friendly error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Authentication failed')) {
        errorMessage = 'Your session has expired. Please log in again.';
      } else if (errorMessage.contains('address not found')) {
        errorMessage = 'The selected delivery address is not valid.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              // Do something
            },
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _openCheckout,
                child: Text('Pay with Razorpay'),
              ),
      ),
    );
  }
}