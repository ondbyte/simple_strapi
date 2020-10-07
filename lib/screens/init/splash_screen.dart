import 'package:bapp/config/constants.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/storage_store.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return InitWidget(
      initializer: () async {
        await Provider.of<AuthStore>(context,listen: false).init();
        //await context.read<FeedbackStore>().init();
      },
      onInitComplete: () async {
        ///show onboarding screens if first time customer
        //await FirebaseAuth.instance.signOut();
        final authStore = Provider.of<AuthStore>(context,listen: false);
        final cloudStore = Provider.of<CloudStore>(context,listen: false);

        if(authStore.status==AuthStatus.userNotPresent){
          Navigator.of(context).pushReplacementNamed("/onboarding");
          return;
        }
        if(authStore.status==AuthStatus.anonymousUser||authStore.status==AuthStatus.userPresent){
          await cloudStore.init(context.read<AuthStore>());
          if(cloudStore.myLocation==null){
            Navigator.of(context).pushReplacementNamed("/pickaplace",arguments: 0);
            return;
          } else {
            ///customer is not a first timer
            Navigator.of(context).pushReplacementNamed("/home");
          }
        }
      },
      child: Scaffold(
        body: Center(
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
      ),
    );
  }
}

