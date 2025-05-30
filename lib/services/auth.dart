import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import '../services/user.dart';
import 'config.dart';

class AuthService {
  Future<AuthResponse> signup({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? idToken,
    BuildContext? context,
  }) async {
    try {
      Map<String, dynamic> body = {};
      
      if (idToken != null) {
        // Firebase authentication flow
        body = {'idToken': idToken};
      } else {
        // Traditional email/password signup
        if (email == null || password == null || firstName == null || lastName == null) {
          throw Exception('Missing required fields for email signup');
        }
        body = {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        };
      }

      final response = await http.post(
        Uri.parse('$apiUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(data);
        await _saveUserData(authResponse);
        
        // Initialize user data in provider if context is provided
        if (context != null) {
          await _initializeUserProvider(context, authResponse);
        }
        
        return authResponse;
      } else {
        print(data['error']);
        throw Exception(data['error'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Failed to signup: $e');
    }
  }

  Future<AuthResponse> login({
    String? email,
    String? password,
    String? idToken,
    BuildContext? context,
  }) async {
    try {
      Map<String, dynamic> body = {};
      
      if (idToken != null) {
        // Firebase authentication flow
        body = {'idToken': idToken};
      } else {
        // Traditional email/password login
        if (email == null || password == null) {
          throw Exception('Email and password are required');
        }
        body = {
          'email': email,
          'password': password,
        };
      }

      final response = await http.post(
        Uri.parse('$apiUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(data);
        await _saveUserData(authResponse);
        
        // Initialize user data in provider if context is provided
        if (context != null) {
          await _initializeUserProvider(context, authResponse);
        }
        
        return authResponse;
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> logout({BuildContext? context}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Remove all stored user data
      await Future.wait([
        prefs.remove('token'),
        prefs.remove('user_id'),
        prefs.remove('user_email'),
        prefs.remove('user_first_name'),
        prefs.remove('user_last_name'),
        prefs.remove('user_phone_number'),
      ]);
      
      // Clear user data from provider if context is provided
      if (context != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clearUserData();
        userProvider.setAuthenticationState(false);
      }
      
      print('User successfully logged out');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout: $e');
    }
  }

  // Private method to save user data to SharedPreferences
  Future<void> _saveUserData(AuthResponse authResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authResponse.token);
    await prefs.setString('user_id', authResponse.user.userId);
    await prefs.setString('user_email', authResponse.user.email);
    await prefs.setString('user_first_name', authResponse.user.firstName);
    await prefs.setString('user_last_name', authResponse.user.lastName);
    if (authResponse.user.phoneNumber != null) {
      await prefs.setString('user_phone_number', authResponse.user.phoneNumber!);
    }
  }

  // Private method to initialize user data in UserProvider
  Future<void> _initializeUserProvider(BuildContext context, AuthResponse authResponse) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Create UserProfile from auth response
      final userProfile = UserProfile(
        userId: authResponse.user.userId,
        email: authResponse.user.email,
        firstName: authResponse.user.firstName,
        lastName: authResponse.user.lastName,
        phoneNumber: authResponse.user.phoneNumber,
        authProvider: 'email', // or determine from response
        uid: null,
      );
      
      // Set the user profile directly in provider
      userProvider.setUserProfile(userProfile);
      
      // Initialize user data (fetch addresses and complete profile)
      await userProvider.initializeUserData();
    } catch (e) {
      print('Error initializing user provider: $e');
      // Don't throw error here as auth was successful
    }
  }

  // Method to restore user session on app startup
  Future<void> restoreUserSession(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('user_id');
      String? email = prefs.getString('user_email');
      String? firstName = prefs.getString('user_first_name');
      String? lastName = prefs.getString('user_last_name');
      String? phoneNumber = prefs.getString('user_phone_number');
      
      if (token != null && userId != null && email != null && firstName != null && lastName != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        // Create UserProfile from stored data
        final userProfile = UserProfile(
          userId: userId,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          authProvider: 'email',
          uid: null,
        );
        
        // Set the user profile in provider
        userProvider.setUserProfile(userProfile);
        
        // Initialize user data
        await userProvider.initializeUserData();
      }
    } catch (e) {
      print('Error restoring user session: $e');
    }
  }

  // Enhanced method to check authentication status
  Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('user_id');
      
      // Check if both token and user ID exist
      return token != null && token.isNotEmpty && userId != null && userId.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Method to clear all user data (used for complete logout)
  Future<void> clearAllUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Get all keys that start with 'user_' or are 'token'
      final keysToRemove = prefs.getKeys().where((key) => 
        key.startsWith('user_') || key == 'token'
      ).toList();
      
      // Remove all user-related data
      for (String key in keysToRemove) {
        await prefs.remove(key);
      }
      
      print('All user data cleared from SharedPreferences');
    } catch (e) {
      print('Error clearing user data: $e');
      throw Exception('Failed to clear user data: $e');
    }
  }

  Future<ReviewResponse> addReview({
    required String token,
    required String productId,
    required double rating,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/products/$productId/reviews/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'rating': rating,
          'comment': comment ?? '',
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 201) {
        return ReviewResponse.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to add review');
      }
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  Future<ReportResponse> reportReview({
    required String token,
    required String productId,
    required String reviewId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/products/$productId/reviews/$reviewId/report/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ReportResponse.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to report review');
      }
    } catch (e) {
      throw Exception('Failed to report review: $e');
    }
  }
}

class User {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;

  User({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
    );
  }
}

class AuthResponse {
  final String message;
  final User user;
  final String token;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      user: User.fromJson(json),
      token: json['token'],
    );
  }
}

class ReviewResponse {
  final String message;
  final String reviewId;
  final double updatedRating;
  final int totalReviews;

  ReviewResponse({
    required this.message,
    required this.reviewId,
    required this.updatedRating,
    required this.totalReviews,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      message: json['message'],
      reviewId: json['review_id'],
      updatedRating: (json['updated_rating'] is int) 
          ? (json['updated_rating'] as int).toDouble() 
          : json['updated_rating'],
      totalReviews: json['total_reviews'],
    );
  }
}

class ReportResponse {
  final String message;
  final String reportId;
  final int reportedCount;

  ReportResponse({
    required this.message,
    required this.reportId,
    required this.reportedCount,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      message: json['message'],
      reportId: json['report_id'],
      reportedCount: json['reported_count'],
    );
  }
}
