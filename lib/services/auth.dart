import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class AuthService {
  Future<AuthResponse> signup({
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? idToken,
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
        return AuthResponse.fromJson(data);
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
        Uri.parse('$apiUrl/users/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_first_name');
      await prefs.remove('user_last_name');
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
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
