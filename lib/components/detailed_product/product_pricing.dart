import 'package:flutter/material.dart';
import '../../services/detailed_product.dart';

class ProductPricing extends StatelessWidget {
  final DetailedProduct product;
  final ValidOption? selectedOption;

  const ProductPricing({
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
    final double discountPercentage = hasDiscount ? (discountAmount / originalPrice) * 100 : 0;    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${currentPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontSize: 24,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  '₹${originalPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
          
          if (hasDiscount) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                  fontSize: 11,
                ),
              ),
            ),
          ],
          
          // Additional discount info if available
          if (product.discount != null && 
              product.discount!.isNotEmpty && 
              (originalPrice == 0 || currentPrice == originalPrice)) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade200),
              ),
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
        ],
      ),
    );
  }
}
