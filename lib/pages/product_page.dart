import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/detailed_product.dart';
import '../services/products.dart';
import '../providers/product_provider.dart';
import '../pages/category_page.dart';
import '../components/common/categories.dart';
import '../components/detailed_product/product_image_carousel.dart';
import '../components/detailed_product/product_info_and_pricing.dart';
import '../components/detailed_product/product_option_selector.dart';
import '../components/detailed_product/product_description.dart';
import '../components/detailed_product/product_features.dart';
import '../components/detailed_product/product_specifications.dart';
import '../components/detailed_product/product_reviews.dart';
import '../components/detailed_product/product_action_buttons.dart';
import '../components/common/suggestions.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  final String heroTag;

  const ProductPage({Key? key, required this.productId, required this.heroTag})
      : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<DetailedProduct> _detailedProductFuture;
  final DetailedProductService _productService = DetailedProductService();
  ValidOption? _selectedOption;

  @override
  void initState() {
    super.initState();
    _detailedProductFuture = _productService.getDetailedProduct(widget.productId);
    // Load products for suggestions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  void _onOptionSelected(ValidOption? option) {
    setState(() {
      _selectedOption = option;
    });
  }  List<SuggestionItem> _getCategoryProducts(DetailedProduct currentProduct, List<Product> allProducts) {
    // Filter products by category, excluding current product and similar products already shown
    final categoryProducts = allProducts
        .where((product) {
          // Exclude current product
          if (product.id == currentProduct.id) return false;
          
          // Check for category match (case insensitive)
          final productCategory = product.category.toLowerCase().trim();
          final currentCategory = currentProduct.category.toLowerCase().trim();
          
          return productCategory.contains(currentCategory) || 
                 currentCategory.contains(productCategory);
        })
        .take(8) // Show more products for category
        .toList();

    return categoryProducts.map((product) => SuggestionItem(
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
              heroTag: 'category_${product.id}',
            ),
          ),
        );
      },
    )).toList();
  }

  List<SuggestionItem> _getSimilarProducts(DetailedProduct currentProduct, List<Product> allProducts) {
    // Filter products by category or brand, excluding current product
    final similarProducts = allProducts
        .where((product) {
          // Exclude current product
          if (product.id == currentProduct.id) return false;
          
          // Check for category or brand match (case insensitive)
          final productCategory = product.category.toLowerCase().trim();
          final productBrand = product.brand.toLowerCase().trim();
          final currentCategory = currentProduct.category.toLowerCase().trim();
          final currentBrand = currentProduct.brand.toLowerCase().trim();
          
          return productCategory.contains(currentCategory) || 
                 currentCategory.contains(productCategory) ||
                 productBrand.contains(currentBrand) || 
                 currentBrand.contains(productBrand);
        })
        .take(6)
        .toList();

    return similarProducts.map((product) => SuggestionItem(
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
              heroTag: 'similar_${product.id}',
            ),
          ),
        );
      },
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: FutureBuilder<DetailedProduct>(
          future: _detailedProductFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data!.name,
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              );
            } else {
              return const Text('Product');
            }
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return FutureBuilder<DetailedProduct>(
            future: _detailedProductFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading product',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _detailedProductFuture = _productService.getDetailedProduct(widget.productId);
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );              } else if (snapshot.hasData) {
                final product = snapshot.data!;
                
                // Get similar products with error handling
                List<SuggestionItem> similarProducts = [];
                List<SuggestionItem> categoryProducts = [];
                try {
                  if (productProvider.products.isNotEmpty) {
                    similarProducts = _getSimilarProducts(product, productProvider.products);
                    categoryProducts = _getCategoryProducts(product, productProvider.products);
                  }
                } catch (e) {
                  // Handle any errors in similar products generation
                  print('Error generating similar products: $e');
                  similarProducts = [];
                  categoryProducts = [];
                }
                
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(                        child: Column(
                          children: [
                            // Product Images and Videos
                            ProductImageCarousel(
                              images: product.images,
                              videos: product.videos,
                              heroTag: widget.heroTag,
                            ),
                            
                            // Content with proper spacing
                            Column(
                              children: [
                                // Combined Product Info and Pricing
                                ProductInfoAndPricing(
                                  product: product,
                                  selectedOption: _selectedOption,
                                ),
                                
                                // Option Selector (if variants exist)
                                if (product.validOptions.isNotEmpty) ...[
                                  Divider(color: Colors.grey.shade200, height: 32),
                                  ProductOptionSelector(
                                    product: product,
                                    onOptionSelected: _onOptionSelected,
                                  ),
                                ],
                                
                                Divider(color: Colors.grey.shade200, height: 32),
                                
                                // Description
                                ProductDescription(product: product),
                                
                                Divider(color: Colors.grey.shade200, height: 32),
                                
                                // Features
                                ProductFeatures(product: product),
                                  Divider(color: Colors.grey.shade200, height: 32),
                                
                                // Specifications
                                ProductSpecifications(product: product),                                // Similar Products Suggestions (before reviews)
                                if (similarProducts.isNotEmpty) ...[
                                  Divider(color: Colors.grey.shade200, height: 32),
                                  ScrollableSuggestionRow(
                                    title: 'Similar Products',
                                    items: similarProducts,
                                    itemHeight: 195, // Reduced from 200 to fix overflow
                                    itemWidth: 140,
                                    showMore: false,
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Reduced vertical padding
                                  ),
                                ],
                                
                                // More Category Products
                                if (categoryProducts.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  ScrollableSuggestionRow(
                                    title: 'More ${product.category}',
                                    items: categoryProducts,
                                    itemHeight: 195,
                                    itemWidth: 140,
                                    showMore: true,
                                    onMoreTap: () {
                                      // TODO: Navigate to category page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CategoryPage(
                                            category: CategoryItem(
                                              id: product.category.toLowerCase(),
                                              title: product.category,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                  ),
                                ],
                                
                                // Reviews (only show if there are reviews)
                                if (product.reviews.isNotEmpty) ...[
                                  Divider(color: Colors.grey.shade200, height: 32),
                                  ProductReviews(product: product),
                                ],
                                const SizedBox(height: 80), // Space for fixed bottom buttons
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Fixed Action Buttons at Bottom
                    ProductActionButtons(
                      product: product,
                      selectedOption: _selectedOption,
                    ),
                  ],
                );
              } else {
                return const Center(
                  child: Text('No product data found.'),
                );
              }
            },
          );
        },
      ),
    );
  }
}
