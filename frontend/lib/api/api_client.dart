import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mouni/env/env.dart';

class ApiClient {
  static String get baseUrl => Env.apiBaseUrl;
  static const _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  /// GET request
  static Future<http.Response> getRequest(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.get(uri, headers: _headers);
  }

  /// POST request
  static Future<http.Response> postRequest(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.post(uri, body: jsonEncode(body), headers: _headers);
  }

  /// PUT request
  static Future<http.Response> putRequest(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.put(uri, body: jsonEncode(body), headers: _headers);
  }

  /// PATCH request
  static Future<http.Response> patchRequest(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.patch(uri, body: jsonEncode(body), headers: _headers);
  }

  /// DELETE request
  static Future<http.Response> deleteRequest(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.delete(uri, headers: _headers);
  }
}
