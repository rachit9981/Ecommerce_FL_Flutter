import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/app_bar/home.dart';
import 'package:ecom/components/common/suggestions.dart';
import 'package:ecom/components/common/infity_scroll_suggestions.dart';
import 'package:ecom/components/home/banners.dart';
import 'package:ecom/components/home/categories.dart';
import 'package:ecom/components/home/searchbar.dart'; // Added import for the new search bar
import 'package:ecom/pages/cart_page.dart';
import 'package:ecom/pages/category_page.dart';
import 'package:ecom/pages/product_page.dart';
import 'package:ecom/providers/product_provider.dart';
import 'package:ecom/providers/banner_provider.dart';
import 'package:ecom/services/products.dart';
import 'package:ecom/services/cart_wishlist.dart';
import 'package:ecom/components/common/categories.dart' show CategoryItem; // For creating CategoryItem instances

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CartWishlistService _cartService = CartWishlistService();
  int _cartItemCount = 0;
  bool _isLoadingCart = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
      context.read<BannerProvider>().loadBanners();
    });
    _loadCartCount();
  }

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
      if (mounted) {
        setState(() {
          _cartItemCount = 0;
          _isLoadingCart = false;
        });
      }
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

  List<SuggestionItem> _getNewestProducts(List<Product> products, {int limit = 4, String heroTagPrefix = 'newest'}) {
    // Sort products by creation date or id (assuming newer products have higher IDs)
    // If products have a createdAt field, use that instead
    final sortedProducts = List<Product>.from(products)
      ..sort((a, b) {
        // Try to parse product IDs as numbers for date-based sorting
        // This assumes newer products have higher IDs
        try {
          final aId = int.tryParse(a.id) ?? 0;
          final bId = int.tryParse(b.id) ?? 0;
          return bId.compareTo(aId); // Descending order (newest first)
        } catch (e) {
          // Fallback to string comparison if IDs are not numeric
          return b.id.compareTo(a.id);
        }
      });
    
    final newestProducts = sortedProducts.take(limit).toList();
    
    return newestProducts.map((product) => _convertProductToSuggestionItem(product, heroTagPrefix)).toList();
  }

  @override
  void dispose() {
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
            _loadCartCount();
          });
        },
      ),      body: SafeArea(
        child: Consumer2<ProductProvider, BannerProvider>(
          builder: (context, productProvider, bannerProvider, child) {            if (productProvider.isLoading && productProvider.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show loading if banners are still loading and we have no banners yet
            if (bannerProvider.isLoading && bannerProvider.banners.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!productProvider.isLoading && productProvider.products.isEmpty && productProvider.error != null) { // Changed errorMessage to error
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),                    Text(
                      'Failed to load products: ${productProvider.error}', // Changed errorMessage to error
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () {
                        productProvider.reloadProducts(); // Changed to reloadProducts for a full refresh
                        bannerProvider.reloadBanners(); // Also reload banners
                      },
                    ),
                  ],
                ),
              );
            } else if (!productProvider.isLoading && productProvider.products.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 60),
                      SizedBox(height: 16),                      Text(
                        'No products found.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Check back later!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
            }            
            final products = productProvider.products;
            final carouselBanners = bannerProvider.carouselBanners;
            final heroBanners = bannerProvider.heroBanners;
              final featuredProducts = _getFeaturedProducts(products, limit: 6, heroTagPrefix: 'home_featured');
            final electronicsProducts = _getProductsByCategory(products, 'electronics', limit: 4, heroTagPrefix: 'home_electronics');
            final fashionProducts = _getProductsByCategory(products, 'fashion', limit: 4, heroTagPrefix: 'home_fashion');
            final moreProducts = _getRandomProducts(products, limit: 20, heroTagPrefix: 'home_more');
            // New product lists for additional rows
            final laptopComputerProducts = _getProductsByCategory(products, 'laptops', limit: 4, heroTagPrefix: 'home_laptops'); // Assuming 'laptops' or 'computers' category exists
            final popularProducts = _getRandomProducts(products, limit: 6, heroTagPrefix: 'home_popular'); // Using random for popular for now
            final trendingProducts = _getFeaturedProducts(products, limit: 5, heroTagPrefix: 'home_trending'); // Using featured for trending for now
            final accessoryProducts = _getProductsByCategory(products, 'accessories', limit: 4, heroTagPrefix: 'home_accessories'); // New list for accessories
            final newestProducts = _getNewestProducts(products, limit: 6, heroTagPrefix: 'home_newest'); // New products sorted by date

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  // Add the search bar here
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    child: HomeSearchBarComponent(),
                  ),                  const SizedBox(height: 8),
                  PromotionalBannerCarousel(
                    banners: carouselBanners,
                    bannerType: 'carousel',
                  ),
                  const SizedBox(height: 8),                  // Dynamic Categories Widget
                  HomeCategoriesSection(products: products),

                  // Featured Products
                  if (featuredProducts.isNotEmpty) ...[                    ScrollableSuggestionRow(
                      title: 'Featured', // Shortened title
                      items: featuredProducts,
                      itemHeight: 220,
                      itemWidth: 145,
                      showMore: false,
                    ),
                    const SizedBox(height: 16),
                  ],                  // Laptops & Computers
                  if (laptopComputerProducts.isNotEmpty && products.any((p) => 
                      p.category.toLowerCase().contains('laptop') || 
                      p.category.toLowerCase().contains('computer'))) ...[
                    ScrollableSuggestionRow(
                      title: 'Laptops',
                      items: laptopComputerProducts,
                      itemHeight: 220,
                      itemWidth: 145,
                      showMore: true,
                      onMoreTap: () {
                        final laptopCategoryProduct = products.firstWhere(
                          (p) => p.category.toLowerCase().contains('laptop') || 
                                 p.category.toLowerCase().contains('computer'),
                          orElse: () => Product(id: '_fallback', name: 'Fallback', brand: 'N/A', category: 'Laptops', description: '', price: 0, discountPrice: 0, stock: 0, rating: 0, reviews: 0, images: [], features: [], specifications: {}, variant: {}),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoryPage(category: CategoryItem(id: laptopCategoryProduct.category, title: 'Laptops'))),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],                  // Recommended For You (Electronics)
                  if (electronicsProducts.isNotEmpty) ...[                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Recommended',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ScrollableSuggestionRow(
                      items: electronicsProducts,
                      itemHeight: 220,
                      itemWidth: 145,
                      showMore: true,
                      onMoreTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoryPage(category: CategoryItem(id: 'electronics', title: 'Electronics'))), // Pass CategoryItem
                        );
                      },
                    ),                    const SizedBox(height: 12),
                  ],                  // Second Banner Carousel
                  PromotionalBannerCarousel(
                    banners: heroBanners,
                    bannerType: 'hero',
                  ), 
                  const SizedBox(height: 8),// Accessories Section
                  if (accessoryProducts.isNotEmpty && products.any((p) => 
                      p.category.toLowerCase().contains('accessori') || // Broader match for accessories
                      p.category.toLowerCase().contains('headphone') ||
                      p.category.toLowerCase().contains('earphone') ||
                      p.category.toLowerCase().contains('charger') ||
                      p.category.toLowerCase().contains('cable'))) ...[
                    ScrollableSuggestionRow(
                      title: 'Accessories',
                      items: accessoryProducts,
                      itemHeight: 220,
                      itemWidth: 145,
                      showMore: true,
                      onMoreTap: () {
                        final accessoryCategoryProduct = products.firstWhere(
                          (p) => p.category.toLowerCase().contains('accessori') || 
                                 p.category.toLowerCase().contains('headphone') || 
                                 p.category.toLowerCase().contains('earphone') || 
                                 p.category.toLowerCase().contains('charger') || 
                                 p.category.toLowerCase().contains('cable'),
                          orElse: () => Product(id: '_fallback', name: 'Fallback', brand: 'N/A', category: 'Accessories', description: '', price: 0, discountPrice: 0, stock: 0, rating: 0, reviews: 0, images: [], features: [], specifications: {}, variant: {}),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoryPage(category: CategoryItem(id: accessoryCategoryProduct.category, title: 'Accessories'))),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],                  // Popular Items
                  if (popularProducts.isNotEmpty) ...[                    ScrollableSuggestionRow(
                      title: 'Popular',
                      items: popularProducts,
                      itemHeight: 220,
                      itemWidth: 145,
                      showMore: false,
                    ),
                    const SizedBox(height: 16),
                  ],                  // Top Deals in Fashion
                  if (fashionProducts.isNotEmpty && products.any((p) => 
                    p.category.toLowerCase().contains('fashion') || 
                    p.category.toLowerCase().contains('clothing') || 
                    p.category.toLowerCase().contains('apparel') || 
                    p.category.toLowerCase().contains('wear'))) ...[
                  ScrollableSuggestionRow(
                    title: 'Fashion Deals',
                    items: fashionProducts,
                    itemHeight: 220,
                    itemWidth: 145,
                    showMore: true,
                    onMoreTap: () {
                      // Find a representative category name string
                      final fashionCategoryProduct = products.firstWhere(
                        (p) => p.category.toLowerCase().contains('fashion') || 
                               p.category.toLowerCase().contains('clothing') || 
                               p.category.toLowerCase().contains('apparel') || 
                               p.category.toLowerCase().contains('wear'),
                        // Provide a default Product with all required fields for orElse
                        orElse: () => Product(id: '_fallback', name: 'Fallback', brand: 'N/A', category: 'Fashion', description: '', price: 0, discountPrice: 0, stock: 0, rating: 0, reviews: 0, images: [], features: [], specifications: {}, variant: {}),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryPage(category: CategoryItem(id: fashionCategoryProduct.category, title: fashionCategoryProduct.category))), // Pass CategoryItem
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],                // Trending Now
                if (trendingProducts.isNotEmpty) ...[                  ScrollableSuggestionRow(
                    title: 'Trending',
                    items: trendingProducts,
                    itemHeight: 220,
                    itemWidth: 145,
                    showMore: false,
                  ),const SizedBox(height: 16),                ],

                // Just Added (Newest Products)
                if (newestProducts.isNotEmpty) ...[
                  ScrollableSuggestionRow(
                    title: 'Just Added',
                    items: newestProducts,
                    itemHeight: 220,
                    itemWidth: 145,
                    showMore: false,
                  ),
                  const SizedBox(height: 16),
                ],

                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 12),
                  child: Text(
                    'More For You',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 500,
                  padding: const EdgeInsets.only(bottom: 24),
                  alignment: Alignment.center,
                  child: moreProducts.isNotEmpty
                      ? InfiniteProductGrid(
                          initialProducts: moreProducts.take(moreProducts.length < 4 ? moreProducts.length : 4).toList(), // Ensure take doesn't exceed length
                          loadMoreProducts: (page) async {
                            // Implement proper pagination if API supports it
                            // For now, simulate loading more from the existing list
                            int itemsPerPage = 8; // Or any other number
                            int startIndex = (page -1) * itemsPerPage + 4; // +4 because initialProducts takes 4
                            if (startIndex >= moreProducts.length) return [];
                            int endIndex = startIndex + itemsPerPage;
                            if (endIndex > moreProducts.length) endIndex = moreProducts.length;
                            return moreProducts.sublist(startIndex, endIndex);
                          },
                          crossAxisCount: 2,
                          childAspectRatio: 0.7, // Adjust as needed
                          spacing: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Added horizontal padding
                          showTitle: false,
                          loadOnInit: true, // Already true, but good to confirm
                          centerLoading: true,
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // Center content
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No products available.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 32),
              ],
            ),
           ); // This was the missing parenthesis
          },
        ),
      ),
    );
  }
}
