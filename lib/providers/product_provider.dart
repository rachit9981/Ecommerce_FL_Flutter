import 'package:flutter/foundation.dart';
import '../services/products.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;

  Future<void> loadProducts() async {
    // Only load if not already loaded
    if (_hasLoaded && _products.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getProducts();
      _hasLoaded = true;
      _error = null;
      print('Products loaded successfully: ${_products.length} items');
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadProducts() async {
    _hasLoaded = false;
    _products = [];
    await loadProducts();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
