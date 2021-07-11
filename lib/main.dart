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
  runApp(BappReboot(child: App()));
}
