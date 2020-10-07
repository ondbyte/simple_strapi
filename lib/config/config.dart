import 'package:bapp/stores/auth_store.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter/widgets.dart';

import 'config_data_types.dart';

///add colors of cards across the app (color will be picked up randomly most of the time)
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
      img: "assets/svg/calendar.svg",
      title: "Skip Queues and Waiting time",
      description: "Bapp helps you  to discover services &\nbook appointments",
    ),

    ///3
    Slide(
      img: "assets/svg/review.svg",
      title: "Only The Best",
      description: "Choose from the best service providers\naround you.",
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
        "Creating account will help you to book and manage all your appointments.",
  );
  static Reasons favoritesTabLoginReason = Reasons(
    primary: "Login to view your Favorites",
    secondary:
        "Favorites will help you to bookmark places and book appointments faster.",
  );
}

///the dynamic menu items, can be set to be visible/hidden depending on the [AuthStatus] and can be specific to [UserType]
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
