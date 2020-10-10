import 'package:flutter/material.dart';
import 'package:get/get.dart';

export 'theme_base.dart';

@immutable
class AppTheme {
  final ThemeData themeData;
  final String themeID;
  final String description;
  final AppThemeStyles styles;

  AppTheme({
    @required this.themeID,
    @required themeData,
    String description,
    this.styles,
  })  : this.themeData = themeData,
        this.description = description ??
            (themeData.brightness == Brightness.light
                ? "Light Theme"
                : "Dark Theme");

  factory AppTheme.light() {
    return AppTheme(
        themeData: ThemeData.light(),
        themeID: 'light_theme',
        description: 'Default light theme');
  }

  factory AppTheme.dark() {
    return AppTheme(
        themeData: ThemeData.dark(),
        themeID: 'dark_theme',
        description: 'Default dark theme');
  }

  AppTheme copyWith({
    @required String themeID,
    String description,
    ThemeData themeData,
    AppThemeStyles styles,
  }) {
    return AppTheme(
      themeID: themeID,
      description: description ?? this.description,
      themeData: themeData ?? this.themeData,
      styles: styles ?? this.styles,
    );
  }
}

class AppThemeController {
  static AppThemeController _instance;

  int _currentThemeIndex;
  final Map<String, AppTheme> _appThemes = Map<String, AppTheme>();
  final List<String> _appThemeIds = List<String>();

  String get appThemeId => _appThemeIds[_currentThemeIndex];
  AppTheme get theme => _appThemes[appThemeId];
  List<AppTheme> get allThemes =>
      _appThemeIds.map<AppTheme>((id) => _appThemes[id]).toList();

  AppThemeController._({
    @required List<AppTheme> themes,
    String defaultThemeId,
  }) {
    for (AppTheme theme in themes) {
      assert(!this._appThemes.containsKey(theme.themeID),
          "Conflicting theme ids found: ${theme.themeID} is already added to the widget tree,");
      this._appThemes[theme.themeID] = theme;
      _appThemeIds.add(theme.themeID);
    }

    if (defaultThemeId == null) {
      _currentThemeIndex = 0;
    } else {
      _currentThemeIndex = _appThemeIds.indexOf(defaultThemeId);
      assert(_currentThemeIndex != -1,
          "No app theme with the default theme id: $defaultThemeId");
    }
    _instance = this;
  }

  factory AppThemeController() {
    return AppThemeController.defineThemes(
      themes: [
        AppTheme.light(),
        AppTheme.dark(),
      ],
      reset: false,
    );
  }

  factory AppThemeController.defineThemes({
    @required List<AppTheme> themes,
    String defaultThemeId,
    bool reset = true,
  }) {
    if (reset) _instance = null;
    if (_instance == null) {
      _instance = AppThemeController._(
        themes: themes,
        defaultThemeId: defaultThemeId,
      );
    }
    return _instance;
  }

  void _setThemeByIndex(int themeIndex) {
    int _oldThemeIndex = _currentThemeIndex;
    _currentThemeIndex = themeIndex;
    if (_oldThemeIndex != _currentThemeIndex)
      Get.changeTheme(this.theme.themeData);
  }

  void nextTheme() {
    int nextThemeIndex = (_currentThemeIndex + 1) % _appThemes.length;
    _setThemeByIndex(nextThemeIndex);
  }

  void setTheme(String themeId) {
    assert(_appThemes.containsKey(themeId));
    int themeIndex = _appThemeIds.indexOf(themeId);
    _setThemeByIndex(themeIndex);
  }

  void setByAppTheme(AppTheme theme) {
    assert(_appThemes.containsKey(theme.themeID));
    setTheme(theme.themeID);
  }
}

extension AppThemeExt on GetInterface {
  AppThemeController get themCtrl => AppThemeController();
  void defineThemes({
    @required List<AppTheme> themes,
    String defaultThemeId,
  }) =>
      AppThemeController.defineThemes(
          themes: themes, defaultThemeId: defaultThemeId);

  T style<T extends AppThemeStyles>() => this.themCtrl.theme.styles;

  ThemeData get currTheme => Get.themCtrl.theme.themeData;
}

abstract class AppThemeStyles {}
