import 'package:flutter/material.dart';
import 'package:ecom/components/common/suggestions.dart';
import 'package:ecom/components/product/product_comps.dart'; // Added import

enum LoadingStatus { idle, loading, error, noMoreData }

/// Widget for displaying products in a grid with infinite scrolling capability
class InfiniteProductGrid extends StatefulWidget {
  final List<SuggestionItem> initialProducts;
  
  final Future<List<SuggestionItem>> Function(int page) loadMoreProducts;
  
  final int? crossAxisCount;
  
  final double? spacing;
  
  final double? childAspectRatio;
  
  final EdgeInsets? padding;
  
  final String? title;
  
  final bool showTitle;
  
  final bool loadOnInit;
  
  // Add centerLoading parameter
  final bool centerLoading;

  const InfiniteProductGrid({
    Key? key,
    required this.initialProducts,
    required this.loadMoreProducts,
    this.crossAxisCount,
    this.spacing,
    this.childAspectRatio,
    this.padding,
    this.title,
    this.showTitle = true,
    this.loadOnInit = false,
    this.centerLoading = false,
  }) : super(key: key);

  @override
  State<InfiniteProductGrid> createState() => _InfiniteProductGridState();
}

class _InfiniteProductGridState extends State<InfiniteProductGrid> {
  final List<SuggestionItem> _products = [];
  final ScrollController _scrollController = ScrollController();
  LoadingStatus _loadingStatus = LoadingStatus.idle;
  int _currentPage = 1;
  bool _hasInitialized = false;

