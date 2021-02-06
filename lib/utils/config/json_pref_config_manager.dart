import 'config_manager.dart';
import '../model/json_object.dart';
import '../storage/storage_service.dart';

class JsonConfigManager implements ConfigManagerBase {
  JsonObject get _jsonObject => _jsonStorage.data;
  final StorageServiceBase<JsonObject> _jsonStorage;

  JsonConfigManager()
      : _jsonStorage = DummyStorageService<JsonObject>(JsonObject.fromMap({})),
        super();

  JsonConfigManager.fromAsset(String assetFile, {bool reset = false})
      : _jsonStorage = JsonObjectAssetsStorageService(assetFile, reset: reset),
        super();

  void initCheck() {
    assert(isInitialized(),
        'Config manager is not initialized yet. Make sure you called "init" function');
  }

  @override
  void clear() {
    initCheck();
    _jsonObject.clear();
  }

  @override
  bool containsKey(String key) {
    initCheck();
    return _jsonObject[key] != null;
  }

  @override
  void dispose() {
    _jsonStorage.dispose();
  }

  @override
  get(String key, [defaultValue]) {
    initCheck();

    dynamic resValue = _jsonObject[key];

    if (resValue == null && defaultValue != null) {
      set(key, defaultValue);
      resValue = defaultValue;
    }

    return resValue;
  }

  @override
  bool getBool(String key, [bool defaultValue]) => get(key, defaultValue);

  @override
  double getDouble(String key, [double defaultValue]) => get(key, defaultValue);

  @override
  int getInt(String key, [int defaultValue]) => get(key, defaultValue);

  @override
  Set<String> getKeys() {
    return _jsonObject.keys.toSet();
  }

  @override
  List getList(String key) => get(key);

  @override
  String getString(String key, [String defaultValue]) => get(key, defaultValue);

  @override
  List<String> getStringList(String key) => getList(key).cast<String>();

  @override
  Type getValueType(String key) {
    return get(key)?.runtimeType;
  }

  @override
  Future<bool> init() async {
    await _jsonStorage.load();
    return _jsonStorage.isLoaded;
  }

  @override
  bool isInitialized() {
    return _jsonStorage.isLoaded;
  }

  @override
  Future<bool> remove(String key) async {
    initCheck();
    return _jsonObject.remove(key) != null;
  }

  @override
  Future<bool> save() async {
    await _jsonStorage.save();
    return true;
  }

  @override
  void set(String key, value) {
    initCheck();
    _jsonObject[key] = value;
  }

  @override
  void setBool(String key, bool value) => set(key, value);

  @override
  void setDouble(String key, double value) => set(key, value);

  @override
  void setInt(String key, int value) => set(key, value);

  @override
  void setList(String key, List value) => set(key, value);

  @override
  void setString(String key, String value) => set(key, value);

  @override
  void setStringList(String key, List<String> value) => set(key, value);

  @override
  String toString() {
    return _jsonObject.toString();
  }
}

class JsonObjectAssetsStorageService extends StorageServiceBase<JsonObject> {
  final TextAssetsStorageService _assetStorageService;
  JsonObject _data;

  JsonObjectAssetsStorageService(String assetFile, {bool reset = false})
      : _assetStorageService =
            TextAssetsStorageService(assetFile, reset: reset);

  @override
  void dispose() {
    _data = null;
    _assetStorageService.dispose();
  }

  @override
  bool get isLoaded => _data != null;

  @override
  Future<JsonObject> load() async {
    _data = JsonObject.fromString(await _assetStorageService.load());
    return _data;
  }

  @override
  Future<void> save() async {
    _assetStorageService.data = _data.toStringWithIndent();
    _assetStorageService.save();
  }

  @override
  JsonObject get data => _data;

  @override
  set data(JsonObject value) => _data = value;
}
