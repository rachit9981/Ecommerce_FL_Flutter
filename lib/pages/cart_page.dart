import 'package:flutter/material.dart';
import 'package:ecom/components/cart/cart_comp.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Sample cart items - in a real app, these would come from a state management solution
  List<CartItem> _cartItems = [
    CartItem(
      id: '1',
      title: 'Wireless Earbuds',
      imageUrl: 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      price: 79.99,
      originalPrice: 99.99,
      description: 'Noise cancellation',
      quantity: 1,
      attributes: {
        'Color': 'Black',
      },
    ),
    CartItem(
      id: '2',
      title: 'Smart Watch',
      imageUrl: 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      price: 199.99,
      originalPrice: 249.99,
      description: 'Fitness tracking',
      quantity: 2,
      attributes: {
        'Color': 'Silver',
        'Size': '44mm',
      },
    ),
    CartItem(
      id: '3',
      title: 'Laptop Backpack',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      price: 49.99,
      originalPrice: 69.99,
      description: 'Water resistant',
      quantity: 1,
    ),
  ];

  // Shipping and discount values
  final double _shippingCost = 0.0; // Free shipping
  double _discountAmount = 0.0;

  void _updateQuantity(String itemId, int newQuantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      }
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      _cartItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems = [];
      _discountAmount = 0;
    });
  }

  void _proceedToCheckout() {
    // Navigate to checkout page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to checkout...')),
    );
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
          if (_cartItems.isNotEmpty)
            IconButton(
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
                          _clearCart();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _cartItems.isEmpty 
            ? EmptyCartView(onStartShopping: _navigateToHome)
            : Column(
                children: [
                  // Cart items list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return CartItemCard(
                          item: item,
                          onQuantityChanged: (newQuantity) {
                            _updateQuantity(item.id, newQuantity);
                          },
                          onRemove: () {
                            _removeItem(item.id);
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Cart summary
                  CartSummary(
                    items: _cartItems,
                    discountAmount: _discountAmount,
                    shippingCost: _shippingCost,
                    onCheckout: _proceedToCheckout,
                  ),
                ],
              ),
      ),
    );
  }
}
