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

  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    double scaleFactor = 1.0;
    if (screenWidth < 600) {
      scaleFactor = 0.9; // Slightly smaller on mobile
    } else if (screenWidth > 900) {
      scaleFactor = 1.1; // Slightly larger on desktop
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
                letterSpacing: -0.5,
                fontSize: _getResponsiveFontSize(context, 20),
              ),
            ),
          ),
          
        Expanded(
          child: _products.isEmpty && !_hasInitialized
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = _getResponsiveCrossAxisCount(context);
                        final spacing = _getResponsiveSpacing(context);
                        final childAspectRatio = _getResponsiveChildAspectRatio(context);
                        
                        return GridView.builder(
                          controller: _scrollController,
                          padding: responsivePadding,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: _products.length + (_loadingStatus == LoadingStatus.noMoreData ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index >= _products.length) {
                              return Center(child: _buildLoadMoreIndicator());
                            }
                            
                            return _buildProductItem(_products[index]);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  Widget _buildProductItem(SuggestionItem product) {
    final heroTag = 'infinite_grid_product_${product.id}';
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    
    return Hero(
      tag: heroTag,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: isLargeScreen ? 12 : 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: isLargeScreen ? 6 : 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
          color: Colors.transparent,
          child: InkWell(
            onTap: product.onTap,
            borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image with badges
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isLargeScreen ? 20 : 16),
                            topRight: Radius.circular(isLargeScreen ? 20 : 16),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.grey.shade50,
                                  Colors.grey.shade100,
                                ],
                              ),
                            ),
                            child: _buildProductImage(product, isLargeScreen),
                          ),
                        ),
                        
                        // Gradient overlay for better badge visibility
                        if (product.discountPercentage != null || product.isNew || product.isFeatured)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isLargeScreen ? 20 : 16),
                                  topRight: Radius.circular(isLargeScreen ? 20 : 16),
                                ),
                              ),
                            ),
                          ),
                        
                        // Product badges
                        if (product.discountPercentage != null || product.isNew || product.isFeatured)
                          Positioned(
                            top: isLargeScreen ? 12 : 8,
                            left: isLargeScreen ? 12 : 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.discountPercentage != null)
                                  _buildBadge(
                                    "-${product.discountPercentage}%",
                                    [Colors.red.shade700, Colors.red.shade500],
                                    isLargeScreen,
                                  ),
                                
                                if (product.isNew)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: _buildBadge(
                                      "NEW",
                                      [Colors.green.shade700, Colors.green.shade500],
                                      isLargeScreen,
                                    ),
                                  ),
                                if (product.isFeatured)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: _buildBadge(
                                      "FEATURED",
                                      [Colors.purple.shade700, Colors.purple.shade500],
                                      isLargeScreen,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                
                // Product information
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(isLargeScreen ? 12.0 : 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            product.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: _getResponsiveFontSize(context, 14),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        
                        if (product.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              product.description!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: _getResponsiveFontSize(context, 12),
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        
                        if (product.rating != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                _buildRatingStars(product.rating!, isLargeScreen),
                                if (product.reviewCount != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      "(${product.reviewCount})",
                                      style: TextStyle(
                                        fontSize: _getResponsiveFontSize(context, 10),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        
                        const Spacer(),
                        
                        if (product.price != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  "₹${product.price!.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getResponsiveFontSize(context, 16),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (product.originalPrice != null && product.originalPrice! > product.price!)
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      "₹${product.originalPrice!.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: _getResponsiveFontSize(context, 12),
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
            size: isLargeScreen ? 50 : 40,
            color: Colors.grey,
          );
  }

  Widget _buildLoadMoreIndicator() {
    switch (_loadingStatus) {
      case LoadingStatus.loading:
        return widget.centerLoading 
          ? Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width, // Take full width
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading more products...',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Loading more products...',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );

      case LoadingStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 30),
                  const SizedBox(height: 8),
                  const Text('Failed to load more products'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _retryLoading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );

      case LoadingStatus.noMoreData:
        return const SizedBox.shrink();

      default:
        return const SizedBox(height: 80);
    }
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Products Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or check back later',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_loadingStatus == LoadingStatus.error)
            ElevatedButton.icon(
              onPressed: _retryLoading,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildBadge(String text, List<Color> gradientColors, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 10 : 8, 
        vertical: isLargeScreen ? 6 : 4
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isLargeScreen ? 10 : 8),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: _getResponsiveFontSize(context, 10),
        ),
      ),);
  }

  Widget _buildRatingStars(double rating, bool isLargeScreen) {
    final starSize = isLargeScreen ? 16.0 : 14.0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(
            Icons.star_rounded,
            size: starSize,
            color: Colors.amber,
          );
        } else if (index < rating.ceil() && index >= rating.floor()) {
          return Icon(
            Icons.star_half_rounded,
            size: starSize,
            color: Colors.amber,
          );
        } else {
          return Icon(
            Icons.star_border_rounded,
            size: starSize,
            color: Colors.amber.withOpacity(0.7),
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
  final bool centerLoading;  // Add centerLoading parameter here too

  const InfiniteProductList({
    Key? key,
    required this.initialProducts,
    required this.loadMoreProducts,
    this.title,
    this.showTitle = true,
    this.padding,
    this.loadOnInit = false,
    this.centerLoading = false,  // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return InfiniteProductGrid(
      initialProducts: initialProducts,
      loadMoreProducts: loadMoreProducts,
      crossAxisCount: 1,
      childAspectRatio: screenWidth < 600 ? 2.2 : 2.8, // Responsive aspect ratio
      spacing: screenWidth < 600 ? 12.0 : 16.0,
      padding: padding,
      title: title,
      showTitle: showTitle,
      loadOnInit: loadOnInit,
      centerLoading: centerLoading,  // Pass the parameter
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
