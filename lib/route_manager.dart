
import 'package:bapp/screens/authentication/pick_a_place.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/screens/onboarding/onboardingscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/addbusiness/choose_category.dart';
import 'screens/addbusiness/thank_you_for_your_interest.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/home/bapp.dart';
import 'screens/init/splash_screen.dart';
import 'screens/location/search_a_place.dart';


class RouteManager {
  static const String selectBusinessCategoryScreen = "/sbcs";
  static const String thankYouForYourInterestScreen = "/tfyis";
  static const String pickALocation = "/pal";
  static const String searchAPlace = "/sap";
  static const String home = "/home";
  static const String contextualMessage = "/ctxtmsg";
  static const String pickAPlace = "/pap";
  static const String onBoardingScreen = "/obs";
  static const String loginScreen = "/ls";
  static const String profileScreen = "/ps";
  static const String settingsScreen = "/ss";
  static const String rateMyAppScreen = "/rmas";
  static const String helpUsImproveScreen = "/huis";

  static Route<dynamic> onGenerate(RouteSettings settings) {
    print("route called: ${settings.name}");
    switch (settings.name) {
      case contextualMessage:
        final list = settings.arguments as List;
        return MaterialPageRoute(
          builder: (_) {
            return ContextualMessageScreen(init: list[0],message: list[1],);
          },
        );
      case searchAPlace:
        return MaterialPageRoute(
          builder: (_) {
            return SearchAPlaceScreen();
          },
        );
      case pickALocation:
        return MaterialPageRoute(
          builder: (_) {
            return PickAPlaceLocationScreen();
          },
        );
      case selectBusinessCategoryScreen:
        return MaterialPageRoute(
          builder: (_) {
            return ChooseYourBusinessCategoryScreen();
          },
        );
      case thankYouForYourInterestScreen:
        return MaterialPageRoute(
          builder: (_) {
            return ThankYouForYourInterestScreen(category: settings.arguments,);
          },
        );
      case loginScreen:
      return MaterialPageRoute(
        builder: (_) {
          return LoginScreen();
        },
      );
      case home:
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
      case onBoardingScreen:
        return MaterialPageRoute(
          builder: (_) {
            return OnBoardingScreen();
          },
        );
      case pickAPlace:
        return MaterialPageRoute(
          builder: (_) {
            return PickAPlaceScreen(settings.arguments);
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
