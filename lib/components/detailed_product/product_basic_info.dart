import 'package:flutter/material.dart';
import '../../services/detailed_product.dart';

class ProductBasicInfo extends StatelessWidget {
  final DetailedProduct product;

  const ProductBasicInfo({
    Key? key,
    required this.product,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Product Name
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        
        // Brand and Category
        Row(
          children: [
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
          ],
        ),
        const SizedBox(height: 16),
          // Rating and Reviews
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
        const SizedBox(height: 12),        // Stock Status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                size: 14,
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
                  fontSize: 12,
                ),              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
