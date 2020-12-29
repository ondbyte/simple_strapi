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
import 'package:bapp/widgets/business/business_branch_switch.dart';
import 'package:bapp/widgets/app/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

import '../../stores/business_store.dart';

class BusinessHome extends StatefulWidget {
  final UserType forRole;

  const BusinessHome({Key key, this.forRole}) : super(key: key);
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
    return Consumer3<BusinessStore, BookingFlow, CloudStore>(
        builder: (_, businessStore, flow, cloudStore, __) {
      return InitWidget(
        initializer: () async {
          if (businessStore.business == null) {
            businessStore.getMyBusiness();
          }
          flow.getBranchBookings();
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _selectedPage != _tabs.length-1
                ? BusinessBranchSwitchWidget()
                : SizedBox(),
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
            onTap: (i) {
              setState(() {
                _selectedPage = i;
              });
            },
            currentIndex: _selectedPage,
            items: [..._filterBottomNavigations()],
          ),
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
            icon: e.name=="Updates"?UpdatesIcon(child:Icon(e.icon)):Icon(e.icon),
            label: e.name,
          ),
        )
        .toList();
  }

  bool get _shouldShowToolkit =>
      widget.forRole == UserType.businessOwner ||
      widget.forRole == UserType.businessManager;
}
