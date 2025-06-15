import 'package:flutter/material.dart';
import '../../services/detailed_product.dart';

class ProductInfoAndPricing extends StatelessWidget {
  final DetailedProduct product;
  final ValidOption? selectedOption;

  const ProductInfoAndPricing({
    Key? key,
    required this.product,
    this.selectedOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double currentPrice = selectedOption?.discountedPrice ?? product.discountPrice;
    final double originalPrice = selectedOption?.price ?? product.price;
    final bool hasDiscount = originalPrice > currentPrice;
    final double discountAmount = originalPrice - currentPrice;
    final double discountPercentage = hasDiscount ? (discountAmount / originalPrice) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            product.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          
          // Brand, Category, and Stock Status Row
          Row(
            children: [
              // Brand Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  product.brand,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Category Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  product.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const Spacer(),
              
              // Stock Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.stock > 0 ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: product.stock > 0 ? Colors.green.shade200 : Colors.red.shade200,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      product.stock > 0 ? Icons.check_circle_outline : Icons.cancel_outlined,
                      size: 12,
                      color: product.stock > 0 ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.stock > 0 
                          ? product.stock <= 5 
                              ? 'Few left' 
                              : 'In stock'
                          : 'Out of stock',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: product.stock > 0 ? Colors.green.shade600 : Colors.red.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
            // Rating and Price Section - All Left Aligned
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Section
              Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < product.rating.floor()
                            ? Icons.star
                            : index < product.rating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${product.rating.toStringAsFixed(1)} (${product.totalReviews})',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Price Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${currentPrice.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      // color: Theme.of(context).primaryColor,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasDiscount) ...[
                    Text(
                      '₹${originalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              
              if (hasDiscount) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade200, width: 0.5),
                  ),
                  child: Text(
                    'Save ₹${discountAmount.toStringAsFixed(0)} (${discountPercentage.toStringAsFixed(0)}% off)',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Additional discount info if available
          if (product.discount != null && 
              product.discount!.isNotEmpty && 
              (originalPrice == 0 || currentPrice == originalPrice)) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: Colors.orange.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Special Offer: ${product.discount}',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
