import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  
  // Sample order data - replace with your actual data fetching logic
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-1234',
      'date': '15 May 2023',
      'total': 178.99,
      'status': 'Delivered',
      'statusColor': Colors.green,
      'items': 3,
    },
    {
      'id': 'ORD-5678',
      'date': '02 May 2023',
      'total': 245.50,
      'status': 'Processing',
      'statusColor': Colors.orange,
      'items': 4,
    },
    {
      'id': 'ORD-9012',
      'date': '28 Apr 2023',
      'total': 99.99,
      'status': 'Shipped',
      'statusColor': Colors.blue,
      'items': 1,
    },
    {
      'id': 'ORD-3456',
      'date': '15 Apr 2023',
      'total': 352.75,
      'status': 'Cancelled',
      'statusColor': Colors.red,
      'items': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              '${_orders.length} orders',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _orders.isEmpty
          ? _buildEmptyOrders(context)
          : _buildOrdersList(context),
    );
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
    return ListView.builder(
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
    );
  }

  Widget _buildAnimatedOrder(BuildContext context, Map<String, dynamic> order, Animation<double> animation) {
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

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final statusColor = order['statusColor'];
    
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
                arguments: order,
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
                            'Order #${order['id']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Placed on ${order['date']}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      _buildStatusBadge(order['status']),
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
                            '${order['items']} item${order['items'] > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Order progress
                      if (order['status'] != 'Cancelled')
                        _buildOrderProgress(order['status']),
                        
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
                                '\$${order['total'].toStringAsFixed(2)}',
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
                                arguments: order,
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;
    IconData icon;
    
    switch (status) {
      case 'Processing':
        bgColor = Colors.orange;
        icon = Icons.pending_outlined;
        break;
      case 'Shipped':
        bgColor = Colors.blue;
        icon = Icons.local_shipping_outlined;
        break;
      case 'Delivered':
        bgColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'Cancelled':
        bgColor = Colors.red;
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = Colors.grey;
        icon = Icons.info_outline;
    }
    
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
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProgress(String status) {
    int currentStep;
    
    switch (status) {
      case 'Processing':
        currentStep = 0;
        break;
      case 'Shipped':
        currentStep = 1;
        break;
      case 'Delivered':
        currentStep = 2;
        break;
      default:
        currentStep = -1;
    }
    
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
