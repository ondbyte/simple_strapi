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

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final allStore = AllStore();
    return MultiProvider(
      providers: [
        Provider<AllStore>(
          create: (_) => allStore,
        ),
        Provider<ThemeStore>(
          create: (_) => ThemeStore(),
        ),
        Provider<CloudStore>(
          create: (_) => CloudStore()..setAllStore(allStore),
        ),
        Provider<UpdatesStore>(
          create: (_) => UpdatesStore(),
        ),
        Provider<BusinessStore>(
          create: (_) => BusinessStore()..setAllStore(allStore),
        ),
        Provider<BookingFlow>(
          create: (_) => BookingFlow()..setAllStore(allStore),
        ),
      ],
      builder: (context, w) {
        return Consumer5<ThemeStore,CloudStore,BusinessStore,AllStore,BookingFlow>(
          builder: (_, themeStore,cloudStore,businessStore,allStore,flow, __) {
            allStore.set(cloudStore);
            allStore.set(businessStore);
            allStore.set(flow);
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
  }
}
