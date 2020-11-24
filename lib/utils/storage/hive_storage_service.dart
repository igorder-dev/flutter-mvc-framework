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
      await Hive.openBox<T>(_boxName);
      _box = Hive.box(_boxName);
      return _box.get(_defaultKey);
  }

  @override
  Future<void> save() async {
    assert(isLoaded, 'Box $_boxName has to be loaded first');
    await _box.put(_defaultKey, _data);
  }

  @override
  T get data => _data;

  @override
  set data(T value) => _data = value;
}