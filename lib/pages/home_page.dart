import 'package:flutter/material.dart';
import 'package:ecom/components/app_bar/home.dart';
import 'package:ecom/components/common/suggestions.dart';
import 'package:ecom/components/common/categories.dart';
import 'package:ecom/components/common/infity_scroll_suggestions.dart'; // Add this import
import 'package:ecom/pages/cart_page.dart';
import 'package:ecom/pages/search_page.dart';
import 'package:ecom/pages/notification_page.dart';
import 'package:ecom/pages/product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = CategoryData.getSampleCategories(context);

    // Define mobile brands
    final mobileBrands = [
      CategoryItem(
        id: 'samsung',
        title: 'Samsung',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/2560px-Samsung_Logo.svg.png',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Samsung products')),
          );
        },
      ),
      CategoryItem(
        id: 'apple',
        title: 'Apple',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Apple products')),
          );
        },
      ),
      CategoryItem(
        id: 'xiaomi',
        title: 'Xiaomi',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Xiaomi_logo_%282021-%29.svg/1024px-Xiaomi_logo_%282021-%29.svg.png',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xiaomi products')),
          );
        },
      ),
      CategoryItem(
        id: 'oneplus',
        title: 'OnePlus',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Oneplus-logo.jpg/2560px-Oneplus-logo.jpg',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OnePlus products')),
          );
        },
      ),
      CategoryItem(
        id: 'oppo',
        title: 'OPPO',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/OPPO_LOGO_2019.svg/2560px-OPPO_LOGO_2019.svg.png',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OPPO products')),
          );
        },
      ),
      CategoryItem(
        id: 'vivo',
        title: 'Vivo',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Vivo_logo.svg/1024px-Vivo_logo.svg.png',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vivo products')),
          );
        },
      ),
    ];

    final List<SuggestionItem> trendingProducts = [
      SuggestionItem(
        id: '1',
        title: 'Wireless Earbuds',
        imageUrl:
            'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 5999.00,
        originalPrice: 7999.00, // Added for discount
        description: 'Noise cancellation',
        isProduct: true,
        isNew: true, // Show "NEW" badge
        rating: 4.5, // Display rating
        reviewCount: 256, // Show review count
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '1',
                heroTag: 'trending_now_product_1', // Match the Hero tag format from your carousel
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: '2',
        title: 'Smart Watch',
        imageUrl:
            'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 12999.00,
        originalPrice: 15999.00,
        description: 'Fitness tracking',
        isProduct: true,
        isNew: true,
        rating: 4.7,
        reviewCount: 128,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '2',
                heroTag: 'trending_now_product_2',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: '3',
        title: 'Laptop Backpack',
        imageUrl:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 2799.00,
        originalPrice: 3499.00,
        description: 'Water resistant',
        isProduct: true,
        isNew: false,
        rating: 4.2,
        reviewCount: 75,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '3',
                heroTag: 'trending_now_product_3',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: '4',
        title: 'Portable Charger',
        imageUrl:
            'https://images.unsplash.com/photo-1585003791087-a5aabb863540?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 1499.00,
        originalPrice: 1999.00,
        description: '20000mAh capacity',
        isProduct: true,
        isNew: false,
        rating: 4.8,
        reviewCount: 200,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '4',
                heroTag: 'trending_now_product_4',
              ),
            ),
          );
        },
      ),
    ];

    final List<SuggestionItem> recommendedProducts = [
      SuggestionItem(
        id: '5',
        title: 'Coffee Maker',
        imageUrl:
            'https://images.unsplash.com/photo-1517466787929-bc90951d0974?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 7499.00,
        description: 'Automatic brewing',
        isProduct: true,
        rating: 4.3,
        reviewCount: 128,
        isFeatured: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '5',
                heroTag: 'recommended_for_you_product_5',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: '6',
        title: 'Yoga Mat',
        imageUrl:
            'https://images.unsplash.com/photo-1590432923467-c5469804a8a9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 1999.00,
        description: 'Non-slip surface',
        isProduct: true,
        rating: 4.0,
        reviewCount: 86,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '6',
                heroTag: 'recommended_for_you_product_6',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: '7',
        title: 'LED Desk Lamp',
        imageUrl:
            'https://images.unsplash.com/photo-1534159559673-de7bc89fa998?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 2999.00,
        description: 'Adjustable brightness',
        isProduct: true,
        rating: 4.6,
        reviewCount: 112,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '7',
                heroTag: 'recommended_for_you_product_7',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: '8',
        title: 'Bluetooth Speaker',
        imageUrl:
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 3999.00,
        description: 'Waterproof',
        isProduct: true,
        rating: 4.4,
        reviewCount: 95,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '8',
                heroTag: 'recommended_for_you_product_8',
              ),
            ),
          );
        },
      ),
    ];

    // New Top Mobiles section
    final List<SuggestionItem> topMobiles = [
      SuggestionItem(
        id: 'm1',
        title: 'UltraPhone Pro',
        imageUrl:
            'https://images.unsplash.com/photo-1598327105666-5b89351aff97?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 49999.00,
        originalPrice: 59999.00,
        description: '108MP Camera, 12GB RAM',
        isProduct: true,
        isNew: true,
        rating: 4.7,
        reviewCount: 1243,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: '2',
                heroTag: 'top_mobiles_m1',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: 'm2',
        title: 'iSuperPhone 13',
        imageUrl:
            'https://images.unsplash.com/photo-1605236453806-6ff36851218e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 72999.00,
        originalPrice: 79999.00,
        description: 'A15 Chip, Pro Camera',
        isProduct: true,
        rating: 4.8,
        reviewCount: 985,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'm2',
                heroTag: 'top_mobiles_m2',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: 'm3',
        title: 'Galaxy X23',
        imageUrl:
            'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 42999.00,
        originalPrice: 45999.00,
        description: '120Hz AMOLED, 5G',
        isProduct: true,
        rating: 4.6,
        reviewCount: 756,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'm3',
                heroTag: 'top_mobiles_m3',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: 'm4',
        title: 'Mi Note 11',
        imageUrl:
            'https://images.unsplash.com/photo-1543069190-f90727ac6639?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 19999.00,
        originalPrice: 24999.00,
        description: '64MP Quad Camera',
        isProduct: true,
        rating: 4.4,
        reviewCount: 1475,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'm4',
                heroTag: 'top_mobiles_m4',
              ),
            ),
          );
        },
      ),
    ];

    // New Top Electronics section
    final List<SuggestionItem> topElectronics = [
      SuggestionItem(
        id: 'e1',
        title: 'Smart 4K TV',
        imageUrl:
            'https://images.unsplash.com/photo-1593784991095-a205069470b6?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 42999.00,
        originalPrice: 54999.00,
        description: '55-inch, HDR, Dolby Vision',
        isProduct: true,
        isFeatured: true,
        rating: 4.6,
        reviewCount: 532,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'e1',
                heroTag: 'top_electronics_e1',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: 'e2',
        title: 'Gaming Laptop',
        imageUrl:
            'https://images.unsplash.com/photo-1603302576837-37561b2e2302?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 89999.00,
        originalPrice: 104999.00,
        description: 'RTX 3060, 16GB RAM',
        isProduct: true,
        rating: 4.5,
        reviewCount: 328,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'e2',
                heroTag: 'top_electronics_e2',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: 'e3',
        title: 'Noise-Canceling Headphones',
        imageUrl:
            'https://images.unsplash.com/photo-1578319439584-104c94d37305?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 24999.00,
        originalPrice: 32999.00,
        description: 'Wireless, 30h Battery',
        isProduct: true,
        rating: 4.7,
        reviewCount: 894,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'e3',
                heroTag: 'top_electronics_e3',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: 'e4',
        title: 'Smartwatch Pro',
        imageUrl:
            'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 18999.00,
        originalPrice: 22999.00,
        description: 'Heart Rate, GPS, NFC',
        isProduct: true,
        rating: 4.4,
        reviewCount: 672,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'e4',
                heroTag: 'top_electronics_e4',
              ),
            ),
          );
        },
      ),
    ];

    // For infinite scroll products
    final List<SuggestionItem> moreProducts = [
      // Start with products already defined in trendingProducts
      ...trendingProducts,
      // Add more products
      SuggestionItem(
        id: 'mp1',
        title: 'Fitness Tracker Band',
        imageUrl:
            'https://images.unsplash.com/photo-1576243345690-4e4b79b63288?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 2499.00,
        originalPrice: 3499.00,
        description: 'Heart rate & sleep monitoring',
        isProduct: true,
        rating: 4.3,
        reviewCount: 428,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'mp1',
                heroTag: 'infinite_product_mp1',
              ),
            ),
          );
        },
      ),
      SuggestionItem(
        id: 'mp2',
        title: 'Digital Camera 24MP',
        imageUrl:
            'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 35999.00,
        originalPrice: 41999.00,
        description: '4K Video, 30x Optical Zoom',
        isProduct: true,
        rating: 4.6,
        reviewCount: 213,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'mp2',
                heroTag: 'infinite_product_mp2',
              ),
            ),
          );
        },
      ),
      // Add products from recommendedProducts as well for more variety
      ...recommendedProducts,
      SuggestionItem(
        id: 'mp3',
        title: 'Home Theater System',
        imageUrl:
            'https://images.unsplash.com/photo-1558403194-611308249627?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 24999.00,
        originalPrice: 29999.00,
        description: 'Dolby Atmos, 5.1 Channel',
        isProduct: true,
        rating: 4.5,
        reviewCount: 186,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(
                productId: 'mp3',
                heroTag: 'infinite_product_mp3',
              ),
            ),
          );
        },
      ),
      // Add remaining products from topMobiles and topElectronics
      ...topMobiles,
      ...topElectronics,
    ];

    return Scaffold(
      appBar: HomeAppBar(
        cartItemCount: 2,
        onCartPressed: () {
          // Navigate to cart page instead of showing a snackbar
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
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Updated search bar to navigate to search page
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

            // Category grid section
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
              addAnimation: true,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Summer Sale",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Up to 50% off",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Shop Now"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ScrollableSuggestionRow(
              title: 'Trending Now',
              items: trendingProducts,
              itemHeight: 220,
              itemWidth: 145,
              showMore: true,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all trending products')),
                );
              },
            ),
            const SizedBox(height: 12),
            ScrollableSuggestionRow(
              title: 'Recommended For You',
              items: recommendedProducts,
              itemHeight: 220,
              itemWidth: 145,
              showMore: true,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View all recommended products'),
                  ),
                );
              },
            ),
            // Mobile Brands section
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
              addAnimation: true,
              brandMode: true, // Pass a flag to indicate these are brands
            ),

            // Top Mobiles section
            const SizedBox(height: 16),
            ScrollableSuggestionRow(
              title: 'Top Mobiles',
              items: topMobiles,
              itemHeight: 220,
              itemWidth: 145,
              showMore: true,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all top mobiles')),
                );
              },
            ),

            // Top Electronics section
            const SizedBox(height: 16),
            ScrollableSuggestionRow(
              title: 'Top Electronics',
              items: topElectronics,
              itemHeight: 220,
              itemWidth: 145,
              showMore: true,
              onMoreTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all top electronics')),
                );
              },
            ),

            const SizedBox(height: 24), // Increased vertical spacing
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
            
            // The height needs to be defined since we're using a ListView
            Container(
              height: 500, // Fixed height for the infinite grid
              padding: const EdgeInsets.only(bottom: 24), // Increased bottom padding
              alignment: Alignment.center, // Center align the grid content
              child: InfiniteProductGrid(
                initialProducts: moreProducts.take(4).toList(),
                loadMoreProducts: (page) async {
                  // Simulate network delay
                  await Future.delayed(const Duration(seconds: 1));
                  
                  // Calculate start and end indices for pagination
                  final startIndex = page * 4;
                  if (startIndex >= moreProducts.length) {
                    return []; // No more products
                  }
                  
                  final endIndex = (startIndex + 4 <= moreProducts.length) 
                      ? startIndex + 4 
                      : moreProducts.length;
                      
                  return moreProducts.sublist(startIndex, endIndex);
                },
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                spacing: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Added vertical padding
                showTitle: false, // We already added the title above
                loadOnInit: true,
              ),
            ),

            const SizedBox(height: 32), // Added more bottom padding
          ],
        ),
      ),
    );
  }
}
