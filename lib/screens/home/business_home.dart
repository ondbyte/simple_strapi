import 'package:bapp/config/config.dart';
import 'package:bapp/screens/business/tabs/business_bookings_tab.dart';
import 'package:bapp/screens/business/tabs/business_dashboard_tab.dart';
import 'package:bapp/screens/business/tabs/business_toolkit_tab.dart';
import 'package:bapp/screens/init/initiating_widget.dart';
import 'package:bapp/stores/booking_flow.dart';
import 'package:bapp/widgets/business/business_branch_switch.dart';
import 'package:bapp/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../stores/business_store.dart';

class BusinessHome extends StatefulWidget {
  @override
  _BusinessHomeState createState() => _BusinessHomeState();
}

class _BusinessHomeState extends State<BusinessHome> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      initializer: () async {
        await Provider.of<BookingFlow>(context, listen: false)
            .getBranchBookings();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: BusinessBranchSwitchWidget(),
        ),
        endDrawer: Menu(),
        body: Consumer<BusinessStore>(
          builder: (_, businessStore, __) {
            return Observer(
              builder: (_) {
                if (businessStore.business == null) {
                  return Center(
                    child: Text(
                      "No business is selected",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return IndexedStack(
                  children: [
                    BusinessDashboardTab(),
                    BusinessBookingsTab(),
                    BusinessToolkitTab(),
                    SizedBox(),
                  ],
                  index: _selectedPage,
                );
              },
            );
          },
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
      ),
    );
  }
}
