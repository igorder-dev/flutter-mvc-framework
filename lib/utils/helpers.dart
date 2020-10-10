import 'package:flutter/cupertino.dart';
import 'model/disposable.dart';
import 'model/cached.dart';

typedef WidgetListBuilder<T> = Widget Function(
    BuildContext context, T item, int index);

class MvcHelpers {
  static final Map<dynamic, Widget> _widgetsCache = Map<dynamic, Widget>();

  static List<Widget> widgetListBuilder<T>({
    List<T> list,
    WidgetListBuilder<T> itemBuilder,
    BuildContext context,
    bool cache = false,
  }) {
    int index = 0;
    cleanDisposedObjects();

    return list
        ?.map<Widget>((item) => !cache
            ? itemBuilder(context, item, index++)
            : _getCachedWidget(item, itemBuilder, context, index++))
        ?.toList();
  }

  static void cleanDisposedObjects() {
    _widgetsCache.removeWhere((key, value) =>
        (key is Disposable) ? (key as Disposable).isDisposed : false);
  }

  static Widget _getCachedWidget<T>(T item, WidgetListBuilder<T> itemBuilder,
      BuildContext context, int index) {
    bool isCached = _widgetsCache.containsKey(item);
    bool isRenewed =
        (item is Cached) ? (item as Cached).didObjectUpdate() : false;

    if (isCached && !isRenewed) {
      return _widgetsCache[item];
    } else {
      _widgetsCache[item] = itemBuilder(context, item, index);
      (item as Cached).cacheObject();
      return _widgetsCache[item];
    }
  }
}
