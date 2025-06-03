import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/cart/cart_comp.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // Fetch cart items when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.fetchCartItems();
    });
  }

  void _navigateToHome() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cartItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear cart',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text('Are you sure you want to remove all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              cartProvider.clearCart();
                              Navigator.pop(context);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            }
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading cart...')
                  ],
                ),
              );
            }
            
            if (cartProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: ${cartProvider.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        cartProvider.clearError();
                        cartProvider.fetchCartItems();
                      },
                      child: Text('Retry'),
                    )
                  ],
                ),
              );
            }
            
            if (cartProvider.isEmpty) {
              return EmptyCartView(onStartShopping: _navigateToHome);
            }
            
            return Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.cartItems[index];
                      return CartItemCard(
                        item: item,
                        onQuantityChanged: (newQuantity) {
                          cartProvider.updateQuantity(item.itemId, newQuantity);
                        },
                        onRemove: () {
                          cartProvider.removeFromCart(item.itemId);
                        },
                      );
                    },
                  ),
                ),
                
                // Cart summary
                CartSummary(
                  items: cartProvider.cartItems,
                  discountAmount: cartProvider.discountAmount,
                  shippingCost: cartProvider.shippingCost,
                  onCheckout: () {
                    // Navigate to checkout page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proceeding to checkout...')),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
