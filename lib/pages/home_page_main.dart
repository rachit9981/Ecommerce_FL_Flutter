import 'package:flutter/material.dart';
import 'package:ecom/components/app_bar/home.dart';
import 'package:ecom/components/common/suggestions.dart';
import 'package:ecom/components/common/categories.dart';
import 'package:ecom/components/common/infity_scroll_suggestions.dart';
import 'package:ecom/pages/cart_page.dart';
import 'package:ecom/pages/search_page.dart';
import 'package:ecom/pages/notification_page.dart';
import 'package:ecom/pages/product_page.dart';
import 'package:ecom/pages/category_page.dart';
import 'package:ecom/services/products.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentBannerIndex = 0;
  
  // API integration variables
  final ProductService _productService = ProductService();
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Auto-scroll the banner every 3 seconds
    Future.delayed(Duration.zero, () {
      _startAutoScroll();
    });
    // Load products from API
    _loadProducts();
  }
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
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
      }
    });
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final products = await _productService.getProducts();
      
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  SuggestionItem _convertProductToSuggestionItem(Product product, String heroTagPrefix) {
    return SuggestionItem(
      id: product.id,
      title: product.name,
      imageUrl: product.images.isNotEmpty ? product.images.first : '',
      price: product.discountPrice,
      originalPrice: product.price != product.discountPrice ? product.price : null,
      description: product.description,
      isProduct: true,
      isNew: product.featured == true,
      rating: product.rating,
      reviewCount: product.reviews,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(
              productId: product.id,
              heroTag: '${heroTagPrefix}_${product.id}',
            ),
          ),
        );
      },
    );
  }

  List<SuggestionItem> _getProductsByCategory(String category, {int limit = 4, String heroTagPrefix = 'product'}) {
    final categoryProducts = _allProducts
        .where((product) => product.category.toLowerCase() == category.toLowerCase())
        .take(limit)
        .toList();
    
    return categoryProducts.map((product) => _convertProductToSuggestionItem(product, heroTagPrefix)).toList();
  }

  List<SuggestionItem> _getFeaturedProducts({int limit = 4, String heroTagPrefix = 'featured'}) {
    final featuredProducts = _allProducts
        .where((product) => product.featured == true)
        .take(limit)
        .toList();
    
    return featuredProducts.map((product) => _convertProductToSuggestionItem(product, heroTagPrefix)).toList();
  }

  List<SuggestionItem> _getRandomProducts({int limit = 4, String heroTagPrefix = 'random'}) {
    final shuffledProducts = List<Product>.from(_allProducts)..shuffle();
    final randomProducts = shuffledProducts.take(limit).toList();
    
    return randomProducts.map((product) => _convertProductToSuggestionItem(product, heroTagPrefix)).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final categories = CategoryData.getSampleCategories(context);

    // Define mobile brands with navigation to CategoryPage
    final mobileBrands = [
      CategoryItem(
        id: 'samsung',
        title: 'Samsung',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(
                category: CategoryItem(
                  id: 'samsung',
                  title: 'Samsung',
                  imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
                ),
              ),
            ),
          );
        },
      ),
      CategoryItem(
        id: 'apple',
        title: 'Apple',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(
                category: CategoryItem(
                  id: 'apple',
                  title: 'Apple',
                  imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
                ),
              ),
            ),
          );
        },
      ),
      CategoryItem(
        id: 'xiaomi',
        title: 'Xiaomi',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(
                category: CategoryItem(
                  id: 'xiaomi',
                  title: 'Xiaomi',
                  imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
                ),
              ),
            ),
          );
        },
      ),
      CategoryItem(
        id: 'oneplus',
        title: 'OnePlus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(
                category: CategoryItem(
                  id: 'oneplus',
                  title: 'OnePlus',
                  imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
                ),
              ),
            ),
          );
        },
      ),
      CategoryItem(
        id: 'oppo',
        title: 'OPPO',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/OPPO_LOGO_2019.svg/2560px-OPPO_LOGO_2019.svg.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(
                category: CategoryItem(
                  id: 'oppo',
                  title: 'OPPO',
                  imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/OPPO_LOGO_2019.svg/2560px-OPPO_LOGO_2019.svg.png',
                ),
              ),
            ),
          );
        },
      ),
      CategoryItem(
        id: 'vivo',
        title: 'Vivo',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Vivo_logo.svg/1024px-Vivo_logo.svg.png',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(
                category: CategoryItem(
                  id: 'vivo',
                  title: 'Vivo',
                  imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Vivo_logo.svg/1024px-Vivo_logo.svg.png',
                ),
              ),
            ),
          );
        },
      ),
    ];    
    // Get dynamic product data from API
    final trendingProducts = _getRandomProducts(limit: 4, heroTagPrefix: 'trending_now_product');
    final recommendedProducts = _getFeaturedProducts(limit: 4, heroTagPrefix: 'recommended_for_you_product');
    final topMobiles = _getProductsByCategory('mobiles', limit: 4, heroTagPrefix: 'top_mobiles');
    final topElectronics = _getProductsByCategory('electronics', limit: 4, heroTagPrefix: 'top_electronics');
    
    // For infinite scroll products - combine all available products
    final moreProducts = List<SuggestionItem>.from(_allProducts.map(
      (product) => _convertProductToSuggestionItem(product, 'infinite_product'),
    ));

    // Modify the category onTap actions to navigate to the CategoryPage
    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      categories[i] = CategoryItem(
        id: category.id,
        title: category.title,
        imageUrl: category.imageUrl,
        icon: category.icon,
        backgroundColor: category.backgroundColor,
        iconColor: category.iconColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(category: category),
            ),
          );
        },
      );
    }    return Scaffold(
      appBar: HomeAppBar(
        cartItemCount: 2,
        onCartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          );
        },
        onNotificationsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationPage()),
          );
        },
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load products',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Search products',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Search',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Shop by Category section
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 8,
              ),
              child: Text(
                'Shop by Category',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Horizontal category list from categories.dart
            HorizontalCategoryList(
              categories: categories,
              itemWidth: 100,
              itemHeight: 120,
              spacing: 12,
              showShadow: true,
            ),

            // Image carousel with auto-scroll
            Padding(
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
                  itemCount: 3,
                  controller: _pageController,
                  allowImplicitScrolling: true,
                  onPageChanged: (index) {
                    setState(() {
                      _currentBannerIndex = index;
                    });
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
            ),            ScrollableSuggestionRow(
              title: 'Trending Now',
              items: trendingProducts.isNotEmpty 
                  ? trendingProducts 
                  : [
                      SuggestionItem(
                        id: 'placeholder',
                        title: 'No products available',
                        imageUrl: '',
                        price: 0.0,
                        description: 'Check back later',
                        isProduct: false,
                        onTap: () {},
                      ),
                    ],
              itemHeight: 220,
              itemWidth: 145,
              showMore: trendingProducts.isNotEmpty,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all trending products')),
                );
              },
            ),
            const SizedBox(height: 12),
            ScrollableSuggestionRow(
              title: 'Recommended For You',
              items: recommendedProducts.isNotEmpty 
                  ? recommendedProducts 
                  : [
                      SuggestionItem(
                        id: 'placeholder',
                        title: 'No products available',
                        imageUrl: '',
                        price: 0.0,
                        description: 'Check back later',
                        isProduct: false,
                        onTap: () {},
                      ),
                    ],
              itemHeight: 220,
              itemWidth: 145,
              showMore: recommendedProducts.isNotEmpty,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View all recommended products'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 8,
              ),
              child: Text(
                'Popular Mobile Brands',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            HorizontalCategoryList(
              categories: mobileBrands,
              itemWidth: 80,
              itemHeight: 100,
              spacing: 12,
              showShadow: true,
              brandMode: true,
            ),            const SizedBox(height: 16),
            ScrollableSuggestionRow(
              title: 'Top Mobiles',
              items: topMobiles.isNotEmpty 
                  ? topMobiles 
                  : [
                      SuggestionItem(
                        id: 'placeholder',
                        title: 'No mobiles available',
                        imageUrl: '',
                        price: 0.0,
                        description: 'Check back later',
                        isProduct: false,
                        onTap: () {},
                      ),
                    ],
              itemHeight: 220,
              itemWidth: 145,
              showMore: topMobiles.isNotEmpty,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all top mobiles')),
                );
              },
            ),

            const SizedBox(height: 16),
            ScrollableSuggestionRow(
              title: 'Top Electronics',
              items: topElectronics.isNotEmpty 
                  ? topElectronics 
                  : [
                      SuggestionItem(
                        id: 'placeholder',
                        title: 'No electronics available',
                        imageUrl: '',
                        price: 0.0,
                        description: 'Check back later',
                        isProduct: false,
                        onTap: () {},
                      ),
                    ],
              itemHeight: 220,
              itemWidth: 145,
              showMore: topElectronics.isNotEmpty,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all top electronics')),
                );
              },
            ),            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16, // Increased top padding
                bottom: 12, // Increased bottom padding
              ),
              child: Text(
                'More Products For You',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center, // Center align the title
              ),
            ),
            Container(
              height: 500, // Fixed height for the infinite grid
              padding: const EdgeInsets.only(
                bottom: 24,
              ), // Increased bottom padding
              alignment: Alignment.center, // Center align the grid content
              child: moreProducts.isNotEmpty
                  ? InfiniteProductGrid(
                      initialProducts: moreProducts.take(4).toList(),
                      loadMoreProducts: (page) async {
                        await Future.delayed(const Duration(seconds: 1));

                        final startIndex = page * 4;
                        if (startIndex >= moreProducts.length) {
                          return [];
                        }

                        final endIndex =
                            (startIndex + 4 <= moreProducts.length)
                                ? startIndex + 4
                                : moreProducts.length;

                        return moreProducts.sublist(startIndex, endIndex);
                      },
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      spacing: 16,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ), // Added vertical padding
                      showTitle: false, // We already added the title above
                      loadOnInit: true,
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back later for new arrivals',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),            const SizedBox(height: 32), // Added more bottom padding
                      ],
                    ),
                  ),
      ),
    );
  }
}
