import 'package:bapp/config/constants.dart';
import 'package:bapp/config/firebase_config.dart';
import 'package:bapp/helpers/tmp.dart';

import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_provider_initializer.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///all the error should go to through us
  FlutterError.onError = (e) {
    FlutterError.dumpErrorToConsole(e);
  };
  await initFirebase();
  runApp(App());
}

