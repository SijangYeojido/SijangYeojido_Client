import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  String? _accessToken;

  String get baseUrl => AppConfig.apiBaseUrl.replaceFirst(RegExp(r'/$'), '');

  set accessToken(String? token) => _accessToken = token;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        params[key] = value.toString();
      }
    });
    return Uri.parse(
      '$baseUrl$normalizedPath',
    ).replace(queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> get _headers => {
    HttpHeaders.contentTypeHeader: 'application/json',
    if (_accessToken != null)
      HttpHeaders.authorizationHeader: 'Bearer $_accessToken',
  };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await http.get(_uri(path, query), headers: _headers);
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(0, _networkMessage(error));
    }
  }

  Future<dynamic> post(String path, {Object? body}) async {
    try {
      final response = await http.post(
        _uri(path),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      );
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(0, _networkMessage(error));
    }
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    try {
      final response = await http.patch(
        _uri(path),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      );
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(0, _networkMessage(error));
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await http.delete(_uri(path), headers: _headers);
      return _decode(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(0, _networkMessage(error));
    }
  }

  Future<String> uploadImage(String filePath) async {
    final request = http.MultipartRequest('POST', _uri('/uploads/images'));
    if (_accessToken != null) {
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $_accessToken';
    }
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    final body = await http.Response.fromStream(response);
    final decoded = _decode(body) as Map<String, dynamic>;
    return resolveAssetUrl(decoded['url']?.toString());
  }

  String resolveAssetUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$baseUrl${url.startsWith('/') ? url : '/$url'}';
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    final dynamic decoded = text.isEmpty ? null : jsonDecode(text);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final message = decoded is Map<String, dynamic>
        ? decoded['message']?.toString() ?? response.reasonPhrase ?? 'API 오류'
        : response.reasonPhrase ?? 'API 오류';
    throw ApiException(response.statusCode, message);
  }

  String _networkMessage(Object error) {
    final message = error.toString();
    if (message.contains('SocketException') ||
        message.contains('Failed host lookup') ||
        message.contains('Connection refused') ||
        message.contains('Network is unreachable')) {
      return '서버에 연결할 수 없습니다. 네트워크 연결을 확인해 주세요.';
    }
    return '서버와 통신 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
  }
}
