import 'dart:isolate';

import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/themestore.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../fcm.dart';
import '../../main.dart';
import '../../route_manager.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with AutomaticKeepAliveClientMixin {
  bool killState = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InitWidget(
      initializer: () async {
        ///init authentication store / load user
        BappFCM().initForAndroid();
        await Provider.of<ThemeStore>(context, listen: false).init();
        await _initCrashlytics();
        await Provider.of<CloudStore>(context, listen: false).init(
            onLogin: () async {
          if (mounted) {
            //await FirebaseAuth.instance.signOut();
            final cloudStore = Provider.of<CloudStore>(context, listen: false);
            await Provider.of<BusinessStore>(context, listen: false)
                .init(context);

            if (cloudStore.myAddress != null) {
              ///customer is not a first timer
              BappNavigator.bappPushAndRemoveAll(context, Bapp());
              killState = !killState;
              return;
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteManager.pickAPlace, (route) => false);
              killState = !killState;
              return;
            }
          }
        }, onNotLogin: () async {
          if (mounted) {
            Navigator.of(context).pushNamed(RouteManager.onBoardingScreen);
          }
          return;
        });
        //await context.read<FeedbackStore>().init();
      },

      ///show splash screen while everything happens behind the scenes
      child: _getSplashScreen(),
    );
  }

  Widget _getSplashScreen() {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              height: 80,
              child: SvgPicture.asset(
                'assets/svg/logo.svg',
                semanticsLabel: 'Ice Cream',
              ),
            ),
            Column(
              children: <Widget>[
                Text(
                  '$kAppName',
                  style: Theme.of(context).textTheme.headline1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Book Appointments',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _initCrashlytics() async {
    ///TO DO
    //switch in release
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      ///errors other than flutter
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        if (errorAndStacktrace.first
            .toString()
            .contains("The service is currently unavailable")) {
          Provider.of<EventBus>(context, listen: false).fire(AppEvents.reboot);
        }
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
        );
        print(errorAndStacktrace.first);
        print(errorAndStacktrace.last);
      }).sendPort);
    }
  }

  @override
  bool get wantKeepAlive => !killState;
}
