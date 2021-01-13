import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'widgets/multi_animated_builder.dart';
import 'async/async_lock.dart';

class AnimationContextManager {
  final TickerProvider vsync;
  final Map<dynamic, AnimationContext> _contexts = Map();

  AnimationContextManager({this.vsync}) : assert(vsync != null);

  AnimationContext operator [](dynamic key) {
    if (!_contexts.containsKey(key))
      _contexts[key] = AnimationContext(vsync: vsync);
    return _contexts[key];
  }

  void init() {
    _contexts.values.forEach((context) {
      context.init();
    });
  }

  void dispose() {
    _contexts.values.forEach((context) {
      context.dispose();
    });
    _contexts.clear();
  }

  Widget builder({
    List<dynamic> keys,
    Widget child,
    @required TransitionBuilder builder,
  }) {
    List<Listenable> _buildContexts = _getContextControllers(keys);
    assert(_buildContexts.length > 0,
        "MultiAnmiatedBuilder needs at least one listendable");
    return MultiAnimatedBuilder(
      animations: _buildContexts,
      child: child,
      builder: builder,
    );
  }

  List<AnimationController> _getContextControllers(List<dynamic> keys) {
    List<dynamic> _keys = keys ?? _contexts.keys.toList();
    List<AnimationController> _buildContextsControllers = List();
    _keys.forEach((key) {
      if (_contexts.containsKey(key))
        _buildContextsControllers.add(_contexts[key].controller);
    });
    return _buildContextsControllers;
  }

  Future forward({List<dynamic> keys, double from, bool parallel = true}) {
    return _executeContollersAction(
      keys: keys,
      parallel: parallel,
      action: (controller) => controller.forward(from: from),
    );
  }

  Future stop(
      {List<dynamic> keys, bool canceled = true, bool parallel = true}) {
    return _executeContollersAction(
      keys: keys,
      parallel: parallel,
      action: (controller) => controller.stop(canceled: canceled),
    );
  }

  Future repeat(
      {List<dynamic> keys,
      double min,
      double max,
      bool reverse = false,
      Duration period,
      bool parallel = true}) {
    return _executeContollersAction(
      keys: keys,
      parallel: parallel,
      action: (controller) => controller.repeat(
          max: max, min: min, period: period, reverse: reverse),
    );
  }

  Future _executeParallelAction(
      {List<dynamic> keys,
      dynamic Function(AnimationController controller) action}) {
    List<AnimationController> _buildContexts = _getContextControllers(keys);
    List<Future> _executionPool = List();
    _buildContexts.forEach(
      (context) {
        var result = action(context);
        if (result is Future) _executionPool.add(result);
      },
    );
    return Future.wait(_executionPool);
  }

  Future _executeSeqAction(
      {List<dynamic> keys,
      dynamic Function(AnimationController controller) action}) async {
    List<AnimationController> _buildContextControllers =
        _getContextControllers(keys);
    AsyncLock lock = AsyncLock();
    for (var controller in _buildContextControllers) {
      var result = action(controller);
      if (result is Future) await result;
    }
    lock.release();
    return lock.lock;
  }

  Future _executeContollersAction({
    List<dynamic> keys,
    dynamic Function(
      AnimationController controller,
    )
        action,
    bool parallel = true,
  }) async {
    switch (parallel) {
      case true:
        return _executeParallelAction(keys: keys, action: action);
        break;
      case false:
        return _executeSeqAction(keys: keys, action: action);
        break;
    }
  }
}

class AnimationContext {
  final AnimationController controller;
  final SequenceAnimationBuilder seq = SequenceAnimationBuilder();
  SequenceAnimation _animations;

  Animation operator [](dynamic key) {
    assert(_animations != null,
        "Initialize animation context first via [init method]");
    return _animations[key];
  }

  void init() {
    // controller.reset();
    _animations = seq.animate(controller);
  }

  AnimationContext({TickerProvider vsync})
      : assert(vsync != null),
        controller = AnimationController(vsync: vsync);

  Widget builder({
    Widget child,
    @required Function(AnimationContext animContext, Widget child) builder,
  }) =>
      MultiAnimatedBuilder(
        animations: [controller],
        child: child,
        builder: (BuildContext context, Widget child) {
          assert(builder != null);
          return builder(this, child);
        },
      );

  SequenceAnimationBuilder add({
    @required Animatable animatable,
    Duration from,
    Duration to,
    Duration duration,
    Curve curve = Curves.linear,
    @required Object tag,
  }) =>
      seq.add(
        animatable: animatable,
        tag: tag,
        from: from,
        to: to,
        duration: duration,
        curve: curve,
      );

  void dispose() {
    controller.dispose();
  }
}

class _AnimationInformation {
  _AnimationInformation({
    this.animatable,
    this.from,
    this.to,
    Duration duration,
    this.curve,
    this.tag,
  }) {
    _duration = duration != null ? duration : to - from;
  }

