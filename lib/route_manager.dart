import 'package:bapp/screens/business/addbusiness/choose_category.dart';
import 'package:bapp/screens/business/addbusiness/thank_you_for_your_interest.dart';
import 'package:bapp/screens/business/branch_chooser.dart';
import 'package:bapp/screens/business/toolkit/manage_holidays/add_a_holiday.dart';
import 'package:bapp/screens/business/toolkit/manage_holidays/holidays.dart';
import 'package:bapp/screens/business/toolkit/manage_branches/add_a_branch.dart';
import 'package:bapp/screens/business/toolkit/manage_branches/manage_branches.dart';
import 'package:bapp/screens/business/toolkit/manage_contact.dart';
import 'package:bapp/screens/business/toolkit/manage_media.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_category.dart';
import 'package:bapp/screens/business/toolkit/manage_services/add_a_service.dart';
import 'package:bapp/screens/business/toolkit/manage_services/manage_services.dart';
import 'package:bapp/screens/business/toolkit/manage_staff/add_a_staff.dart';
import 'package:bapp/screens/business/toolkit/manage_staff/manage_staff.dart';
import 'package:bapp/screens/business/toolkit/store_name_address.dart';
import 'package:bapp/screens/business/toolkit/timings.dart';
import 'package:bapp/screens/location/pick_a_location.dart';
import 'package:bapp/screens/location/pick_a_place.dart';
import 'package:bapp/screens/misc/contextual_message.dart';
import 'package:bapp/screens/onboarding/onboardingscreen.dart';
import 'package:bapp/screens/search/show_results.dart';
import 'package:bapp/stores/firebase_structures/business_holidays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens/authentication/create_profile.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/business/toolkit/submit_for_verification.dart';
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

  ///business expansion tiles routes

  static const String businessReportsAndInsightsScreen =
      "/businessReportsAndInsightsScreen";
  static const String businessOffersAndPromoScreen =
      "/businessOffersAndPromoScreen";
  static const String businessVoucherScreen = "/businessVoucherScreen";
  static const String businessLoyaltyProgramScreen =
      "/businessLoyaltyProgramScreen";
  static const String businessSeleMerchScreen = "/businessSeleeMerchScreen";
  static const String businessManageCampaignScreen =
      "/businessManageCampaignScreen";
  static const String businessBookingChannelsScreen =
      "/businessBookingChannelsScreen";
  static const String businessYourClientsScreen = "/businessYourClientsScreen";
  static const String businessCustomerSupportScreen =
      "/businessCustomerSupportScreen";
  static const String businessCustomerFeedbackScreen =
      "/businessCustomerFeedbackScreen";
  static const String businessManageStaffScreen = "/businessManageStaffScreen";
  static const String businessLeavesScreen = "/businessLeavesScreen";
  static const String businessSalariesScreen = "/businessSalariesScreen";
  static const String businessStocksScreen = "/businessStocksScreen";
  static const String businessMerchScreen = "/businessMerchScreen";
  static const String businessNameAndAddressScreen =
      "/businessNameAndAddressScreen";
  static const String businessManageMediaScreen = "/businessManageMediaScreen";
  static const String businessProductsPricingScreen =
      "/businessProductsPricingScreen";
  static const String businessContactDetailsScreen =
      "/businessContactDetailsScreen";
  static const String businessTimingssScreen = "/businessHoursScreen";
  static const String businessHolidaysScreen = "/businessHolidaysScreen";
  static const String businessManageBranchesScreen =
      "/businessManageBranchesScreen";
  static const String businessAddABranchScreeen = "/businessAddABranchScreeen";
  static const String businessVerificationScreen =
      "/submitSelectedBranchForVerification";
  static const String businessAddAHolidayScreen = "/businessAddAHolidayScreen";

  static const String businessAddAServiceScreen = "/businessAddAServiceScreen";
  static const String businessAddAServiceCategoryScreen =
      "/businessAddAServiceCategoryScreen";
  static const String businessAddAStaffScreen = "/businessAddAStaffScreen";

  static Route<dynamic> onGenerate(RouteSettings settings) {
    print("route called: ${settings.name}");
    switch (settings.name) {

      ///business

      case businessAddAStaffScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessAddAStaffScreen();
          },
        );

      case businessManageStaffScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessManageStaffScreen();
          },
        );

      case businessProductsPricingScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessProductsPricingScreen();
          },
        );

      case businessAddAServiceCategoryScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessAddServiceCategoryScreen();
          },
        );
      case businessAddAServiceScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessAddAServiceScreen();
          },
        );

      case businessProductsPricingScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessProductsPricingScreen();
          },
        );

      case businessAddAHolidayScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessAddAHolidayScreen();
          },
        );

      case businessHolidaysScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessManageHolidaysScreen();
          },
        );

      case businessTimingssScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessTimingsScreen();
          },
        );

      case businessContactDetailsScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessManageContactDetailsScreen();
          },
        );

      case businessNameAndAddressScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessStoreNameAddress();
          },
        );

      case businessVerificationScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessSubmitBranchForVerification();
          },
        );

      case businessAddABranchScreeen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessAddABranchScreen();
          },
        );

      case businessManageBranchesScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessManageBranchesScreen();
          },
        );

      case businessManageMediaScreen:
        return MaterialPageRoute(
          builder: (_) {
            return BusinessManageMediaScreen();
          },
        );

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
            return SearchAPlaceScreen(
              googlePlace: settings.arguments,
            );
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
