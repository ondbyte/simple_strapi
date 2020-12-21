import 'package:bapp/classes/firebase_structures/business_booking.dart';
import 'package:bapp/classes/firebase_structures/rating.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/screens/business/toolkit/manage_branches/manage_branches.dart';
import 'package:bapp/screens/business/toolkit/manage_contact.dart';
import 'package:bapp/screens/business/toolkit/manage_holidays/holidays.dart';
import 'package:bapp/screens/business/toolkit/manage_media.dart';
import 'package:bapp/screens/business/toolkit/manage_services/manage_services.dart';
import 'package:bapp/screens/business/toolkit/manage_staff/manage_staff.dart';
import 'package:bapp/screens/business/toolkit/store_name_address.dart';
import 'package:bapp/screens/business/toolkit/submit_for_verification.dart';
import 'package:bapp/screens/business/toolkit/timings.dart';
import 'package:bapp/stores/cloud_store.dart';
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
      title: "Choose from the best",
      description: "Choose from our handpicked service providers\naround you.",
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
        title: "Best in \nSavings",
        icon: FeatherIcons.package,
        ref: "",
        cardColor: CardsColor.next()),
    Featured(
        title: "Top \n Rated",
        icon: FeatherIcons.package,
        ref: "",
        cardColor: CardsColor.next()),
    Featured(
        title: "Only On Bapp",
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
      /*MenuItem(
        name: "Help us improve",
        icon: FeatherIcons.user,
        kind: MenuItemKind.helpUsImprove,
        showWhenAuthStatusIs: AuthStatus.values,
        showWhenUserTypeIs: UserType.values,
        showWhenAlterEgoIs: UserType.values,
      ),*/
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
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Offers & Promotions",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Vouchers",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Loyalty Program",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Sell Merchandise",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Manage Campaigns",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Booking Channel",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
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
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Customer Support",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Customer Feedback",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
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
          onClickRoute: BusinessManageStaffScreen(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Leaves",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Salaries",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
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
          onClickRoute: SizedBox(),
          enabled: false,
        ),
        BusinessExpandingTile(
          name: "Merchandise",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: SizedBox(),
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
          onClickRoute: BusinessStoreNameAddress(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Manage Media",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: BusinessManageMediaScreen(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Products & Pricing",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: BusinessProductsPricingScreen(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Contact Details",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: BusinessManageContactDetailsScreen(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Business Hours",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: BusinessManageWorkingHoursScreen(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Holidays",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: BusinessManageHolidaysScreen(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Manage Branches",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: BusinessManageBranchesScreen(),
          enabled: true,
        ),
        BusinessExpandingTile(
          name: "Business Verification",
          iconData: FeatherIcons.alertOctagon,
          onClickRoute: BusinessSubmitBranchForVerificationScreen(),
          enabled: true,
        ),
      ],
    ),
  ];
}

class RatingConfig {
  static const reviewLabel = "Would you like share a short review?";
  static const reviewHint = "Write your review here.";

  static String getThankYouForTheReviewForBooking(BusinessBooking booking){
    return "Thank you for the review of "+ booking.branch.name.value+", looking forawrd to serve you better.";
  }

  static String getFirstSentenceForRating(BookingRating rating) {
    switch (rating.type) {
      case BookingRatingType.overAll:
        {
          return "How was your overall experience at";
        }
      case BookingRatingType.staff:
        {
          return "How was the service provided by";
        }
      case BookingRatingType.facilities:
        {
          return "How was the facilities at";
        }
    }
  }

  static String getSecondSentenceForRatingWithBooking(
      BookingRating rating, BusinessBooking booking) {
    switch (rating.type) {
      case BookingRatingType.overAll:
      case BookingRatingType.facilities:
        {
          return booking.branch.name.value;
        }
      case BookingRatingType.staff:
        {
          return booking.staff.name;
        }
    }
  }
}
