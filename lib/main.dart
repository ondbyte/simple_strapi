import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/storage_store.dart';
import 'package:bapp/stores/themestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'stores/business_store.dart';
import 'stores/updates_store.dart';

void main() {
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
        Provider<AuthStore>(
          create: (_)=> AuthStore(),
        ),
        Provider<StorageStore>(
          create: (_)=>StorageStore(),
        ),
        Provider<CloudStore>(
          create: (_)=>CloudStore(),
        ),
        Provider<UpdatesStore>(
          create: (_)=>UpdatesStore(),
        ),
        Provider<BusinessStore>(
          create: (_)=>BusinessStore(),
        ),
      ],

      builder: (context,w){
        return MaterialApp(
          title: "Bapp",
          theme: Provider.of<ThemeStore>(context,listen: false).selectedThemeData,
          initialRoute: "/",
          onGenerateRoute: RouteManager.onGenerate,
        );
      },
    );
  }
}
