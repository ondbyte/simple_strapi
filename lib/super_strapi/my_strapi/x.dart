import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

///base class for new bapp reactive stores
abstract class X {
  ///dispose all the data when closing the app

  final _memoizers = <String, AsyncMemoizer>{};

  Future<T> memoize<T>(
      String method, Future<T> Function() toReturn, bool force) async {
    final m = _memoizers.remove(method);
    final memoizer = (force || m == null) ? AsyncMemoizer<T>() : m;
    _memoizers[method] = memoizer;
    return memoizer.runOnce(() => toReturn());
  }

  @mustCallSuper
  Future dispose() async {
    _memoizers.clear();
  }
}
