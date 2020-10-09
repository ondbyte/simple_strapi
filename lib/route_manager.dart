
import 'package:bapp/screens/authentication/pick_a_place.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
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
  static const String businessCategoryScreen = "/businesscategoryscreeen";
  static const String thankYouForYourInterestScreen = "/thankyouforinterest";
  static const String pickALocation = "/pickalocation";
  static const String searchAPlace = "/searchaplace";
  static const String home = "/home";
  static const String contextualMessage = "/ctxtmsg";

  static Route<dynamic> onGenerate(RouteSettings settings) {
    print("route called: ${settings.name}");
    switch (settings.name) {
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
      case businessCategoryScreen:
        return MaterialPageRoute(
          builder: (_) {
            return ChooseYourBusinessScreen();
          },
        );
      case thankYouForYourInterestScreen:
        return MaterialPageRoute(
          builder: (_) {
            return ThankYouForYourInterestScreen(category: settings.arguments,);
          },
        );
      case "/loginscreen":
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
      case "/onboarding":
        return MaterialPageRoute(
          builder: (_) {
            return OnBoardingScreen();
          },
        );
      case "/pickaplace":
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
