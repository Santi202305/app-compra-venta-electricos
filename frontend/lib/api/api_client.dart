import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final List<dynamic> details;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const [],
  });

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? 'http://localhost:3000/api/v1',
        _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
    try {
      final response = await _client.get(uri, headers: _buildHeaders()).timeout(
        const Duration(seconds: 10),
      );
      return _processResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        code: 'NETWORK_ERROR',
        message: 'No se pudo conectar con el servidor backend',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        code: 'TIMEOUT',
        message: 'Tiempo de espera agotado al conectar con el servidor',
      );
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        code: 'NETWORK_ERROR',
        message: 'No se pudo conectar con el servidor backend',
      );
    } on TimeoutException {
      throw const ApiException(
        statusCode: 408,
        code: 'TIMEOUT',
        message: 'Tiempo de espera agotado al conectar con el servidor',
      );
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (decoded is Map<String, dynamic> && decoded.containsKey('error')) {
      final errorMap = decoded['error'] as Map<String, dynamic>;
      throw ApiException(
        statusCode: response.statusCode,
        code: errorMap['code']?.toString() ?? 'ERROR',
        message: errorMap['message']?.toString() ?? 'Error desconocido del servidor',
        details: (errorMap['details'] as List<dynamic>?) ?? const [],
      );
    }

    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_${response.statusCode}',
      message: 'Error en la petición: ${response.reasonPhrase ?? 'Status ${response.statusCode}'}',
    );
  }

  void close() {
    _client.close();
  }
}

final defaultApiClient = ApiClient();
