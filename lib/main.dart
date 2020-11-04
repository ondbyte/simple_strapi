import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/storage_store.dart';
import 'package:bapp/stores/themestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import 'stores/business_store.dart';
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
    return MultiProvider(
      providers: [
        Provider<ThemeStore>(
          create: (_) => ThemeStore(),
        ),
        Provider<CloudStore>(
          create: (_) => CloudStore(),
        ),
        Provider<UpdatesStore>(
          create: (_) => UpdatesStore(),
        ),
        Provider<BusinessStore>(
          create: (_) => BusinessStore(),
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
  }
}
