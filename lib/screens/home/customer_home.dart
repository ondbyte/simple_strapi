import 'package:bapp/config/config.dart';
import 'package:bapp/screens/tabs/bookings_tab.dart';
import 'package:bapp/screens/tabs/discover_tab.dart';
import 'package:bapp/screens/tabs/favorites_tab.dart';
import 'package:bapp/screens/tabs/updates_tab.dart';
import 'package:bapp/widgets/location_label.dart';
import 'package:bapp/widgets/app/menu.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _getPageTitle(_selectedPage),
        centerTitle: false,
      ),
      endDrawer: Menu(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: IndexedStack(
          children: [
            DiscoverTab(),
            BookingsTab(),
            FavoritesTab(),
            UpdatesTab(),
          ],
          index: _selectedPage,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // selectedFontSize: 16,
        onTap: (i) {
          setState(() {
            _selectedPage = i;
          });
        },
        currentIndex: _selectedPage,
        items: [
          ...HomeScreenTabsConfig.tabs.map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              label: e.name,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getPageTitle(int i) {
    switch (i) {
      case 0:
        {
          return LocationLabelWidget();
        }
      case 1:
        {
          return Text("Your Bookings");
        }
      case 2:
        {
          return Text("Your Favorites");
        }
      case 3:
        {
          return Text("Updates for you");
        }
      default:
        {
          return SizedBox();
        }
    }
  }
}
