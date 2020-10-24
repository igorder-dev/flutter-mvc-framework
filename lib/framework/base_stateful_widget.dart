import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:id_mvc_app_framework/model.dart';
import 'base_controller.dart';

abstract class MvcWidget<T extends MvcController> extends StatelessWidget {
  final bool global;
  final bool autoRemove;
  final String id;
  final ObjectWrapper<T> ct = ObjectWrapper();

  T get controller => ct.object;
  T get c => ct.object;

  set controller(T value) => ct.object = value;
  set c(T value) => ct.object = value;

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

  @override
  Widget build(BuildContext context) => _buildWithController(context);

  Widget _build() {
    try {
      onWidgetBuild();
      switch (controller.state) {
        case MvcController.NORMAL_STATE:
          return buildMain();
        case MvcController.LOADING_STATE:
          return buildLoading() ?? buildMain();
        default:
          return buildMain();
      }
    } on Exception catch (e) {
      if (controller.onError(e)) {
        return buildError(e) ?? buildMain();
      } else
        throw e;
    }
  }

  Widget _buildWithController(BuildContext context) {
    final c = initController();
    return GetBuilder<T>(
      global: this.global,
      tag: c?.id,
      id: this.id,
      init: c,
      autoRemove: this.autoRemove,
      builder: _controllerBuilder,
    );
  }

  Widget _controllerBuilder(T controller) {
    this.controller = controller;
    return _build();
  }
}
