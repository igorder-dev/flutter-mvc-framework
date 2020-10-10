import 'package:flutter/widgets.dart';
import '../../framework/base_controller.dart';

typedef ExtLayoutWidgetBuilder<T extends MvcController> = Widget Function(
    Orientation orientation, BoxConstraints constraints, T controller);

class LayoutBuilderEx<T extends MvcController> extends StatelessWidget {
  final ExtLayoutWidgetBuilder<T> builder;
  final T controller;
  const LayoutBuilderEx({
    Key key,
    @required this.builder,
    @required this.controller,
  })  : assert(builder != null),
        assert(controller != null),
        super(key: key);

  Widget _buildWithConstraints(
      BuildContext context, BoxConstraints constraints) {
    final Orientation orientation = constraints.maxWidth > constraints.maxHeight
        ? Orientation.landscape
        : Orientation.portrait;
    return builder(orientation, constraints, controller);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildWithConstraints);
  }
}
