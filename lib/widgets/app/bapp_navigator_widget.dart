import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/main.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/misc/error.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bapp_provider_initializer.dart';

enum AppEvents { reboot, unHandledError }

class AppEventsWithExtra {
  final AppEvents event;
  final Object extra;

  AppEventsWithExtra(this.event, this.extra);
}

class BappNavigatorWidget extends StatefulWidget {
  final Widget child;
  final EventBus bus;

  const BappNavigatorWidget({Key key, this.child, this.bus}) : super(key: key);
  @override
  _BappNavigatorWidgetState createState() => _BappNavigatorWidgetState();
}

class _BappNavigatorWidgetState extends State<BappNavigatorWidget> {
  var _key = UniqueKey();
  var _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void didChangeDependencies() {
    _listenForEvents(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: BappProviderInitializerWidget(
        builder:(_){
          return Navigator(
            key: _navigatorKey,
            onGenerateRoute: RouteManager.onGenerate,
            initialRoute: "/",
          );
        },
      ),
    );
  }

  void _listenForEvents(BuildContext context) {
    widget.bus.on<AppEvents>().listen(
      (event) {
        switch (event) {
          case AppEvents.reboot:
            {
              setState(() {
                _key = UniqueKey();
                _navigatorKey = GlobalKey<NavigatorState>();
              });
              break;
            }
        }
      },
    );
    widget.bus.on<AppEventsWithExtra>().listen(
      (event) {
        switch (event.event) {
          case AppEvents.unHandledError:
            {
              Helper.printLog("ERROR, Showing error screen");
              BappNavigator.pushAndRemoveAll(_navigatorKey.currentContext, NoInternet());
              break;
            }
        }
      },
    );
  }
}

