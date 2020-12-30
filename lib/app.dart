

import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_provider_initializer.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:flutter/material.dart';

import 'config/constants.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BappReboot(
      child: BappProviderInitializerWidget(
        child: BappThemedApp(
          child: BappNavigator(),
        ),
      ),
    );
  }
}

class BappReboot extends StatefulWidget {
  final Widget child;

  const BappReboot({Key key, this.child}) : super(key: key);
  @override
  _BappRebootState createState() => _BappRebootState();
}

class _BappRebootState extends State<BappReboot> {
  var _key = UniqueKey();

  @override
  void initState() {
    _listenForReboot();
    super.initState();
  }

  void _listenForReboot() {
    kBus.on<AppEvents>().listen((event) {
      if (event == AppEvents.reboot) {
        setState(() {
          _key = UniqueKey();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}