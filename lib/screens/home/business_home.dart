import 'package:bapp/config/config.dart';
import 'package:bapp/widgets/bapp_bar.dart';
import 'package:bapp/widgets/bookings_tab.dart';
import 'package:bapp/widgets/business/business_dashboard_tab.dart';
import 'package:bapp/widgets/business/business_manage_tab.dart';
import 'package:bapp/widgets/discover_tab.dart';
import 'package:bapp/widgets/favorites_tab.dart';
import 'package:bapp/widgets/location_label.dart';
import 'package:bapp/widgets/menu.dart';
import 'package:bapp/widgets/updates_tab.dart';
import 'package:flutter/material.dart';

class BusinessHome extends StatefulWidget {
  @override
  _BusinessHomeState createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHome> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Menu(),
      body: IndexedStack(
        children: [
          BusinessDashboardTab(),
          SizedBox(),
          BusinessManageTab(),
          SizedBox(),
        ],
        index: _selectedPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedFontSize: 16,
        onTap: (i) {
          setState(() {
            _selectedPage = i;
          });
        },
        currentIndex: _selectedPage,
        items: [
          ...BusinessHomeScreenTabsConfig.tabs.map(
                (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              label: e.name,
            ),
          ),
        ],
      ),
    );
  }
}
