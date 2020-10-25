import 'package:bapp/stores/auth_store.dart';
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
  referABusiness,
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
  final List<AuthStatus> showWhenAuthStatusIs;
  final bool enabled;

  MenuItem({
    this.showWhenAuthStatusIs = const [],
    this.name,
    this.icon,
    this.kind,
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

  Tab({this.name, this.icon});
}

class Featured {
  final String title;
  final IconData icon;
  final String ref;
  final Color cardColor;

  Featured({this.title, this.icon, this.ref, this.cardColor});
}

class Slide {
  final String img;
  final String title;
  final String description;

  Slide({this.img, this.title, this.description});
}

class BusinessExpandingPanelConfig {
  final String title;
  final String subTitle;
  final List<BusinessExpandingTile> tiles;

  BusinessExpandingPanelConfig({this.tiles, this.title, this.subTitle});
}

class BusinessExpandingTile {
  final IconData iconData;
  final String name;
  final String onClickRoute;
  final bool enabled;

  BusinessExpandingTile(
      {this.iconData, this.name, this.onClickRoute, this.enabled});
}