  double _getResponsiveSpacing(BuildContext context) {
    if (widget.spacing != null) return widget.spacing!;
    
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 12.0; // Mobile
    } else if (screenWidth < 900) {
      return 16.0; // Tablet
    } else {
      return 20.0; // Desktop
    }
  }

  double _getResponsiveChildAspectRatio(BuildContext context) {
    if (widget.childAspectRatio != null) return widget.childAspectRatio!;
    
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 0.65; // Mobile - taller cards
    } else if (screenWidth < 900) {
      return 0.7; // Tablet
    } else {
      return 0.75; // Desktop - wider cards
    }
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    if (widget.padding != null) return widget.padding!;
    
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.all(12.0); // Mobile
    } else if (screenWidth < 900) {
      return const EdgeInsets.all(16.0); // Tablet
    } else {
      return const EdgeInsets.all(20.0); // Desktop
    }
  }

  // Add a more refined responsive font size calculation
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    double scaleFactor = 1.0;
    if (screenWidth < 360) {
      scaleFactor = 0.8; // Very small screens
    } else if (screenWidth < 600) {
      scaleFactor = 0.85; // Small screens
    } else if (screenWidth < 900) {
      scaleFactor = 0.9; // Medium screens
    } else {
      scaleFactor = 0.95; // Large screens
    }
    
    return baseFontSize * scaleFactor * textScaleFactor;
  }

  @override
  void initState() {
    super.initState();
    _products.addAll(widget.initialProducts);
    
    _scrollController.addListener(_scrollListener);
    
    if (widget.loadOnInit && widget.initialProducts.isEmpty) {
      _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_loadingStatus == LoadingStatus.loading || 
        _loadingStatus == LoadingStatus.noMoreData) {
      return;
    }
    
    if (_scrollController.position.extentAfter < 200) {
      _loadMoreData();
    }
  }
  
  Future<void> _loadMoreData() async {
    if (_loadingStatus == LoadingStatus.loading || 
        _loadingStatus == LoadingStatus.noMoreData) {
      return;
    }
    
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });
    
    try {
      final newProducts = await widget.loadMoreProducts(_currentPage);
      
      setState(() {
        if (newProducts.isEmpty) {
          _loadingStatus = LoadingStatus.noMoreData;
        } else {
          _products.addAll(newProducts);
          _currentPage++;
          _loadingStatus = LoadingStatus.idle;
        }
        _hasInitialized = true;
      });
    } catch (e) {
      setState(() {
        _loadingStatus = LoadingStatus.error;
        _hasInitialized = true;
      });
    }
  }
  
  void _retryLoading() {
    setState(() {
      _loadingStatus = LoadingStatus.idle;
    });
    _loadMoreData();
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = _getResponsivePadding(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section if showTitle is true
        if (widget.showTitle && widget.title != null)
          Padding(
            padding: EdgeInsets.only(
              left: responsivePadding.left,
              right: responsivePadding.right,
              top: responsivePadding.top,
              bottom: 8,
            ),            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                fontSize: _getResponsiveFontSize(context, 18),
                color: Colors.black87,
              ),
            ),
          ),
          
        Expanded(
          child: _products.isEmpty && !_hasInitialized
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    controller: _scrollController,
                    padding: responsivePadding,
                    itemCount: (_products.length / 2).ceil() + (_loadingStatus == LoadingStatus.noMoreData ? 0 : 1),
                    itemBuilder: (context, index) {
                      // If this is the last row and we're loading more items
                      if (index >= (_products.length / 2).ceil()) {
                        return _buildLoadingRow();
                      }
                      
                      // Calculate the indices for the two products in this row
                      final firstProductIndex = index * 2;
                      final secondProductIndex = firstProductIndex + 1;
                      
                      // Calculate the product item height based on screen width
                      final screenWidth = MediaQuery.of(context).size.width;
                      final itemWidth = (screenWidth - responsivePadding.horizontal - _getResponsiveSpacing(context)) / 2;
                      final aspectRatio = _getResponsiveChildAspectRatio(context);
                      final itemHeight = itemWidth / aspectRatio;
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: _getResponsiveSpacing(context)),
                        child: SizedBox(
                          height: itemHeight, // Explicitly set the row height
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // First product
                              Expanded(
                                child: _buildProductItem(_products[firstProductIndex]),
                              ),
                              
                              SizedBox(width: _getResponsiveSpacing(context)),
                              
                              // Second product (if available)
                              if (secondProductIndex < _products.length)
                                Expanded(
                                  child: _buildProductItem(_products[secondProductIndex]),
                                )
                              else
                                // Empty placeholder to maintain the layout
                                Expanded(
                                  child: SizedBox.shrink(),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    ]);
  }
  
  Widget _buildProductItem(SuggestionItem product) {
    final heroTag = 'infinite_grid_product_${product.id}';
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final isVerySmallScreen = screenWidth < 360;    // Adjust padding based on screen size
    final contentPadding = isVerySmallScreen ? 6.0 : // Reduced padding for cleaner look
                           isLargeScreen ? 10.0 : 8.0; // Reduced padding for cleaner look

    return Hero(
      tag: heroTag,
      child: Container(        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(12), // Match updated border radius
          color: Colors.transparent,
          child: InkWell(
            onTap: product.onTap,
            borderRadius: BorderRadius.circular(12), // Match updated border radius
            child: Container(
              // Removed redundant decoration, parent Container handles it
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  // Product Image - AspectRatio for consistent image height
                  AspectRatio(
                    aspectRatio: 1.0, // Square aspect ratio for image container
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: _buildProductImage(product, isLargeScreen),
                    ),
                  ),
                  // Product Information
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(contentPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                        children: [
                          // Product Title
                          Flexible(                            child: Text(
                              product.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: _getResponsiveFontSize(context, 14),
                                height: 1.3,
                                letterSpacing: -0.3,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                          ),
                          
                          // Spacer to push price and rating down if title is short
                          const Spacer(),

                          // Price and Rating Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Product Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.originalPrice != null && product.price != null && product.originalPrice! > product.price!)                                    Text(
                                      '₹${product.originalPrice!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey.shade500,
                                        fontSize: _getResponsiveFontSize(context, 11),
                                        height: 1.2,
                                      ),
                                    ),
                                  if (product.price != null)                                  Text(
                                    '₹${product.price!.toStringAsFixed(0)}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: _getResponsiveFontSize(context, 15),
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              // Rating
                              if (product.rating != null && product.rating! > 0)
                                _buildRatingStars(product.rating!, isLargeScreen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),);
  }

  Widget _buildProductImage(SuggestionItem product, bool isLargeScreen) {
    return product.imageUrl != null
        ? CustomNetworkImage( // Replaced SmoothNetworkImage
            imageUrl: product.imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity, // Ensure it fills the AspectRatio
            height: double.infinity, // Ensure it fills the AspectRatio
            placeholder: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
            errorWidget: Container(
              color: Colors.grey.shade100,
              child: Icon(
                Icons.broken_image_outlined,
                size: isLargeScreen ? 40 : 32,
                color: Colors.grey.shade400,
              ),
            ),
          )
        : Container( // Added a container for consistent background
            color: Colors.grey.shade50,
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: isLargeScreen ? 40 : 32,
                color: Colors.grey.shade400,
              ),
            ),
          );
  }
  Widget _buildLoadingRow() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),Text(
              'Loading more...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: _getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 12),Text(
            'No Products',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),          const SizedBox(height: 6),          Text(
            'Check back later',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: _getResponsiveFontSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_loadingStatus == LoadingStatus.error)
            OutlinedButton.icon(
              onPressed: _retryLoading,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildRatingStars(double rating, bool isLargeScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 360;
    
    final starSize = isVerySmallScreen ? 12.0 : 
                     isLargeScreen ? 16.0 : 14.0; // Slightly larger stars
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) { // Always show 5 stars for consistency
        final starValue = index + 1;
        IconData iconData;
        Color starColor = Colors.amber.shade600;

        if (starValue <= rating) {
          iconData = Icons.star_rounded;
        } else if (starValue - 0.5 <= rating) {
          iconData = Icons.star_half_rounded;
        } else {
          iconData = Icons.star_border_rounded;
          starColor = Colors.grey.shade400; // Dimmer color for empty stars
        }
        
        return Icon(
          iconData,
          size: starSize,
          color: starColor,
        );
      }),
    );
  }
}

