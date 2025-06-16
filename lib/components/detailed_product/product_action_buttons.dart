import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/detailed_product.dart';
import '../../services/cart_wishlist.dart';
import '../../services/address_service.dart';
import '../../providers/user_provider.dart';
import '../../pages/checkout.dart';

class ProductActionButtons extends StatefulWidget {
  final DetailedProduct product;
  final ValidOption? selectedOption;

  const ProductActionButtons({
    Key? key,
    required this.product,
    this.selectedOption,
  }) : super(key: key);

  @override
  State<ProductActionButtons> createState() => _ProductActionButtonsState();
}

class _ProductActionButtonsState extends State<ProductActionButtons> {
  final CartWishlistService _cartWishlistService = CartWishlistService();
  final AddressService _addressService = AddressService();
  bool _isProcessing = false;

  String? get _variantId => widget.selectedOption?.id;

  Future<void> _addToWishlist() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isAuthenticated) {
      _showLoginRequiredDialog('add to wishlist');
      return;
    }

    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      await _cartWishlistService.addToWishlist(widget.product.id, variantId: _variantId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.favorite, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.product.name} added to wishlist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.pink.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to wishlist: ${e.toString().replaceAll('Exception: ', '')}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _addToCart() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isAuthenticated) {
      _showLoginRequiredDialog('add to cart');
      return;
    }

    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      await _cartWishlistService.addToCart(widget.product.id, variantId: _variantId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${widget.product.name} added to cart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString().replaceAll('Exception: ', '')}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _buyNow() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isAuthenticated) {
      _showLoginRequiredDialog('proceed to checkout');
      return;
    }

    if (_isProcessing) return;    // Calculate price based on selected option or product price
    final double price = widget.selectedOption?.discountedPrice ?? 
                        widget.selectedOption?.price ?? 
                        widget.product.discountPrice;
                        
    final int amountInPaise = (price * 100).toInt();

    if (amountInPaise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid price. Please try again.')),
      );
      return;
    }    setState(() {
      _isProcessing = true;
    });

    try {
      final addresses = await _addressService.getAddresses();
      
      setState(() {
        _isProcessing = false;
      });

      if (addresses.isEmpty) {
        _showAddAddressDialog();
        return;
      } else if (addresses.length == 1) {
        _navigateToCheckout(addresses[0].id, amountInPaise);
      } else {
        _showAddressSelectionDialog(addresses, amountInPaise);
      }    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading addresses: $e')),
      );
    }
  }

  void _showLoginRequiredDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text('Please login to $action.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Address Found'),
        content: Text('Please add a delivery address before proceeding to checkout.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addresses/add');
            },
            child: Text('Add Address'),
          ),
        ],
      ),
    );
  }

  void _showAddressSelectionDialog(List<UserAddress> addresses, int amountInPaise) {
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
                  groupValue: null,
                  onChanged: (value) {
                    Navigator.pop(context);
                    _navigateToCheckout(address.id, amountInPaise);
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
                  _navigateToCheckout(address.id, amountInPaise);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/addresses/add');
            },
            child: Text('Add New Address'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(String addressId, int amountInPaise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          addressId: addressId,
          productIds: [widget.product.id],
          amountInPaise: amountInPaise,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final bool isAvailable = (widget.selectedOption?.stock ?? widget.product.stock) > 0;
    
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
          children: [
            // Add to Wishlist Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                onPressed: _isProcessing ? null : _addToWishlist,
                icon: _isProcessing 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade700),
                        ),
                      )
                    : const Icon(Icons.favorite_border, size: 20),
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
                  onPressed: (isAvailable && !_isProcessing) ? _addToCart : null,
                  icon: _isProcessing 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: Text(
                    _isProcessing 
                        ? 'Adding...' 
                        : isAvailable 
                            ? 'Add to Cart' 
                            : 'Out of Stock'
                  ),
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
                  onPressed: (isAvailable && !_isProcessing) ? _buyNow : null,
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
                  child: _isProcessing 
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
                            const SizedBox(width: 8),
                            Text('Loading...'),
                          ],
                        )
                      : Text(isAvailable ? 'Buy Now' : 'Unavailable'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
