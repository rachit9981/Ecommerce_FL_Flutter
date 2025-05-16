import 'package:flutter/material.dart';

/// Product model
class Product {
  final String id;
  final String title;
  final double price;
  final double? originalPrice;
  final String description;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockCount;
  final List<String> sizes;
  final List<Color> colors;
  final Map<String, List<String>> techSpecs; // For RAM, storage options
  final String brand;
  final Map<String, String> specifications;
  final List<Review> reviews;
  final List<String> tags;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.images,
    required this.rating,
    required this.reviewCount,
    this.inStock = true,
    this.stockCount = 0,
    this.sizes = const [],
    this.colors = const [],
    this.techSpecs = const {},
    required this.brand,
    this.specifications = const {},
    this.reviews = const [],
    this.tags = const [],
    required this.category,
  });

  // Create a sample product for testing
  static Product getSampleProduct() {
    return Product(
      id: '1',
      title: 'Premium Wireless Earbuds with Active Noise Cancellation',
      price: 5999.0,
      originalPrice: 7999.0,
      description: 'Experience crystal-clear sound and complete silence from the outside world with our premium wireless earbuds. The active noise cancellation technology blocks out external noise, allowing you to focus on your music, calls, or work without distractions.\n\nThese earbuds feature Bluetooth 5.2 for stable connectivity, touch controls for easy operation, and an IPX7 waterproof rating that protects against sweat and rain. The compact charging case provides up to 24 hours of total playback time, with each charge giving you 6 hours of continuous use.\n\nThe ergonomic design ensures a secure and comfortable fit for extended wearing periods, making these earbuds perfect for workouts, commuting, or all-day use.',
      images: [
        'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f39?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1613040809024-b4ef7ba99bc3?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      ],
      rating: 4.5,
      reviewCount: 256,
      inStock: true,
      stockCount: 42,
      sizes: [],
      colors: [
        Colors.black,
        Colors.white,
        Colors.blue,
      ],
      techSpecs: {
        'Storage': ['32GB', '64GB', '128GB'],
        'Battery': ['Standard', 'Extended'],
      },
      brand: 'SoundMaster',
      specifications: {
        'Connectivity': 'Bluetooth 5.2',
        'Battery Life': 'Up to 6 hours (24 hours with case)',
        'Noise Cancellation': 'Active Noise Cancellation (ANC)',
        'Water Resistance': 'IPX7',
        'Charging': 'USB-C and Wireless',
        'Weight': '5.6g per earbud, 45g charging case',
      },
      reviews: [
        Review(
          id: '1',
          userName: 'Rajesh S.',
          rating: 5.0,
          date: DateTime.now().subtract(const Duration(days: 5)),
          comment: 'Best earbuds I have ever used. The sound quality is amazing and the ANC works great in noisy environments.',
          helpfulCount: 24,
        ),
        Review(
          id: '2',
          userName: 'Priya M.',
          rating: 4.0,
          date: DateTime.now().subtract(const Duration(days: 15)),
          comment: 'Good sound quality and comfortable fit. Battery life is as advertised. The only downside is the touch controls can be a bit sensitive.',
          helpfulCount: 15,
        ),
        Review(
          id: '3',
          userName: 'Amit K.',
          rating: 5.0,
          date: DateTime.now().subtract(const Duration(days: 30)),
          comment: 'Excellent purchase! The noise cancellation is top-notch and I can wear them all day without discomfort.',
          helpfulCount: 32,
        ),
      ],
      tags: ['Wireless', 'Earbuds', 'ANC', 'Bluetooth', 'Premium'],
      category: 'Electronics',
    );
  }

  // Sample smartphone product
  static Product getSampleSmartphone() {
    return Product(
      id: '2',
      title: 'UltraPhone Pro with 108MP Camera',
      price: 49999.0,
      originalPrice: 59999.0,
      description: 'Meet the UltraPhone Pro, our most advanced smartphone yet. Featuring a stunning 6.7-inch AMOLED display with 120Hz refresh rate for ultra-smooth scrolling and gaming. The revolutionary 108MP main camera system lets you capture professional-quality photos in any lighting condition.\n\nPowered by the latest octa-core processor and available with up to 12GB RAM and 512GB storage, this phone handles everything from intensive gaming to multitasking with ease. The 5000mAh battery supports all-day usage, while 65W fast charging gets you back to 100% in just 35 minutes.\n\nExperience the future of mobile technology with UltraPhone Pro.',
      images: [
        'https://images.unsplash.com/photo-1598327105666-5b89351aff97?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1565849904461-04a58ad377e0?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        'https://images.unsplash.com/photo-1609252924198-30b8cb130dd1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      ],
      rating: 4.7,
      reviewCount: 1243,
      inStock: true,
      stockCount: 75,
      sizes: [],
      colors: [
        Colors.black,
        Colors.grey.shade200, // Silver
        Color(0xFF1E3A8A), // Deep Blue
      ],
      techSpecs: {
        'RAM': ['6GB', '8GB', '12GB'],
        'Storage': ['128GB', '256GB', '512GB'],
      },
      brand: 'UltraTech',
      specifications: {
        'Processor': 'Octa-core 2.9GHz',
        'Display': '6.7-inch AMOLED (120Hz)',
        'Main Camera': '108MP + 12MP + 8MP',
        'Front Camera': '32MP',
        'Battery': '5000mAh',
        'Charging': '65W Fast Charging',
        'OS': 'Android 13',
        'Water Resistance': 'IP68',
      },
      reviews: [
        Review(
          id: '1',
          userName: 'Vikram R.',
          rating: 5.0,
          date: DateTime.now().subtract(const Duration(days: 3)),
          comment: 'Best smartphone I\'ve ever owned. The camera quality is mind-blowing and battery life is outstanding. Worth every rupee!',
          helpfulCount: 47,
        ),
        Review(
          id: '2',
          userName: 'Ananya K.',
          rating: 4.0,
          date: DateTime.now().subtract(const Duration(days: 10)),
          comment: 'Great phone with impressive performance. The only minor issue is that it gets a bit warm during gaming sessions.',
          helpfulCount: 23,
        ),
      ],
      tags: ['Smartphone', 'Camera', 'Gaming', 'Fast Charging'],
      category: 'Electronics',
    );
  }
}

/// Review model
class Review {
  final String id;
  final String userName;
  final double rating;
  final DateTime date;
  final String comment;
  final int helpfulCount;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.date,
    required this.comment,
    this.helpfulCount = 0,
  });
}

