import 'package:bapp/helpers/constants.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///add colors of cards across the app (color will be picked up randomely most of the time)
class CardsColor {
  static Map<String, Color> colors = {
    "lightGreen": Color(0xff75B79E),
    "purple": Color(0xff5A3D55),
    "orange": Color(0xffE79C2A),
    "teal": Color(0xff1BC3AD),
  };

  static int last = 0;
  static Color next() {
    last++;
    if (last == colors.length) last = 0;
    return colors.values.elementAt(last);
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
      name: "Updates",
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
      secondary: "Favorites will help you to bookmark places and book appointments faster ");
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
        showWhenAuthStatusIs: [
          AuthStatus.userPresent,
        ],
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
        showWhenAuthStatusIs: [
          AuthStatus.userPresent,
          AuthStatus.anonymousUser,
        ],
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
        showWhenAuthStatusIs: [
          AuthStatus.userPresent,
        ],
      ),
      MenuItem(
        name: "Logout",
        icon: FeatherIcons.logOut,
        kind: MenuItemKind.logOut,
        showWhenAuthStatusIs: [
          AuthStatus.userPresent,
        ],
      ),
      MenuItem(
        name: "Login",
        icon: FeatherIcons.logIn,
        kind: MenuItemKind.logIn,
        showWhenAuthStatusIs: [
          AuthStatus.anonymousUser,
        ],
      ),
    ],

    ///after divider another list of menu items
    [
      MenuItem(
          name: "Switch to shopping",
          icon: FeatherIcons.repeat,
          kind: MenuItemKind.switchTosShopping,
          showWhenAuthStatusIs: [
            AuthStatus.userPresent
          ],
          showWhenUserTypeIs: [
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
          showWhenAuthStatusIs: [
            AuthStatus.userPresent
          ],
          showWhenAlterEgoIs: [
            UserType.businessOwner,
            UserType.businessStaff,
            UserType.customer,
          ],
          showWhenUserTypeIs: [
            UserType.customer,
          ]),
      MenuItem(
          name: "Switch to sales",
          icon: FeatherIcons.repeat,
          kind: MenuItemKind.switchToSales,
          showWhenAuthStatusIs: [
            AuthStatus.userPresent
          ],
          showWhenAlterEgoIs: [
            UserType.customer,
            UserType.sales
          ],
          showWhenUserTypeIs: [
            UserType.customer,
          ]),
      MenuItem(
          name: "Manager",
          icon: FeatherIcons.briefcase,
          kind: MenuItemKind.switchToManager,
          showWhenAuthStatusIs: [
            AuthStatus.userPresent
          ],
          showWhenAlterEgoIs: [
            UserType.salesManager
          ],
          showWhenUserTypeIs: [
            UserType.customer,
          ]),
      MenuItem(
          name: "Sudo",
          icon: FeatherIcons.hash,
          kind: MenuItemKind.switchToSudoUser,
          showWhenAlterEgoIs: [
            UserType.sudo
          ],
          showWhenUserTypeIs: [
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