  final Animatable animatable;
  final Duration from;
  final Duration to;
  Duration _duration;
  Duration get duration => _duration;
  final Curve curve;
  final dynamic tag;
}

class SequenceAnimationBuilder {
  List<_AnimationInformation> _animations = [];

  /// Adds an [Animatable] to the sequence, in the most cases this would be a [Tween].
  /// The from and to [Duration] specify points in time where the animation takes place.
  /// You can also specify a [Curve] for the [Animatable].
  ///
  /// [Animatable]s which animate on the same tag are not allowed to overlap and they also need to be add in the same order they are played.
  /// These restrictions only apply to [Animatable]s operating on the same tag.
  ///
  ///
  /// ## Sample code
  ///
  /// ```dart
  ///     SequenceAnimation sequenceAnimation = new SequenceAnimationBuilder()
  ///         .addAnimatable(
  ///           animatable: new ColorTween(begin: Colors.red, end: Colors.yellow),
  ///           from: const Duration(seconds: 0),
  ///           to: const Duration(seconds: 2),
  ///           tag: "color",
  ///         )
  ///         .animate(controller);
  /// ```
  ///
  SequenceAnimationBuilder add({
    @required Animatable animatable,
    Duration from,
    Duration to,
    Duration duration,
    Curve curve = Curves.linear,
    @required Object tag,
  }) {
    final _from = from ?? (_animations.last?.to ?? Duration.zero);
    final _to = to ?? _from + (duration ?? Duration.zero);
    assert(_to >= _from, "[to] should be higher [from] when adding animation");
    _animations.add(new _AnimationInformation(
      animatable: animatable,
      from: _from,
      to: _to,
      duration: duration,
      curve: curve,
      tag: tag,
    ));
    return this;
  }

  /// The controllers duration is going to be overwritten by this class, you should not specify it on your own
  SequenceAnimation animate(AnimationController controller) {
    int longestTimeMicro = 0;
    _animations.forEach((info) {
      int micro = info.to.inMicroseconds;
      if (micro > longestTimeMicro) {
        longestTimeMicro = micro;
      }
    });
    // Sets the duration of the controller
    controller.duration = new Duration(microseconds: longestTimeMicro);

    Map<Object, Animatable> animatables = {};
    Map<Object, double> begins = {};
    Map<Object, double> ends = {};

    _animations.forEach((info) {
      assert(info.to.inMicroseconds <= longestTimeMicro);

      double begin = info.from.inMicroseconds / longestTimeMicro;
      double end = info.to.inMicroseconds / longestTimeMicro;
      Interval intervalCurve = new Interval(begin, end, curve: info.curve);
      if (animatables[info.tag] == null) {
        animatables[info.tag] =
            IntervalAnimatable.chainCurve(info.animatable, intervalCurve);
        begins[info.tag] = begin;
        ends[info.tag] = end;
      } else {
        assert(
            ends[info.tag] <= begin,
            "When animating the same property you need to: \n"
            "a) Have them not overlap \n"
            "b) Add them in an ordered fashion");
        animatables[info.tag] = new IntervalAnimatable(
          animatable: animatables[info.tag],
          defaultAnimatable:
              IntervalAnimatable.chainCurve(info.animatable, intervalCurve),
          begin: begins[info.tag],
          end: ends[info.tag],
        );
        ends[info.tag] = end;
      }
    });

    Map<dynamic, Animation> result = {};

    animatables.forEach((tag, animInfo) {
      result[tag] = animInfo.animate(controller);
    });

    return new SequenceAnimation._internal(result);
  }
}

class SequenceAnimation {
  final Map<dynamic, Animation> _animations;

  /// Use the [SequenceAnimationBuilder] to construct this class.
  SequenceAnimation._internal(this._animations);

  /// Returns the animation with a given tag, this animation is tied to the controller.
  Animation operator [](dynamic key) {
    assert(_animations.containsKey(key),
        "There was no animatable with the key: $key");
    return _animations[key];
  }
}

/// Evaluates [animatable] if the animation is in the time-frame of [begin] (inclusive) and [end] (inclusive),
/// if not it evaluates the [defaultAnimatable]
class IntervalAnimatable<T> extends Animatable<T> {
  IntervalAnimatable({
    @required this.animatable,
    @required this.defaultAnimatable,
    @required this.begin,
    @required this.end,
  });

  final Animatable animatable;
  final Animatable defaultAnimatable;

  /// The relative begin to of [animatable]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double begin;

  /// The relative end to of [animatable]
  /// If your [AnimationController] is running from 0->1, this needs to be a value between those two
  final double end;

  /// Chains an [Animatable] with a [CurveTween] and the given [Interval].
  /// Basically, the animation is being constrained to the given interval
  static Animatable chainCurve(Animatable parent, Interval interval) {
    return parent.chain(new CurveTween(curve: interval));
  }

  @override
  T transform(double t) {
    if (t >= begin && t <= end) {
      return animatable.transform(t);
    } else {
      return defaultAnimatable.transform(t);
    }
  }
}
