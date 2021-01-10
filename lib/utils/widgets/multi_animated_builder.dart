import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class MultiAnimatedWidget extends StatefulWidget {
  /// Creates a widget that rebuilds when the given listenable changes.
  ///
  /// The [listenable] argument is required.
  const MultiAnimatedWidget({
    Key key,
    @required this.listenables,
  })  : assert(listenables != null),
        super(key: key);

  /// The [Listenable] to which this widget is listening.
  ///
  /// Commonly an [Animation] or a [ChangeNotifier].
  final List<Listenable> listenables;

  /// Override this method to build widgets that depend on the state of the
  /// listenable (e.g., the current value of the animation).
  @protected
  Widget build(BuildContext context);

  /// Subclasses typically do not override this method.
  @override
  _MultiAnimatedState createState() => _MultiAnimatedState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<List<Listenable>>('animation', listenables));
  }
}

class _MultiAnimatedState extends State<MultiAnimatedWidget> {
  @override
  void initState() {
    super.initState();
    widget.listenables.forEach((listenable) {
      listenable.addListener(_handleChange);
    });
  }

  @override
  void didUpdateWidget(MultiAnimatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenables != oldWidget.listenables) {
      oldWidget.listenables.forEach((listenable) {
        listenable.removeListener(_handleChange);
      });
      widget.listenables.forEach((listenable) {
        listenable.addListener(_handleChange);
      });
    }
  }

  @override
  void dispose() {
    widget.listenables.forEach((listenable) {
      listenable.removeListener(_handleChange);
    });
    super.dispose();
  }

  void _handleChange() {
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  @override
  Widget build(BuildContext context) => widget.build(context);
}

class MultiAnimatedBuilder extends MultiAnimatedWidget {
  /// Creates an animated builder.
  ///
  /// The [animation] and [builder] arguments must not be null.
  const MultiAnimatedBuilder({
    Key key,
    @required List<Listenable> animations,
    @required this.builder,
    this.child,
  })  : assert(animations != null),
        assert(builder != null),
        super(key: key, listenables: animations);

  /// Called every time the animation changes value.
  final TransitionBuilder builder;

  /// The child widget to pass to the [builder].
  ///
  /// If a [builder] callback's return value contains a subtree that does not
  /// depend on the animation, it's more efficient to build that subtree once
  /// instead of rebuilding it on every animation tick.
  ///
  /// If the pre-built subtree is passed as the [child] parameter, the
  /// [AnimatedBuilder] will pass it back to the [builder] function so that it
  /// can be incorporated into the build.
  ///
  /// Using this pre-built child is entirely optional, but can improve
  /// performance significantly in some cases and is therefore a good practice.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
