import 'package:flutter/material.dart';
import 'package:ecom/components/common/suggestions.dart';

enum LoadingStatus { idle, loading, error, noMoreData }

/// Widget for displaying products in a grid with infinite scrolling capability
class InfiniteProductGrid extends StatefulWidget {
  final List<SuggestionItem> initialProducts;
  
  final Future<List<SuggestionItem>> Function(int page) loadMoreProducts;
  
  final int crossAxisCount;
  
  final double spacing;
  
  final double childAspectRatio;
  
  final EdgeInsets padding;
  
  final String? title;
  
  final bool showTitle;
  
  final bool loadOnInit;

  const InfiniteProductGrid({
    Key? key,
    required this.initialProducts,
    required this.loadMoreProducts,
    this.crossAxisCount = 2,
    this.spacing = 16.0,
    this.childAspectRatio = 0.7,
    this.padding = const EdgeInsets.all(16.0),
    this.title,
    this.showTitle = true,
    this.loadOnInit = false,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section if showTitle is true
        if (widget.showTitle && widget.title != null)
          Padding(
            padding: EdgeInsets.only(
              left: widget.padding.left,
              right: widget.padding.right,
              top: widget.padding.top,
              bottom: 8,
            ),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          
        Expanded(
          child: _products.isEmpty && !_hasInitialized
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      controller: _scrollController,
                      padding: widget.padding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.crossAxisCount,
                        crossAxisSpacing: widget.spacing,
                        mainAxisSpacing: widget.spacing,
                        childAspectRatio: widget.childAspectRatio,
                      ),
                      itemCount: _products.length + (_loadingStatus == LoadingStatus.noMoreData ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index >= _products.length) {
                          return _buildLoadMoreIndicator();
                        }
                        
                        return _buildProductItem(_products[index]);
                      },
                    ),
        ),
      ],
    );
  }
  
  Widget _buildProductItem(SuggestionItem product) {
    final heroTag = 'infinite_grid_product_${product.id}';
    
    return Hero(
      tag: heroTag,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: product.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: product.imageUrl != null
                              ? SmoothNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      ),
                      
                      if (product.discountPercentage != null || product.isNew || product.isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.discountPercentage != null)
                                _buildBadge(
                                  "-${product.discountPercentage}%",
                                  [Colors.red.shade700, Colors.red.shade500],
                                ),
                              
                              if (product.isNew)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _buildBadge(
                                    "NEW",
                                    [Colors.green.shade700, Colors.green.shade500],
                                  ),
                                ),
                              if (product.isFeatured)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _buildBadge(
                                    "FEATURED",
                                    [Colors.purple.shade700, Colors.purple.shade500],
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
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (product.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              product.description!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
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
                                _buildRatingStars(product.rating!),
                                if (product.reviewCount != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      "(${product.reviewCount})",
                                      style: TextStyle(
                                        fontSize: 10,
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
                              Text(
                                "₹${product.price!.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (product.originalPrice != null && product.originalPrice! > product.price!)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    "₹${product.originalPrice!.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
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
      ),
    );
  }
  
  Widget _buildLoadMoreIndicator() {
    switch (_loadingStatus) {
      case LoadingStatus.loading:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
        );
        
      case LoadingStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
  
  Widget _buildBadge(String text, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star_rounded,
            size: 14,
            color: Colors.amber,
          );
        } else if (index < rating.ceil() && index >= rating.floor()) {
          return const Icon(
            Icons.star_half_rounded,
            size: 14,
            color: Colors.amber,
          );
        } else {
          return Icon(
            Icons.star_border_rounded,
            size: 14,
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
  final EdgeInsets padding;
  final bool loadOnInit;

  const InfiniteProductList({
    Key? key,
    required this.initialProducts,
    required this.loadMoreProducts,
    this.title,
    this.showTitle = true,
    this.padding = const EdgeInsets.all(16.0),
    this.loadOnInit = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfiniteProductGrid(
      initialProducts: initialProducts,
      loadMoreProducts: loadMoreProducts,
      crossAxisCount: 1,
      childAspectRatio: 2.5, // Horizontal layout for list items
      spacing: 16.0,
      padding: padding,
      title: title,
      showTitle: showTitle,
      loadOnInit: loadOnInit,
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
