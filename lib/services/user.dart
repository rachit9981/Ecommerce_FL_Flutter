import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class UserService {
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

  // Address Management Methods
  Future<List<Address>> getAddresses() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/users/addresses/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> addressesJson = data['addresses'];
        
        return addressesJson.map((json) => Address.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load addresses: $e');
    }
  }

  Future<Address> addAddress(Address address) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiUrl/users/addresses/add/'),
        headers: headers,
        body: json.encode(address.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Address.fromJson(data['address']);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to add address: ${errorData['error']}');
      }
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<Address> updateAddress(String addressId, Address address) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$apiUrl/users/addresses/update/$addressId/'),
        headers: headers,
        body: json.encode(address.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Address.fromJson(data['address']);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to update address: ${errorData['error']}');
      }
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$apiUrl/users/addresses/delete/$addressId/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete address: ${errorData['error']}');
      }
    } catch (e) {
      throw Exception('Failed to delete address: $e');
    }
  }

  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiUrl/users/addresses/set-default/$addressId/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to set default address: ${errorData['error']}');
      }
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  // Profile Management Methods
  Future<UserProfile> getProfile() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$apiUrl/users/profile/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (currentPassword != null) updateData['current_password'] = currentPassword;
      if (newPassword != null) updateData['new_password'] = newPassword;
      if (confirmNewPassword != null) updateData['confirm_new_password'] = confirmNewPassword;

      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$apiUrl/users/profile/update/'),
        headers: headers,
        body: json.encode(updateData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfile.fromJson(data['user']);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to update profile: ${errorData['error']}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}

class Address {
  final String? id;
  final String type;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String phoneNumber;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    this.id,
    required this.type,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.phoneNumber,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      type: json['type'],
      streetAddress: json['street_address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      phoneNumber: json['phone_number'],
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'phone_number': phoneNumber,
      'is_default': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? type,
    String? streetAddress,
    String? city,
    String? state,
    String? postalCode,
    String? phoneNumber,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      type: type ?? this.type,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserProfile {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? authProvider;
  final String? uid;

  UserProfile({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.authProvider,
    this.uid,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      authProvider: json['auth_provider'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'auth_provider': authProvider,
      'uid': uid,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? authProvider,
    String? uid,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      authProvider: authProvider ?? this.authProvider,
      uid: uid ?? this.uid,
    );
  }
}
