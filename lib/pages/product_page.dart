import 'package:flutter/material.dart';
import 'package:ecom/components/product/product_comps.dart';
// import 'package:ecom/services/products.dart'; // Kept for Review class if needed, or can be removed if DetailedProduct handles all Review aspects
import 'package:ecom/services/detailed_product.dart'; // Added for DetailedProductService and DetailedProduct
import 'package:ecom/services/cart_wishlist.dart';
import 'package:ecom/pages/cart_page.dart';
import 'package:ecom/pages/wishlist.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  final String heroTag;

  const ProductPage({Key? key, required this.productId, required this.heroTag})
    : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with TickerProviderStateMixin {
  DetailedProduct? _product; // Changed from Product?
  bool _isLoading = true;
  String? _error;
  Map<String, String> _selectedVariants = {};
  bool _isFavorite = false;
  bool _isAddingToCart = false;
  bool _isTogglingWishlist = false;

  final DetailedProductService _productService = DetailedProductService(); // Changed from ProductService
  final CartWishlistService _cartService = CartWishlistService();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _specController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _specAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _specController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _specAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _specController, curve: Curves.elasticOut),
    );

    _loadProduct();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _specController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch detailed product info
      final detailedProduct = await _productService.getDetailedProduct(widget.productId);

      // Check if product is in wishlist
      await _checkWishlistStatus(detailedProduct.id);

      setState(() {
        _product = detailedProduct;
        _isLoading = false;

        // Initialize selected variants from the DetailedProduct model
        _product!.variants.forEach((key, values) {
          if (values.isNotEmpty) {
            _selectedVariants[key] = values.first;
          }
        });
      });

      _fadeController.forward();
      _slideController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _specController.forward();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _checkWishlistStatus(String productId) async {
    try {
      final wishlistItems = await _cartService.getWishlist();
      final isInWishlist = wishlistItems.any(
        (item) => item.productId == productId,
      );

      if (mounted) {
        setState(() {
          _isFavorite = isInWishlist;
        });
      }
    } catch (e) {
      // Silently fail, keep wishlist status as false
      if (mounted) {
        setState(() {
          _isFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade600,
                        ),
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading Amazing Product...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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

    if (_error != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.red.shade50, Colors.orange.shade50],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.grey.shade700),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load product details',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _loadProduct,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade100, Colors.grey.shade200],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.grey.shade700),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Product not found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Modern app bar
          _buildModernAppBar(),

          // Scrollable content
          Positioned.fill(
            top: 100,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image carousel
                      _buildConnectedImageCarousel(),

                      // Connected product information
                      _buildConnectedProductInfo(),

                      const SizedBox(height: 120), // Space for the AddToCartSection
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Modern add to cart section
          _buildModernAddToCartSection(),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.grey.shade800,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon:
                        _isTogglingWishlist
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red.shade300,
                                ),
                              ),
                            )
                            : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: RotationTransition(
                                    turns: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                _isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey<bool>(_isFavorite),
                                color:
                                    _isFavorite
                                        ? Colors.red.shade500
                                        : Colors.grey.shade800,
                                size: 20,
                              ),
                            ),
                    onPressed: _toggleWishlist,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleWishlist() async {
    if (_product == null || _isTogglingWishlist) return;

    setState(() {
      _isTogglingWishlist = true;
    });

    try {
      if (_isFavorite) {
        // Get wishlist to find the item ID
        final wishlistItems = await _cartService.getWishlist();
        final wishlistItem = wishlistItems.firstWhere(
          (item) => item.productId == _product!.id,
          orElse: () => throw Exception('Item not found in wishlist'),
        );

        // Remove from wishlist
        await _cartService.removeFromWishlist(wishlistItem.itemId);

        if (mounted) {
          setState(() {
            _isFavorite = false;
            _isTogglingWishlist = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.favorite_border, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text('Removed from favorites'),
                ],
              ),
              backgroundColor: Colors.grey.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add to wishlist
        await _cartService.addToWishlist(_product!.id);

        if (mounted) {
          setState(() {
            _isFavorite = true;
            _isTogglingWishlist = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Added to favorites')),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WishlistPage(),
                        ),
                      ).then((_) {
                        // Refresh wishlist status when returning
                        if (_product != null) {
                          _checkWishlistStatus(_product!.id);
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'VIEW WISHLIST',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTogglingWishlist = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to update favorites: ${e.toString().replaceAll('Exception: ', '')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildConnectedImageCarousel() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ProductImageCarousel(
          images: _product!.images,
          heroTag: widget.heroTag,
        ),
      ),
    );
  }

  Widget _buildConnectedProductInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ProductHeader(
              title: _product!.name,
              price: _product!.discountPrice,
              originalPrice: _product!.price,
              // Defensively pass 0.0 for rating if totalReviews is 0 to avoid potential division by zero in ProductHeader
              rating: (_product!.totalReviews == 0) ? 0.0 : _product!.rating,
              reviews: _product!.totalReviews,
              brand: _product!.brand,
              onReviewsTap: _scrollToReviews,
            ),
          ),

          if (_product!.variants.isNotEmpty) ...[ // Changed from _product!.variant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ProductVariantSelector(
                variants: _product!.variants, // Changed from _product!.variant
                selectedVariants: _selectedVariants,
                onVariantSelected: (variantName, value) {
                  setState(() {
                    _selectedVariants[variantName] = value;
                  });
                },
              ),
            ),
          ],

          // Product Description
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ProductDescription(description: _product!.description),
          ),

          if (_product!.specifications.isNotEmpty) ...[
            _buildConnectedSpecifications(),
          ],

          if (_product!.features.isNotEmpty) ...[
            Container(
              height: 1,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(vertical: 24),
            ),
            _buildConnectedFeatures(),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectedSpecifications() {
    return FadeTransition(
      opacity: _specAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.engineering_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technical Specifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    Text(
                      'Detailed product information',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Specifications table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
            },
            children:
                _product!.specifications.entries.map((entry) {
                  return TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade100,
                          width: 1,
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 4,
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 4,
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Key Features',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),

    // Features list
    Column(
      children: _product!.features.asMap().entries.map<Widget>((entry) {
        int index = entry.key;
        String feature = entry.value;
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 120)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    )
      ],
    );
  }

  Widget _buildModernAddToCartSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: AddToCartSection(
          inStock: _product!.stock > 0,
          stockCount: _product!.stock,
          onAddToCart: _isAddingToCart ? null : _addToCart,
          onBuyNow: _isAddingToCart ? null : _buyNow,
          isLoading: _isAddingToCart,
        ),
      ),
    );
  }

  void _scrollToReviews() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.reviews, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text('Scrolling to reviews...'),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addToCart() async {
    if (_product == null) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Get selected quantity from variant (default to 1 if not specified)
      int quantity = 1;
      if (_selectedVariants.containsKey('quantity')) {
        quantity = int.tryParse(_selectedVariants['quantity'] ?? '1') ?? 1;
      }

      final result = await _cartService.addToCart(
        _product!.id,
        quantity: quantity,
      );

      // Only update UI if widget is still mounted
      if (!mounted) return;

      setState(() {
        _isAddingToCart = false;
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
              Text(
                'Added to cart',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ),
      );
    } catch (e) {
      // Only update UI if widget is still mounted
      if (!mounted) return;

      setState(() {
        _isAddingToCart = false;
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
                  Icons.error_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to add to cart: ${e.toString().replaceAll('Exception: ', '')}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _buyNow() async {
    if (_product == null) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Get selected quantity from variant (default to 1 if not specified)
      int quantity = 1;
      if (_selectedVariants.containsKey('quantity')) {
        quantity = int.tryParse(_selectedVariants['quantity'] ?? '1') ?? 1;
      }

      // First add to cart
      await _cartService.addToCart(_product!.id, quantity: quantity);

      // Only update UI if widget is still mounted
      if (!mounted) return;

      setState(() {
        _isAddingToCart = false;
      });

      // Then navigate to cart page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartPage()),
      );
    } catch (e) {
      // Only update UI if widget is still mounted
      if (!mounted) return;

      setState(() {
        _isAddingToCart = false;
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
                  Icons.error_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to proceed: ${e.toString().replaceAll('Exception: ', '')}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
