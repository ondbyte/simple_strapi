import 'dart:async';

import 'package:bapp/config/constants.dart';
import 'package:bapp/config/theme_config.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/app/bapp_themed_app.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'route_manager.dart';
import 'stores/all_store.dart';
import 'stores/booking_flow.dart';
import 'stores/business_store.dart';
import 'stores/cloud_store.dart';
import 'stores/themestore.dart';
import 'stores/updates_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ///all the error should go to through us
  FlutterError.onError = (e) {
    FlutterError.dumpErrorToConsole(e);
    //kBus.fire(AppEventsWithExtra(AppEvents.unHandledError, e));
  };
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BappThemedApp(
      home: BappNavigatorWidget(
        bus: kBus,
      ),
    );
  }
}


