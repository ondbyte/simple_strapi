import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart' hide Tab;
import 'package:flutter/widgets.dart';

import '../stores/auth_store.dart';
import '../stores/auth_store.dart';
import '../stores/auth_store.dart';
import 'config_data_types.dart';
import 'config_data_types.dart';
import 'config_data_types.dart';
import 'config_data_types.dart';
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

///add homescreeen tab names and icons here
class BusinessHomeScreenTabsConfig {
  static List<Tab> tabs = [
    Tab(
      name: "Dashboard",
      icon: FeatherIcons.compass,
    ),
    Tab(
      name: "Bookings",
      icon: FeatherIcons.calendar,
    ),
    Tab(
      name: "Toolkit",
      icon: FeatherIcons.layers,
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
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
      ),
      MenuItem(
        name: "Settings",
        icon: FeatherIcons.settings,
        kind: MenuItemKind.settings,
        showWhenAuthStatusIs: [AuthStatus.userPresent],
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
      ),
      MenuItem(
        name: "Rate the App",
        icon: FeatherIcons.star,
        kind: MenuItemKind.rateTheApp,
        showWhenAuthStatusIs: [
          AuthStatus.userPresent,
          AuthStatus.anonymousUser,
        ],
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
      ),
      MenuItem(
        name: "Help us improve",
        icon: FeatherIcons.user,
        kind: MenuItemKind.helpUsImprove,
        showWhenAuthStatusIs: AuthStatus.values,
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
      ),
      MenuItem(
        name: "Refer a business",
        icon: FeatherIcons.disc,
        kind: MenuItemKind.referABusiness,
        showWhenAuthStatusIs: AuthStatus.values,
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
      ),
      MenuItem(
        name: "Logout",
        icon: FeatherIcons.logOut,
        kind: MenuItemKind.logOut,
        showWhenAuthStatusIs: [
          AuthStatus.userPresent,
        ],
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
      ),
      MenuItem(
        name: "Login",
        icon: FeatherIcons.logIn,
        kind: MenuItemKind.logIn,
        showWhenAuthStatusIs: [
          AuthStatus.anonymousUser,
        ],
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
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
            UserType.manager,
            UserType.businessStaff,
            UserType.businessOwner,
          ],
          showWhenAlterEgoIs: [
            UserType.customer
          ]),
      MenuItem(
        name: "Switch to business",
        icon: FeatherIcons.repeat,
        kind: MenuItemKind.switchToBusiness,
        showWhenAuthStatusIs: [AuthStatus.userPresent],
        showWhenAlterEgoIs: [
          UserType.businessOwner,
          UserType.businessStaff,
          UserType.manager,
        ],
        showWhenUserTypeIs: [
          UserType.customer,
        ],
      ),
      MenuItem(
        name: "Switch to sales",
        icon: FeatherIcons.repeat,
        kind: MenuItemKind.switchToSales,
      ),
      MenuItem(
        name: "Manager",
        icon: FeatherIcons.briefcase,
        kind: MenuItemKind.switchToManager,
        showWhenAuthStatusIs: [AuthStatus.userPresent],
        showWhenAlterEgoIs: [UserType.manager],
        showWhenUserTypeIs: [
          UserType.customer,
        ],
      ),
      MenuItem(
        name: "Sudo",
        icon: FeatherIcons.hash,
        kind: MenuItemKind.switchToSudoUser,
        showWhenAlterEgoIs: [UserType.sudo],
        showWhenUserTypeIs: [
          UserType.customer,
        ],
      ),
    ],
  ];
}

class BusinessExpandingPanelConfigs {
  static final List<BusinessExpandingPanelConfig> cfgs = [
    BusinessExpandingPanelConfig(
      title: "Grow your business",
      subTitle: "Set of tools to help you grow your business.",
      tiles: [
        BusinessExpandingTile(
          name: "Reports & Insights",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessReportsAndInsightsScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Offers & Promotions",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessOffersAndPromoScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Vouchers",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessVoucherScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Loyalty Program",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessLoyaltyProgramScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Sell Merchandise",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessSeleMerchScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Manage Campaigns",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessManageCampaignScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Booking Channel",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessBookingChannelsScreen,
          enabled: false,
        ),
      ],
    ),
    BusinessExpandingPanelConfig(
      title: "Client Management",
      subTitle: "Set of tools to help you grow your business",
      tiles: [
        BusinessExpandingTile(
          name: "Your Clients",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessYourClientsScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Customer Support",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessCustomerSupportScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Customer Feedback",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessCustomerFeedbackScreen,
          enabled: false,
        ),
      ],
    ),
    BusinessExpandingPanelConfig(
      title: "HRMs",
      subTitle: "Set of tools to help you grow your business",
      tiles: [
        BusinessExpandingTile(
          name: "Manage Staff",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessManageStaffScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Leaves",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessLeavesScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Salaries",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessSalariesScreen,
          enabled: false,
        ),
      ],
    ),
    BusinessExpandingPanelConfig(
      title: "Logistics",
      subTitle: "Set of tools to help you grow your business",
      tiles: [
        BusinessExpandingTile(
          name: "Stocks",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessStocksScreen,
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Merchandise",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessMerchScreen,
          enabled: false,
        ),
      ],
    ),
    BusinessExpandingPanelConfig(
      title: "Store Presence",
      subTitle: "Set of tools to help you grow your business",
      tiles: [
        BusinessExpandingTile(
          name: "Store Name & Address",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessNameAndAddressScreen,
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Manage Media",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessManageMediaScreen,
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Products & Pricing",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessProductsPricingScreen,
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Contact Details",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessContactDetailsScreen,
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Business Hours",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessTimingssScreen,
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Holidays",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessHolidaysScreen,
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Manage Branches",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessManageBranchesScreen,
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Business Verification",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: RouteManager.businessVerificationScreen,
          enabled: true,
        ),
      ],
    ),
  ];
}
