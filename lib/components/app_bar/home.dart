import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final VoidCallback? onCartPressed;
  final VoidCallback? onNotificationsPressed;

  const HomeAppBar({
    super.key,
    this.height = kToolbarHeight,
    this.onCartPressed,
    this.onNotificationsPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color darkenedPrimaryColor = Color.lerp(primaryColor, Colors.white, 0.8)!;

    return AppBar(
      leadingWidth: 120,
      backgroundColor: darkenedPrimaryColor,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Image.asset('assets/logo.png', fit: BoxFit.contain),
            const SizedBox(width: 8),
          ],
        ),
      ),
      title: const Text(''),
      centerTitle: true,
      elevation: 4.0,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          tooltip: 'Notifications',
          onPressed: onNotificationsPressed ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications pressed')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          tooltip: 'Cart',
          onPressed: onCartPressed ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cart pressed')),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}