import 'package:bapp/screens/business/addbusiness/choose_category.dart';
import 'package:bapp/screens/business/addbusiness/thank_you_for_your_interest.dart';
import 'package:bapp/screens/business/branch_chooser.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/screens/location/pick_a_place.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/screens/onboarding/onboardingscreen.dart';
import 'package:bapp/screens/search/show_results.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/authentication/create_profile.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/home/bapp.dart';
import 'screens/init/splash_screen.dart';
import 'screens/location/search_a_place.dart';
import 'screens/search/search_inside_bapp.dart';

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
  static const String createProfileScreen = "/crps";
  static const String settingsScreen = "/ss";
  static const String rateMyAppScreen = "/rmas";
  static const String helpUsImproveScreen = "/huis";
  static const String searchInsideBapp = "/sib";
  static const String showResultsScreen = "/srs";
  static const String businessBranchChooserScreen = "/bbcs";

  static Route<dynamic> onGenerate(RouteSettings settings) {
    print("route called: ${settings.name}");
    switch (settings.name) {
      case businessBranchChooserScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BranchChooserScreen();
          },
        );
      case createProfileScreen:
        return MaterialPageRoute(
          builder: (_) {
            return CreateYourProfileScreen();
          },
        );
      case showResultsScreen:
        return MaterialPageRoute(
          builder: (_) {
            return ShowResultsScreen(
              showResultsFor: settings.arguments,
            );
          },
        );
      case searchInsideBapp:
        return MaterialPageRoute(
          builder: (_) {
            return SearchInsideBappScreen();
          },
        );
      case contextualMessage:
        final list = settings.arguments as List;
        return MaterialPageRoute(
          builder: (_) {
            return ContextualMessageScreen(
              init: list[0],
              message: list[1],
            );
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
            return ThankYouForYourInterestScreen(
              category: settings.arguments,
            );
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
