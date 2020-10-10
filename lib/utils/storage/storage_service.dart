import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

abstract class StorageServiceBase<T> {
  T get data;
  set data(T value);
  Future<T> load();
  bool get isLoaded;
  Future<void> save();
  void dispose();
}

class DummyStorageService<T> extends StorageServiceBase<T> {
  T _data;
  DummyStorageService(T data) : _data = data;

  @override
  void dispose() {
    data = null;
  }

  @override
  bool get isLoaded => data != null;

  @override
  Future<T> load() async {
    return data;
  }

  @override
  Future<void> save() {
    return Future(null);
  }

  @override
  T get data => _data;

  @override
  set data(T value) {
    _data = value;
  }
}

class TextAssetsStorageService extends StorageServiceBase<String> {
  File _file;
  final String _filePath;
  bool _reset;
  String _data;

  TextAssetsStorageService(String assetFile, {bool reset = false})
      : assert(assetFile != null),
        _filePath = assetFile,
        _reset = reset,
        super();

  @override
  void dispose() {
    _file = null;
  }

  @override
  bool get isLoaded => data != null;

  @override
  Future<String> load() async {
    final directory = await getApplicationDocumentsDirectory();
    try {
      _file = File('${directory.path}/$_filePath');
      if (_reset) await resetStorage();
      _data = await _file.readAsString();
      return data;
    } catch (e) {
      _data = await rootBundle.loadString('assets/$_filePath');
      await _file.create(recursive: true);
      await _file.writeAsString(data);
      return data;
    }
  }

  @override
  Future<void> save() async {
    assert(isLoaded, 'File $_filePath must be loaded first');
    await _file.writeAsString(data);
  }

  Future<void> resetStorage() async {
    assert(_file != null, 'File $_filePath must be loaded first');

    if (await _file.exists()) await _file.delete();
  }

  @override
  String get data => _data;

  @override
  set data(String value) => _data = value;
}
