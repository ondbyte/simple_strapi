

import 'package:bapp/stores/auth_store.dart';
import 'package:flutter/material.dart';

enum UserType {
  customer,
  businessStaff,
  businessOwner,
  sales,
  salesManager,
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

  MenuItem(
      {this.showWhenAuthStatusIs = AuthStatus.values,
        this.name,
        this.icon,
        this.kind,
        this.showWhenUserTypeIs = const [UserType.customer],
        this.showWhenAlterEgoIs = const [UserType.customer]});
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