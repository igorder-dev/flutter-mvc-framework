import 'dart:collection';
import 'dart:convert' as convert;

import 'cached.dart';

///Base class describing JSON object. to be used for further extensions
class JsonObject extends MapBase<String, dynamic> implements Cached {
  final Map<String, dynamic> _json;

  JsonObject() : _json = Map<String, dynamic>();

  JsonObject.fromString(String json) : _json = convert.jsonDecode(json);

  JsonObject.fromMap(Map map) : _json = map.cast<String, dynamic>();

  JsonObject.fromJson(Map<String, dynamic> json) : _json = json;

  @override
  operator [](Object key) {
    return getValueByPath(key.toString());
  }

  @override
  void operator []=(Object key, value) {
    setValueByPath(key.toString(), value);
  }

  @override
  void clear() {
    _didObjectUpdate = true;
    _json.clear();
  }

  @override
  Iterable<String> get keys => _json.keys;

  @override
  remove(Object key) {
    // TODO : implement removal basing on value path
    _didObjectUpdate = true;
    _json.remove(key.toString());
  }

  @override
  String toString() => convert.jsonEncode(_json);

  Map<String, dynamic> toJson() => this._json;

  String toStringWithIndent() {
    convert.JsonEncoder encoder = convert.JsonEncoder.withIndent('  ');
    return encoder.convert(_json);
  }

  static JsonObject tryFromString(String val) {
    try {
      return JsonObject.fromString(val);
    } catch (e) {
      return null;
    }
  }

  void setValueByPath(String path, value) {
    List<String> pathList = path.split('.');

    dynamic pointer = _json;
    _didObjectUpdate = true;

    while (pathList.length > 0) {
      if (pointer is List) {
        var _list = pointer as List;
        var _listIndex = int.tryParse(pathList[0]) ?? 0;
        if (_listIndex >= _list.length) {
          var _pathList = pathList.toList();
          _pathList[0] = (_listIndex - _list.length).toString();
          _pathList.insert(0, '.');
          _list.addAll(_populateJsonList(_pathList));
        }
        if (pathList.length == 1) {
          pointer[_listIndex] = value;
          return;
        } else {
          pointer = pointer[_listIndex];
          pathList.removeAt(0);
        }
      } else if (pointer is Map) {
        if (pathList.length == 1) {
          pointer[pathList[0]] = value;
          return;
        } else {
          if (pointer[pathList[0]] == null) {
            if (int.tryParse(pathList[1]) == null) {
              pointer[pathList[0]] = Map<String, dynamic>();
            } else {
              pointer[pathList[0]] = _populateJsonList(pathList);
            }
          }
          pointer = pointer[pathList[0]];
          pathList.removeAt(0);
        }
      } else {
        pointer[pathList[0]] = value;
        return;
      }
    }
  }

  dynamic _populateJsonList(List<String> pathList) {
    List<String> _pathList = pathList.toList();
    _pathList.removeAt(0);
    if (_pathList.length == 0) return Map<String, dynamic>();
    if (int.tryParse(_pathList[0]) == null) return Map<String, dynamic>();
    List<dynamic> _list = List<dynamic>();
    var _listLenght = int.tryParse(_pathList[0]) + 1;

    for (int i = 0; i < _listLenght; i++) {
      _list.add(_pathList.length >= 2
          ? _populateJsonList(_pathList)
          : Map<String, dynamic>());
    }
    return _list;
  }

  dynamic getValueByPath(String path) {
    List<String> pathList = path.split('.');
    var returnValue;
    dynamic pointer = _json;

    while (pathList.length > 0) {
      if (pointer is List) {
        try {
          returnValue = pointer[int.tryParse(pathList[0]) ?? 0];
        } catch (e) {
          return null;
        }
      } else
        returnValue = pointer[pathList[0]];
      if (returnValue == null) return null;
      if (returnValue is Map || returnValue is List) {
        pointer = returnValue;
        pathList.removeAt(0);
      } else {
        return returnValue;
      }
    }
    return returnValue;
  }

  bool _isDisposed = false;
  bool _didObjectUpdate = false;

  @override
  void dispose() {
    _isDisposed = true;
  }

  @override
  bool get isDisposed => _isDisposed;

  @override
  void cacheObject() {
    _didObjectUpdate = false;
  }

  @override
  bool didObjectUpdate() => _didObjectUpdate;
}

abstract class JsonObjectSerializer<T extends JsonObject> {
  T fromJson(Map<String, dynamic> json);
  T fromString(String data);
  List<T> fromJsonArray(List<dynamic> jsonArray);
  List<T> fromStringArray(String data);
  Map<String, dynamic> toJson(T t);
  List<dynamic> toJsonArray(List<T> tList);
}
