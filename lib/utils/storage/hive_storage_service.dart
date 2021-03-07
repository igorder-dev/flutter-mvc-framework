import 'package:hive/hive.dart';
import 'package:id_mvc_app_framework/utils/storage/storage_service.dart';

class HiveStorageService extends StorageServiceBase<Box> {
  String _boxName;
  Box _box;

  // constructor with default box name
  HiveStorageService(String boxName)
      : assert(boxName != null),
        _boxName = boxName,
        super();

  // Closing the hive box
  @override
  Future<void> dispose() async {
    assert(isLoaded, 'Box $_boxName has to be loaded first');
    await _box.close();
  }

  // Checking the open status
  @override
  bool get isLoaded => _box != null;
  void assertLoaded() {
    assert(isLoaded, 'Box $_boxName has to be loaded first');
  }

  // To match StorageServiceBase
  @override
  Future<Box> load() async {
    _box = await getOpenBox();

    return _box;
  }

  @override
  Future<void> save() async {
    assertLoaded();
  }

  Future<void> clear() async {
    assertLoaded();
    await _box.clear();
  }

  dynamic get(key, [defaultValue]) {
    assertLoaded();
    return _box.get(key, defaultValue: defaultValue);
  }

  void put(key, value) async {
    assertLoaded();
    await _box.put(key, value);
  }

  static Future<HiveStorageService> openAndLoad(String boxName) async {
    var storage = HiveStorageService(boxName);
    if (!storage.isLoaded) await storage.load();
    return storage;
  }

  static void purge() async {
    Hive.deleteFromDisk();
  }

  // Getter/setter for data
  @override
  Box get data {
    assertLoaded();
    return _box;
  }

  @override
  set data(Box value) {
    assert(
        false, 'You cannot assign box. Create seperate storage with Box name');
  }

  // List of keys for iterating through them
  Set<dynamic> get allKeys => (isLoaded ? _box.keys.toSet() : Set());

  // To prevent opening new box every time
  Future<Box> getOpenBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  // Checking if item is present in the box
  bool containsKey(dynamic key) => (isLoaded ? _box.containsKey(key) : false);
}
