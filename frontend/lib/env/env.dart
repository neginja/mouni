import 'dart:convert';
import 'package:http/http.dart' as http;

class Env {
  static late Map<String, dynamic> _config;

  /// Load config at app start
  static Future<void> load() async {
    final response = await http.get(Uri.parse('config.json'));
    if (response.statusCode == 200) {
      _config = jsonDecode(response.body);
    } else {
      throw Exception('Failed to load config.json');
    }
  }

  static String get apiBaseUrl =>
      _config['API_BASE_URL'] ?? 'http://localhost:8080';
}
