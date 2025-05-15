import 'package:flutter/material.dart';
import 'package:ecom/components/app_bar/home.dart';
import 'package:ecom/components/common/suggestions.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample categories data
    final List<SuggestionItem> categories = [
      SuggestionItem(
        id: '1',
        title: 'Electronics',
        imageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Electronics category tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '2',
        title: 'Fashion',
        imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fashion category tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '3',
        title: 'Home & Kitchen',
        imageUrl: 'https://images.unsplash.com/photo-1556911220-bda9f7f3fe9b?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Home & Kitchen category tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '4',
        title: 'Beauty',
        imageUrl: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Beauty category tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '5',
        title: 'Sports & Outdoors',
        imageUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sports category tapped')),
          );
        },
      ),
    ];
    
    // Sample trending products data
    final List<SuggestionItem> trendingProducts = [
      SuggestionItem(
        id: '1',
        title: 'Wireless Earbuds',
        imageUrl: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 79.99,
        description: 'Noise cancellation',
        isProduct: true,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wireless Earbuds product tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '2',
        title: 'Smart Watch',
        imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 199.99,
        description: 'Fitness tracking',
        isProduct: true,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Smart Watch product tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '3',
        title: 'Laptop Backpack',
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 49.99,
        description: 'Water resistant',
        isProduct: true,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laptop Backpack product tapped')),
          );
        },
      ),
      SuggestionItem(
        id: '4',
        title: 'Portable Charger',
        imageUrl: 'https://images.unsplash.com/photo-1585003791087-a5aabb863540?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 29.99,
        description: '20000mAh capacity',
        isProduct: true,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Portable Charger product tapped')),
          );
        },
      ),
    ];
    
    // Sample recommended products data
    final List<SuggestionItem> recommendedProducts = [
      SuggestionItem(
        id: '1',
        title: 'Coffee Maker',
        imageUrl: 'https://images.unsplash.com/photo-1517466787929-bc90951d0974?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 129.99,
        description: 'Automatic brewing',
        isProduct: true,
        onTap: () {},
      ),
      SuggestionItem(
        id: '2',
        title: 'Yoga Mat',
        imageUrl: 'https://images.unsplash.com/photo-1590432923467-c5469804a8a9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 24.99,
        description: 'Non-slip surface',
        isProduct: true,
        onTap: () {},
      ),
      SuggestionItem(
        id: '3',
        title: 'LED Desk Lamp',
        imageUrl: 'https://images.unsplash.com/photo-1534159559673-de7bc89fa998?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 39.99,
        description: 'Adjustable brightness',
        isProduct: true,
        onTap: () {},
      ),
      SuggestionItem(
        id: '4',
        title: 'Bluetooth Speaker',
        imageUrl: 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        price: 59.99,
        description: 'Waterproof',
        isProduct: true,
        onTap: () {},
      ),
    ];

    return Scaffold(
      appBar: HomeAppBar(),
      body: ListView(
        children: [
          // Featured banner or carousel could go here
          const SizedBox(height: 12), // Reduced from 16
          
          // Categories row
          ScrollableSuggestionRow(
            title: 'Categories',
            items: categories,
            itemHeight: 130, // Increased from 120 to allow more space
            itemWidth: 120, // Reduced from default 140
          ),
          
          const SizedBox(height: 12), // Reduced from 16
          
          // Trending products row
          ScrollableSuggestionRow(
            title: 'Trending Now',
            items: trendingProducts,
            showMore: true,
            itemHeight: 170, // Increased to accommodate product details
            itemWidth: 130, // Reduced from default 140
            onMoreTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View all trending products')),
              );
            },
          ),
          
          const SizedBox(height: 12), // Reduced from 16
          
          // Recommended products row
          ScrollableSuggestionRow(
            title: 'Recommended For You',
            items: recommendedProducts,
            showMore: true,
            onMoreTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('View all recommended products')),
              );
            },
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
