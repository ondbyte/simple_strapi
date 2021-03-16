import 'dart:io';

import 'package:bapp/helpers/helper.dart';
import 'package:firebase_core/firebase_core.dart';

const androidAppID = "1:347111752310:android:ad7a5613a0e76ec2699557";
const iosAppID = "1:347111752310:ios:9f46321d48acc13c699557";
const androidClientID =
    "347111752310-5d1q0kvkpv34pnvjlm3sepa8dakgeh9k.apps.googleusercontent.com";
const iosClientID =
    "347111752310-tkh0280494mrj413rpvuu9ifnvb2976o.apps.googleusercontent.com";
const projectId = "bapp-production";
const storageBucket = "bapp-production.appspot.com";
const messagingSenderID = "347111752310";

Future _initFirebase({bool production = false}) async {
  if (production) {
    Helper.bPrint("using bapp-production firebase project");
    return _bappProductionFirebaseProjectInitialization();
  }
  Helper.bPrint("using bapp-dev firebase project");
  return await Firebase.initializeApp();
}

///this initialization uses bapp-production firebase project
Future _bappProductionFirebaseProjectInitialization() async {
  return Firebase.initializeApp(
    name: "BAPP-PRODUCTION",
    options: FirebaseOptions(
        androidClientId: androidClientID,
        iosClientId: iosClientID,
        apiKey: "AIzaSyDwd498Byn1UhjjM_0W96TBQjEV8vsEOj4",
        appId: _decideFirebaseAppID(),
        projectId: projectId,
        storageBucket: storageBucket,
        messagingSenderId: messagingSenderID),
  );
}

String _decideFirebaseAppID() {
  if (Platform.isAndroid) {
    return androidAppID;
  }
  if (Platform.isIOS) {
    return iosAppID;
  }
  throw Exception("only android or ios is supported");
}
