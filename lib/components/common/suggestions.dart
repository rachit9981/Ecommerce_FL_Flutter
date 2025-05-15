import 'package:flutter/material.dart';

class SuggestionItem {
  final String id;
  final String title;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isProduct;
  final double? price;
  final double? originalPrice;
  final String? description;
  final bool isNew;
  final bool isFeatured;
  final double? rating;
  final int? reviewCount;

  SuggestionItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isProduct = false,
    this.price,
    this.originalPrice,
    this.description,
    this.isNew = false,
    this.isFeatured = false,
    this.rating,
    this.reviewCount,
  });

  int? get discountPercentage {
    if (originalPrice != null && price != null && originalPrice! > price!) {
      return ((1 - price! / originalPrice!) * 100).round();
    }
    return null;
  }
}

/// A horizontal scrollable row of suggestion items for navigation or products display
class ScrollableSuggestionRow extends StatefulWidget {
  final String? title;
  final List<SuggestionItem> items;
  final double itemHeight;
  final double itemWidth;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool showMore;
  final VoidCallback? onMoreTap;
  final ScrollController? scrollController;

  const ScrollableSuggestionRow({
    Key? key,
    this.title,
    required this.items,
    this.itemHeight = 150.0,
    this.itemWidth = 140.0,
    this.spacing = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.showMore = false,
    this.onMoreTap,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ScrollableSuggestionRow> createState() =>
      _ScrollableSuggestionRowState();
}

class _ScrollableSuggestionRowState extends State<ScrollableSuggestionRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Map<String, bool> _favoriteStates = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite(String itemId) {
    setState(() {
      _favoriteStates[itemId] = !(_favoriteStates[itemId] ?? false);
    });

    if (_favoriteStates[itemId] ?? false) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final theme = Theme.of(context);

    final effectivePadding = EdgeInsets.symmetric(
      horizontal: isSmallScreen ? 8.0 : widget.padding.horizontal,
      vertical: widget.padding.vertical,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: EdgeInsets.only(
              left: effectivePadding.horizontal / 2,
              right: effectivePadding.horizontal / 2,
              top: effectivePadding.vertical,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : null,
                      letterSpacing: -0.5,
                      color: widget.title!.length < 5 ? theme.colorScheme.primary : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.showMore)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onMoreTap,
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10.0 : 14.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'See All',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: isSmallScreen ? 12 : 14,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double calculatedItemWidth =
                isSmallScreen
                    ? (availableWidth - (effectivePadding.horizontal * 2)) / 2.5
                    : widget.itemWidth;

            return SizedBox(
              height: widget.itemHeight,
              child: ListView.builder(
                controller: widget.scrollController,
                scrollDirection: Axis.horizontal,
                padding: effectivePadding,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  // Staggered animation
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOutQuint,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: Transform.scale(
                          scale: 0.9 + (0.1 * value),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right:
                                    index < widget.items.length - 1
                                        ? isSmallScreen
                                            ? widget.spacing / 2
                                            : widget.spacing
                                        : 0,
                              ),
                              child: Hero(
                                tag: 'product_${widget.items[index].id}',
                                flightShuttleBuilder: (
                                  _,
                                  __,
                                  ___,
                                  ____,
                                  _____,
                                ) {
                                  return Material(
                                    color: Colors.transparent,
                                    child:
                                        widget.items[index].isProduct
                                            ? _buildProductItem(
                                              context,
                                              widget.items[index],
                                              calculatedItemWidth,
                                              screenWidth,
                                            )
                                            : _buildCategoryItem(
                                              context,
                                              widget.items[index],
                                              calculatedItemWidth,
                                              screenWidth,
                                            ),
                                  );
                                },
                                child:
                                    widget.items[index].isProduct
                                        ? _buildProductItem(
                                          context,
                                          widget.items[index],
                                          calculatedItemWidth,
                                          screenWidth,
                                        )
                                        : _buildCategoryItem(
                                          context,
                                          widget.items[index],
                                          calculatedItemWidth,
                                          screenWidth,
                                        ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    SuggestionItem item,
    double effectiveWidth,
    double screenWidth,
  ) {
    final bool isSmallScreen = screenWidth < 360;
    final double imageSize = effectiveWidth * (isSmallScreen ? 0.5 : 0.6);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          width: effectiveWidth,
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 160),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.backgroundColor ??
                    theme.colorScheme.primary.withOpacity(0.05),
                item.backgroundColor != null
                    ? item.backgroundColor!.withOpacity(0.2)
                    : theme.colorScheme.primary.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.imageUrl != null)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(top: isSmallScreen ? 4.0 : 8.0),
                    child: Center(
                      child: _buildShimmerImage(
                        context,
                        item.imageUrl!,
                        imageSize,
                        isCircular: true,
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Center(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 10 : 11,
                        color: item.textColor ?? theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
  }

  Widget _buildProductItem(
    BuildContext context,
    SuggestionItem item,
    double effectiveWidth,
    double screenWidth,
  ) {
    final bool isSmallScreen = screenWidth < 360;
    final theme = Theme.of(context);
    final bool isFavorite = _favoriteStates[item.id] ?? false;

    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          width: effectiveWidth,
          constraints: const BoxConstraints(minWidth: 110, maxWidth: 160),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageUrl != null)
                Expanded(
                  flex: 1, // Changed from 3 to 1
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: _buildShimmerImage(
                            context,
                            item.imageUrl!,
                            double.infinity,
                            isCircular: false,
                          ),
                        ),
                      ),

                      // Discount badge with improved design
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.discountPercentage != null)
                              _buildGlassmorphicBadge(
                                "-${item.discountPercentage}%",
                                [Colors.red.shade700, Colors.red.shade500],
                                Colors.red.shade700.withOpacity(0.3),
                              ),

                            if (item.isNew)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: _buildGlassmorphicBadge("NEW", [
                                  Colors.green.shade700,
                                  Colors.green.shade500,
                                ], Colors.green.shade700.withOpacity(0.3)),
                              ),

                            if (item.isFeatured)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: _buildGlassmorphicBadge(
                                  "FEATURED",
                                  [
                                    Colors.purple.shade700,
                                    Colors.purple.shade500,
                                  ],
                                  Colors.purple.shade700.withOpacity(0.3),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Improved wishlist button with animation
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _toggleFavorite(item.id),
                          child: _buildGlassmorphicContainer(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey<bool>(isFavorite),
                                size: isSmallScreen ? 16 : 18,
                                color:
                                    isFavorite
                                        ? Colors.red
                                        : theme.colorScheme.primary,
                              ),
                            ),
                            size: isSmallScreen ? 30 : 36,
                            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmallScreen ? 10 : 11,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (item.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            item.description!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isSmallScreen ? 8 : 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      if (item.rating != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child: Row(
                            children: [
                              // Animated rating stars
                              _buildRatingStars(item.rating!, isSmallScreen),
                              const SizedBox(width: 4),
                              if (item.reviewCount != null)
                                Text(
                                  "(${item.reviewCount})",
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 8 : 9,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),

                      const Spacer(flex: 1),

                      if (item.price != null)
                        Row(
                          children: [
                            Text(
                              "₹${item.price!.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 11 : 13,
                              ),
                            ),
                            if (item.originalPrice != null &&
                                item.originalPrice! > item.price!) ...[
                              const SizedBox(width: 4),
                              Text(
                                "₹${item.originalPrice!.toStringAsFixed(0)}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: isSmallScreen ? 8 : 10,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
  }

  Widget _buildShimmerImage(
    BuildContext context,
    String imageUrl,
    double size, {
    bool isCircular = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: isCircular ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration:
          isCircular
              ? BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              )
              : null,
      child: ClipRRect(
        borderRadius:
            isCircular ? BorderRadius.circular(50) : BorderRadius.zero,
        child: SmoothNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: isCircular ? size : double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildGlassmorphicBadge(
    String text,
    List<Color> gradientColors,
    Color shadowColor,
  ) {
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
            color: shadowColor,
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
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

  Widget _buildGlassmorphicContainer({
    required Widget child,
    required double size,
    required EdgeInsets padding,
  }) {
    return Container(
      height: size,
      width: size,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }

  Widget _buildRatingStars(double rating, bool isSmallScreen) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full star
          return Icon(
            Icons.star_rounded,
            size: isSmallScreen ? 10 : 12,
            color: Colors.amber,
          );
        } else if (index < rating.ceil() && rating - rating.floor() > 0) {
          // Half star
          return Icon(
            Icons.star_half_rounded,
            size: isSmallScreen ? 10 : 12,
            color: Colors.amber,
          );
        } else {
          // Empty star
          return Icon(
            Icons.star_border_rounded,
            size: isSmallScreen ? 10 : 12,
            color: Colors.amber.withOpacity(0.7),
          );
        }
      }),
    );
  }
}

/// A clean network image loader with fade-in animation but no shimmer effect
class SmoothNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SmoothNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<SmoothNetworkImage> createState() => _SmoothNetworkImageState();
}

class _SmoothNetworkImageState extends State<SmoothNetworkImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make sure we have at least a minimum size for the image container
    final double minWidth = widget.width ?? 50.0;
    final double minHeight = widget.height ?? 50.0;

    return SizedBox(
      width: minWidth,
      height: minHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Simple placeholder instead of shimmer
          if (!_isLoaded)
            Container(
              color: Colors.grey.shade200,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),

          // Actual image
          Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                if (!_isLoaded) {
                  _controller.forward();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _isLoaded = true;
                      });
                    }
                  });
                }
                return FadeTransition(opacity: _controller, child: child);
              }
              return const SizedBox();
            },
            errorBuilder: (context, error, stackTrace) {
              if (!_isLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _isLoaded = true;
                    });
                  }
                });
              }
              return Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade400,
                    size: (minWidth / 3).clamp(16.0, 32.0),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
