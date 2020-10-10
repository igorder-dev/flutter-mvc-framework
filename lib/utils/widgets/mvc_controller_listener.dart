//import 'package:flutter/widgets.dart';

//import '../../framework/base_controller.dart';
/*

typedef MvcControllerWidgetBuilder<T extends MvcControllerBase> = Widget
    Function(BuildContext context, T controller);

class MvcControllerListener<T extends MvcControllerBase>
    extends StatefulWidget {
  final T controller;
  final MvcControllerWidgetBuilder<T> builder;

  MvcControllerListener({
    Key key,
    @required this.controller,
    @required this.builder,
  })  : assert(controller != null),
        assert(builder != null),
        super(key: key);

  @override
  _MvcControllerListenerState createState() => _MvcControllerListenerState<T>();
}

class _MvcControllerListenerState<T extends MvcControllerBase>
    extends State<MvcControllerListener> {
  T controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    widget.controller.addListener(_refreshView);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refreshView);
    super.dispose();
  }

  @override
  void didUpdateWidget(MvcControllerListener<MvcControllerBase> oldWidget) {
    // if (oldWidget.controller != widget.controller) {
    //  oldWidget.controller.removeListener(_refreshView);
    //  controller = widget.controller;
    //  widget.controller.addListener(_refreshView);
    
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var res = widget.builder(context, controller);
    return res;
  }

  void _refreshView() {
    this.mounted
        ? setState(() {})
        : widget.controller.removeListener(_refreshView);
  }
}
*/
