import 'package:flutter/material.dart';
import 'package:ecom/components/notifications/notifications_comps.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  String? _selectedFilter;
  final List<String> _filters = [
    'All',
    'Orders',
    'Promotions',
    'Payments',
    'Delivery',
    'Alerts',
  ];
  
  @override
  void initState() {
    super.initState();
    // Load sample notifications
    _notifications = SampleNotifications.getSampleNotifications();
  }
  
  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == null || _selectedFilter == 'All') {
      return _notifications;
    }
    
    NotificationType? type;
    switch (_selectedFilter) {
      case 'Orders':
        type = NotificationType.order;
        break;
      case 'Promotions':
        type = NotificationType.promotion;
        break;
      case 'Payments':
        type = NotificationType.payment;
        break;
      case 'Delivery':
        type = NotificationType.delivery;
        break;
      case 'Alerts':
        type = NotificationType.alert;
        break;
    }
    
    return _notifications.where((notification) => notification.type == type).toList();
  }
  
  Future<void> _refreshNotifications() async {
    // Simulating network request
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _notifications = SampleNotifications.getSampleNotifications();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: _filters.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: NotificationFilterChip(
                    label: filter,
                    isSelected: _selectedFilter == filter,
                    onTap: () {
                      setState(() {
                        _selectedFilter = _selectedFilter == filter ? null : filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Notifications list
          Expanded(
            child: _filteredNotifications.isEmpty
                ? EmptyNotificationState(onRefresh: _refreshNotifications)
                : RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    color: Theme.of(context).colorScheme.primary,
                    child: ListView.builder(
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return NotificationItem(
                          id: notification.id,
                          title: notification.title,
                          message: notification.message,
                          time: notification.time,
                          type: notification.type,
                          onTap: () {
                            // Show a modal bottom sheet with full notification details
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => _buildNotificationDetails(notification),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationDetails(NotificationModel notification) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            notification.message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDetailedTime(notification.time),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.payment:
        return Icons.payment_outlined;
      case NotificationType.delivery:
        return Icons.local_shipping_outlined;
      case NotificationType.alert:
        return Icons.notifications_active_outlined;
    }
  }
  
  String _formatDetailedTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
