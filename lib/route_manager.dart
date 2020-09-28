
import 'package:bapp/screens/authentication/pick_a_location.dart';
import 'package:bapp/screens/onboarding/onboardingscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/bapp.dart';
import 'screens/init/splash_screen.dart';

class RouteManager {
  static Route<dynamic> onGenerate(RouteSettings settings) {
    print("route called: ${settings.name}");
    switch (settings.name) {
      case "/home":
        return MaterialPageRoute(
          builder: (_) {
            return Bapp();
          },
        );
      case "/":
        return MaterialPageRoute(
          builder: (_) {
            return SplashScreen();
          },
        );
      case "/onboarding":
        return MaterialPageRoute(
          builder: (_) {
            return OnBoardingScreen();
          },
        );
      case "/pickaplace":
        return MaterialPageRoute(
          builder: (_) {
            return PickALocationScreen(settings.arguments);
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
