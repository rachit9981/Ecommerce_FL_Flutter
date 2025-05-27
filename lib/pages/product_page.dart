import 'package:flutter/material.dart';
import 'package:ecom/components/product/product_comps.dart';
import 'package:ecom/services/products.dart';
import 'package:ecom/pages/cart_page.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  final String heroTag;

  const ProductPage({
    Key? key,
    required this.productId,
    required this.heroTag,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Product? _product;
  bool _isLoading = true;
  String? _error;
  Map<String, String> _selectedVariants = {};
  bool _isFavorite = false;
  final ProductService _productService = ProductService();
  
  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _productService.getProducts();
      
      // Find product by ID
      final product = products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => products.isNotEmpty ? products.first : throw Exception('No products found'),
      );

      setState(() {
        _product = product;
        _isLoading = false;
        
        // Initialize variant selections with first option of each type
        product.variant.forEach((key, values) {
          if (values.isNotEmpty) {
            _selectedVariants[key] = values.first;
          }
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load product',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProduct,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Favorite button with animation
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(_isFavorite),
                color: _isFavorite ? Colors.red : null,
              ),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite
                      ? 'Added to favorites'
                      : 'Removed from favorites'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image carousel
                ProductImageCarousel(
                  images: _product!.images,
                  heroTag: widget.heroTag,
                ),
                
                // Product header (title, price, rating)
                ProductHeader(
                  title: _product!.name,
                  price: _product!.discountPrice,
                  originalPrice: _product!.price,
                  rating: _product!.rating,
                  reviews: _product!.reviews,
                  brand: _product!.brand,
                  onReviewsTap: _scrollToReviews,
                ),
                
                const SizedBox(height: 8),
                
                // Product variants (colors, storage, etc.)
                if (_product!.variant.isNotEmpty)
                  ProductVariantSelector(
                    variants: _product!.variant,
                    selectedVariants: _selectedVariants,
                    onVariantSelected: (variantName, value) {
                      setState(() {
                        _selectedVariants[variantName] = value;
                      });
                    },
                  ),
                
                const SizedBox(height: 8),
                
                // Product description
                ProductDescription(
                  description: _product!.description,
                ),
                
                const SizedBox(height: 8),
                
                // Product specifications
                if (_product!.specifications.isNotEmpty)
                  ProductSpecifications(
                    specifications: _product!.specifications,
                  ),
                
                const SizedBox(height: 8),
                
                // Features section
                if (_product!.features.isNotEmpty)
                  _buildFeaturesSection(),
                
                // Bottom padding for add to cart button
                const SizedBox(height: 80),
              ],
            ),
          ),
          
          // Add to cart button (fixed at bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AddToCartSection(
              inStock: _product!.stock > 0,
              stockCount: _product!.stock,
              onAddToCart: _addToCart,
              onBuyNow: _buyNow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          ...(_product!.features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )).toList()),
        ],
      ),
    );
  }

  void _scrollToReviews() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scrolling to reviews...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to cart'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
        ),
      ),
    );
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceeding to checkout...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
