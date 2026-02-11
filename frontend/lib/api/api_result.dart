import 'dart:convert';
import 'package:http/http.dart' as http;

/// Generic API response wrapper
class ApiResult<T> {
  final T? data;
  final String? error;

  ApiResult({this.data, this.error});

  bool get isSuccess => error == null;
}

/// Utility to handle API calls
Future<ApiResult<T>> handleApi<T>({
  required Future<http.Response> Function() action,
  required String actionName,
  required String resourceName,
  required T Function(dynamic json) fromJson,
}) async {
  try {
    final response = await action();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Only decode if body is not empty
      if (response.body.isNotEmpty) {
        final jsonData = jsonDecode(response.body);
        return ApiResult(data: fromJson(jsonData));
      } else {
        // No content to parse
        return ApiResult(data: null);
      }
    } else {
      // Try to parse detail from JSON if available
      String detailMessage;
      if (response.body.isNotEmpty) {
        try {
          final Map<String, dynamic> errorJson = jsonDecode(response.body);
          final detail = errorJson['detail'];

          if (detail == null) {
            detailMessage = response.body;
          } else if (detail is String) {
            detailMessage = detail;
          } else if (detail is Map || detail is List) {
            // Pretty-print the object
            detailMessage = detail.toString();
          } else {
            detailMessage = detail.toString();
          }
        } catch (_) {
          detailMessage = response.body;
        }
      } else {
        detailMessage = "No content";
      }

      String message = "$actionName failed for $resourceName: $detailMessage";
      return ApiResult(error: message);
    }
  } catch (e) {
    return ApiResult(error: "$actionName failed for $resourceName: $e");
  }
}
