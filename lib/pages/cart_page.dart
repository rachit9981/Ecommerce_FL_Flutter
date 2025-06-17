import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/components/cart/cart_comp.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import '../services/address_service.dart';
import '../services/cart_wishlist.dart';
import '../components/common/login_required.dart';
import '../pages/login_page.dart';
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
    final cartItems = cartProvider.cartItems;
    final productIds = cartItems.map((item) => item.productId).toList();
    final double subtotal = cartItems.fold(
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
      });      if (addresses.isEmpty) {
        _showAddAddressDialog(context);
        return;
      } else if (addresses.length == 1) {
        _navigateToCheckout(context, addresses[0].id, cartItems, amountInPaise);
      } else {
        _showAddressSelectionDialog(context, addresses, cartItems, amountInPaise);
      }    } catch (e) {
      setState(() {
        _isAddressLoading = false;
      });
      
      print('Error loading addresses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load addresses. Please try again.')),
      );
    }
  }
  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'No Address Found',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Please add a delivery address before proceeding to checkout.',
          style: TextStyle(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pop(context);
          //     // Navigate to add address page
          //     // Replace with your actual navigation code
          //     Navigator.pushNamed(context, '/addresses/add');
          //   },
          //   child: Text('Add Address'),
          // ),
        ],
      ),
    );
  }  void _showAddressSelectionDialog(
    BuildContext context, 
    List<UserAddress> addresses, 
    List<CartItem> cartItems, 
    int amountInPaise
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Delivery Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                dense: true,
                leading: Radio<String>(
                  value: address.id,
                  groupValue: null, // No pre-selection
                  onChanged: (value) {
                    Navigator.pop(context);
                    _navigateToCheckout(context, address.id, cartItems, amountInPaise);
                  },
                ),
                title: Text(
                  address.name,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${address.street}, ${address.city}, ${address.state} ${address.pincode}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCheckout(context, address.id, cartItems, amountInPaise);
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
            child: Text('Cancel', style: TextStyle(fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to add new address
              Navigator.pushNamed(context, '/addresses/add');
            },
            child: Text('Add New', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
  void _navigateToCheckout(
    BuildContext context, 
    String addressId, 
    List<CartItem> cartItems, 
    int amountInPaise
  ) {
    final productIds = cartItems.map((item) => item.productId).toList();
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
    return Scaffold(      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cartItems.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade400, size: 20),
                    tooltip: 'Clear cart',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            'Clear Cart',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          content: const Text(
                            'Remove all items from your cart?',
                            style: TextStyle(fontSize: 14),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(fontSize: 13)),
                            ),
                            TextButton(
                              onPressed: () {
                                cartProvider.clearCart();
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Clear', style: TextStyle(fontSize: 13)),
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
      ),body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          print('CartPage: User authentication state: ${userProvider.isAuthenticated}');
          // If not authenticated, show login prompt for cart features
          if (!userProvider.isAuthenticated) {
            return LoginRequired(
              title: 'Login to Access Your Cart',
              message: 'Please login to view your saved cart items and checkout',
              icon: Icons.shopping_cart_outlined,
              onLoginPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            );
          }
          
          // If authenticated, show the cart content
          return SafeArea(
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {                if (cartProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Loading cart...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
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
                        Icon(Icons.error_outline, size: 40, color: Colors.red.shade300),
                        SizedBox(height: 12),
                        Text(
                          'Error: ${cartProvider.error}',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            cartProvider.clearError();
                            cartProvider.fetchCartItems();
                          },
                          icon: Icon(Icons.refresh, size: 16),
                          label: Text('Retry', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
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
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
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
          );
        },
      ),
    );
  }
}
