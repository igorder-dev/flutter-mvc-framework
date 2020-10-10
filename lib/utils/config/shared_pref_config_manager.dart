import 'package:flutter/widgets.dart';
import '../model/json_object.dart';
import 'dart:convert' as convert;

import 'config_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefConfigManager implements ConfigManagerBase {
  static final SharedPrefConfigManager _this = SharedPrefConfigManager._();

  SharedPreferences _pref;
  factory SharedPrefConfigManager() {
    return _this;
  }

  SharedPrefConfigManager._();

  void initCheck() {
    assert(_this.isInitialized(),
        'Config manager is not initialized yet. Make sure you called "init" function');
  }

  ///try to decode string to Json if not succesfull returns null

  @override
  void clear() {
    initCheck();
    _pref.clear();
  }

  @override
  bool containsKey(String key) {
    initCheck();
    return _pref.containsKey(key);
  }

  @override
  void dispose() {
    _pref = null;
  }

  @override
  get(String key, [defaultValue]) {
    initCheck();

    if (!containsKey(key) && defaultValue != null) {
      set(key, defaultValue);
      return defaultValue;
    }

    dynamic resValue = _pref.get(key);
    return JsonObject.tryFromString(resValue) ?? resValue;
  }

  @override
  void set(String key, value) {
    initCheck();
    _pref.setString(
        key,
        value is Map<String, dynamic>
            ? convert.jsonEncode(value)
            : value.toString());
  }

  @override
  bool getBool(String key, [bool defaultValue]) {
    initCheck();

    if (!containsKey(key) && defaultValue != null) {
      setBool(key, defaultValue);
      return defaultValue;
    }

    return _pref.getBool(key);
  }

  @override
  void setBool(String key, bool value) {
    initCheck();
    _pref.setBool(key, value);
  }

  @override
  double getDouble(String key, [double defaultValue]) {
    initCheck();

    if (!containsKey(key) && defaultValue != null) {
      setDouble(key, defaultValue);
      return defaultValue;
    }

    return _pref.getDouble(key);
  }

  @override
  int getInt(String key, [int defaultValue]) {
    initCheck();

    if (!containsKey(key) && defaultValue != null) {
      setInt(key, defaultValue);
      return defaultValue;
    }

    return _pref.getInt(key);
  }

  @override
  Type getValueType(String key) {
    initCheck();
    return _pref.get(key)?.runtimeType;
  }

  @override
  Set<String> getKeys() {
    initCheck();
    return _pref.getKeys();
  }

  @override
  List getList(String key) {
    initCheck();

    if (!containsKey(key)) {
      return List.of([]);
    }

    return _pref.getStringList(key);
  }

  @override
  String getString(String key, [String defaultValue]) {
    initCheck();

    if (!containsKey(key) && defaultValue != null) {
      setString(key, defaultValue);
      return defaultValue;
    }

    return _pref.getString(key);
  }

  @override
  List<String> getStringList(String key) {
    return getList(key);
  }

  @override
  Future<bool> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _this._pref = await SharedPreferences.getInstance();

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  bool isInitialized() {
    return _this._pref != null;
  }

  @override
  Future<bool> remove(String key) {
    initCheck();
    if (!containsKey(key)) {
      return Future.value(false);
    }
    return _pref.remove(key);
  }

  @override
  Future<bool> save() {
    return Future.value(true);
  }

  @override
  void setDouble(String key, double value) {
    initCheck();
    _pref.setDouble(key, value);
  }

  @override
  void setInt(String key, int value) {
    initCheck();
    _pref.setInt(key, value);
  }

  @override
  void setList(String key, List value) {
    initCheck();
    _pref.setStringList(key, value.cast<String>());
  }

  @override
  void setString(String key, String value) {
    initCheck();
    _pref.setString(key, value);
  }

  @override
  void setStringList(String key, List<String> value) {
    initCheck();
    _pref.setStringList(key, value);
  }
}
