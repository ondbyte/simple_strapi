import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/init/splash_screen.dart';
import 'package:bapp/screens/misc/error.dart';
import 'package:flutter/material.dart';


enum AppEvents { reboot, unHandledError }

class AppEventsWithExtra {
  final AppEvents event;
  final Object extra;

  AppEventsWithExtra(this.event, this.extra);
}

class BappNavigator extends StatefulWidget {
  final Widget child;

  const BappNavigator({
    Key key,
    this.child,
  }) : super(key: key);
  @override
  _BappNavigatorState createState() => _BappNavigatorState();

  static Future push<T>(BuildContext context,Widget routeWidget){
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    return state._navKey.currentState.push<T>(_materialPageRoute(routeWidget));
  }

  static Future pushAndRemoveAll<T>(BuildContext context,Widget routeWidget){
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    return state._navKey.currentState.pushAndRemoveUntil<T>(_materialPageRoute(routeWidget), (route) => false);
  }

  static Future pushReplacement<T,TO>(BuildContext context,Widget routeWidget,{TO result}){
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    state._navKey.currentState.pop(result);
    return state._navKey.currentState.push<T>(_materialPageRoute(routeWidget));
  }

  static void pop<T>(BuildContext context,T result){
    final state = context.findAncestorStateOfType<_BappNavigatorState>();
    return state._navKey.currentState.pop(result);
  }


  static Route _materialPageRoute(Widget routeWidget) {
    return MaterialPageRoute(builder: (_) {
      return routeWidget;
    });
  }
}

class _BappNavigatorState extends State<BappNavigator> {
  final _key = GlobalKey<NavigatorState>();

  @override
  void didChangeDependencies() {
    _listenForEvents(context);
    super.didChangeDependencies();
  }

  GlobalKey<NavigatorState> get _navKey=>_key;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Navigator(
        key: _key,
        onPopPage: (r, res) {
          Helper.printLog("pop");
          return r.didPop(res);
        },
        onGenerateRoute: (s) {
          return MaterialPageRoute(
            builder: (_) {
              return BappInitScreen();
            },
          );
        },
      ),
      onWillPop: () async {
        if(_navKey.currentState.canPop()){
          _navKey.currentState.pop();
          return false;
        } else{
          return true;
        }
      },
    );
  }

  Future<bool> _askToQuit(BuildContext context) {
    return showDialog(
      context: _navKey.currentContext,
      builder: (context) {
        return AlertDialog(
          content: Text("Close app and exit?"),
          actions: [
            FlatButton(
              onPressed: () {
                _navKey.currentState.pop(true);
              },
              child: Text("Yes"),
            ),
            FlatButton(
              onPressed: () {
                _navKey.currentState.pop(false);
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
              Helper.printLog("ERROR Showing error screen");
              BappNavigator.pushAndRemoveAll(
                _key.currentContext,
                NoInternet(),
              );
              break;
            }
        }
      },
    );
  }
}