import 'disposable.dart';

class ObjectWrapper<T> implements Disposable {
  ObjectWrapper({T obj}) : object = obj;

  T object;

  @override
  void dispose() {
    if (object != null) {
      if (object is Disposable) (object as Disposable).dispose();
    }
    object = null;
  }

  @override
  bool get isDisposed => object == null;
}
