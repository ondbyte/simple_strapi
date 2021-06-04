import 'package:bapp/config/firebase_config.dart';
import 'package:bapp/super_strapi/my_strapi/bookingX.dart';
import 'package:bapp/super_strapi/my_strapi/businessX.dart';
import 'package:bapp/super_strapi/my_strapi/categoryX.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/firebaseX.dart';
import 'package:bapp/super_strapi/my_strapi/handPickedX.dart';
import 'package:bapp/super_strapi/my_strapi/localityX.dart';
import 'package:bapp/super_strapi/my_strapi/partnerX.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:bapp/super_strapi/my_strapi/reviewX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///all the error should go to through us
  FlutterError.onError = (e) {
    FlutterError.dumpErrorToConsole(e);
  };

  final h = HandPickedX();
  final b = BookingX();
  final bb = BusinessX();
  final c = CategoryX();
  final d = DefaultDataX();
  final fb = FirebaseX();
  final l = LocalityX();
  final px = PartnerX();
  final ppx = PersistenceX();
  final rx = ReviewX();
  final u = UserX();
  await PersistenceX.i.init();
  runApp(App());
}
