import 'package:flutter/material.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final VoidCallback? onCartPressed;
  final VoidCallback? onNotificationsPressed;

  const HomeAppBar({
    super.key,
    this.height = kToolbarHeight + 10,
    this.onCartPressed,
    this.onNotificationsPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with TickerProviderStateMixin {
  late AnimationController _notificationAnimController;
  late Animation<double> _notificationScaleAnimation;
  
  late AnimationController _cartAnimController;
  late Animation<double> _cartScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize notification animation controller
    _notificationAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _notificationScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.05),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0),
        weight: 1,
      ),
    ]).animate(_notificationAnimController);
    
    // Initialize cart animation controller
    _cartAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _cartScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.05),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0),
        weight: 1,
      ),
    ]).animate(_cartAnimController);
  }

  @override
  void dispose() {
    _notificationAnimController.dispose();
    _cartAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color lightVariant = Color.lerp(primaryColor, Colors.white, 0.8)!;
    final Color darkVariant = Color.lerp(primaryColor, Colors.black, 0.3)!;

    return AppBar(
      leadingWidth: 150,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightVariant, Color.lerp(lightVariant, darkVariant, 0.3)!],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                height: 40,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      title: const Text(''), // Empty title
      centerTitle: true,
      elevation: 8.0, // Increased elevation
      shadowColor: darkVariant.withOpacity(0.5), // Custom shadow color
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AnimatedBuilder(
            animation: _notificationScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _notificationScaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Colors.black87,
                  size: 24,
                ),
                tooltip: 'Notifications',
                onPressed: () {
                  _notificationAnimController.forward(from: 0.0).then((_) {
                    if (widget.onNotificationsPressed != null) {
                      widget.onNotificationsPressed!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications pressed')),
                      );
                    }
                  });
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 16.0),
          child: AnimatedBuilder(
            animation: _cartScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cartScaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.black87,
                  size: 24,
                ),
                tooltip: 'Cart',
                onPressed: () {
                  _cartAnimController.forward(from: 0.0).then((_) {
                    if (widget.onCartPressed != null) {
                      widget.onCartPressed!();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cart pressed')),
                      );
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}