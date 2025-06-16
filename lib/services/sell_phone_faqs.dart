import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class FAQ {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;
  final DateTime updatedAt;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SellPhoneFAQService {
  static Future<List<FAQ>> getFAQs() async {
    final response = await http.get(Uri.parse('$apiUrl/sell-mobile/faqs/'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        final List<dynamic> faqsJson = data['faqs'];
        return faqsJson.map((json) => FAQ.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch FAQs: ${data['status']}');
      }
    } else {
      throw Exception('Failed to fetch FAQs: ${response.statusCode}');
    }
  }
}