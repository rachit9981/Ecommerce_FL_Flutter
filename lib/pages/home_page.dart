import 'package:flutter/material.dart';
import 'package:ecom/components/app_bar/home.dart';
import 'package:ecom/components/common/suggestions.dart';
import 'package:ecom/components/common/categories.dart';
import 'package:ecom/pages/cart_page.dart'; // Add import for cart page

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get sample categories from CategoryData class
    final categories = CategoryData.getSampleCategories(context);

    final List<SuggestionItem> trendingProducts = [
      SuggestionItem(
        id: '1',
        title: 'Wireless Earbuds',
        imageUrl:
            'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 79.99,
        originalPrice: 99.99, // Added for discount
        description: 'Noise cancellation',
        isProduct: true,
        isNew: true, // Show "NEW" badge
        rating: 4.5, // Display rating
        reviewCount: 256, // Show review count
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wireless Earbuds product tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '2',
        title: 'Smart Watch',
        imageUrl:
            'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 199.99,
        originalPrice: 249.99,
        description: 'Fitness tracking',
        isProduct: true,
        isNew: true,
        rating: 4.7,
        reviewCount: 128,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Smart Watch product tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '3',
        title: 'Laptop Backpack',
        imageUrl:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 49.99,
        originalPrice: 69.99,
        description: 'Water resistant',
        isProduct: true,
        isNew: false,
        rating: 4.2,
        reviewCount: 75,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laptop Backpack product tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '4',
        title: 'Portable Charger',
        imageUrl:
            'https://images.unsplash.com/photo-1585003791087-a5aabb863540?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 29.99,
        originalPrice: 39.99,
        description: '20000mAh capacity',
        isProduct: true,
        isNew: false,
        rating: 4.8,
        reviewCount: 200,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Portable Charger product tapped')),
          );
        },
      ),
    ];

    final List<SuggestionItem> recommendedProducts = [
      SuggestionItem(
        id: '1',
        title: 'Coffee Maker',
        imageUrl:
            'https://images.unsplash.com/photo-1517466787929-bc90951d0974?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 129.99,
        description: 'Automatic brewing',
        isProduct: true,
        rating: 4.3,
        reviewCount: 128,
        isFeatured: true,
        onTap: () {},
      ),
      SuggestionItem(
        id: '2',
        title: 'Yoga Mat',
        imageUrl:
            'https://images.unsplash.com/photo-1590432923467-c5469804a8a9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 24.99,
        description: 'Non-slip surface',
        isProduct: true,
        rating: 4.0,
        reviewCount: 86,
        onTap: () {},
      ),
      SuggestionItem(
        id: '3',
        title: 'LED Desk Lamp',
        imageUrl:
            'https://images.unsplash.com/photo-1534159559673-de7bc89fa998?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 39.99,
        description: 'Adjustable brightness',
        isProduct: true,
        rating: 4.6,
        reviewCount: 112,
        onTap: () {},
      ),
      SuggestionItem(
        id: '4',
        title: 'Bluetooth Speaker',
        imageUrl:
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 59.99,
        description: 'Waterproof',
        isProduct: true,
        rating: 4.4,
        reviewCount: 95,
        onTap: () {},
      ),
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
      ),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
