import 'package:flutter/material.dart';
import '../../services/settings.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final VoidCallback? onCartPressed;
  final VoidCallback? onSearchPressed;
  final int cartItemCount;

  const HomeAppBar({
    super.key,
    this.height = kToolbarHeight + 8,
    this.onCartPressed,
    this.onSearchPressed,
    this.cartItemCount = 0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> with TickerProviderStateMixin {
  AnimationController? _notificationAnimController;
  
  AnimationController? _cartAnimController;
  Animation<double>? _cartScaleAnimation;
  
  String? _logoUrl;
  bool _isLoadingLogo = true;
  
  @override
  void initState() {
    super.initState();
    
    _initializeAnimations();
    _fetchLogo();
  }

  void _initializeAnimations() {
    _notificationAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // _notificationScaleAnimation = TweenSequence<double>([
    //   TweenSequenceItem(
    //     tween: Tween<double>(begin: 1.0, end: 0.8),
    //     weight: 1,
    //   ),
    //   TweenSequenceItem(
    //     tween: Tween<double>(begin: 0.8, end: 1.05),
    //     weight: 1,
    //   ),
    //   TweenSequenceItem(
    //     tween: Tween<double>(begin: 1.05, end: 1.0),
    //     weight: 1,
    //   ),
    // ]).animate(_notificationAnimController!);
    
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
    ]).animate(_cartAnimController!);
  }

  Future<void> _fetchLogo() async {
    try {
      final logoResponse = await SettingsService.getLogo();
      if (mounted) {
        setState(() {
          _logoUrl = logoResponse.logoUrl;
          _isLoadingLogo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLogo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notificationAnimController?.dispose();
    _cartAnimController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if animations are initialized, if not, initialize them
    if (_cartScaleAnimation == null) {
      _initializeAnimations();
    }

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color surfaceColor = Theme.of(context).colorScheme.surface;
    final Color lightVariant = Color.lerp(primaryColor, Colors.white, 0.9)!;
    final Color darkVariant = Color.lerp(primaryColor, Colors.black, 0.2)!;
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return AppBar(
      automaticallyImplyLeading: false, // Remove back button
      leadingWidth: isSmallScreen ? 120 : 150,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [lightVariant, Color.lerp(lightVariant, darkVariant, 0.2)!],
          ),
        ),
      ),
      leading: Padding(
        padding: EdgeInsets.only(
          left: isSmallScreen ? 8.0 : 16.0, 
          top: 8.0, 
          bottom: 8.0
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isLoadingLogo
                  ? Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : _logoUrl != null
                      ? Image.network(
                          _logoUrl!,
                          fit: BoxFit.contain,
                          height: 36,
                          width: 36,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.shopping_bag,
                                color: Colors.white,
                                size: 20,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      title: const Text(''), // Empty title
      centerTitle: true,
      elevation: 0, // Modern design: no elevation
      shadowColor: darkVariant.withValues(alpha: 0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      actions: <Widget>[
        // Cart button with badge
        Padding(
          padding: EdgeInsets.only(left: 2.0, right: isSmallScreen ? 8.0 : 16.0),
          child: AnimatedBuilder(
            animation: _cartScaleAnimation ?? const AlwaysStoppedAnimation(1.0),
            builder: (context, child) {
              return Transform.scale(
                scale: _cartScaleAnimation?.value ?? 1.0,
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black87,
                      size: 22,
                    ),
                    tooltip: 'Cart',
                    onPressed: () {
                      _cartAnimController?.forward(from: 0.0).then((_) {
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
                  if (widget.cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          widget.cartItemCount > 99 ? '99+' : widget.cartItemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}