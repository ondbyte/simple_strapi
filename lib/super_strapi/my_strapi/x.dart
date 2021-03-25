import 'package:async/async.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

export "x_helpers.dart";

export 'package:bapp/super_strapi/super_strapi.dart';

///base class for new bapp reactive stores
abstract class X {
  ///dispose all the data when closing the app

  final _memoizers = <String, AsyncMemoizer>{};

  final _workers = <String, Worker>{};

  Future<T> memoize<T>(
    String method,
    Future<T> Function() toReturn, {
    required bool force,
    Rx? runWhenChanged,
  }) async {
    final toRun = (bool f) async {
      final m = _memoizers.remove(method);
      final memoizer = (f || m == null) ? AsyncMemoizer<T>() : m;
      _memoizers[method] = memoizer;
      return memoizer.runOnce(() => toReturn());
    };
    var _worker = _workers.remove("$method");
    if (runWhenChanged != null) {
      _worker?.dispose();
      if (_worker != null) {
        if (_worker.obs != runWhenChanged) {
          _worker = ever(
            runWhenChanged,
            (_) {
              toRun(true);
            },
          );
        }
      } else {
        _worker = ever(
          runWhenChanged,
          (_) {
            toRun(true);
          },
        );
      }
      _workers["$method"] = _worker;
    }
    return await toRun(force);
  }

  @mustCallSuper
  Future dispose() async {
    _workers.values.forEach((element) {
      element.dispose();
    });
    _memoizers.clear();
  }
}
