import 'dart:isolate';

import 'package:bapp/config/constants.dart';
import 'package:bapp/screens/init/initiating_widget.dart';

import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/storage_store.dart';
import 'package:bapp/stores/themestore.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:thephonenumber/thephonenumber.dart';

import '../../FCM.dart';
import '../../route_manager.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with AutomaticKeepAliveClientMixin {
  bool killState = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InitWidget(
      initializer: () async {
        ///init authentication store / load user
        await ThePhoneNumberLib.init();
        BappFCM().initForAndroid();
        await Provider.of<ThemeStore>(context, listen: false).init();
        await _initCrashlytics();
        await Provider.of<CloudStore>(context, listen: false).init(
          onLogin: () async {
            //await FirebaseAuth.instance.signOut();
            final cloudStore = Provider.of<CloudStore>(context, listen: false);

            if (cloudStore.myAddress != null) {
              ///customer is not a first timer
              await Provider.of<BusinessStore>(context, listen: false)
                  .init(context);
              Navigator.of(context).pushNamedAndRemoveUntil(RouteManager.home,(route) => false);
              killState = !killState;
              return;
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(RouteManager.pickAPlace, (route) => false);
              killState = !killState;
              return;
            }
          },
          onNotLogin: () async {
            Navigator.of(context)
                .pushNamed(RouteManager.onBoardingScreen);
            return;
          }
        );
        //await context.read<FeedbackStore>().init();
      },

      ///show splash screen while everything happens behind the scenes
      child: _getSplashScreen(),
    );
  }

  Widget _getSplashScreen() {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              height: 80,
              child: new SvgPicture.asset(
                'assets/svg/logo.svg',
                semanticsLabel: 'Ice Cream',
              ),
            ),
            Column(
              children: <Widget>[
                new Text(
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
          Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false);
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
