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
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cartItems.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade400),
                    tooltip: 'Clear cart',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Cart'),
                          content: const Text('Are you sure you want to remove all items from your cart?'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
                    SizedBox(height: 20),
                    Text(
                      'Loading your cart...',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              );
            }
            
            if (cartProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
                    SizedBox(height: 20),
                    Text(
                      'Error: ${cartProvider.error}',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        cartProvider.clearError();
                        cartProvider.fetchCartItems();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    physics: const BouncingScrollPhysics(),
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
                      SnackBar(
                        content: Text('Proceeding to checkout...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
