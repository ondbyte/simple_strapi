import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/screens/business/tabs/business_bookings_tab.dart';
import 'package:bapp/screens/business/tabs/business_dashboard_tab.dart';
import 'package:bapp/screens/business/tabs/business_toolkit_tab.dart';
import 'package:bapp/screens/home/customer_home.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/screens/tabs/updates_tab.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/super_strapi/my_strapi/defaultDataX.dart';
import 'package:bapp/super_strapi/my_strapi/userX.dart';
import 'package:bapp/super_strapi/super_strapi.dart';
import 'package:bapp/widgets/business/business_branch_switch.dart';
import 'package:bapp/widgets/app/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../stores/business_store.dart';
import 'package:super_strapi_generated/super_strapi_generated.dart';

class BusinessHome extends StatefulWidget {
  final UserRole? forRole;

  const BusinessHome({Key? key, this.forRole}) : super(key: key);
  @override
  _BusinessHomeState createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHome> {
  int _selectedPage = 0;
  final _tabs = <Widget>[];

  @override
  Widget build(BuildContext context) {
    _tabs.clear();
    _tabs.addAll([
      BusinessDashboardTab(),
      BusinessBookingsTab(),
      if (_shouldShowToolkit) BusinessToolkitTab(),
      UpdatesTab(),
    ]);
    return Builder(builder: (_) {
      return Scaffold(
        appBar: _selectedPage != _tabs.length - 1
            ? AppBar(
                automaticallyImplyLeading: false,
                title: BusinessBranchSwitchWidget(),
              )
            : null,
        endDrawer: Menu(),
        body: Builder(
          builder: (_) {
            return FutureBuilder(
              future: DefaultDataX.i.getValue("selectedBusiness"),
              builder: (_, snap) {
                final id = snap.data ?? "";
                final business = UserX.i
                    .user()
                    ?.partner
                    ?.businesses
                    ?.firstWhere((element) => element.id == id);
                if (business is! Business) {
                  return Center(
                    child: Text(
                      "No business is selected",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return IndexedStack(
                  children: _tabs,
                  index: _selectedPage,
                );
              },
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          // selectedFontSize: 14,
          onTap: (i) {},
          currentIndex: _selectedPage,
          items: [..._filterBottomNavigations()],
        ),
      );
    });
  }

  List<BottomNavigationBarItem> _filterBottomNavigations() {
    final tabs = BusinessHomeScreenTabsConfig.tabs;
    tabs.removeWhere((element) =>
        element.name.toLowerCase() == "toolkit" && !_shouldShowToolkit);
    return tabs
        .map(
          (e) => BottomNavigationBarItem(
            icon: e.name == "Updates"
                ? PendingUpdatesIcon(child: Icon(e.icon))
                : Icon(e.icon),
            label: e.name,
          ),
        )
        .toList();
  }

  bool get _shouldShowToolkit =>
      widget.forRole == UserRole.partner || widget.forRole == UserRole.manager;
}
