import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:id_mvc_app_framework/model.dart';
import '../utils/widgets/ticker_provider.dart';
import '../utils/animation.dart';

import 'base_controller.dart';

abstract class MvcWidget<T extends MvcController> extends StatelessWidget {
  final bool global;
  final bool autoRemove;
  final String id;
  final ObjectWrapper<T> ct = ObjectWrapper();

  final ObjectWrapper<AnimationContextManager> _acmWrapper = ObjectWrapper();

  T get controller => ct.object;
  T get c => ct.object;

  set controller(T value) => ct.object = value;
  set c(T value) => ct.object = value;

  AnimationContextManager get animations => _acmWrapper.object;

  void _initAnimations(TickerProvider vsync) {
    if (_acmWrapper.object == null) {
      _acmWrapper.object = AnimationContextManager(vsync: vsync);
      initAnimations();
      animations.init();
    }
  }

  MvcWidget({
    Key key,
    this.global = false,
    this.autoRemove = true,
    this.id,
  }) : super(key: key);

  @protected
  void onWidgetBuild() => null;

  @protected
  @required
  Widget buildMain();

  @protected
  Widget buildLoading() => null;

  @protected
  Widget buildError(Exception e) => null;

  @protected
  T initController() => null;

  @protected
  void initAnimations() => null;

  @override
  Widget build(BuildContext context) => TickerProviderBuilder(
        builder: (TickerProvider vsync) => _buildWithController(context, vsync),
      );

  Widget _build() {
    try {
      onWidgetBuild();
      switch (controller?.state ?? MvcController.NORMAL_STATE) {
        case MvcController.NORMAL_STATE:
          return buildMain();
        case MvcController.LOADING_STATE:
          return buildLoading() ?? buildMain();
        default:
          return buildMain();
      }
    } on Exception catch (e) {
      if (controller?.onError(e) ?? false) {
        return buildError(e) ?? buildMain();
      } else
        throw e;
    }
  }

  Widget _buildWithController(BuildContext context, TickerProvider vsync) {
    //initializing animation engine

    final c = setupController(initController());
    return GetBuilder<T>(
      global: this.global,
      tag: c?.id,
      id: this.id,
      init: c,
      autoRemove: this.autoRemove,
      builder: _controllerBuilder,
      initState: (state) {
        _initAnimations(vsync);
        c?.onInitState(this, vsync);
      },
      didUpdateWidget: (builder, state) {
        _acmWrapper.object = c?.currentWidget?.animations;
        _initAnimations(vsync);
        c?.didUpdateWidget(this);
      },
    );
  }

  T setupController(T init) {
    T _controller;
    var isRegistered = GetInstance().isRegistered<T>(tag: init?.id);

    if (global) {
      if (isRegistered) {
        _controller = GetInstance().find<T>(tag: init?.id);
      } else {
        _controller = init;
        GetInstance().put<T>(_controller, tag: init?.id);
      }
    } else {
      _controller = init;
    }
    return _controller;
  }

  Widget _controllerBuilder(T controller) {
    this.controller = controller;
    return _build();
  }

  Widget updater({String id, @required Function() builder}) {
    assert(builder != null);
    return GetBuilder<T>(
      init: c,
      builder: (c) => builder(),
      id: id,
    );
  }

  dispose() {
    animations.dispose();
  }
}
