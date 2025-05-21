import 'package:flutter/material.dart';

class DetailedOrderPage extends StatelessWidget {
  const DetailedOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the order data passed from the previous screen
    final Map<String, dynamic> orderData = 
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    // Mock order items - in a real app, you would get this from your order data
    final List<Map<String, dynamic>> orderItems = [
      {
        'name': 'Wireless Headphones',
        'price': 129.99,
        'quantity': 1,
        'image': 'assets/images/headphones.jpg',
      },
      {
        'name': 'Smart Watch Series 6',
        'price': 299.99,
        'quantity': 1,
        'image': 'assets/images/watch.jpg',
      },
      {
        'name': 'USB-C Charging Cable',
        'price': 19.99,
        'quantity': 2,
        'image': 'assets/images/cable.jpg',
      },
    ];
    
    // Mock shipping and payment info
    final shippingAddress = {
      'name': 'John Doe',
      'street': '123 Main Street',
      'city': 'New York',
      'state': 'NY',
      'zipCode': '10001',
      'country': 'United States',
      'phone': '+1 (555) 123-4567',
    };
    
    final paymentInfo = {
      'method': 'Credit Card',
      'cardNumber': '**** **** **** 1234',
      'cardType': 'Visa',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderData['id']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Section
            _buildStatusSection(context, orderData),
            const SizedBox(height: 24),
            
            // Order Items Section
            _buildSectionTitle('Order Items'),
            const SizedBox(height: 12),
            ...orderItems.map((item) => _buildOrderItem(context, item)).toList(),
            const SizedBox(height: 24),
            
            // Order Summary Section
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 12),
            _buildSummaryItem('Subtotal', '\$${(orderData['total'] - 15.99).toStringAsFixed(2)}'),
            _buildSummaryItem('Shipping', '\$15.99'),
            _buildSummaryItem('Tax', 'Included'),
            const Divider(height: 24),
            _buildSummaryItem('Total', '\$${orderData['total'].toStringAsFixed(2)}',
                isBold: true),
            const SizedBox(height: 24),
            
            // Shipping Address Section
            _buildSectionTitle('Shipping Address'),
            const SizedBox(height: 12),
            _buildAddressCard(shippingAddress),
            const SizedBox(height: 24),
            
            // Payment Method Section
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 12),
            _buildPaymentCard(paymentInfo),
            const SizedBox(height: 32),
            
            // Action buttons
            if (orderData['status'] == 'Processing')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle cancel order
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order cancellation requested')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel Order'),
                ),
              ),
            if (orderData['status'] == 'Delivered')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle return order
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Return request submitted')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Return Order'),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Handle download invoice
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice downloaded')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Download Invoice'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, Map<String, dynamic> orderData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: orderData['statusColor'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: orderData['statusColor'],
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(orderData['status']),
                color: orderData['statusColor'],
              ),
              const SizedBox(width: 8),
              Text(
                'Status: ${orderData['status']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: orderData['statusColor'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Order Date: ${orderData['date']}',
            style: const TextStyle(fontSize: 14),
          ),
          if (orderData['status'] == 'Shipped' || orderData['status'] == 'Delivered')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  orderData['status'] == 'Shipped'
                      ? 'Estimated Delivery: 18 May 2023'
                      : 'Delivered On: 15 May 2023',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (orderData['status'] == 'Shipped')
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to tracking page
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: orderData['statusColor'],
                      side: BorderSide(color: orderData['statusColor']),
                    ),
                    child: const Text('Track Package'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Processing':
        return Icons.pending_outlined;
      case 'Shipped':
        return Icons.local_shipping_outlined;
      case 'Delivered':
        return Icons.check_circle_outline;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.image, size: 30, color: Colors.grey[400]),
              // Replace with actual image:
              // Image.asset(item['image'], fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item['quantity']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(address['street']),
          Text('${address['city']}, ${address['state']} ${address['zipCode']}'),
          Text(address['country']),
          const SizedBox(height: 8),
          Text('Phone: ${address['phone']}'),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            payment['cardType'] == 'Visa' ? Icons.credit_card : Icons.payment,
            size: 32,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment['method'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(payment['cardNumber']),
            ],
          ),
        ],
      ),
    );
  }
}
