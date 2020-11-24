import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
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
}

enum AppEvents {
  reboot,
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  var _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final bus = EventBus();

    ///listen for reboot
    bus.on<AppEvents>().listen((event) {
      if (event == AppEvents.reboot) {
        setState(() {
          _key = UniqueKey();
        });
      }
    });
    return KeyedSubtree(
      key: _key,
      child: Builder(
        builder: (_) {
          final allStore = AllStore();
          allStore.set<EventBus>(bus);
          final cloudStore = CloudStore()..setAllStore(allStore);
          allStore.set<CloudStore>(cloudStore);
          final businessStore = BusinessStore()..setAllStore(allStore);
          allStore.set<BusinessStore>(businessStore);
          final flow = BookingFlow(allStore);
          allStore.set<BookingFlow>(flow);
          return MultiProvider(
            providers: [
              Provider<EventBus>(
                create: (_) => bus,
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
