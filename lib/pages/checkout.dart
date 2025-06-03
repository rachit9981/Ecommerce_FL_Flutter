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

    // These values are now passed via the widget constructor
    // const int amountInPaise = 100 * 100; // e.g., 100 INR
    // final List<String> productIds = ['prod_123']; // Example product ID
    // final String addressId = 'addr_123'; // Example address ID

    try {
      // 1. Create order on your backend using widget properties
      final orderData = await _orderService.createRazorpayOrder(
        amount: widget.amountInPaise,
        productIds: widget.productIds,
        addressId: widget.addressId,
      );

      // Assuming your backend returns a structure like:
      // {
      //   "razorpay_order_id": "order_xxxx", // Razorpay's order_id
      //   "app_order_id": "your_backend_order_id_xxxx", // Your app's internal order_id
      //   "amount": 10000, // Amount in paise, should match
      //   "api_key": "rzp_test_xxxx" // Your Razorpay API key
      // }
      // Adjust keys based on your actual backend response.
      // For this example, let's assume 'order_id' is Razorpay's and 'app_order_id' is your backend's.
      // And that your backend provides the amount and key to use.

      final String razorpayOrderId = orderData['order_id'] ?? orderData['id']; // Razorpay Order ID from your backend
      _appOrderId = orderData['app_order_id']; // Your backend's order ID
      final int orderAmount = orderData['amount'] ?? widget.amountInPaise; // Use amount from backend or fallback to widget's
      final String razorpayKey = orderData['api_key'] ?? 'rzp_test_8qQx2uqUByXwUX'; // Use key from backend or fallback

      if (_appOrderId == null) {
        throw Exception("app_order_id not found in backend response for verification.");
      }
      
      var options = {
        'key': razorpayKey, 
        'amount': orderAmount, 
        'name': 'Acme Corp',
        'order_id': razorpayOrderId, // Crucial: Pass the order_id obtained from your backend
        'description': 'Test Payment',
        'prefill': {'contact': '8888888888', 'email': 'test@example.com'},
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);

    } catch (e) {
      debugPrint('Error creating order or opening checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')), // This will display the "Selected address not found" error
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