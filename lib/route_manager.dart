
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/bapp.dart';
import 'screens/init/splash_screen.dart';

class RouteManager {
  static Route<dynamic> onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (_) {
            return Bapp();
          },
        );
      case "/splashscreen":
        return MaterialPageRoute(
          builder: (_) {
            return SplashScreen();
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) {
            return Bapp();
          },
        );
    }
  }
}
