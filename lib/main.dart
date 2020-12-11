import 'dart:async';

import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/widgets/network_error.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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

  await Firebase.initializeApp();
  runApp(App());
  runZoned(() async {

  }, onError: (e) {
    Helper.printLog("EXCEPTION");
    kBus.fire(AppEventsWithExtra(AppEvents.unHandledError, e));
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BappEventsHandler(
      bus: kBus,
      child: Builder(
        builder: (_) {
          final allStore = AllStore();
          allStore.set<EventBus>(kBus);
          final cloudStore = CloudStore()..setAllStore(allStore);
          allStore.set<CloudStore>(cloudStore);
          final businessStore = BusinessStore()..setAllStore(allStore);
          allStore.set<BusinessStore>(businessStore);
          final flow = BookingFlow(allStore);
          allStore.set<BookingFlow>(flow);
          return MultiProvider(
            providers: [
              Provider<EventBus>(
                create: (_) => kBus,
              ),
              Provider<AllStore>(
                create: (_) => allStore,
              ),
              Provider<ThemeStore>(
                create: (_) => ThemeStore(),
              ),
              Provider<CloudStore>(
                create: (_) => cloudStore,
              ),
              Provider<UpdatesStore>(
                create: (_) => UpdatesStore(),
              ),
              Provider<BusinessStore>(
                create: (_) => businessStore,
              ),
              Provider<BookingFlow>(
                create: (_) => flow,
              ),
            ],
            builder: (context, w) {
              return Consumer<ThemeStore>(
                builder: (_, themeStore, __) {
                  return Observer(
                    builder: (_) {
                      return MaterialApp(
                        title: "Bapp",
                        theme: themeStore.selectedThemeData,
                        initialRoute: "/",
                        onGenerateRoute: RouteManager.onGenerate,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
