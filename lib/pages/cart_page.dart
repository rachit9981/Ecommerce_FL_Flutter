import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/cart/cart_comp.dart';
import '../providers/cart_provider.dart';
import '../services/address_service.dart'; // Import address service
import 'checkout.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final AddressService _addressService = AddressService(); // Initialize address service
  bool _isAddressLoading = false;

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

  // Method to handle address selection and checkout
  Future<void> _proceedToCheckout(BuildContext context, CartProvider cartProvider) async {
    final productIds = cartProvider.cartItems.map((item) => item.productId).toList();
    final double subtotal = cartProvider.cartItems.fold(
      0,
      (sum, item) => sum + ((item.price ?? 0) * item.quantity),
    );
    final double grandTotal = subtotal - cartProvider.discountAmount + cartProvider.shippingCost;
    final amountInPaise = (grandTotal * 100).toInt();

    if (productIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty. Add items to proceed.')),
      );
      return;
    }
    
    if (amountInPaise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Total amount must be greater than zero.')),
      );
      return;
    }

    setState(() {
      _isAddressLoading = true;
    });

    try {
      final addresses = await _addressService.getAddresses();
      print(addresses);
      setState(() {
        _isAddressLoading = false;
      });

      if (addresses.isEmpty) {
        // No addresses available - prompt to add an address
        _showAddAddressDialog(context);
        return;
      } else if (addresses.length == 1) {
        // Only one address - use it automatically
        print("Using single address: ${addresses[0].id}");
        _navigateToCheckout(context, addresses[0].id, productIds, amountInPaise);
      } else {
        // Multiple addresses - show selection dialog
        _showAddressSelectionDialog(context, addresses, productIds, amountInPaise);
      }
    } catch (e) {
      setState(() {
        _isAddressLoading = false;
      });
      
      print("Error loading addresses: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading addresses: $e')),
      );
    }
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Address Found'),
        content: Text('Please add a delivery address before proceeding to checkout.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add address page
              // Replace with your actual navigation code
              Navigator.pushNamed(context, '/addresses/add');
            },
            child: Text('Add Address'),
          ),
        ],
      ),
    );
  }

  void _showAddressSelectionDialog(
    BuildContext context, 
    List<UserAddress> addresses, 
    List<String> productIds, 
    int amountInPaise
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Delivery Address'),
        contentPadding: EdgeInsets.symmetric(vertical: 20),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                leading: Radio<String>(
                  value: address.id,
                  groupValue: null, // No pre-selection
                  onChanged: (_) {
                    Navigator.pop(context);
                    _navigateToCheckout(context, address.id, productIds, amountInPaise);
                  },
                ),
                title: Text(address.name),
                subtitle: Text(
                  '${address.street}, ${address.city}, ${address.state} ${address.pincode}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCheckout(context, address.id, productIds, amountInPaise);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add new address
              Navigator.pushNamed(context, '/addresses/add');
            },
            child: Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(
    BuildContext context, 
    String addressId, 
    List<String> productIds, 
    int amountInPaise
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          addressId: addressId,
          productIds: productIds,
          amountInPaise: amountInPaise,
        ),
      ),
    );
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
                
                // Cart summary with updated checkout flow
                CartSummary(
                  items: cartProvider.cartItems,
                  discountAmount: cartProvider.discountAmount,
                  shippingCost: cartProvider.shippingCost,
                  isAddressLoading: _isAddressLoading,
                  onCheckout: () => _proceedToCheckout(context, cartProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
