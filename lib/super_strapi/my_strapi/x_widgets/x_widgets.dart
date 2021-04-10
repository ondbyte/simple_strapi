import 'package:flutter/material.dart';
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

class RetriableFutureBuilder<T> extends StatefulWidget {
  final Future<T> Function(bool) futureCaller;
  final String retryMessage;
  final Function(BuildContext, AsyncSnapshot<T>) builder;
  RetriableFutureBuilder({
    Key? key,
    required this.futureCaller,
    required this.builder,
    this.retryMessage = "Unable to reach, tap to retry",
  }) : super(key: key);

  @override
  _RetriableFutureBuilderState createState() =>
      _RetriableFutureBuilderState<T>();
}

class _RetriableFutureBuilderState<T> extends State<RetriableFutureBuilder<T>> {
  AsyncSnapshot<T> _snapShot = AsyncSnapshot.waiting();
  var _retry = false;

  @override
  void initState() {
    super.initState();
    _try(false);
  }

  void _try(bool tryy) async {
    try {
      final answer = await widget.futureCaller(tryy);
      setState(() {
        if (answer is T) {
          _snapShot = AsyncSnapshot.withData(
            ConnectionState.done,
            answer,
          );
        } else {
          _retry = true;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _retry = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _retry
        ? RetryWidget(
            message: widget.retryMessage,
            onRetry: () {
              _try(true);
            },
          )
        : widget.builder(
            context,
            _snapShot,
          );
  }
}

class RetryWidget extends StatelessWidget {
  final String message;
  final Function() onRetry;

  const RetryWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        color: Colors.red.shade100,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(16),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }
}
