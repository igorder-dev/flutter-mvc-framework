import 'package:flutter/widgets.dart';
import 'base_controller.dart';
import 'base_stateful_widget.dart';
import '../utils/widgets/layout_builder_ex.dart';

abstract class MvcScreen<T extends MvcController> extends MvcWidget<T> {
  MvcScreen({Key key}) : super(key: key, global: true) {
    defaultScreenHandler.builder = defaultScreenLayout;
  }

  final ScreenHandler<T> defaultScreenHandler = ScreenHandler<T>(
    handler: ScreenHandler.defaultScreenHandler,
    builder: null,
  );

  @protected
  Set<ScreenHandler> get screenLayouts => null;

  @protected
  @required
  Widget defaultScreenLayout(ScreenParameters screenParameters, T controller);

  Widget _layoutBuilder(
      Orientation orientation, BoxConstraints constraints, T controller) {
    if (screenLayouts != null) {
      for (ScreenHandler item in screenLayouts) {
        if (item.handler(ScreenParameters(
            screenConstraints: constraints, screenOrientation: orientation)))
          return item.build(
              ScreenParameters(
                screenConstraints: constraints,
                screenOrientation: orientation,
              ),
              controller);
      }
    }

    return defaultScreenHandler.build(
        ScreenParameters(
          screenConstraints: constraints,
          screenOrientation: orientation,
        ),
        controller);
  }

  @override
  Widget buildMain() {
    return LayoutBuilderEx(
      builder: _layoutBuilder,
      controller: controller,
    );
  }
}

class ScreenParameters {
  final BoxConstraints screenConstraints;
  final Orientation screenOrientation;

  ScreenParameters(
      {@required this.screenConstraints, @required this.screenOrientation})
      : assert(screenConstraints != null),
        assert(screenOrientation != null);
}

typedef ScreenParametersHandler = bool Function(
    ScreenParameters screenParameters);

typedef ScreenLayoutBuidler<T extends MvcController> = Widget Function(
    ScreenParameters screenParameters, T controller);

class ScreenHandler<T extends MvcController> {
  static final ScreenParametersHandler defaultScreenHandler =
      (ScreenParameters screenParameters) => true;

  static final ScreenParametersHandler landscapeScreenHandler =
      (ScreenParameters screenParameters) =>
          screenParameters.screenOrientation == Orientation.landscape;

  static final ScreenParametersHandler portraitScreenHandler =
      (ScreenParameters screenParameters) =>
          screenParameters.screenOrientation == Orientation.landscape;

  final ScreenParametersHandler handler;
  ScreenLayoutBuidler<T> _builder;
  ScreenLayoutBuidler<T> get builder => _builder;
  set builder(ScreenLayoutBuidler<T> value) {
    _builder = value;
    clearCache();
  }

  final bool cacheBuilder;
  Widget _cache;

  Widget build(ScreenParameters screenParameters, T controller) {
    if (cacheBuilder) {
      _cache ??= builder(screenParameters, controller);
      return _cache;
    } else {
      return builder(screenParameters, controller);
    }
  }

  void dispose() {
    _cache = null;
  }

  void clearCache() {
    _cache = null;
  }

  ScreenHandler({
    @required this.handler,
    @required ScreenLayoutBuidler<T> builder,
    this.cacheBuilder = false,
  })  : _builder = builder,
        assert(handler != null);
}
