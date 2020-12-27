import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/extensions.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/home/bapp.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/screens/location/pick_a_place.dart';
import 'package:bapp/screens/onboarding/onboardingscreen.dart';
import 'package:bapp/stores/business_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../fcm.dart';

class BappInitScreen extends StatefulWidget {
  @override
  _BappInitScreenState createState() => _BappInitScreenState();
}

class _BappInitScreenState extends State<BappInitScreen>
    with AutomaticKeepAliveClientMixin {
  bool killState = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InitWidget(
      initializer: () async {
        if (mounted) {
          ///init authentication store / load user
          BappFCM().init();
          await Provider.of<CloudStore>(context, listen: false).init(
            onLogin: () async {
              if (mounted) {
                //await FirebaseAuth.instance.signOut();
                Provider.of<UpdatesStore>(context, listen: false).init();
                final cloudStore =
                    Provider.of<CloudStore>(context, listen: false);
                await Provider.of<BusinessStore>(context, listen: false).init();

                if (cloudStore.bappUser != null &&
                    !isNullOrEmpty(cloudStore.bappUser.address) &&
                    !isNullOrEmpty(cloudStore.bappUser.address.iso2)) {
                  ///customer is not a first timer
                  if (mounted) {
                    BappNavigator.pushAndRemoveAll(context, Bapp());
                  }
                  killState = !killState;
                  return;
                } else {
                  BappNavigator.pushAndRemoveAll(context, PickAPlaceScreen());
                  killState = !killState;
                  return;
                }
              }
            },
            onNotLogin: () async {
              if (mounted) {
                BappNavigator.push(context, OnBoardingScreen());
              }
              return;
            },
          );
          //await context.read<FeedbackStore>().init();
        }
      },

      ///show splash screen while everything happens behind the scenes
      child: Splash(),
    );
  }

  @override
  bool get wantKeepAlive => !killState;
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
