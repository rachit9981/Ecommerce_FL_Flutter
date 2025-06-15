import 'package:flutter/material.dart';
import '../../services/settings.dart' as settings;
import '../../pages/category_page.dart';
import '../../pages/search_page.dart';
import '../../components/common/categories.dart';

class PromotionalBannerCarousel extends StatefulWidget {
  final List<settings.Banner> banners;
  final String bannerType;
  
  const PromotionalBannerCarousel({
    Key? key, 
    required this.banners,
    this.bannerType = 'carousel',
  }) : super(key: key);

  @override
  State<PromotionalBannerCarousel> createState() => _PromotionalBannerCarouselState();
}

class _PromotionalBannerCarouselState extends State<PromotionalBannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (widget.banners.isEmpty) return;
      
      if (_currentBannerIndex < widget.banners.length - 1) {
        _pageController.animateToPage(
          _currentBannerIndex + 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
      _startAutoScroll();
    });
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _handleBannerTap(BuildContext context, settings.Banner banner) {
    // Navigate based on banner tag/link
    final String destination = banner.link.toLowerCase();
    
    switch (destination) {
      case 'mobile':
      case 'mobiles':
      case 'smartphone':
      case 'smartphones':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              category: CategoryItem(
                id: 'mobile',
                title: 'Mobile',
              ),
            ),
          ),
        );
        break;
      case 'laptop':
      case 'laptops':
      case 'computer':
      case 'computers':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              category: CategoryItem(
                id: 'laptops',
                title: 'Laptops',
              ),
            ),
          ),
        );
        break;
      case 'tv':
      case 'tvs':
      case 'television':
      case 'televisions':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              category: CategoryItem(
                id: 'tvs',
                title: 'TVs',
              ),
            ),
          ),
        );
        break;
      case 'electronics':
      case 'electronic':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              category: CategoryItem(
                id: 'electronics',
                title: 'Electronics',
              ),
            ),
          ),
        );
        break;
      case 'search':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(
              initialQuery: banner.tag,
            ),
          ),
        );
        break;
      default:
        // For unknown links, try to navigate to search with the tag/link as query
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(
              initialQuery: banner.tag.isNotEmpty ? banner.tag : banner.link,
            ),
          ),
        );
        break;
    }
  }@override
  Widget build(BuildContext context) {
    // Show empty container if no banners
    if (widget.banners.isEmpty) {
      // Show default/placeholder banner when no API banners are available
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Loading banners...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.banners.length,
          onPageChanged: (index) {
            setState(() => _currentBannerIndex = index);
          },
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            
            // Parse background color from hex string
            Color backgroundColor = Colors.blue;
            try {
              final colorHex = banner.backgroundColor.replaceAll('#', '');
              backgroundColor = Color(int.parse('ff$colorHex', radix: 16));
            } catch (e) {
              backgroundColor = Theme.of(context).colorScheme.primary;
            }
              return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(                onTap: () {
                  _handleBannerTap(context, banner);
                },
                child: Stack(
                  children: [
                  Image.network(
                    banner.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 140,                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            backgroundColor,
                            backgroundColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Image unavailable',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: backgroundColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: backgroundColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },),                  // Gradient overlay - improved for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        Text(
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),                        Text(
                          banner.subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),const SizedBox(height: 16),                        ElevatedButton(
                          onPressed: () {
                            _handleBannerTap(context, banner);
                          },style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            banner.cta,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),                ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}