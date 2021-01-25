import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_provider_initializer.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'config/constants.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BappReboot(
      child: BappProviderInitializerWidget(
        child: BappThemedApp(
          child: PackageInfoCheck(
            child: BappNavigator(),
          ),
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

class PackageInfoCheck extends StatefulWidget {
  final Widget child;

  const PackageInfoCheck({Key key, this.child}) : super(key: key);
  @override
  _PackageInfoCheckState createState() => _PackageInfoCheckState();
}

class _PackageInfoCheckState extends State<PackageInfoCheck> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  bool _dev = false;
  Future _init() async {
    final info = await PackageInfo.fromPlatform();
    if (info.packageName.endsWith("dev")) {
      setState(() {
        _dev = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _dev
        ? Banner(
            message: "dev",
            location: BannerLocation.topStart,
            child: widget.child,
          )
        : widget.child;
  }
}
