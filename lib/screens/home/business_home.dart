import 'package:bapp/config/config.dart';
import 'package:bapp/widgets/business/business_branch_switch.dart';
import 'package:bapp/widgets/business/business_dashboard_tab.dart';
import 'package:bapp/widgets/business/business_toolkit_tab.dart';
import 'package:bapp/widgets/menu.dart';
import 'package:bapp/widgets/tabs/business/business_bookings_tab.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: BusinessBranchSwitchWidget(),
      ),
      endDrawer: Menu(),
      body: IndexedStack(
        children: [
          BusinessDashboardTab(),
          BusinessBookingsTab(),
          BusinessToolkitTab(),
          SizedBox(),
        ],
        index: _selectedPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // selectedFontSize: 14,
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
