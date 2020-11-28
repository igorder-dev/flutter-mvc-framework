import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:id_mvc_app_framework/utils/storage/storage_service.dart';

class HiveStorageService<T> extends StorageServiceBase<T> {
  String _boxName;
  String _defaultKey;
  Box<T> _box;
  T _data;

  HiveStorageService(String boxName, {String defaultKey = 'default'})
      : assert(boxName != null),
        _boxName = boxName,
        _defaultKey = 'default',
        super();

  @override
  void dispose() async {
    await _box.close();
  }

  @override
  bool get isLoaded => _box != null;

  @override
  Future<T> load() async {
    await loadWithKey(_defaultKey);
  }

  @override
  Future<void> save() async {
    await saveWithKey(_defaultKey);
  }

  Future<void> saveWithKey(String key) async {
    assert(isLoaded, 'Box $_boxName has to be loaded first');
    await _box.put(key, _data);
  }

  Future<void> loadWithKey(String key) async {
    bool exists = await Hive.boxExists('boxName');
    // If the box already exists, get a singleton entry of it
    // and return the value for the key
    if(!exists) {
      _box = await Hive.openBox<T>(_boxName);
      return _box.get(key);
    }else {
      _box = Hive.box(_boxName);
      return _box.get(key);
    }
  }

  // Getter/setter for data
  @override
  T get data => _data;

  @override
  set data(T value) => _data = value;



}
