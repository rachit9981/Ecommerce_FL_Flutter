import 'package:flutter/material.dart';
import '../services/detailed_product.dart';
import '../components/detailed_product/product_image_carousel.dart';
import '../components/detailed_product/product_basic_info.dart';
import '../components/detailed_product/product_pricing.dart';
import '../components/detailed_product/product_option_selector.dart';
import '../components/detailed_product/product_description.dart';
import '../components/detailed_product/product_features.dart';
import '../components/detailed_product/product_specifications.dart';
import '../components/detailed_product/product_reviews.dart';
import '../components/detailed_product/product_action_buttons.dart';

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
  }

  void _onOptionSelected(ValidOption? option) {
    setState(() {
      _selectedOption = option;
    });
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
      ),
      body: FutureBuilder<DetailedProduct>(
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
            );
          } else if (snapshot.hasData) {
            final product = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [                        // Product Images and Videos
                        ProductImageCarousel(
                          images: product.images,
                          videos: product.videos,
                          heroTag: widget.heroTag,
                        ),// Content with proper spacing
                        Column(
                          children: [
                            // Basic Product Info
                            ProductBasicInfo(product: product),
                            
                            Divider(color: Colors.grey.shade200, height: 32),
                            
                            // Pricing
                            ProductPricing(
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
                            ProductSpecifications(product: product),
                            
                            Divider(color: Colors.grey.shade200, height: 32),
                            
                            // Reviews
                            ProductReviews(product: product),
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
      ),
    );
  }
}
