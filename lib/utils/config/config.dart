import 'config_manager.dart';

export 'config_manager.dart';
export '../model/json_object.dart';
export '../storage/storage_service.dart';

class Config {
  static Map<String, ConfigManagerBase> _configMap =
      Map<String, ConfigManagerBase>();

  static void clear() {
    _configMap.clear();
  }

  static void dispose() {
    _configMap = null;
  }

  static Future<void> add({
    String key,
    ConfigManagerBase config,
    bool initOnAdd = true,
  }) async {
    assert(!_configMap.containsKey(key),
        'Configuration manager with key $key is already defined.');
    _configMap[key] = config;

    if (initOnAdd) {
      bool initResult = await _configMap[key].init();
      assert(initResult, 'Could not initialize Config Manager $key');
    }
  }

  static Future<ConfigManagerBase> ofF(String key) async {
    assert(_configMap.containsKey(key),
        'Configuration manager with key $key not found.');
    ConfigManagerBase config = _configMap[key];
    if (!config.isInitialized())
      assert(await config.init(), 'Could not initialize Config Manager $key');
    return config;
  }

  static ConfigManagerBase of(String key) {
    assert(_configMap.containsKey(key),
        'Configuration manager with key $key not found.');
    ConfigManagerBase config = _configMap[key];
    if (!config.isInitialized())
      assert(config.isInitialized(),
          'Config Manager $key is not initialized. Try ofF() version.');
    return config;
  }
}
