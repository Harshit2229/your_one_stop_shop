import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_exceptions.dart';

class NetworkService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  NetworkService({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 30),
  });

  Future<T> get<T>(
      String endpoint, {
        Map<String, String>? headers,
        T Function(Map<String, dynamic>)? parser,
      }) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {...defaultHeaders, ...?headers},
      )
          .timeout(timeout);
      return _handleResponse(response, parser);
    } catch (e) {
      throw _handleException(e);
    }
  }

  Future<T> post<T>(
      String endpoint, {
        Map<String, String>? headers,
        dynamic body,
        T Function(Map<String, dynamic>)? parser,
      }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          ...defaultHeaders,
          ...?headers
        },
        body: jsonEncode(body),
      )
          .timeout(timeout);
      return _handleResponse(response, parser);
    } catch (e) {
      throw _handleException(e);
    }
  }

  T _handleResponse<T>(
      http.Response response,
      T Function(Map<String, dynamic>)? parser,
      ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (parser != null) {
        return parser(data);
      }
      return data as T;
    }

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException();
      case 403:
        throw ForbiddenException();
      case 404:
        throw NotFoundException();
      case 500:
        throw ServerException();
      default:
        throw ApiException('Request failed with status: ${response.statusCode}');
    }
  }

  Exception _handleException(dynamic e) {
    if (e is http.ClientException) {
      return NetworkException();
    }
    if (e is TimeoutException) {
      return TimeoutException();
    }
    return ApiException(e.toString());
  }
}