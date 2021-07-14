import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemedApp extends StatefulWidget {
  final String? title;

  ///themes to use
  final ThemeData? darkTheme, lightTheme;

  ///directory to persist theme
  final Future<Directory> Function() directoryToPersistData;

  ///initalizer is to initialize things like dependency injection
  final Future Function(BuildContext)? initializer;

  ///additional delay so you can show splash for longer
  final Duration additionalDelay;

  ///a builder to let you know whether initializing or not, useful for showing splash
  final Widget Function(BuildContext, bool initializingDone) builder;

  const ThemedApp({
    Key? key,
    this.initializer,
    required this.builder,
    required this.directoryToPersistData,
    this.additionalDelay = Duration.zero,
    this.darkTheme,
    this.lightTheme,
    this.title,
  }) : super(key: key);
  @override
  _ThemedAppState createState() => _ThemedAppState();

  static Future<bool> darken(BuildContext context) async {
    final f = context.findAncestorStateOfType<_ThemedAppState>()?._darken();
    if (f != null) {
      return await f;
    }
    _print("no state for type $_ThemedAppState");
    return false;
  }

  static Future<bool> lighten(BuildContext context) async {
    final f = context.findAncestorStateOfType<_ThemedAppState>()?._lighten();
    if (f != null) {
      return f;
    }
    _print("no state for type $_ThemedAppState");
    return false;
  }

  static bool isDark(BuildContext context) {
    return context.findAncestorStateOfType<_ThemedAppState>()?._isDark ?? false;
  }
}

void _print(data) {
  print("[themedApp]: $data");
}

class _ThemedAppState extends State<ThemedApp> {
  Completer<Directory> _directoryCompleter = Completer();
  Completer _initCompleter = Completer();
  bool _initDone = false;
  final _streamController = StreamController<bool>();
  bool? _isDark = false;

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    _directoryCompleter.complete(widget.directoryToPersistData());
    super.initState();
  }

  Future _asyncInit(BuildContext context) async {
    await widget.initializer?.call(context);
    await Future.delayed(widget.additionalDelay);
    _getPersistenceDark().then((value) => _streamController.add(value));
    _initDone = true;
  }

  Future<bool> _darken() {
    _streamController.add(true);
    return _persist(true);
  }

  Future<bool> _lighten() {
    _streamController.add(false);
    return _persist(false);
  }

  Future<bool> _persist(bool dark) async {
    try {
      _print("saving");
      final directory = await _directoryCompleter.future;

      _print("saving2");
      final file = File("${directory.path}/theme.theme");
      await file.writeAsString(dark.toString());
      _print("saved");
      return true;
    } catch (e, s) {
      _print(e);
      _print(s);
      return false;
    }
  }

  Future<bool> _getPersistenceDark() async {
    final directory = await _directoryCompleter.future;
    final f = File("${directory.path}/theme.theme");
    if (await f.exists()) {
      final s = await f.readAsString();
      return s == "true";
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _streamController.stream,
      builder: (context, snap) {
        final data = snap.data;
        _isDark = data;
        return MaterialApp(
          title: widget.title ?? "",
          debugShowCheckedModeBanner: false,
          themeMode: data is! bool
              ? ThemeMode.system
              : (data ? ThemeMode.dark : ThemeMode.light),
          theme: widget.lightTheme,
          darkTheme: widget.darkTheme,
          home: Builder(
            builder: (context) {
              return FutureBuilder(
                future: () async {
                  if (!_initCompleter.isCompleted) {
                    _initCompleter.complete(_asyncInit(context));
                  }
                  return _initCompleter.future;
                }(),
                builder: (context, snap) {
                  return widget.builder(context, _initDone);
                },
              );
            },
          ),
        );
      },
    );
  }
}
