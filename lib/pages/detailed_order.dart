import 'package:flutter/material.dart';
import '../services/orders.dart';

class DetailedOrderPage extends StatefulWidget {
  final String orderId;
  
  const DetailedOrderPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<DetailedOrderPage> createState() => _DetailedOrderPageState();
}

class _DetailedOrderPageState extends State<DetailedOrderPage> {
  final OrderService _orderService = OrderService();
  OrderDetail? _orderDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderDetail = await _orderService.getOrderDetails(widget.orderId);
      if (mounted) {
        setState(() {
          _orderDetail = orderDetail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId.substring(0, 8)}'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading order details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchOrderDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_orderDetail == null) {
      return const Center(
        child: Text('No order details found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Section
          _buildStatusSection(context, _orderDetail!),
          const SizedBox(height: 24),
          
          // Order Items Section
          _buildSectionTitle('Order Items'),
          const SizedBox(height: 12),
          ..._orderDetail!.orderItems.map((item) => _buildOrderItem(context, item)).toList(),
          const SizedBox(height: 24),
          
          // Order Summary Section
          _buildSectionTitle('Order Summary'),
          const SizedBox(height: 12),
          _buildOrderSummary(_orderDetail!),
          const SizedBox(height: 24),
          
          // Shipping Address Section
          if (_orderDetail!.address != null) ...[
            _buildSectionTitle('Shipping Address'),
            const SizedBox(height: 12),
            _buildAddressCard(_orderDetail!.address!),
            const SizedBox(height: 24),
          ],
          
          // Payment Method Section
          if (_orderDetail!.paymentDetails != null) ...[
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 12),
            _buildPaymentCard(_orderDetail!.paymentDetails!),
            const SizedBox(height: 24),
          ],
          
          // Tracking Information
          if (_orderDetail!.trackingInfo != null) ...[
            _buildSectionTitle('Tracking Information'),
            const SizedBox(height: 12),
            _buildTrackingInfo(_orderDetail!.trackingInfo!),
            const SizedBox(height: 32),
          ],
          
          // Action buttons
          _buildActionButtons(_orderDetail!),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, OrderDetail orderDetail) {
    final Color statusColor = _getStatusColor(orderDetail.status);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(orderDetail.status),
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Status: ${_getFormattedStatus(orderDetail.status)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (orderDetail.createdAtFormatted != null) ...[
            const SizedBox(height: 8),
            Text(
              'Order Date: ${orderDetail.createdAtFormatted}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (orderDetail.estimatedDeliveryFormatted != null) ...[
            const SizedBox(height: 8),
            Text(
              'Estimated Delivery: ${orderDetail.estimatedDeliveryFormatted}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
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
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image,
                        size: 30,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(Icons.image, size: 30, color: Colors.grey[400]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.brand != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Brand: ${item.brand}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
                if (item.color != null || item.model != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${item.color ?? ''} ${item.model ?? ''}'.trim(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${item.quantity}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.totalItemPrice.toStringAsFixed(2)}',
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

  Widget _buildOrderSummary(OrderDetail orderDetail) {
    final subtotal = orderDetail.orderItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalItemPrice,
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          _buildSummaryItem('Shipping', 'Free'),
          _buildSummaryItem('Tax', 'Included'),
          const Divider(height: 24),
          _buildSummaryItem(
            'Total',
            '${orderDetail.currency} ${orderDetail.totalAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),);
  }

  Widget _buildTrackingInfo(TrackingInfo trackingInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trackingInfo.carrier != null) ...[
            Text(
              'Carrier: ${trackingInfo.carrier}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
          ],
          if (trackingInfo.trackingNumber != null) ...[
            Text('Tracking Number: ${trackingInfo.trackingNumber}'),
            const SizedBox(height: 8),
          ],
          if (trackingInfo.statusHistory.isNotEmpty) ...[
            const Text(
              'Status History:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...trackingInfo.statusHistory.map((status) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.description,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (status.timestampFormatted != null)
                          Text(
                            status.timestampFormatted!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderDetail orderDetail) {
    return Column(
      children: [
        if (orderDetail.status.toLowerCase() == 'processing') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
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
          const SizedBox(height: 16),
        ],
        if (orderDetail.status.toLowerCase() == 'delivered') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
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
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
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
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'pending_payment':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
      case 'payment_successful':
        return Colors.green;
      case 'cancelled':
      case 'payment_failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFormattedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending_payment':
        return 'Pending Payment';
      case 'payment_successful':
        return 'Payment Confirmed';
      case 'payment_failed':
        return 'Payment Failed';
      default:
        return status.split('_')
            .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
            .join(' ');
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'pending_payment':
        return Icons.pending_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
      case 'payment_successful':
        return Icons.check_circle_outline;
      case 'cancelled':
      case 'payment_failed':
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address['name'] != null) ...[
            Text(
              address['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (address['street'] != null) Text(address['street']),
          if (address['city'] != null || address['state'] != null || address['zip_code'] != null)
            Text('${address['city'] ?? ''}, ${address['state'] ?? ''} ${address['zip_code'] ?? ''}'.trim()),
          if (address['country'] != null) Text(address['country']),
          if (address['phone'] != null) ...[
            const SizedBox(height: 8),
            Text('Phone: ${address['phone']}'),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentDetail payment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            payment.cardNetwork?.toLowerCase() == 'visa' ? Icons.credit_card : Icons.payment,
            size: 32,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.method ?? 'Credit Card',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                if (payment.cardLast4 != null)
                  Text('**** **** **** ${payment.cardLast4}'),
                if (payment.status != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${payment.status}',
                    style: TextStyle(
                      color: payment.status?.toLowerCase() == 'captured' 
                          ? Colors.green 
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
