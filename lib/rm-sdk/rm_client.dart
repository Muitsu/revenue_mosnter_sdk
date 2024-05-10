import 'dart:convert';
import 'package:http/http.dart' as http;

class RmClient {
  final String baseUrl;

  RmClient({required this.baseUrl});

  Future<dynamic> get({String? baseUrl, String? endpoint}) async {
    try {
      final response = await http
          .get(Uri.parse('${baseUrl ?? this.baseUrl}${endpoint ?? ""}'));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Handle errors, you can throw an exception or return null
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<dynamic> post(
      {String? baseUrl, String? endpoint, dynamic body}) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl ?? this.baseUrl}${endpoint ?? ""}'),
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Handle errors, you can throw an exception or return null
        throw Exception('Failed to post data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}
