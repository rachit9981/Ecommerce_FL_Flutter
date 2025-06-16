import 'package:flutter/material.dart';
import '../services/cart_wishlist.dart';

class CartProvider with ChangeNotifier {
  final CartWishlistService _cartService = CartWishlistService();
  
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  double _discountAmount = 0.0;
  double _shippingCost = 0.0;
  
  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get discountAmount => _discountAmount;
  double get shippingCost => _shippingCost;
  bool get isEmpty => _cartItems.isEmpty;
  
  // Get total items in cart
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  // Calculate subtotal (before discount and shipping)
  double get subtotal => _cartItems.fold(
    0, 
    (sum, item) => sum + ((item.price ?? 0) * item.quantity)
  );
  
  // Calculate total (after discount and shipping)
  double get total => subtotal - _discountAmount + _shippingCost;
  
  // Fetch cart items from API
  Future<void> fetchCartItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _cartItems = await _cartService.getCart();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _cartItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
    // Add item to cart
  Future<void> addToCart(String productId, {int quantity = 1, String? variantId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _cartService.addToCart(productId, quantity: quantity, variantId: variantId);
      await fetchCartItems(); // Refresh cart after adding
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
    // Update item quantity
  Future<void> updateQuantity(String itemId, int newQuantity) async {
    // First update locally for UI responsiveness
    final index = _cartItems.indexWhere((item) => item.itemId == itemId);
    if (index != -1) {
      // Create updated cart item with all the existing fields
      final existingItem = _cartItems[index];
      
      // Optimistically update the UI
      setState(() {
        _cartItems[index] = CartItem(
          itemId: existingItem.itemId,
          productId: existingItem.productId,
          variantId: existingItem.variantId,
          name: existingItem.name,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          image: existingItem.image,
          quantity: newQuantity,
          stock: existingItem.stock,
          category: existingItem.category,
          brand: existingItem.brand,
          variant: existingItem.variant,
          addedAt: existingItem.addedAt,
          error: existingItem.error,
        );
      });
      
      try {
        // Then update on server using the new updateCartQuantity method
        await _cartService.updateCartQuantity(itemId, newQuantity);
        await fetchCartItems(); // Refresh to ensure consistency
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        // If failed, refresh cart to restore correct state
        await fetchCartItems();
      }
    }
  }
  
  // Helper method to update state with notification
  void setState(Function() updateFn) {
    updateFn();
    notifyListeners();
  }
  
  // Remove item from cart
  Future<void> removeFromCart(String itemId) async {
    // First update locally for UI responsiveness
    final removedItemIndex = _cartItems.indexWhere((item) => item.itemId == itemId);
    if (removedItemIndex == -1) return;
    
    final removedItem = _cartItems[removedItemIndex];
    _cartItems.removeAt(removedItemIndex);
    notifyListeners();
    
    try {
      await _cartService.removeFromCart(itemId);
    } catch (e) {
      // If failed, add the item back
      _cartItems.insert(removedItemIndex, removedItem);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Clear cart
  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Remove each item individually
      final itemsToRemove = List<CartItem>.from(_cartItems);
      for (var item in itemsToRemove) {
        await _cartService.removeFromCart(item.itemId);
      }
      _cartItems = [];
      _discountAmount = 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Apply discount
  void applyDiscount(double amount) {
    _discountAmount = amount;
    notifyListeners();
  }
  
  // Update shipping cost
  void updateShippingCost(double cost) {
    _shippingCost = cost;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
