import 'package:bapp/config/firebase_config.dart';
import 'package:bapp/super_strapi/my_strapi/persistenceX.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///all the error should go to through us
  FlutterError.onError = (e) {
    FlutterError.dumpErrorToConsole(e);
  };

  await PersistenceX.i.init();
  runApp(App());
}
