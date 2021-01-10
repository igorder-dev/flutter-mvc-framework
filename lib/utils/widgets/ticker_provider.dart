import 'package:flutter/material.dart';

class TickerProviderBuilder extends StatefulWidget {
  final Widget Function(TickerProvider vsync) builder;
  TickerProviderBuilder({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  _TickerProviderState createState() => _TickerProviderState();
}

class _TickerProviderState extends State<TickerProviderBuilder>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => widget.builder(this);
}
