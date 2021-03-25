import 'package:bapp/screens/business/booking_flow/services_screen.dart';
import 'package:bapp/screens/business/tabs/business_bookings_tab.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:flutter/material.dart';

enum UserType {
  customer,
  businessStaff,
  businessReceptionist,
  businessManager,
  businessOwner,
  sales,
  manager,
  sudo
}

enum MenuItemKind {
  logIn,
  yourProfile,
  settings,
  rateTheApp,
  helpUsImprove,
  logOut,
  switchTosShopping,
  switchToBusiness,
  switchToManager,
  onBoardABusiness,
  switchToSales,
  switchToSudoUser
}

class MenuItem {
  final String name;
  final IconData icon;
  final MenuItemKind kind;
  final List<UserType> showWhenUserTypeIs;
  final List<UserType> showWhenAlterEgoIs;
  final bool enabled;

  MenuItem({
    required this.name,
    required this.icon,
    required this.kind,
    this.showWhenUserTypeIs = const [],
    this.showWhenAlterEgoIs = const [],
    this.enabled = true,
  });
}

class Reasons {
  final String primary;
  final String secondary;

  Reasons({this.primary = "", this.secondary = ""});
}

class Tab {
  final String name;
  final IconData icon;

  Tab({required this.name, required this.icon});
}

class Featured {
  final String title;
  final IconData icon;
  final String ref;
  final Color cardColor;

  Featured(
      {required this.title,
      required this.icon,
      required this.ref,
      required this.cardColor});
}

class Slide {
  final String img;
  final String title;
  final String description;

  Slide({required this.img, required this.title, required this.description});
}

class BusinessExpandingPanelConfig {
  final String title;
  final String subTitle;
  final List<BusinessExpandingTile> tiles;

  BusinessExpandingPanelConfig(
      {required this.tiles, required this.title, required this.subTitle});
}

class BusinessExpandingTile {
  final IconData iconData;
  final String name;
  final Widget onClickRoute;
  final bool enabled;

  BusinessExpandingTile({
    required this.iconData,
    required this.name,
    required this.onClickRoute,
    required this.enabled,
  });
}

class BookingsTabAddOptionConfig {
  final String name;
  final Widget widgetToPush;

  BookingsTabAddOptionConfig(this.name, this.widgetToPush);

  static final options = [
    /* 
    ///change options to show up when add button is pressed in bookings tab of business side of the app
    BookingsTabAddOptionConfig("Add walk-in", BusinessProfileServicesScreen()),
    BookingsTabAddOptionConfig("Block Time", BlockTimeScreen()), */
  ];
}
