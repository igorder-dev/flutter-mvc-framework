abstract class ConfigManagerBase {
  Set<String> getKeys();

  dynamic get(String key, [defaultValue]);
  void set(String key, value);

  bool getBool(String key, [bool defaultValue]);
  void setBool(String key, bool value);

  int getInt(String key, [int defaultValue]);
  void setInt(String key, int value);

  double getDouble(String key, [double defaultValue]);
  void setDouble(String key, double value);

  String getString(String key, [String defaultValue]);
  void setString(String key, String value);

  List<String> getStringList(String key);
  void setStringList(String key, List<String> value);

  List<dynamic> getList(String key);
  void setList(String key, List<dynamic> value);

  bool containsKey(String key);
  Future<bool> remove(String key);

  bool isInitialized();
  Future<bool> init();
  Future<bool> save();

  void clear();
  void dispose();

  Type getValueType(String key);
}
