import 'dart:io';
import 'package:http/http.dart' as http;
import 'http_exceptions.dart';

class HttpServiceBase {
  final String baseUrl;
  final Map<String, String> params = Map();
  final Map<String, String> headers = {"content-type": "application/json"};
  final String defaultPath;
  final bool keepConnection;
  http.Client _client;

  HttpServiceBase(
      {this.baseUrl,
      this.defaultPath,
      Map<String, String> initialParams,
      Map<String, String> defaultHeaders,
      this.keepConnection = false}) {
    if (initialParams != null) params.addAll(initialParams);
    if (defaultHeaders != null) headers.addAll(defaultHeaders);
  }

  Future<http.Response> get(String path, {Map<String, String> params}) async {
    var response;
    try {
      response = await _withClient((client) =>
          client.get(_buildRequestUrl(path, params: params), headers: headers));
      _isSuccessOrThrow(response);
    } catch (e) {
      _throwSpecificException(e);
    }
    return response;
  }

  Future<http.Response> post(String path, dynamic body,
      {Map<String, String> params}) async {
    var response;
    try {
      response = await _withClient((client) => client.post(
            _buildRequestUrl(path, params: params),
            body: body,
            headers: headers,
          ));
      _isSuccessOrThrow(response);
    } catch (e) {
      _throwSpecificException(e);
    }
    return response;
  }

  Future<http.Response> put(String path, dynamic body,
      {Map<String, String> params}) async {
    var response;
    try {
      response = await _withClient((client) => client.put(
            _buildRequestUrl(path, params: params),
            body: body,
            headers: headers,
          ));
      _isSuccessOrThrow(response);
    } catch (e) {
      _throwSpecificException(e);
    }
    return response;
  }

  Future<bool> delete(String path, {Map<String, String> params}) async {
    var result;
    try {
      final response = await _withClient((client) => client.delete(
            _buildRequestUrl(path, params: params),
            headers: headers,
          ));
      _isSuccessOrThrow(response);
      result = response.statusCode == 200;
    } catch (e) {
      _throwSpecificException(e);
    }
    return result;
  }

  Future<http.Response> _withClient(
      Future<http.Response> Function(http.Client) fn) async {
    if (!keepConnection) {
      var client = http.Client();
      try {
        return await fn(client);
      } finally {
        client.close();
      }
    } else {
      _client ??= http.Client();
      return await fn(_client);
    }
  }

  void dispose() {
    _client?.close();
  }

  String _buildRequestUrl(String path, {Map<String, String> params}) {
    Map<String, String> _requestParams = Map();
    _requestParams.addAll(this.params);
    if (params != null) _requestParams.addAll(params);
    var paramsString = _paramsToString(_requestParams);

    var result = baseUrl +
        (path ?? (defaultPath ?? '')) +
        (paramsString.length > 0 ? '?$paramsString' : '');
    return result;
  }

  String _paramsToString(Map<String, String> params) =>
      params.map((key, value) => MapEntry(key, '$key=$value')).values.join('&');

  _throwSpecificException(Exception e) {
    if (e is FormatException) {
      throw BadUrlException(e.message);
    } else if (e is SocketException) {
      throw FetchDataException('No Internet connection');
    } else
      throw e;
  }

  bool _isSuccessOrThrow(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return true;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 404:
        throw ResourceNotFoundException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server : ${response.statusCode} : ${response.reasonPhrase}');
    }
  }
}
