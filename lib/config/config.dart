import 'package:bapp/helpers/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///add colors of cards across the app (color will be picked up randomely most of the time)
class CardsColor {
  static List<Color> colors = [
    Color(0xff75B79E),
    Color(0xff5A3D55),
    Color(0xffE79C2A),
    Color(0xff1BC3AD),
  ];

  static int last = 0;
  static Color next() {
    last++;
    if (last == colors.length) last = 0;
    return colors[last];
  }
}

///add or change onboarding slides here
class OnBoardingConfig {
  static List<Slide> slides = [
    ///slide one
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services &\nbook appointments",
    ),

    ///2
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services &\nbook appointments",
    ),

    ///3
    Slide(
      img: "assets/svg/barber.svg",
      title: "Welcome to Bapp",
      description: "Bapp helps you  to discover services &\nbook appointments",
    ),
  ];
}

///add homescreeen tab names and icons here
class HomeScreenTabsConfig {
  static List<Tab> tabs = [
    Tab(
      name: "Discover",
      icon: FeatherIcons.compass,
    ),
    Tab(
      name: "Bookings",
      icon: FeatherIcons.calendar,
    ),
    Tab(
      name: "Favorites",
      icon: FeatherIcons.heart,
    ),
    Tab(
      name: "Bookings",
      icon: FeatherIcons.bell,
    ),
  ];
}

///add home screen featured cards to show
class HomeScreenFeaturedConfig {
  static List<Featured> slides = [
    Featured(
        title: "New On Bapp",
        icon: FeatherIcons.package,
        ref: "",
        cardColor: CardsColor.next()),
    Featured(
        title: "New On Bapp",
        icon: FeatherIcons.package,
        ref: "",
        cardColor: CardsColor.next()),
    Featured(
        title: "New On Bapp",
        icon: FeatherIcons.package,
        ref: "",
        cardColor: CardsColor.next()),
    Featured(
        title: "New On Bapp",
        icon: FeatherIcons.package,
        ref: "",
        cardColor: CardsColor.next()),
  ];
}

class LoginConfig {
  static Reasons bookingTabLoginReason = Reasons(
      primary: "Login to view your bookings",
      secondary:
          "Creating account will help you to book and manage all your appointments");
  static Reasons favoritesTabLoginReason = Reasons(
      primary: "Login to view your Favorites",
      secondary: "Favorites will help ");
}

class MenuConfig {
  static final String title = "Menu";
  static final IconData closeIcon = FeatherIcons.xCircle;
  static final List<List<MenuItem>> menuItems = [
    [
      MenuItem(
        name: "Your Profile",
        icon: FeatherIcons.user,
        kind: MenuItemKind.yourProfile,
      ),
      MenuItem(
        name: "Settings",
        icon: FeatherIcons.settings,
        kind: MenuItemKind.settings,
      ),
      MenuItem(
        name: "Rate the App",
        icon: FeatherIcons.star,
        kind: MenuItemKind.rateTheApp,
      ),
      MenuItem(
        name: "Help us improve",
        icon: FeatherIcons.user,
        kind: MenuItemKind.helpUsImprove,
      ),
      MenuItem(
        name: "Refer a business",
        icon: FeatherIcons.disc,
        kind: MenuItemKind.referABusiness,
      ),
      MenuItem(
        name: "Logout",
        icon: FeatherIcons.logOut,
        kind: MenuItemKind.logout,
      ),
    ],

    ///after divider another list of menu items
    [
      MenuItem(
          name: "Switch to shopping",
          icon: FeatherIcons.repeat,
          kind: MenuItemKind.switchTosShopping,
          showWhen: [
            UserType.sudo,
            UserType.sales,
            UserType.salesManager,
            UserType.businessStaff,
            UserType.businessOwner,
          ]),
      MenuItem(
          name: "Switch to business",
          icon: FeatherIcons.repeat,
          kind: MenuItemKind.switchToBusiness,
          specificToAlterEgo: [UserType.businessOwner,UserType.businessStaff],
          showWhen: [
            UserType.customer,
          ]),
      MenuItem(
          name: "Manager",
          icon: FeatherIcons.briefcase,
          kind: MenuItemKind.manager,
          specificToAlterEgo: [UserType.salesManager],
          showWhen: [
            UserType.customer,
          ]),
    ],
  ];
}

enum UserType {
  customer,
  businessStaff,
  businessOwner,
  sales,
  salesManager,
  sudo
}

enum MenuItemKind {
  yourProfile,
  settings,
  rateTheApp,
  helpUsImprove,
  referABusiness,
  logout,
  switchTosShopping,
  switchToBusiness,
  manager,
  onBoardABusiness
}

class MenuItem {
  final String name;
  final IconData icon;
  final MenuItemKind kind;
  final List<UserType> showWhen;
  final List<UserType> specificToAlterEgo;

  MenuItem(
      {this.name,
      this.icon,
      this.kind,
      this.showWhen = const [UserType.customer],
      this.specificToAlterEgo = const [UserType.customer]});
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
