import 'package:flutter/material.dart';
import '../services/user.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  // Profile Data
  UserProfile? _userProfile;
  bool _isProfileLoading = false;
  String? _profileError;
  
  // Address Data
  List<Address> _addresses = [];
  bool _isAddressesLoading = false;
  String? _addressError;
  Address? _defaultAddress;
  
  // Getters for Profile
  UserProfile? get userProfile => _userProfile;
  bool get isProfileLoading => _isProfileLoading;
  String? get profileError => _profileError;
  
  // Getters for Addresses
  List<Address> get addresses => _addresses;
  bool get isAddressesLoading => _isAddressesLoading;
  String? get addressError => _addressError;
  Address? get defaultAddress => _defaultAddress;
  
  // Profile Methods
  Future<void> fetchProfile() async {
    _isProfileLoading = true;
    _profileError = null;
    notifyListeners();
    
    try {
      _userProfile = await _userService.getProfile();
      _profileError = null;
    } catch (e) {
      _profileError = e.toString();
      _userProfile = null;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
  }) async {
    _isProfileLoading = true;
    _profileError = null;
    notifyListeners();
    
    try {
      _userProfile = await _userService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      _profileError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _profileError = e.toString();
      _isProfileLoading = false;
      notifyListeners();
      return false;
    } finally {
      _isProfileLoading = false;
    }
  }
  
  // Address Methods
  Future<void> fetchAddresses() async {
    _isAddressesLoading = true;
    _addressError = null;
    notifyListeners();
    
    try {
      _addresses = await _userService.getAddresses();
      _updateDefaultAddress();
      _addressError = null;
    } catch (e) {
      _addressError = e.toString();
      _addresses = [];
    } finally {
      _isAddressesLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> addAddress(Address address) async {
    try {
      final newAddress = await _userService.addAddress(address);
      _addresses.add(newAddress);
      _updateDefaultAddress();
      notifyListeners();
      return true;
    } catch (e) {
      _addressError = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> updateAddress(String addressId, Address address) async {
    try {
      final updatedAddress = await _userService.updateAddress(addressId, address);
      final index = _addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        _updateDefaultAddress();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _addressError = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> deleteAddress(String addressId) async {
    try {
      final success = await _userService.deleteAddress(addressId);
      if (success) {
        _addresses.removeWhere((addr) => addr.id == addressId);
        _updateDefaultAddress();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _addressError = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final success = await _userService.setDefaultAddress(addressId);
      if (success) {
        // Update local state
        for (int i = 0; i < _addresses.length; i++) {
          if (_addresses[i].id == addressId) {
            _addresses[i] = _addresses[i].copyWith(isDefault: true);
          } else {
            _addresses[i] = _addresses[i].copyWith(isDefault: false);
          }
        }
        _updateDefaultAddress();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _addressError = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Helper Methods
  void _updateDefaultAddress() {
    try {
      _defaultAddress = _addresses.firstWhere((addr) => addr.isDefault);
    } catch (e) {
      _defaultAddress = null;
    }
  }
  
  // Get address by ID
  Address? getAddressById(String addressId) {
    try {
      return _addresses.firstWhere((addr) => addr.id == addressId);
    } catch (e) {
      return null;
    }
  }
  
  // Get addresses by type
  List<Address> getAddressesByType(String type) {
    return _addresses.where((addr) => addr.type.toLowerCase() == type.toLowerCase()).toList();
  }
  
  // Clear all data (useful for logout)
  void clearUserData() {
    _userProfile = null;
    _addresses = [];
    _defaultAddress = null;
    _isProfileLoading = false;
    _isAddressesLoading = false;
    _profileError = null;
    _addressError = null;
    notifyListeners();
  }
  
  // Clear errors
  void clearProfileError() {
    _profileError = null;
    notifyListeners();
  }
  
  void clearAddressError() {
    _addressError = null;
    notifyListeners();
  }
  
  // Check if user has addresses
  bool get hasAddresses => _addresses.isNotEmpty;
  
  // Check if user has default address
  bool get hasDefaultAddress => _defaultAddress != null;
  
  // Get user's full name
  String get userFullName {
    if (_userProfile != null) {
      return _userProfile!.fullName;
    }
    return 'User';
  }
  
  // Get user's email
  String get userEmail {
    if (_userProfile != null) {
      return _userProfile!.email;
    }
    return '';
  }
  
  // Initialize user data (call this when user logs in)
  Future<void> initializeUserData() async {
    await Future.wait([
      fetchProfile(),
      fetchAddresses(),
    ]);
  }
  
  // Refresh all user data
  Future<void> refreshUserData() async {
    await initializeUserData();
  }
}
