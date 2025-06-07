import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/app_bar/home.dart';
import 'package:ecom/components/common/suggestions.dart';
import 'package:ecom/components/common/categories.dart';
import 'package:ecom/components/common/infity_scroll_suggestions.dart';
import 'package:ecom/pages/cart_page.dart';
import 'package:ecom/pages/category_page.dart';
import 'package:ecom/pages/search_page.dart';
// import 'package:ecom/pages/notification_page.dart';
import 'package:ecom/pages/product_page.dart';
import 'package:ecom/providers/product_provider.dart';
import 'package:ecom/services/products.dart';
import 'package:ecom/services/cart_wishlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentBannerIndex = 0;
  
  // Cart service for cart count
  final CartWishlistService _cartService = CartWishlistService();
  int _cartItemCount = 0;
  bool _isLoadingCart = false;

  @override
  void initState() {
    super.initState();
    // Auto-scroll the banner every 3 seconds
    Future.delayed(Duration.zero, () {
      _startAutoScroll();
    });
    // Load products using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
    // Load cart count
    _loadCartCount();
  }

  // Method to load cart count
  Future<void> _loadCartCount() async {
    try {
      setState(() {
        _isLoadingCart = true;
      });
      
      final cartItems = await _cartService.getCart();
      
      if (mounted) {
        setState(() {
          _cartItemCount = cartItems.length;
          _isLoadingCart = false;
        });
      }
    } catch (e) {
      // Handle error silently, just set count to 0
      if (mounted) {
        setState(() {
          _cartItemCount = 0;
          _isLoadingCart = false;
        });
      }
    }
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

  // Method to get dynamic categories from product data
  List<CategoryItem> _getDynamicCategories(BuildContext context, List<Product> products) {
    // Extract unique categories from products (case insensitive)
    final Map<String, String> uniqueCategories = {};
    
    for (var product in products) {
      final categoryKey = product.category.toLowerCase().trim();
      if (!uniqueCategories.containsKey(categoryKey)) {
        uniqueCategories[categoryKey] = product.category;
      }
    }
    
    // Map of category names to their respective icons and colors
    final Map<String, IconData> categoryIcons = {
      'mobiles': Icons.smartphone,
      'mobile': Icons.smartphone,
      'phones': Icons.smartphone,
      'phone': Icons.smartphone,
      'electronics': Icons.devices,
      'laptops': Icons.laptop,
      'laptop': Icons.laptop,
      'computer': Icons.computer,
      'computers': Icons.computer,
      'accessories': Icons.headphones,
      'audio': Icons.headphones,
      'watches': Icons.watch,
      'watch': Icons.watch,
      'wearables': Icons.watch,
      'clothing': Icons.checkroom,
      'clothes': Icons.checkroom,
      'fashion': Icons.checkroom,
      'apparel': Icons.checkroom,
      'shoes': Icons.hiking,
      'footwear': Icons.hiking,
      'home': Icons.home,
      'furniture': Icons.chair,
      'appliances': Icons.kitchen,
      'books': Icons.book,
      'book': Icons.book,
      'sports': Icons.sports_basketball,
      'toys': Icons.toys,
      'beauty': Icons.face,
      'health': Icons.health_and_safety,
      'grocery': Icons.local_grocery_store,
      'food': Icons.fastfood,
      'automotive': Icons.directions_car,
      'car': Icons.directions_car,
      'tools': Icons.build,
      'garden': Icons.yard,
    };
    
    // Default color list for categories
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    
    // Convert unique categories to CategoryItem objects
    List<CategoryItem> categoryItems = [];
    int colorIndex = 0;
    
    for (var entry in uniqueCategories.entries) {
      final categoryKey = entry.key;
      final originalCategory = entry.value;
      
      // Find the matching icon
      IconData icon = Icons.category; // Default icon
      
      for (var key in categoryIcons.keys) {
        if (categoryKey.contains(key)) {
          icon = categoryIcons[key]!;
          break;
        }
      }
      
      // Create category item with rotating colors
      categoryItems.add(
        CategoryItem(
          id: originalCategory, // Use original case for ID
          title: originalCategory.substring(0, 1).toUpperCase() + originalCategory.substring(1),
          icon: icon,
          backgroundColor: colorOptions[colorIndex % colorOptions.length].withOpacity(0.2),
          iconColor: colorOptions[colorIndex % colorOptions.length],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPage(
                  category: CategoryItem(
                    id: originalCategory, // Use original case for consistency
                    title: originalCategory.substring(0, 1).toUpperCase() + originalCategory.substring(1),
                    icon: icon,
                    backgroundColor: colorOptions[colorIndex % colorOptions.length].withOpacity(0.2),
                    iconColor: colorOptions[colorIndex % colorOptions.length],
                  ),
                ),
              ),
            );
          },
        ),
      );
      
      colorIndex++;
    }
    
    return categoryItems;
  }
  
  // Method to get dynamic mobile brands from product data
  List<CategoryItem> _getDynamicBrands(BuildContext context, List<Product> products) {
    // Extract unique brands from mobile products (case insensitive)
    final Map<String, String> uniqueBrands = {};
    
    for (var product in products) {
      final categoryLower = product.category.toLowerCase().trim();
      final brandKey = product.brand.toLowerCase().trim();
      
      if ((categoryLower.contains('mobile') || 
           categoryLower.contains('smartphone') ||
           categoryLower.contains('phone')) &&
          !uniqueBrands.containsKey(brandKey)) {
        uniqueBrands[brandKey] = product.brand;
      }
    }
    
    // Map of brand names to their logo URLs
    final Map<String, String> brandLogos = {
      'samsung': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
      'apple': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
      'xiaomi': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
      'oneplus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
      'oppo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/OPPO_LOGO_2019.svg/2560px-OPPO_LOGO_2019.svg.png',
      'vivo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Vivo_logo.svg/1024px-Vivo_logo.svg.png',
      'google': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png',
      'huawei': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Huawei.svg/1280px-Huawei.svg.png',
      'motorola': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Motorola_logo.svg/2560px-Motorola_logo.svg.png',
      'realme': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Realme_logo.svg/2560px-Realme_logo.svg.png',
      'nokia': 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Nokia_wordmark.svg/1280px-Nokia_wordmark.svg.png',
      'sony': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Sony_logo.svg/2560px-Sony_logo.svg.png',
      'asus': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/ASUS_Logo.svg/2560px-ASUS_Logo.svg.png',
      'htc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/HTC_logo.svg/1024px-HTC_logo.svg.png',
    };
    
    // Convert unique brands to CategoryItem objects
    List<CategoryItem> brandItems = [];
    
    for (var entry in uniqueBrands.entries) {
      final brandKey = entry.key;
      final originalBrand = entry.value;
      
      String logoUrl = '';
      
      // Try to find a matching logo
      for (var key in brandLogos.keys) {
        if (brandKey.contains(key)) {
          logoUrl = brandLogos[key]!;
          break;
        }
      }
      
      // Use default logo if no match found
      if (logoUrl.isEmpty) {
        logoUrl = 'https://via.placeholder.com/200x100?text=${originalBrand.toUpperCase()}';
      }
      
      brandItems.add(
        CategoryItem(
          id: originalBrand, // Use original case for ID
          title: originalBrand.substring(0, 1).toUpperCase() + originalBrand.substring(1),
          imageUrl: logoUrl,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPage(
                  category: CategoryItem(
                    id: originalBrand, // Use original case for consistency
                    title: originalBrand.substring(0, 1).toUpperCase() + originalBrand.substring(1),
                    imageUrl: logoUrl,
                  ),
                ),
              ),
            );
          },
        ),);
    }
    
    return brandItems;
  }
  
  // Fallback method to provide brand items if API data is unavailable
  List<CategoryItem> _getFallbackBrandItems(BuildContext context) {
    return [
      CategoryItem(
        id: 'samsung',
        title: 'Samsung',
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
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
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
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
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
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
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
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
    ];
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

  List<SuggestionItem> _getProductsByCategory(List<Product> products, String category, {int limit = 4, String heroTagPrefix = 'product'}) {
    // Case insensitive category matching with better logic
    final normalizedCategory = category.toLowerCase().trim();
    
    final categoryProducts = products.where((product) {
      final productCategory = product.category.toLowerCase().trim();
      
      // Direct match
      if (productCategory == normalizedCategory) return true;
      
      // Partial matches for common category variations
      if (normalizedCategory.contains('mobile') || normalizedCategory.contains('phone')) {
        return productCategory.contains('mobile') || 
               productCategory.contains('phone') || 
               productCategory.contains('smartphone');
      }
      
      if (normalizedCategory.contains('laptop') || normalizedCategory.contains('computer')) {
        return productCategory.contains('laptop') || 
               productCategory.contains('computer') || 
               productCategory.contains('pc');
      }
      
      if (normalizedCategory.contains('electronic')) {
        return productCategory.contains('electronic') || 
               productCategory.contains('gadget') ||
               productCategory.contains('device');
      }
      
      if (normalizedCategory.contains('fashion') || normalizedCategory.contains('clothing')) {
        return productCategory.contains('fashion') || 
               productCategory.contains('clothing') || 
               productCategory.contains('apparel') ||
               productCategory.contains('wear');
      }
      
      // Generic partial match as fallback
      return productCategory.contains(normalizedCategory) || 
             normalizedCategory.contains(productCategory);
    }).take(limit).toList();
    
    return categoryProducts.map((product) => _convertProductToSuggestionItem(product, heroTagPrefix)).toList();
  }

  List<SuggestionItem> _getFeaturedProducts(List<Product> products, {int limit = 4, String heroTagPrefix = 'featured'}) {
    final featuredProducts = products
        // .where((product) => product.featured == true)
        .take(limit)
        .toList();
    
    return featuredProducts.map((product) => _convertProductToSuggestionItem(product, heroTagPrefix)).toList();
  }

  List<SuggestionItem> _getRandomProducts(List<Product> products, {int limit = 4, String heroTagPrefix = 'random'}) {
    final shuffledProducts = List<Product>.from(products)..shuffle();
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
    return Scaffold(
      appBar: HomeAppBar(
        cartItemCount: _isLoadingCart ? 0 : _cartItemCount,
        onCartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          ).then((_) {
            // Refresh cart count when returning from cart page
            _loadCartCount();
          });
        },
        // onNotificationsPressed: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const NotificationPage()),
        //   );
        // },
      ),
      body: SafeArea(
        child: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final products = productProvider.products;
            final isLoading = productProvider.isLoading;
            final error = productProvider.error;

            if (isLoading && products.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (error != null && products.isEmpty) {
              return Center(
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
                      error,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => productProvider.reloadProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Generate dynamic categories and brands from product data
            final categories = products.isNotEmpty 
                ? _getDynamicCategories(context, products) 
                : CategoryData.getSampleCategories();

            // Generate dynamic mobile brands from product data
            final mobileBrands = products.isNotEmpty 
                ? _getDynamicBrands(context, products) 
                : _getFallbackBrandItems(context);
            
            // Get dynamic product data from provider for different sections
            final trendingProducts = _getRandomProducts(products, limit: 4, heroTagPrefix: 'trending_now_product');
            final recommendedProducts = _getFeaturedProducts(products, limit: 4, heroTagPrefix: 'recommended_for_you_product');
            
            // For infinite scroll products - combine all available products
            final moreProducts = List<SuggestionItem>.from(products.map(
              (product) => _convertProductToSuggestionItem(product, 'infinite_product'),
            ));

            return RefreshIndicator(
              onRefresh: () => productProvider.reloadProducts(),
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
                              'Search products...',
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
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  ),            const SizedBox(height: 12),
            
            // Display products by category if available - improved logic
            if (products.any((p) => 
                p.category.toLowerCase().contains('mobile') || 
                p.category.toLowerCase().contains('phone') ||
                p.category.toLowerCase().contains('smartphone'))) ...[
              ScrollableSuggestionRow(
                title: 'Top Mobile Phones',
                items: _getProductsByCategory(products, 'mobile', limit: 4, heroTagPrefix: 'top_mobiles'),
                itemHeight: 220,
                itemWidth: 145,
                showMore: true,
                onMoreTap: () {
                  // Find the actual mobile category from products
                  final mobileCategory = products.firstWhere(
                    (p) => p.category.toLowerCase().contains('mobile') || 
                           p.category.toLowerCase().contains('phone') ||
                           p.category.toLowerCase().contains('smartphone'),
                    orElse: () => products.first,
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: CategoryItem(
                          id: mobileCategory.category,
                          title: 'Mobile Phones',
                          icon: Icons.smartphone,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            
            if (products.any((p) => 
                p.category.toLowerCase().contains('laptop') ||
                p.category.toLowerCase().contains('computer'))) ...[
              ScrollableSuggestionRow(
                title: 'Laptops & Computers',
                items: _getProductsByCategory(products, 'laptop', limit: 4, heroTagPrefix: 'top_laptops'),
                itemHeight: 220,
                itemWidth: 145,
                showMore: true,
                onMoreTap: () {
                  // Find the actual laptop category from products
                  final laptopCategory = products.firstWhere(
                    (p) => p.category.toLowerCase().contains('laptop') ||
                           p.category.toLowerCase().contains('computer'),
                    orElse: () => products.first,
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: CategoryItem(
                          id: laptopCategory.category,
                          title: 'Laptops & Computers',
                          icon: Icons.laptop,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            
            if (products.any((p) => 
                p.category.toLowerCase().contains('electronic') &&
                !p.category.toLowerCase().contains('mobile') &&
                !p.category.toLowerCase().contains('laptop'))) ...[
              ScrollableSuggestionRow(
                title: 'Electronics',
                items: _getProductsByCategory(products, 'electronics', limit: 4, heroTagPrefix: 'top_electronics'),
                itemHeight: 220,
                itemWidth: 145,
                showMore: true,
                onMoreTap: () {
                  // Find the actual electronics category from products
                  final electronicsCategory = products.firstWhere(
                    (p) => p.category.toLowerCase().contains('electronic') &&
                           !p.category.toLowerCase().contains('mobile') &&
                           !p.category.toLowerCase().contains('laptop'),
                    orElse: () => products.first,
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: CategoryItem(
                          id: electronicsCategory.category,
                          title: 'Electronics',
                          icon: Icons.devices,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            
            if (products.any((p) => 
                p.category.toLowerCase().contains('fashion') ||
                p.category.toLowerCase().contains('clothing') ||
                p.category.toLowerCase().contains('apparel'))) ...[
              ScrollableSuggestionRow(
                title: 'Fashion & Clothing',
                items: _getProductsByCategory(products, 'fashion', limit: 4, heroTagPrefix: 'top_fashion'),
                itemHeight: 220,
                itemWidth: 145,
                showMore: true,
                onMoreTap: () {
                  // Find the actual fashion category from products
                  final fashionCategory = products.firstWhere(
                    (p) => p.category.toLowerCase().contains('fashion') ||
                           p.category.toLowerCase().contains('clothing') ||
                           p.category.toLowerCase().contains('apparel'),
                    orElse: () => products.first,
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: CategoryItem(
                          id: fashionCategory.category,
                          title: 'Fashion & Clothing',
                          icon: Icons.checkroom,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            
            if (products.any((p) => 
                p.category.toLowerCase().contains('home') ||
                p.category.toLowerCase().contains('furniture') ||
                p.category.toLowerCase().contains('kitchen'))) ...[
              ScrollableSuggestionRow(
                title: 'Home & Kitchen',
                items: _getProductsByCategory(products, 'home', limit: 4, heroTagPrefix: 'top_home'),
                itemHeight: 220,
                itemWidth: 145,
                showMore: true,
                onMoreTap: () {
                  // Find the actual home category from products
                  final homeCategory = products.firstWhere(
                    (p) => p.category.toLowerCase().contains('home') ||
                           p.category.toLowerCase().contains('furniture') ||
                           p.category.toLowerCase().contains('kitchen'),
                    orElse: () => products.first,
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryPage(
                        category: CategoryItem(
                          id: homeCategory.category,
                          title: 'Home & Kitchen',
                          icon: Icons.home,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],

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
            ),
            const SizedBox(height: 16),
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
                      centerLoading: true, // Add this parameter to center align the loading indicator
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
            ),
            const SizedBox(height: 32), // Added more bottom padding
          ],
        ),
      );
    },
  ),
      ),
    );
  }
}
