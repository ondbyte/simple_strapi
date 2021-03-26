import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class XFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function(bool) futureCaller;
  final Function(BuildContext, AsyncSnapshot) builder;
  final List<Rx>? observeList;
  final Rx? observe;
  XFutureBuilder({
    Key? key,
    required this.futureCaller,
    required this.builder,
    this.observeList,
    this.observe,
  }) : super(key: key);

  @override
  _XFutureBuilderState<T> createState() => _XFutureBuilderState<T>();
}

class _XFutureBuilderState<T> extends State<XFutureBuilder<T>> {
  var _force = false;
  @override
  void initState() {
    super.initState();
    final observeList = widget.observeList;
    if (observeList is List<Rx>) {
      everAll(observeList, (_) {
        setState(() {
          _force = true;
        });
      });
    }
    final observe = widget.observe;
    if (observe is Rx) {
      ever(observe, (_) {
        setState(() {
          _force = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: () {
        _force = false;
        return widget.futureCaller(_force);
      }(),
      builder: (context, snap) {
        return widget.builder(context, snap);
      },
    );
  }
}