/// A wrapper around InfiniteProductGrid for showing products in a vertical list
class InfiniteProductList extends StatelessWidget {
  final List<SuggestionItem> initialProducts;
  final Future<List<SuggestionItem>> Function(int page) loadMoreProducts;
  final String? title;
  final bool showTitle;
  final EdgeInsets? padding;
  final bool loadOnInit;
  final bool centerLoading;

  const InfiniteProductList({
    Key? key,
    required this.initialProducts,
    required this.loadMoreProducts,
    this.title,
    this.showTitle = true,
    this.padding,
    this.loadOnInit = false,
    this.centerLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return InfiniteProductGrid(
      initialProducts: initialProducts,
      loadMoreProducts: loadMoreProducts,
      crossAxisCount: 1,
      childAspectRatio: screenWidth < 600 ? 2.5 : 3.0, // Adjusted aspect ratio
      spacing: screenWidth < 600 ? 10.0 : 14.0, // Reduced spacing
      padding: padding,
      title: title,
      showTitle: showTitle,
      loadOnInit: loadOnInit,
      centerLoading: centerLoading,
    );
  }
}

/// Usage example page for infinite scroll products
class InfiniteProductsExample extends StatelessWidget {
  final List<SuggestionItem> sampleProducts;
  
  const InfiniteProductsExample({
    Key? key,
    required this.sampleProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: InfiniteProductGrid(
          initialProducts: sampleProducts.take(4).toList(),
          loadMoreProducts: (page) async {
            await Future.delayed(const Duration(seconds: 1));
            final startIndex = page * 4;
            if (startIndex >= sampleProducts.length) {
              return []; // No more products
            }
            
            final endIndex = (startIndex + 4 <= sampleProducts.length) 
                ? startIndex + 4 
                : sampleProducts.length;
                
            return sampleProducts.sublist(startIndex, endIndex);
          },
          title: 'Products',
          showTitle: true,
          crossAxisCount: 2,
          spacing: 16,
          childAspectRatio: 0.7,
          loadOnInit: true,
        ),
      ),
    );
  }
}