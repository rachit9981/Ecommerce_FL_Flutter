import 'package:flutter/material.dart';
import '../../services/cart_wishlist.dart';

/// Widget to display a single cart item with quantity controls
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image - more compact
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: (item.imageUrl != null && item.imageUrl!.isNotEmpty) || 
                     (item.image != null && item.image!.isNotEmpty)
                  ? Image.network(
                      item.imageUrl ?? item.image!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade50,
                          child: Icon(Icons.image_not_supported, color: Colors.grey.shade300, size: 16),
                        );
                      },
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade50,
                      child: Icon(Icons.image, color: Colors.grey.shade300, size: 16),
                    ),
            ),
            const SizedBox(width: 10),
            
            // Product details - more compact layout
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  
                  // Brand and category info - smaller
                  if (item.brand != null || item.category != null)
                    Text(
                      [item.brand, item.category].where((e) => e != null).join(' • '),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),
                  
                  const SizedBox(height: 4),
                  
                  // Price and variant in same row
                  Row(
                    children: [
                      if (item.price != null)
                        Text(
                          '₹${item.price!.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      if (item.variant != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.grey.shade200, width: 0.5),
                            ),
                            child: Text(
                              _getVariantDisplayText(item.variant!),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Stock info - smaller
                  if (item.stock != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.stock! > 0 ? 'In Stock (${item.stock})' : 'Out of Stock',
                        style: TextStyle(
                          color: item.stock! > 0 ? Colors.green.shade600 : Colors.red.shade600,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 6),
                  
                  // Quantity and remove button - more compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade200, width: 0.5),
                        ),
                        child: Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      
                      InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red.shade400,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getVariantDisplayText(Map<String, dynamic> variant) {
    final List<String> variantInfo = [];
    
    // Common variant fields to display
    if (variant['color'] != null) variantInfo.add('Color: ${variant['color']}');
    if (variant['size'] != null) variantInfo.add('Size: ${variant['size']}');
    if (variant['storage'] != null) variantInfo.add('Storage: ${variant['storage']}');
    if (variant['ram'] != null) variantInfo.add('RAM: ${variant['ram']}');
    if (variant['memory'] != null) variantInfo.add('Memory: ${variant['memory']}');
    
    return variantInfo.isNotEmpty ? variantInfo.join(' • ') : 'Variant Selected';
  }
}

/// Cart summary widget showing price breakdown and checkout button
class CartSummary extends StatelessWidget {
  final List<CartItem> items;
  final double discountAmount;
  final double shippingCost;
  final VoidCallback onCheckout;
  final bool isAddressLoading; // New property for address loading state

  const CartSummary({
    Key? key,
    required this.items,
    required this.discountAmount,
    required this.shippingCost,
    required this.onCheckout,
    this.isAddressLoading = false, // Default to false
  }) : super(key: key);

  double get subtotal {
    return items.fold(
      0,
      (sum, item) => sum + ((item.price ?? 0) * item.quantity),
    );
  }

  double get total {
    return subtotal - discountAmount + shippingCost;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary header
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          
          // Order summary details
          _buildSummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          if (discountAmount > 0)
            _buildSummaryRow(
              'Discount', 
              '-₹${discountAmount.toStringAsFixed(0)}',
              valueColor: Colors.green.shade600,
            ),
          _buildSummaryRow(
            'Shipping',
            shippingCost > 0 ? '₹${shippingCost.toStringAsFixed(0)}' : 'Free',
            valueColor: shippingCost == 0 ? Colors.green.shade600 : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.grey.shade200, thickness: 0.5, height: 1),
          ),
          _buildSummaryRow(
            'Total',
            '₹${total.toStringAsFixed(0)}',
            isBold: true,
          ),
          const SizedBox(height: 16),
          
          // Checkout button with loading state
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isAddressLoading ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: isAddressLoading 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              fontSize: isBold ? 13 : 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? (isBold ? Colors.black87 : Colors.grey.shade700),
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              fontSize: isBold ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty cart state widget
class EmptyCartView extends StatelessWidget {
  final VoidCallback onStartShopping;

  const EmptyCartView({
    Key? key,
    required this.onStartShopping,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add items to your cart to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onStartShopping,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}