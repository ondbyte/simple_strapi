import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/feedback_store.dart';
import 'package:bapp/stores/storage_store.dart';
import 'package:bapp/stores/themestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        Provider<FeedbackStore>(
          create: (_)=>FeedbackStore(),
        )
      ],
      builder: (context,w){
        return MaterialApp(
          title: "Bapp",
          theme: context.watch<ThemeStore>().selectedThemeData,
          initialRoute: "/",
          onGenerateRoute: RouteManager.onGenerate,
        );
      },
    );
  }
}
