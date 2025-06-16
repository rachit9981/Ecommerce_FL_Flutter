import 'package:flutter/material.dart';
import 'package:ecom/services/cart_wishlist.dart';
import 'package:ecom/pages/product_page.dart';
import 'package:provider/provider.dart';
import 'package:ecom/providers/user_provider.dart';
import 'package:ecom/components/common/login_required.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({Key? key}) : super(key: key);

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final CartWishlistService _wishlistService = CartWishlistService();
  
  List<WishlistItem> _wishlistItems = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadWishlist();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWishlist() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final wishlistItems = await _wishlistService.getWishlist();
      
      if (mounted) {
        setState(() {
          _wishlistItems = wishlistItems;
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromWishlist(String itemId) async {
    if (_isProcessing) return;
    
    try {
      setState(() {
        _isProcessing = true;
      });
      
      await _wishlistService.removeFromWishlist(itemId);
      
      if (mounted) {
        setState(() {
          _wishlistItems.removeWhere((item) => item.itemId == itemId);
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text('Item removed from wishlist'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.grey.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: ${e.toString().replaceAll('Exception: ', '')}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }
  Future<void> _addToCart(WishlistItem item) async {
    if (_isProcessing) return;
    
    try {
      setState(() {
        _isProcessing = true;
      });
      
      await _wishlistService.addToCart(item.productId, variantId: item.variantId);
      
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${item.name} added to cart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to add to cart: ${e.toString().replaceAll('Exception: ', '')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  AppBar _buildAppBar({bool isLoading = false}) {
    return AppBar(
      elevation: 0,
      title: const Text('My Wishlist'),
      actions: [
        if (_isProcessing && !isLoading)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // If not authenticated, show login prompt for wishlist features
        if (!userProvider.isAuthenticated) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: const Text('My Wishlist'),
              elevation: 0,
              centerTitle: true,
            ),
            body: LoginRequired(
              title: 'Login to Access Your Wishlist',
              message: 'Please login to view and manage your saved items',
              icon: Icons.favorite_border,
            ),
          );
        }

        // If authenticated, show the wishlist content
        final theme = Theme.of(context);
        final primaryColor = theme.colorScheme.primary;
        
        if (_isLoading) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: _buildAppBar(isLoading: true),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Loading your wishlist...',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          );
        }
        
        if (_error != null) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: _buildAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
                  const SizedBox(height: 20),
                  Text(
                    'Failed to load wishlist',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadWishlist,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildAppBar(),
          body: _wishlistItems.isEmpty
              ? _buildEmptyWishlist(primaryColor)
              : _buildWishlistItems(context),
        );
      },
    );
  }

  Widget _buildEmptyWishlist(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 72,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Save your favorite items to buy them later',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Start Shopping'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItems(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadWishlist,
      child: Column(
        children: [
          // Summary bar at the top
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 20,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_wishlistItems.length} ${_wishlistItems.length == 1 ? 'item' : 'items'} in your wishlist',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Wishlist items in a grid (2 per row)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _wishlistItems.length,
              itemBuilder: (context, index) {
                final item = _wishlistItems[index];
                
                // Create staggered animation for each item
                final Animation<double> animation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (1 / _wishlistItems.length) * index,
                    1.0,
                    curve: Curves.easeOut,
                  ),
                );
                
                return _buildAnimatedItem(context, item, animation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(BuildContext context, WishlistItem item, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
        child: _buildWishlistItem(context, item),
      ),
    );
  }

  Widget _buildWishlistItem(BuildContext context, WishlistItem item) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Card(
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: item.productId,
                heroTag: 'wishlist_${item.itemId}',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image and heart icon
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),                  child: (item.imageUrl != null && item.imageUrl!.isNotEmpty) || 
                         (item.image != null && item.image!.isNotEmpty)
                      ? Hero(
                          tag: 'wishlist_${item.itemId}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              item.imageUrl ?? item.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(Icons.image, size: 40, color: Colors.grey.shade400),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.image, size: 40, color: Colors.grey.shade400),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => _removeFromWishlist(item.itemId),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.red.shade400,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),                    const SizedBox(height: 6),
                    // Brand and category info
                    if (item.brand != null || item.category != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          [item.brand, item.category].where((e) => e != null).join(' • '),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    // Price
                    Text(
                      item.price != null ? '₹${item.price!.toStringAsFixed(2)}' : 'Price not available',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Variant info if available
                    if (item.variant != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            _getVariantDisplayText(item.variant!),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    // Stock info if available
                    if (item.stock != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.stock! > 0 ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            color: item.stock! > 0 ? Colors.green.shade600 : Colors.red.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(item),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                          padding: EdgeInsets.zero,
                          shadowColor: primaryColor.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getVariantDisplayText(Map<String, dynamic> variant) {
    final List<String> variantInfo = [];
    
    // Common variant fields to display
    if (variant['color'] != null) variantInfo.add('${variant['color']}');
    if (variant['size'] != null) variantInfo.add('${variant['size']}');
    if (variant['storage'] != null) variantInfo.add('${variant['storage']}');
    if (variant['ram'] != null) variantInfo.add('${variant['ram']}');
    if (variant['memory'] != null) variantInfo.add('${variant['memory']}');
    
    return variantInfo.isNotEmpty ? variantInfo.join(' • ') : 'Variant';
  }
}
