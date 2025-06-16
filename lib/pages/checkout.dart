/*
Checkout Page - Updated for new OrderService and RazorpayService

Usage:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CheckoutPage(
      addressId: 'user_address_id',
      productIds: ['product_1', 'product_2'], // Cart item IDs
      amountInPaise: 150000, // ₹1500.00 in paise
    ),
  ),
);

Features:
- Integrated with updated OrderService for backend compatibility
- Uses RazorpayService for streamlined payment processing
- Automatic payment verification with backend
- Enhanced error handling and user feedback
- Support for single product and cart-based orders
*/

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '/services/orders.dart';
import '/services/razorpay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final String addressId;
  final List<String> productIds;
  final int amountInPaise;

  const CheckoutPage({
    Key? key,
    required this.addressId,
    required this.productIds,
    required this.amountInPaise,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  late final RazorpayService _razorpayService;
  String? _appOrderId;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize RazorpayService
    _razorpayService = RazorpayService();
      // Set up payment callbacks
    _razorpayService.setPaymentSuccessCallback(_handlePaymentSuccess);
    _razorpayService.setPaymentErrorCallback(_handlePaymentError);
    _razorpayService.setExternalWalletCallback(() => _handleExternalWallet());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment success: ${response.paymentId}");
    setState(() {
      _isLoading = false;
    });

    // The RazorpayService already handles verification in the background
    // Show success dialog immediately
    if (mounted) {
      _showSuccessDialog();
    }
  }
  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading = false;
    });
    _showErrorSnackBar('Payment Failed: ${response.message ?? "Unknown error"}');
  }
  void _handleExternalWallet() {
    print("External wallet selected");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('External wallet selected'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 12),              Text(
                'Your order has been placed successfully and your cart has been cleared.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (_appOrderId != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Order ID: ${_appOrderId!.substring(0, 8)}...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close checkout page
                      },
                      child: const Text('Continue Shopping'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close checkout page
                        Navigator.pushNamed(context, '/orders'); // Navigate to orders
                      },
                      child: const Text('View Orders'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }
  @override
  void dispose() {
    _razorpayService.dispose();
    _animationController.dispose();
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

      // Get user details from SharedPreferences or use defaults
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('email') ?? 'test@example.com';
      final userPhone = prefs.getString('phone') ?? '8888888888';
      final userName = prefs.getString('name') ?? 'User';

      // Use the RazorpayService to initiate payment
      await _razorpayService.initiatePayment(
        razorpayKeyId: razorpayKey,
        razorpayOrderId: razorpayOrderId,
        appOrderId: _appOrderId!,
        amount: orderAmount / 100.0, // Convert paise to rupees
        currency: 'INR',
        userEmail: userEmail,
        userPhone: userPhone,
        userName: userName,
        description: 'Purchase from Your Store',
      );
    } catch (e) {
      debugPrint('Error creating order or opening checkout: $e');

      // Show a more user-friendly error message
      String errorMessage = e.toString();
      if (errorMessage.contains('Authentication failed')) {
        errorMessage = 'Your session has expired. Please log in again.';
      } else if (errorMessage.contains('address not found')) {
        errorMessage = 'The selected delivery address is not valid.';
      }

      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = widget.amountInPaise / 100;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSummaryRow('Items', '${widget.productIds.length}'),
                        _buildSummaryRow('Subtotal', '₹${amount.toStringAsFixed(2)}'),
                        _buildSummaryRow('Shipping', 'Free'),
                        _buildSummaryRow('Tax', 'Included'),
                        const Divider(height: 30),
                        _buildSummaryRow(
                          'Total Amount',
                          '₹${amount.toStringAsFixed(2)}',
                          isBold: true,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Methods Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.payment,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Payment Methods',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildPaymentOption(
                          icon: Icons.credit_card,
                          title: 'Credit/Debit Card',
                          subtitle: 'Visa, Mastercard, RuPay',
                          color: Colors.purple,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          icon: Icons.account_balance_wallet,
                          title: 'UPI',
                          subtitle: 'PhonePe, Google Pay, Paytm',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          icon: Icons.account_balance,
                          title: 'Net Banking',
                          subtitle: 'All major banks supported',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Security Notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your payment information is secure and encrypted',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: _isLoading
              ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _openCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pay ₹${amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : Colors.grey[800],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }
}