/// Image carousel for product images
class ProductImageCarousel extends StatefulWidget {
  final List<String> images;
  final String heroTag;

  const ProductImageCarousel({
    Key? key,
    required this.images,
    required this.heroTag,
  }) : super(key: key);

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Main image carousel with improved styling
          Container(
            height: 300,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          images: widget.images,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: index == 0 ? widget.heroTag : 'product_image_${widget.heroTag}_$index',
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Image.network(
                        widget.images[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Image indicator dots - improved style
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _currentImageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          
          // Thumbnail row - improved
          if (widget.images.length > 1)
            Container(
              height: 70,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentImageIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          width: _currentImageIndex == index ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          widget.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer
class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Image ${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Product header information with improved UI
class ProductHeader extends StatelessWidget {
  final String title;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String brand;
  final VoidCallback onReviewsTap;

  const ProductHeader({
    Key? key,
    required this.title,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.brand,
    required this.onReviewsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discount = originalPrice != null
        ? ((originalPrice! - price) / originalPrice! * 100).round()
        : 0;

    return Container(
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
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand with badge design
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              brand,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Title with improved typography
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          // Rating with animated stars
          const SizedBox(height: 16),
          InkWell(
            onTap: onReviewsTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      if (index < rating.floor()) {
                        return Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: Colors.amber,
                        );
                      } else if (index < rating.ceil() && rating.floor() != rating.ceil()) {
                        return Icon(
                          Icons.star_half_rounded,
                          size: 20,
                          color: Colors.amber,
                        );
                      } else {
                        return Icon(
                          Icons.star_border_rounded,
                          size: 20,
                          color: Colors.amber,
                        );
                      }
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$rating ($reviewCount)',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'See Reviews',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          
          // Divider for visual separation
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(),
          ),
          
          // Price with better discount visualization
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (originalPrice != null) ...[
                const SizedBox(width: 12),
                Text(
                  '₹${originalPrice!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$discount% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Tax information
          const SizedBox(height: 8),
          Text(
            'Inclusive of all taxes',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tech specs selector for RAM, storage, etc.
class TechSpecSelector extends StatelessWidget {
  final Map<String, List<String>> specs;
  final Map<String, String> selectedSpecs;
  final Function(String, String) onSpecSelected;

  const TechSpecSelector({
    Key? key,
    required this.specs,
    required this.selectedSpecs,
    required this.onSpecSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: specs.entries.map((entry) {
          final specName = entry.key;
          final specOptions = entry.value;
          final selectedValue = selectedSpecs[specName];
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spec title
              Text(
                specName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              // Options grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: specOptions.map((option) {
                  final isSelected = selectedValue == option;
                  
                  return GestureDetector(
                    onTap: () => onSpecSelected(specName, option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Color and size selector with improved UI
class ProductVariantSelector extends StatelessWidget {
  final List<Color> availableColors;
  final List<String> availableSizes;
  final Color? selectedColor;
  final String? selectedSize;
  final ValueChanged<Color?> onColorSelected;
  final ValueChanged<String?> onSizeSelected;

  const ProductVariantSelector({
    Key? key,
    required this.availableColors,
    required this.availableSizes,
    required this.selectedColor,
    required this.selectedSize,
    required this.onColorSelected,
    required this.onSizeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> selectors = [];
    
    // Only add sections that have options
    if (availableColors.isNotEmpty) {
      selectors.add(_buildColorSelector(context));
    }
    
    if (availableSizes.isNotEmpty) {
      selectors.add(const SizedBox(height: 24));
      selectors.add(_buildSizeSelector(context));
    }
    
    if (selectors.isEmpty) return const SizedBox.shrink();
    
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
        children: selectors,
      ),
    );
  }

  Widget _buildColorSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Color',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (selectedColor != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  // Get color name based on material color
                  _getColorName(selectedColor!),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: availableColors.map((color) {
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    ),
                    // Color indicator dot below
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Size',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (selectedSize != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedSize!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSizes.map((size) {
            final isSelected = selectedSize == size;
            return GestureDetector(
              onTap: () => onSizeSelected(size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  // Get color name from material color
  String _getColorName(Color color) {
    if (color == Colors.black) return 'Black';
    if (color == Colors.white) return 'White';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.red) return 'Red';
    if (color == Colors.green) return 'Green';
    if (color == Colors.yellow) return 'Yellow';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.grey) return 'Grey';
    if (color == Colors.grey.shade200) return 'Silver';
    // Add more color names as needed
    
    return 'Custom';
  }
}

/// Product description section
class ProductDescription extends StatefulWidget {
  final String description;

  const ProductDescription({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: _expanded ? double.infinity : 100,
              ),
              child: Text(
                widget.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_expanded ? 'Read Less' : 'Read More'),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Product specifications table with improved UI
class ProductSpecifications extends StatelessWidget {
  final Map<String, String> specifications;

  const ProductSpecifications({
    Key? key,
    required this.specifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.description_outlined),
                SizedBox(width: 8),
                Text(
                  'Specifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Specs table with improved styling
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: specifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = specifications.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Product reviews section
class ProductReviews extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final List<Review> reviews;
  final VoidCallback onViewAllTap;

  const ProductReviews({
    Key? key,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
    required this.onViewAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with view all
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: onViewAllTap,
                child: const Text('View All'),
              ),
            ],
          ),
          
          // Rating summary
          Row(
            children: [
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating.floor()
                            ? Icons.star
                            : (index < rating.ceil() && index >= rating.floor())
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text('Based on $reviewCount reviews'),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          
          // Review list (top 3)
          ...reviews.take(3).map((review) => _buildReviewItem(context, review)).toList(),
          
          if (reviews.length > 3) ...[
            Center(
              child: TextButton(
                onPressed: onViewAllTap,
                child: const Text('View All Reviews'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                child: Text(
                  review.userName.isEmpty ? 'U' : review.userName[0],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDateToRelative(review.date)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Helpful (${review.helpfulCount})',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (reviews.indexOf(review) < reviews.length - 1) const Divider(height: 24),
        ],
      ),
    );
  }

  String _formatDateToRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}

/// Add to cart button with modern design
class AddToCartSection extends StatelessWidget {
  final bool inStock;
  final int stockCount;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const AddToCartSection({
    Key? key,
    required this.inStock,
    required this.stockCount,
    required this.onAddToCart,
    required this.onBuyNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stock status with improved styling
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: inStock ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        inStock ? Icons.check_circle : Icons.cancel,
                        color: inStock ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        inStock
                            ? stockCount > 0
                                ? 'In Stock ($stockCount available)'
                                : 'In Stock'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: inStock ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Free delivery badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.blue.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Free Delivery',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (inStock) ...[
              const SizedBox(height: 12),
              
              // Action buttons with improved styling
              Row(
                children: [
                  // Add to cart button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: inStock ? onAddToCart : null,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Buy now button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: inStock ? onBuyNow : null,
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Buy Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
