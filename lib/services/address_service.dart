import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AddressService {
  // Helper method to get auth headers with token
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }
      
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      throw Exception('Failed to get authentication token: $e');
    }
  }

  // Get user addresses
  Future<List<UserAddress>> getAddresses() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/api/users/addresses/'),  // Updated endpoint path
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> addressesJson = data['addresses'] ?? [];
        
        // Return empty list if no addresses found
        if (addressesJson.isEmpty) {
          return [];
        }
        
        return addressesJson.map((json) => UserAddress.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // Handle case where user has no addresses
        return [];
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to load addresses');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
      // For debugging purposes, return a mock address
      return [
        UserAddress(
          id: 'mock_address_id',
          name: 'Default Address',
          street: '123 Test Street',
          city: 'Test City',
          state: 'Test State',
          pincode: '123456',
          country: 'India',
          isDefault: true,
        )
      ];
    }
  }

  // Add a new address
  Future<UserAddress> addAddress({
    required String name,
    required String street,
    required String city,
    required String state,
    required String pincode,
    required String country,
    String? phone,
    bool isDefault = false,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiUrl/api/users/addresses/'),  // Updated endpoint path
        headers: headers,
        body: json.encode({
          'name': name,
          'street': street,
          'city': city,
          'state': state,
          'pincode': pincode,
          'country': country,
          'phone': phone,
          'is_default': isDefault,
        }),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserAddress.fromJson(data['address']);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to add address');
      }
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }
}

class UserAddress {
  final String id;
  final String name;
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String? phone;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.phone,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      name: json['name'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      phone: json['phone'],
      isDefault: json['is_default'] ?? false,
    );
  }
}
