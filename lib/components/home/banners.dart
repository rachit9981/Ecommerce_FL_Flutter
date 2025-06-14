import 'package:flutter/material.dart';

class PromotionalBannerCarousel extends StatefulWidget {
  const PromotionalBannerCarousel({Key? key}) : super(key: key);

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
      if (_currentBannerIndex < 2) {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: PageView.builder(
          controller: _pageController,
          itemCount: 3,
          onPageChanged: (index) {
            setState(() => _currentBannerIndex = index);
          },
          itemBuilder: (context, index) {
            // List of promotional banners
            final List<Map<String, dynamic>> banners = [
              {
                'image': 'https://images.unsplash.com/photo-1607082350899-7e105aa886ae?ixlib=rb-1.2.1&auto=format&fit=crop&w=2000&q=80',
                'title': 'Summer Sale',
                'subtitle': 'Up to 50% off',
                'buttonText': 'Shop Now',
                'color': Theme.of(context).colorScheme.primary,
              },
              {
                'image': 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?ixlib=rb-1.2.1&auto=format&fit=crop&w=2000&q=80',
                'title': 'New Arrivals',
                'subtitle': 'Discover the latest',
                'buttonText': 'Explore Now',
                'color': Theme.of(context).colorScheme.secondary,
              },
              {
                'image': 'https://images.unsplash.com/photo-1546027658-7aa750153465?ixlib=rb-1.2.1&auto=format&fit=crop&w=2000&q=80',
                'title': 'Tech Deals',
                'subtitle': 'Save up to 30%',
                'buttonText': 'Buy Now',
                'color': Colors.blue,
              },
            ];
            
            final banner = banners[index];
            
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    banner['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: banner['color'],
                      child: const Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 25,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner['subtitle'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: banner['color'],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(banner['buttonText']),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}