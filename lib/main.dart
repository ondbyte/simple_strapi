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
import 'package:flutter/services.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///all the error should go to through us
  FlutterError.onError = (e) {
    FlutterError.dumpErrorToConsole(e);
  };

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  final ppx = PersistenceX();
  await PersistenceX.i.init();
  runApp(App());
}
