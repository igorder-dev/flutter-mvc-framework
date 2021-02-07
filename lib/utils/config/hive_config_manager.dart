import '../../storage.dart';
import 'config_manager.dart';

class HiveConfigManager implements ConfigManagerBase {
  final HiveStorageService _storage;

  HiveConfigManager(String boxName) : _storage = HiveStorageService(boxName);

  @override
  Future<void> clear() async {
    await _storage.clear();
  }

  @override
  bool containsKey(String key) => _storage.containsKey(key);

  @override
  Future<void> dispose() async {
    await _storage.dispose();
  }

  @override
  get(String key, [defaultValue]) => _storage.get(key, defaultValue);

  @override
  bool getBool(String key, [bool defaultValue]) {
    var value = get(key, defaultValue);
    if (value == null) return null;
    if (value is bool) return value;
    return value.toString().toLowerCase() == "true";
  }

  @override
  double getDouble(String key, [double defaultValue]) {
    var value = get(key, defaultValue);
    if (value == null) return null;
    if (value is double) return value;
    return double.parse(value.toString());
  }

  @override
  int getInt(String key, [int defaultValue]) {
    var value = get(key, defaultValue);
    if (value == null) return null;
    if (value is int) return value;
    return int.parse(value.toString());
  }

  @override
  Set<String> getKeys() => new Set<String>.from(_storage.allKeys);

  @override
  List getList(String key) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  String getString(String key, [String defaultValue]) {
    var value = get(key, defaultValue);
    if (value == null) return null;
    return value.toString();
  }

  @override
  List<String> getStringList(String key) {
    // TODO: implement getStringList
    throw UnimplementedError();
  }

  @override
  Type getValueType(String key) {
    var value = get(key);
    if (value == null) return null;
    return value.runtimeType;
  }

  @override
  Future<bool> init() async {
    await _storage.load();
    return true;
  }

  @override
  bool isInitialized() => _storage.isLoaded;

  @override
  Future<bool> remove(String key) async {
    await _storage.data.delete(key);
    return true;
  }

  @override
  Future<bool> save() async {
    await _storage.save();
    return true;
  }

  @override
  void set(String key, value) => _storage.put(key, value);

  @override
  void setBool(String key, bool value) {
    set(key, value);
  }

  @override
  void setDouble(String key, double value) {
    set(key, value);
  }

  @override
  void setInt(String key, int value) {
    set(key, value);
  }

  @override
  void setList(String key, List value) {
    // TODO: implement setList
  }

  @override
  void setString(String key, String value) {
    set(key, value);
  }

  @override
  void setStringList(String key, List<String> value) {
    // TODO: implement setStringList
  }
}
