import 'package:flutter/material.dart';
import '../../services/detailed_product.dart';

class ProductActionButtons extends StatelessWidget {
  final DetailedProduct product;
  final ValidOption? selectedOption;

  const ProductActionButtons({
    Key? key,
    required this.product,
    this.selectedOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = (selectedOption?.stock ?? product.stock) > 0;
      return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [            // Add to Wishlist Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                onPressed: () {
                  // TODO: Add to wishlist functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to wishlist'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite_border, size: 20),
                color: Colors.grey.shade700,
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Add to Cart Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: isAvailable ? () {
                    // TODO: Add to cart functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } : null,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(isAvailable ? 'Add to Cart' : 'Out of Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? Theme.of(context).primaryColor : Colors.grey,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 10),
            
            // Buy Now Button
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: isAvailable ? () {
                    // TODO: Buy now functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Proceeding to checkout'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? Colors.orange : Colors.grey,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  child: Text(isAvailable ? 'Buy Now' : 'Unavailable'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
