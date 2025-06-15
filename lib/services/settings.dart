import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class Banner {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final String tag;
  final String link;
  final String position;
  final String backgroundColor;
  final String cta;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  Banner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.tag,
    required this.link,
    required this.position,
    required this.backgroundColor,
    required this.cta,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      image: json['image'],
      tag: json['tag'],
      link: json['link'],
      position: json['position'],
      backgroundColor: json['backgroundColor'],
      cta: json['cta'],
      active: json['active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class BannerResponse {
  final List<Banner> banners;

  BannerResponse({required this.banners});

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      banners: (json['banners'] as List)
          .map((banner) => Banner.fromJson(banner))
          .toList(),
    );
  }
}

class LogoResponse {
  final String logoUrl;

  LogoResponse({required this.logoUrl});

  factory LogoResponse.fromJson(Map<String, dynamic> json) {
    return LogoResponse(
      logoUrl: json['logo_url'],
    );
  }
}

class SettingsService {
  static Future<BannerResponse> getBanners() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/admin/banners/public/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return BannerResponse.fromJson(data);
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching banners: $e');
    }
  }

  static Future<LogoResponse> getLogo() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/admin/content/logo'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return LogoResponse.fromJson(data);
      } else {
        throw Exception('Failed to load logo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching logo: $e');
    }
  }
}
