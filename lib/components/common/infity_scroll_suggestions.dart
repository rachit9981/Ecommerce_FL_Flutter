import 'package:flutter/material.dart';
import 'package:ecom/components/common/suggestions.dart';

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

  // Responsive helper methods
  int _getResponsiveCrossAxisCount(BuildContext context) {
    if (widget.crossAxisCount != null) return widget.crossAxisCount!;
    
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2; // Mobile
    } else if (screenWidth < 900) {
      return 3; // Tablet
    } else {
      return 4; // Desktop
    }
  }

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
            ),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
                fontSize: _getResponsiveFontSize(context, 18),
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
    final isVerySmallScreen = screenWidth < 360;
    
    // Adjust padding based on screen size
    final contentPadding = isVerySmallScreen ? 6.0 : 
                           isLargeScreen ? 12.0 : 8.0;
    
    return Hero(
      tag: heroTag,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.06),
              blurRadius: isLargeScreen ? 8 : 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
          color: Colors.transparent,
          child: InkWell(
            onTap: product.onTap,
            borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image section - 60% of height
                  AspectRatio(
                    aspectRatio: 1.0, // Square image
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isLargeScreen ? 16 : 12),
                            topRight: Radius.circular(isLargeScreen ? 16 : 12),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            child: _buildProductImage(product, isLargeScreen),
                          ),
                        ),
                        
                        // Product badges
                        if (product.discountPercentage != null || product.isNew || product.isFeatured)
                          Positioned(
                            top: isLargeScreen ? 10 : 8,
                            left: isLargeScreen ? 10 : 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.discountPercentage != null)
                                  _buildBadge(
                                    "-${product.discountPercentage}%",
                                    Theme.of(context).colorScheme.error,
                                    isLargeScreen,
                                  ),
                                
                                if (product.isNew)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: _buildBadge(
                                      "NEW",
                                      Theme.of(context).colorScheme.tertiary,
                                      isLargeScreen,
                                    ),
                                  ),
                                if (product.isFeatured)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: _buildBadge(
                                      "FEATURED",
                                      Theme.of(context).colorScheme.secondary,
                                      isLargeScreen,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                
                // Improved product information section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title with adaptive size
                        Flexible(
                          flex: 3,
                          child: Text(
                            product.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: _getResponsiveFontSize(context, isVerySmallScreen ? 12 : 13),
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                            maxLines: isVerySmallScreen ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        
                        // Description with adaptive visibility
                        if (product.description != null && !isVerySmallScreen)
                          Padding(
                            padding: EdgeInsets.only(top: isLargeScreen ? 3 : 2),
                            child: Text(
                              product.description!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: _getResponsiveFontSize(context, isLargeScreen ? 11 : 10),
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        // Ratings with adaptive size
                        if (product.rating != null)
                          Padding(
                            padding: EdgeInsets.only(top: isLargeScreen ? 3 : 2),
                            child: Row(
                              children: [
                                _buildRatingStars(product.rating!, isLargeScreen),
                                if (product.reviewCount != null && !isVerySmallScreen)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Text(
                                      "(${product.reviewCount})",
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(context, isLargeScreen ? 9 : 8),
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        
                        const Spacer(),
                        
                        // Price section with adaptive layout
                        if (product.price != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                flex: 3,
                                child: Text(
                                  "₹${product.price!.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getResponsiveFontSize(context, isVerySmallScreen ? 13 : 14),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.originalPrice != null && 
                                  product.originalPrice! > product.price! &&
                                  screenWidth > 320) // Hide on extremely small screens
                                Flexible(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      "₹${product.originalPrice!.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        fontSize: _getResponsiveFontSize(context, isVerySmallScreen ? 10 : 11),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
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
      ),),);
  }

  Widget _buildProductImage(SuggestionItem product, bool isLargeScreen) {
    return product.imageUrl != null
        ? SmoothNetworkImage(
            imageUrl: product.imageUrl!,
            fit: BoxFit.cover,
          )
        : Icon(
            Icons.image,
            size: isLargeScreen ? 40 : 32, // Reduced size
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          );
  }

  Widget _buildLoadingRow() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading more products...',
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Found',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: _getResponsiveFontSize(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
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
  
  Widget _buildBadge(String text, Color color, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 8 : 6, 
        vertical: isLargeScreen ? 4 : 3
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(isLargeScreen ? 8 : 6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: _getResponsiveFontSize(context, 9), // Reduced size
        ),
      ),);
  }

  Widget _buildRatingStars(double rating, bool isLargeScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 360;
    
    // Adjust star size based on screen size
    final starSize = isVerySmallScreen ? 10.0 : 
                     isLargeScreen ? 14.0 : 12.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(isVerySmallScreen ? 3 : 5, (index) {
        if (index < rating.floor()) {
          return Icon(
            Icons.star_rounded,
            size: starSize,
            color: Colors.amber.shade600,
          );
        } else if (index < rating.ceil() && index >= rating.floor()) {
          return Icon(
            Icons.star_half_rounded,
            size: starSize,
            color: Colors.amber.shade600,
          );
        } else {
          return Icon(
            Icons.star_border_rounded,
            size: starSize,
            color: Colors.amber.shade600.withOpacity(0.4),
          );
        }
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
          title: 'All Products',
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