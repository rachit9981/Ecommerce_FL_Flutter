import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/orders.dart';
import '../providers/user_provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final OrderService _orderService = OrderService();
  
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Fetch orders when the page initializes
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final orders = await _orderService.getUserOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        // Capitalize first letter of each word
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

  int _getCurrentStep(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'pending_payment':
      case 'payment_successful':
        return 0;
      case 'shipped':
        return 1;
      case 'delivered':
        return 2;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAuthenticated = userProvider.isAuthenticated;
    
    // Check authentication status
    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('My Orders'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Please sign in to view your orders',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Orders',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _isLoading ? 'Loading...' : '${_orders.length} orders',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchOrders,
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
              'Error loading orders',
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
              onPressed: _fetchOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_orders.isEmpty) {
      return _buildEmptyOrders(context);
    }
    
    return _buildOrdersList(context);
  }

  Widget _buildEmptyOrders(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'When you place orders, they will appear here for easy tracking',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to homepage
            },
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          
          // Create staggered animation for each item
          final Animation<double> animation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (1 / _orders.length) * index,
              1.0,
              curve: Curves.easeOut,
            ),
          );
          
          return _buildAnimatedOrder(context, order, animation);
        },
      ),
    );
  }

  Widget _buildAnimatedOrder(BuildContext context, Order order, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildOrderCard(context, order),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);
    final formattedStatus = _getFormattedStatus(order.status);
    
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to detailed order page
              Navigator.pushNamed(
                context, 
                '/detailed-order',
                arguments: order.orderId,
              );
            },
            splashColor: statusColor.withOpacity(0.1),
            highlightColor: statusColor.withOpacity(0.05),
            child: Column(
              children: [
                // Order header with gradient
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.8),
                        statusColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderId.substring(0, min(8, order.orderId.length))}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Placed on ${order.createdAt ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      _buildStatusBadge(formattedStatus, order.status),
                    ],
                  ),
                ),
                
                // Order content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Order item count with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 18,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Order progress
                      if (!order.status.toLowerCase().contains('cancelled') && 
                          !order.status.toLowerCase().contains('failed'))
                        _buildOrderProgress(order.status),
                        
                      const SizedBox(height: 16),
                      
                      // Order total and view details button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${order.currency} ${order.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to detailed order page
                              Navigator.pushNamed(
                                context, 
                                '/detailed-order',
                                arguments: order.orderId,
                              );
                            },
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            label: const Text('View Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: statusColor,
                              elevation: 0,
                              side: BorderSide(color: statusColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String displayStatus, String originalStatus) {
    final statusColor = _getStatusColor(originalStatus);
    final icon = _getStatusIcon(originalStatus);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            displayStatus,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgress(String status) {
    int currentStep = _getCurrentStep(status);
    
    return Row(
      children: [
        _buildProgressStep(0, currentStep, 'Confirmed', Icons.check_circle_outline),
        _buildProgressLine(0, currentStep),
        _buildProgressStep(1, currentStep, 'Shipped', Icons.local_shipping_outlined),
        _buildProgressLine(1, currentStep),
        _buildProgressStep(2, currentStep, 'Delivered', Icons.home_outlined),
      ],
    );
  }

  Widget _buildProgressStep(int step, int currentStep, String label, IconData icon) {
    final bool isActive = step <= currentStep;
    final bool isCurrent = step == currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive 
                  ? (isCurrent ? Colors.blue : Colors.green)
                  : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: Colors.blue.shade300, width: 2)
                  : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent 
                  ? Colors.blue
                  : (isActive ? Colors.black : Colors.grey),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(int step, int currentStep) {
    final bool isActive = step < currentStep;
    
    return Container(
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Helper function for min value to avoid importing dart:math
int min(int a, int b) => a < b ? a : b;
