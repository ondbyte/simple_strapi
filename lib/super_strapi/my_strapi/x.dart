import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

export "x_helpers.dart";
export "./x_extensions/all.dart";

///base class for new bapp reactive stores
abstract class X {
  ///dispose all the data when closing the app

  final _memoizers = <Key, AsyncMemoizer>{};

  final _workers = <Key, Worker>{};

  Future<T> memoize<T>(
    Key key,
    Future<T> Function() toReturn, {
    Rx? runWhenChanged,
  }) async {
    final toRun = () async {
      final m = _memoizers.remove(key);
      final memoizer = ((m == null)) ? AsyncMemoizer<T>() : m;
      _memoizers[key] = memoizer;
      return memoizer.runOnce(() => toReturn());
    };
    var _worker = _workers.remove(key);
    if (runWhenChanged != null) {
      _worker?.dispose();
      if (_worker != null) {
        if (_worker.obs != runWhenChanged) {
          _worker = ever(
            runWhenChanged,
            (_) {
              toRun();
            },
          );
        }
      } else {
        _worker = ever(
          runWhenChanged,
          (_) {
            toRun();
          },
        );
      }
      _workers[key] = _worker;
    }
    return await toRun();
  }

  @mustCallSuper
  Future dispose() async {
    _workers.values.forEach((element) {
      element.dispose();
    });
    _memoizers.clear();
  }
}
