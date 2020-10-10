import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/exceptions/exceptions_handling_config.dart';

import '../theme/base_app_theme.dart';
import 'package:catcher/catcher.dart';
import 'mvc_app_setup.dart';

void runMVCApp({
  Widget home,
  ExceptionsHandlingConfig exceptionsHandlingConfig,
  MvcAppSettings appSetup = const MvcAppSettings(),
  List<AppTheme> themes,
}) {
  if (themes?.length ?? 0 > 0) Get.defineThemes(themes: themes);
  if (exceptionsHandlingConfig != null) {
    Catcher(
      _getMaterialApp(home, appSetup),
      debugConfig: exceptionsHandlingConfig.debugConfig,
      releaseConfig: exceptionsHandlingConfig.releaseConfig,
      profileConfig: exceptionsHandlingConfig.profileConfig,
      enableLogger: exceptionsHandlingConfig.enableLogger,
      ensureInitialized: exceptionsHandlingConfig.ensureInitialized,
      navigatorKey: exceptionsHandlingConfig.navigatorKey,
    );
  } else {
    runApp(_getMaterialApp(home, appSetup));
  }
}

Widget _getMaterialApp(Widget app, MvcAppSettings setup) {
  return GetMaterialApp(
    home: app,
    key: setup.key,
    builder: setup.builder,
    color: setup.color,
    title: setup.title,
    theme: setup.theme ?? Get.themCtrl.theme.themeData,
    themeMode: setup.themeMode,
    checkerboardOffscreenLayers: setup.checkerboardOffscreenLayers,
    checkerboardRasterCacheImages: setup.checkerboardRasterCacheImages,
    customTransition: setup.customTransition,
    darkTheme: setup.darkTheme,
    debugShowCheckedModeBanner: setup.debugShowCheckedModeBanner,
    debugShowMaterialGrid: setup.debugShowMaterialGrid,
    defaultGlobalState: setup.defaultGlobalState,
    defaultTransition: setup.defaultTransition,
    enableLog: setup.enableLog,
    fallbackLocale: setup.fallbackLocale,
    getPages: setup.getPages,
    initialBinding: setup.initialBinding,
    initialRoute: setup.initialRoute,
    locale: setup.locale,
    localeListResolutionCallback: setup.localeListResolutionCallback,
    localeResolutionCallback: setup.localeResolutionCallback,
    localizationsDelegates: setup.localizationsDelegates,
    logWriterCallback: setup.logWriterCallback,
    navigatorKey: setup.navigatorKey,
    navigatorObservers: setup.navigatorObservers,
    onDispose: setup.onDispose,
    onGenerateInitialRoutes: setup.onGenerateInitialRoutes,
    onGenerateRoute: setup.onGenerateRoute,
    onGenerateTitle: setup.onGenerateTitle,
    onInit: setup.onInit,
    onUnknownRoute: setup.onUnknownRoute,
    opaqueRoute: setup.opaqueRoute,
    popGesture: setup.popGesture,
    routes: setup.routes,
    routingCallback: setup.routingCallback,
    shortcuts: setup.shortcuts,
    showPerformanceOverlay: setup.showPerformanceOverlay,
    showSemanticsDebugger: setup.showSemanticsDebugger,
    smartManagement: setup.smartManagement,
    supportedLocales: setup.supportedLocales,
    transitionDuration: setup.transitionDuration,
    translations: setup.translations,
    translationsKeys: setup.translationsKeys,
    unknownRoute: setup.unknownRoute,
  );
}
