import 'package:flutter/material.dart';

/// Represents a single notification item with various types
class NotificationItem extends StatelessWidget {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final VoidCallback onTap;

  const NotificationItem({
    Key? key,
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(time),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;
    
    IconData iconData;
    Color backgroundColor;
    Color iconColor;
    
    switch (type) {
      case NotificationType.order:
        iconData = Icons.shopping_bag_outlined;
        backgroundColor = primaryColor.withOpacity(0.1);
        iconColor = primaryColor;
        break;
      case NotificationType.promotion:
        iconData = Icons.local_offer_outlined;
        backgroundColor = secondaryColor.withOpacity(0.1);
        iconColor = secondaryColor;
        break;
      case NotificationType.payment:
        iconData = Icons.payment_outlined;
        backgroundColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        break;
      case NotificationType.delivery:
        iconData = Icons.local_shipping_outlined;
        backgroundColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue;
        break;
      case NotificationType.alert:
        iconData = Icons.notifications_active_outlined;
        backgroundColor = Colors.red.withOpacity(0.1);
        iconColor = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Filter chip for notification categories
class NotificationFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NotificationFilterChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Empty notifications state widget
class EmptyNotificationState extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyNotificationState({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Notifications Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll notify you when something arrives',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum for notification types
enum NotificationType {
  order,
  promotion,
  payment,
  delivery,
  alert,
}

/// Model class for a notification
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });
}

/// Utility to get sample notifications for testing
class SampleNotifications {
  static List<NotificationModel> getSampleNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'Your order has been shipped!',
        message: 'Order #1234 has been shipped and will arrive in 2-3 business days.',
        time: DateTime.now().subtract(const Duration(minutes: 10)),
        type: NotificationType.order,
      ),
      NotificationModel(
        id: '2',
        title: 'Special Offer: 30% Off!',
        message: 'Get 30% off on all electronics this weekend only! Use code: WEEKEND30',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.promotion,
      ),
      NotificationModel(
        id: '3',
        title: 'Payment Successful',
        message: 'Your payment of ₹4,599 for order #1234 was successful.',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.payment,
      ),
      NotificationModel(
        id: '4',
        title: 'Order Delivered',
        message: 'Your order #1233 has been delivered. Enjoy your purchase!',
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.delivery,
      ),
      NotificationModel(
        id: '5',
        title: 'Price Drop Alert!',
        message: 'The product "Smart Watch" in your wishlist has dropped in price.',
        time: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.alert,
      ),
      NotificationModel(
        id: '6',
        title: 'New Collection Arrived',
        message: 'Check out our latest summer collection with exciting new products!',
        time: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.promotion,
      ),
      NotificationModel(
        id: '7',
        title: 'Rate Your Purchase',
        message: 'How was your experience with "Wireless Earbuds"? Tap to rate the product.',
        time: DateTime.now().subtract(const Duration(days: 4)),
        type: NotificationType.order,
      ),
    ];
  }
}
