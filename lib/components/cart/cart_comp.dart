import 'package:flutter/material.dart';

/// Model class for cart items
class CartItem {
  final String id;
  final String title;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final String? description;
  final int quantity;
  final bool isAvailable;
  final Map<String, String>? attributes; // Size, color, etc.

  CartItem({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.price,
    this.originalPrice,
    this.description,
    required this.quantity,
    this.isAvailable = true,
    this.attributes,
  });

  double get totalPrice => price * quantity;
  
  int? get discountPercentage {
    if (originalPrice != null && originalPrice! > price) {
      return ((1 - price / originalPrice!) * 100).round();
    }
    return null;
  }

  CartItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    double? price,
    double? originalPrice,
    String? description,
    int? quantity,
    bool? isAvailable,
    Map<String, String>? attributes,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
      attributes: attributes ?? this.attributes,
    );
  }
}

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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrl != null
                      ? Image.network(
                          item.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
                
                const SizedBox(width: 12),
                
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isSmallScreen ? 12 : 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      if (item.attributes != null && item.attributes!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: item.attributes!.entries.map((attr) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${attr.key}: ${attr.value}",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10 : 11,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      const SizedBox(height: 8),
                      
                      // Price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "₹${item.price.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                              if (item.originalPrice != null &&
                                  item.originalPrice! > item.price) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "₹${item.originalPrice!.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey.shade500,
                                    fontSize: isSmallScreen ? 12 : 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          if (item.discountPercentage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${item.discountPercentage}% OFF",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 10 : 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          
          // Bottom actions row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remove button
                TextButton.icon(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.delete_outline,
                    size: isSmallScreen ? 18 : 20,
                    color: Colors.red.shade400,
                  ),
                  label: Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: 0,
                    ),
                  ),
                ),
                
                // Quantity control
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: item.quantity > 1
                          ? () => onQuantityChanged(item.quantity - 1)
                          : null,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(
                      width: isSmallScreen ? 36 : 40,
                      child: Center(
                        child: Text(
                          "${item.quantity}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: () => onQuantityChanged(item.quantity + 1),
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for quantity adjustment buttons
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isSmallScreen;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isSmallScreen ? 28 : 32,
      width: isSmallScreen ? 28 : 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed == null
            ? Colors.grey.shade200
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: onPressed == null
              ? Colors.grey.shade300
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: isSmallScreen ? 14 : 16,
          color: onPressed == null
              ? Colors.grey.shade400
              : Theme.of(context).colorScheme.primary,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

/// Cart summary widget showing price breakdown and checkout button
class CartSummary extends StatelessWidget {
  final List<CartItem> items;
  final double? discountAmount;
  final double? shippingCost;
  final String? promoCode;
  final VoidCallback onCheckout;
  final VoidCallback? onPromoCodeApply;
  final TextEditingController? promoController;

  const CartSummary({
    Key? key,
    required this.items,
    this.discountAmount,
    this.shippingCost,
    this.promoCode,
    required this.onCheckout,
    this.onPromoCodeApply,
    this.promoController,
  }) : super(key: key);

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get total {
    double result = subtotal;
    if (discountAmount != null) result -= discountAmount!;
    if (shippingCost != null) result += shippingCost!;
    return result > 0 ? result : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary section
          Text(
            "Order Summary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 16 : 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Price breakdown
          _SummaryRow(
            label: "Subtotal",
            value: "₹${subtotal.toStringAsFixed(0)}",
            isSmallScreen: isSmallScreen,
          ),
          
          if (shippingCost != null) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: "Shipping",
              value: shippingCost! == 0
                  ? "Free"
                  : "₹${shippingCost!.toStringAsFixed(0)}",
              isSmallScreen: isSmallScreen,
            ),
          ],
          
          if (discountAmount != null && discountAmount! > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: "Discount",
              value: "-₹${discountAmount!.toStringAsFixed(0)}",
              valueColor: Colors.green.shade700,
              isSmallScreen: isSmallScreen,
            ),
          ],
          
          if (promoCode != null && promoCode!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: "Promo ($promoCode)",
              value: "Applied",
              valueColor: Colors.green.shade700,
              isSmallScreen: isSmallScreen,
            ),
          ],
          
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          
          // Total row
          _SummaryRow(
            label: "Total",
            value: "₹${total.toStringAsFixed(0)}",
            isTotal: true,
            isSmallScreen: isSmallScreen,
          ),
          
          const SizedBox(height: 24),
          
          // Promo code input
          if (onPromoCodeApply != null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoController,
                    decoration: InputDecoration(
                      hintText: "Enter promo code",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: isSmallScreen ? 13 : 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isSmallScreen ? 10 : 14,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                ElevatedButton(
                  onPressed: onPromoCodeApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 14 : 20,
                      vertical: isSmallScreen ? 10 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 13 : 14,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
          
          // Checkout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: items.isEmpty ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: Text(
                "Proceed to Checkout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for summary rows
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;
  final bool isSmallScreen;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isSmallScreen
                ? (isTotal ? 15 : 14)
                : (isTotal ? 16 : 15),
            color: isTotal ? null : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isSmallScreen
                ? (isTotal ? 15 : 14)
                : (isTotal ? 16 : 15),
            color: isTotal
                ? null
                : (valueColor ?? Colors.grey.shade800),
          ),
        ),
      ],
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
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty cart icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title text
            Text(
              "Your Cart is Empty",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Description text
            Text(
              "Looks like you haven't added any items to your cart yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Start shopping button
            ElevatedButton(
              onPressed: onStartShopping,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Start Shopping",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}