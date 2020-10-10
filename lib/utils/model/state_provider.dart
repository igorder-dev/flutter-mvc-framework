import 'cached.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';

mixin ModelStateProvider implements Disposable, Cached {
  final _stateController = BehaviorSubject<ModelStateEvent>();
  bool _isDisposed = false;
  bool _didObjectUpdate = false;

  Stream<ModelStateEvent> get state => _stateController.stream;

  void listenToUpdates(EventCallback callback,
          {Function onError, void onDone(), bool cancelOnError}) =>
      state.listen(callback,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  void updateState({ModelStateEvent event = const ModelStateEvent.empty()}) {
    _stateController.add(event);
    _didObjectUpdate = true;
  }

  @override
  void dispose() {
    _stateController.close();
    _isDisposed = true;
  }

  @override
  bool get isDisposed => _isDisposed;

  @override
  bool didObjectUpdate() => _didObjectUpdate;
  @override
  void cacheObject() {
    _didObjectUpdate = false;
  }
}

typedef EventCallback = void Function(ModelStateEvent event);

class ModelStateEvent<T> {
  final String eventMessage;
  final T eventValue;

  const ModelStateEvent.empty()
      : eventMessage = 'UPDATE',
        eventValue = null;
  ModelStateEvent(this.eventMessage, this.eventValue);
}
