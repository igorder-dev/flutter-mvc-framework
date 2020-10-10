import '../model/json_object.dart';
import 'http_service.dart';

class HttpJsonService<T extends JsonObject, S extends JsonObjectSerializer<T>> {
  final S _serializer;
  final HttpServiceBase _httpService;

  HttpJsonService(
    this._serializer, {
    String baseUrl,
    String defaultPath,
    Map<String, String> initialParams,
    Map<String, String> defaultHeaders,
    bool keepConnection = false,
  }) : _httpService = HttpServiceBase(
            baseUrl: baseUrl,
            defaultPath: defaultPath,
            initialParams: initialParams,
            defaultHeaders: defaultHeaders,
            keepConnection: keepConnection);

  Future<T> get(String path, {Map<String, String> params}) async {
    var response = await _httpService.get(path, params: params);
    return _serializer.fromString(response.body);
  }

  Future<List<T>> getList(String path, {Map<String, String> params}) async {
    var response = await _httpService.get(path, params: params);
    return _serializer.fromStringArray(response.body);
  }

  Future<T> post(String path, T obj, {Map<String, String> params}) async {
    var response =
        await _httpService.post(path, _serializer.toJson(obj), params: params);
    return _serializer.fromString(response.body);
  }

  Future<T> put(String path, T obj, {Map<String, String> params}) async {
    var response =
        await _httpService.put(path, _serializer.toJson(obj), params: params);
    return _serializer.fromString(response.body);
  }

  Future<bool> delete(String path, {Map<String, String> params}) async {
    return await _httpService.delete(path, params: params);
  }

  void dispose() => _httpService.dispose();
}
