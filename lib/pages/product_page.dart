import 'package:flutter/material.dart';
import 'package:ecom/components/product/product_comps.dart';
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
  late Product _product;
  Color? _selectedColor;
  String? _selectedSize;
  Map<String, String> _selectedTechSpecs = {};
  bool _isFavorite = false;
  
  @override
  void initState() {
    super.initState();
    
    // Choose which product to show based on productId
    if (widget.productId == '2') {
      _product = Product.getSampleSmartphone();
    } else {
      _product = Product.getSampleProduct();
    }
    
    // Initialize selections
    if (_product.colors.isNotEmpty) {
      _selectedColor = _product.colors.first;
    }
    
    if (_product.sizes.isNotEmpty) {
      _selectedSize = _product.sizes.first;
    }
    
    // Initialize tech specs with first option of each type
    _product.techSpecs.forEach((key, values) {
      if (values.isNotEmpty) {
        _selectedTechSpecs[key] = values.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  images: _product.images,
                  heroTag: widget.heroTag,
                ),
                
                // Product header (title, price, rating)
                ProductHeader(
                  title: _product.title,
                  price: _product.price,
                  originalPrice: _product.originalPrice,
                  rating: _product.rating,
                  reviewCount: _product.reviewCount,
                  brand: _product.brand,
                  onReviewsTap: _scrollToReviews,
                ),
                
                const SizedBox(height: 8),
                
                // Tech specs selector (RAM, storage)
                if (_product.techSpecs.isNotEmpty)
                  TechSpecSelector(
                    specs: _product.techSpecs,
                    selectedSpecs: _selectedTechSpecs,
                    onSpecSelected: (specName, value) {
                      setState(() {
                        _selectedTechSpecs[specName] = value;
                      });
                    },
                  ),
                
                const SizedBox(height: 8),
                
                // Color and size selector
                if (_product.colors.isNotEmpty || _product.sizes.isNotEmpty)
                  ProductVariantSelector(
                    availableColors: _product.colors,
                    availableSizes: _product.sizes,
                    selectedColor: _selectedColor,
                    selectedSize: _selectedSize,
                    onColorSelected: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    onSizeSelected: (size) {
                      setState(() {
                        _selectedSize = size;
                      });
                    },
                  ),
                
                const SizedBox(height: 8),
                
                // Product description
                ProductDescription(
                  description: _product.description,
                ),
                
                const SizedBox(height: 8),
                
                // Product specifications
                if (_product.specifications.isNotEmpty)
                  ProductSpecifications(
                    specifications: _product.specifications,
                  ),
                
                const SizedBox(height: 8),
                
                // Product reviews
                ProductReviews(
                  rating: _product.rating,
                  reviewCount: _product.reviewCount,
                  reviews: _product.reviews,
                  onViewAllTap: _showAllReviews,
                ),
                
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
              inStock: _product.inStock,
              stockCount: _product.stockCount,
              onAddToCart: _addToCart,
              onBuyNow: _buyNow,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToReviews() {
    // Implementation would require ScrollController to scroll to reviews section
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scrolling to reviews...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAllReviews() {
    // In a real app, navigate to reviews page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing all ${_product.reviewCount} reviews...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addToCart() {
    // Add to cart logic
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
    // Buy now logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proceeding to checkout...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
