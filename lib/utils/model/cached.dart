import 'disposable.dart';

abstract class Cached implements Disposable {
  bool didObjectUpdate();
  void cacheObject();
}
