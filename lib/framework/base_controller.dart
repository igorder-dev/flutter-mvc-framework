import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:id_mvc_app_framework/framework/base_stateful_widget.dart';
import '../utils/animation.dart';

abstract class MvcController extends GetxController {
  static const int NORMAL_STATE = 0;
  static const int LOADING_STATE = 1;
  static const int ERROR_STATE = 2;

  MvcController({
    int startingState = MvcController.NORMAL_STATE,
  }) : _state = startingState;

  ///unique controller ID that let's know dependency injection system
  ///understanding if new controller needs to be created
  ///Very handful if you need to generate list of widgets of the same class,
  /// but handling of each needs to be done by seperate controller
  String get id => null;

  int _state;
  int get state => _state;
  set state(int value) {
    var oState = _state;
    _state = value;
    update(null, _state != oState);
  }

  bool get isLoading => state == MvcController.LOADING_STATE;
  set isLoading(bool value) {
    state = value ? MvcController.LOADING_STATE : MvcController.NORMAL_STATE;
  }

  void norm() {
    state = MvcController.NORMAL_STATE;
  }

  bool onError(Exception e) {
    return false;
  }

  MvcWidget _currentWidget;
  MvcWidget get currentWidget => _currentWidget;

  @mustCallSuper
  void didUpdateWidget(MvcWidget widget) {
    _currentWidget = widget;
  }

  @mustCallSuper
  void onInitState(MvcWidget widget, TickerProvider vsync) {
    _currentWidget = widget;
  }
}
