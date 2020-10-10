import 'package:catcher/catcher.dart';
import 'package:flutter/widgets.dart';

abstract class ExceptionsHandlingConfig {
  CatcherOptions get releaseConfig;
  CatcherOptions get debugConfig;
  CatcherOptions get profileConfig;
  bool enableLogger;
  bool ensureInitialized;
  GlobalKey<NavigatorState> get navigatorKey;
}

class DefaultExceptionsHandlingConfig implements ExceptionsHandlingConfig {
  @override
  CatcherOptions get releaseConfig => CatcherOptions.getDefaultReleaseOptions();
  @override
  CatcherOptions get debugConfig => CatcherOptions.getDefaultDebugOptions();
  @override
  CatcherOptions get profileConfig => CatcherOptions.getDefaultProfileOptions();
  @override
  bool enableLogger = true;
  @override
  bool ensureInitialized = false;
  @override
  GlobalKey<NavigatorState> get navigatorKey => null;
}
