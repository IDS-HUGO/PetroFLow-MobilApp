import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

typedef TokenProvider = String? Function();

class ApiClient {
  ApiClient({
    required String baseUrl,
    required this.tokenProvider,
    http.Client? client,
  })  : _baseUri = Uri.parse(baseUrl),
        _client = client ?? http.Client();

  final Uri _baseUri;
  final TokenProvider tokenProvider;
  final http.Client _client;

  Future<dynamic> getJson(String path, {Map<String, String>? headers}) {
    return _request('GET', path, headers: headers);
  }

  Future<dynamic> postJson(String path, {Map<String, String>? headers, Object? body}) {
    return _request('POST', path, headers: headers, body: body);
  }

  Future<dynamic> putJson(String path, {Map<String, String>? headers, Object? body}) {
    return _request('PUT', path, headers: headers, body: body);
  }

  Future<dynamic> deleteJson(String path, {Map<String, String>? headers, Object? body}) {
    return _request('DELETE', path, headers: headers, body: body);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = _baseUri.resolve(path.startsWith('/') ? path.substring(1) : path);
    final token = tokenProvider();
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final response = await switch (method) {
      'GET' => _client.get(uri, headers: requestHeaders),
      'POST' => _client.post(uri, headers: requestHeaders, body: body == null ? null : jsonEncode(body)),
      'PUT' => _client.put(uri, headers: requestHeaders, body: body == null ? null : jsonEncode(body)),
      'DELETE' => _client.delete(uri, headers: requestHeaders, body: body == null ? null : jsonEncode(body)),
      _ => throw const ApiException('Método HTTP no soportado.'),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_extractErrorMessage(response.body), statusCode: response.statusCode);
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _extractErrorMessage(String rawBody) {
    if (rawBody.isEmpty) {
      return 'La API respondió sin contenido.';
    }

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return (decoded['detail'] ?? decoded['message'] ?? decoded['error'] ?? rawBody).toString();
      }

      return decoded.toString();
    } on FormatException {
      return rawBody;
    }
  }
}