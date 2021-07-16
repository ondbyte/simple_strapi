import 'dart:async';

import 'package:bapp/config/theme_config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/screens/init/splash_screen.dart';
import 'package:bapp/screens/location/pick_a_place.dart';
import 'package:bapp/screens/onboarding/onboardingscreen.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/categoryX.dart';
import 'package:bapp/super_strapi/my_strapi/featuredX.dart';
import 'package:bapp/super_strapi/my_strapi/handPickedX.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:bapp/super_strapi/my_strapi/partnerX.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/super_strapi/my_strapi/reviewX.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_provider_initializer.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';
import 'package:yadunandans_flutter_helpers/themed_app.dart';

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
  final _initCompleter = Completer();
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _init(context);
  }

  Future _init(BuildContext context) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final h = HandPickedX();
      final b = BookingX();
      final bb = BusinessX();
      final c = CategoryX();
      final d = DefaultDataX();
      final fb = FirebaseX();
      final l = LocalityX();
      final px = PartnerX();
      final rx = ReviewX();
      final u = UserX();
      final p = PersistenceX();
      final f = FeaturedX();
      await p.init();
      final fbUser = await FirebaseX.i.init();
      await StrapiSettings.i.init();
      final defaultData = await DefaultDataX.i.init();
      final user = await UserX.i.init();

      if (await PersistenceX.i
          .getValue(StorageKeys.isFirstTimeOnDevice, defaultValue: true)) {
        final firstTimeDone = await Get.to(OnBoardingScreen());
        if (firstTimeDone == true) {
          await PersistenceX.i
              .saveValue(StorageKeys.isFirstTimeOnDevice, false);
        } else {
          return Get.back();
        }
      }
      final makeSurePlace = () async {
        var data;
        await Future.doWhile(() async {
          data = await Get.to(PickAPlaceScreen());

          return data == null;
        });
        return data;
      };
      var data;
      if (user != null && user.city == null && user.locality == null) {
        data = await makeSurePlace();
        if (data is City) {
          await UserX.i.setLocalityOrCity(city: data);
        } else {
          await UserX.i.setLocalityOrCity(locality: data);
        }
      } else if (defaultData is DefaultData &&
          defaultData.city == null &&
          defaultData.locality == null) {
        data = await makeSurePlace();
        if (data is City) {
          await DefaultDataX.i.setLocalityOrCity(city: data);
        } else {
          await DefaultDataX.i.setLocalityOrCity(locality: data);
        }
      }
    } catch (e, s) {
      bPrint(e);
      bPrint(s);
    }
    Get.offAll(Bapp());
  }

  Widget _rootRoute() {
    return Init(
      onInitDone: (_) {},
      initialization: (context) async {
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete(_init(context));
        }
        return _initCompleter.future;
      },
      builder: (context, initDone) {
        return initDone ? Bapp() : Splash();
      },
    );
  }

  @override
  Widget build(context) {
    return GetMaterialApp(
      theme: getLightThemeData(),
      darkTheme: getDarkThemeData(),
      themeMode: ThemeMode.system,
      initialRoute: "/",
      onGenerateRoute: (_) {
        if (_.name == "/") {
          return GetPageRoute(page: () => Splash());
        }
      },
    );
  }

/*   @override
  Widget build(BuildContext context) {
    return ThemedApp(
      lightTheme: getLightThemeData(),
      darkTheme: getDarkThemeData(),
      initializer: (context) {
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete(_init(context));
        }
        return _initCompleter.future;
      },
      builder: (context, initialized) {
        if (initialized) {
          return firstScreen();
        }
        return Splash();
      },
      directoryToPersistData: () {
        return getApplicationSupportDirectory();
      },
    );
  } */
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
