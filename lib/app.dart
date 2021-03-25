import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/screens/init/splash_screen.dart';
import 'package:bapp/screens/onboarding/onboardingscreen.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_provider_initializer.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

import 'config/constants.dart';
import 'super_strapi/my_strapi/defaultDataX.dart';
import 'super_strapi/my_strapi/firebaseX.dart';
import 'super_strapi/my_strapi/init.dart';
import 'super_strapi/my_strapi/userX.dart';

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final firstScreen = Rx<Widget>(SizedBox());
  @override
  Widget build(BuildContext context) {
    return BappReboot(
      child: BappThemedApp(
        child: InitWidget(
          initializer: () async {
            final fbUser = await FirebaseX.i.init();
            await StrapiSettings.i.init();
            final defaultData = await DefaultDataX.i.init();
            final user = await UserX.i.init();
            if (DefaultDataX.i.isFirstTimeOnDevice) {
              firstScreen(BappNavigator(rootScreen: OnBoardingScreen()));
            } else {
              firstScreen(BappNavigator(rootScreen: Bapp()));
            }
          },
          showWhileInit: Splash(),
          child: PackageInfoCheck(
            child: Obx(
              () => firstScreen() ?? SizedBox(),
            ),
          ),
        ),
      ),
    );
  }
}

class BappReboot extends StatefulWidget {
  final Widget child;

  const BappReboot({Key? key, required this.child}) : super(key: key);
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

  const PackageInfoCheck({Key? key, required this.child}) : super(key: key);
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
