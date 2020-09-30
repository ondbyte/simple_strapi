import 'package:bapp/config/config.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/bookings_tab.dart';
import 'package:bapp/widgets/discover_tab.dart';
import 'package:bapp/widgets/favorites_tab.dart';
import 'package:bapp/widgets/menu.dart';
import 'package:bapp/widgets/store_provider.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
        title: _getPageTitle(_selectedPage),
        centerTitle: false,
      ),
      endDrawer: Menu(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: IndexedStack(
          children: [
            DiscoverTab(),
            BookingsTab(),
            FavoritesTab(),
            Container(),
          ],
          index: _selectedPage,
        ),
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
          ...HomeScreenTabsConfig.tabs.map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.icon),
              title: Text(e.name),
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
          return Row(
            children: [
              Icon(
                FeatherIcons.mapPin,
                color: Theme.of(context).primaryColorDark,
              ),
              SizedBox(
                width: 10,
              ),
              StoreProvider<CloudStore>(
                store: context.watch<CloudStore>(),
                builder: (_, cloudStore) {
                  return Observer(
                    builder: (_) {
                      return Text(
                        cloudStore.myLocation.locality,
                        style: Theme.of(context).textTheme.headline3,
                      );
                    },
                  );
                },
              ),
            ],
          );
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
