import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/init/splash_screen.dart';
import 'package:bapp/screens/misc/error.dart';
import 'package:flutter/material.dart';

enum AppEvents {
  reboot,
  unHandledError,
  totalUpdates,
}

class AppEventsWithExtra {
  final AppEvents event;
  final Object extra;

  AppEventsWithExtra(this.event, this.extra);
}

class BappNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget rootScreen;
  const BappNavigator(
      {Key? key, required this.rootScreen, required this.navigatorKey})
      : super(key: key);
  @override
  _BappNavigatorState createState() => _BappNavigatorState();

  static Future<T?> push<T>(BuildContext context, Widget routeWidget) async {
    return Navigator.push(context, _pageRoute(routeWidget));
    bPrint("pushing screen ${routeWidget.runtimeType}");
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    return state?._navKey.currentState?.push<T>(_pageRoute<T>(routeWidget));
  }

  static Future<T?> pushAndRemoveAll<T>(
      BuildContext context, Widget routeWidget) async {
    return Navigator.pushAndRemoveUntil<T>(
        context, _pageRoute<T>(routeWidget), (route) => false);
    bPrint("pushing screen ${routeWidget.runtimeType}");
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    return state?._navKey.currentState
        ?.pushAndRemoveUntil<T>(_pageRoute<T>(routeWidget), (route) => false);
  }

  static Future<T?>? pushReplacement<T, TO>(
      BuildContext context, Widget routeWidget,
      {TO? result}) async {
    return Navigator.of(context)
        .pushReplacement(_pageRoute<T>(routeWidget), result: result);
    bPrint("pushing screen ${routeWidget.runtimeType}");
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    state?._navKey.currentState?.pop(result);
    return state?._navKey.currentState?.push<T>(_pageRoute<T>(routeWidget));
  }

  static void pop<T>(BuildContext context, T result) {
    return Navigator.of(context).pop(result);
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    return state?._navKey.currentState?.pop(result);
  }

  static Future<T?> dialog<T>(BuildContext context, Widget dialog) {
    bPrint("pushing dialog ");
    return showDialog<T>(
        context: context,
        useRootNavigator: false,
        builder: (_) {
          return dialog;
        });
  }

  static Route<T> _pageRoute<T>(Widget routeWidget, {bool isDialog = false}) {
    Helper.bPrint(isDialog);
    return PageRouteBuilder(
      fullscreenDialog: isDialog,
      barrierColor: Colors.transparent,
      opaque: isDialog,
      pageBuilder: (_, __, ___) {
        return routeWidget;
      },
    );
  }
}

class _BappNavigatorState extends State<BappNavigator> {
  @override
  void didChangeDependencies() {
    _listenForEvents(context);
    super.didChangeDependencies();
  }

  GlobalKey<NavigatorState> get _navKey => widget.navigatorKey;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Navigator(
        key: widget.navigatorKey,
        onPopPage: (r, s) {
          if (r.isFirst) {
            return false;
          }
          return r.didPop(s);
        },
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) {
              return widget.rootScreen;
            },
          );
        },
      ),
    );
  }

  Future<bool?> _askToQuit(BuildContext context) async {
    final context = _navKey.currentContext;
    if (context is! BuildContext) {
      return false;
    }
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("Close app and exit?"),
          actions: [
            TextButton(
              onPressed: () {
                _navKey.currentState?.pop(true);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                _navKey.currentState?.pop(false);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _listenForEvents(BuildContext context) {
    kBus.on<AppEventsWithExtra>().listen(
      (event) {
        switch (event.event) {
          case AppEvents.unHandledError:
            {
              Helper.bPrint("ERROR Showing error screen");
              BappNavigator.pushAndRemoveAll(
                _navKey.currentContext ?? context,
                NoInternet(),
              );
              break;
            }
        }
      },
    );
  }
}
