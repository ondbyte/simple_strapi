import 'dart:async';

import 'package:bapp/config/config.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/screens/tabs/bookings_tab.dart';
import 'package:bapp/screens/tabs/discover_tab.dart';
import 'package:bapp/screens/tabs/favorites_tab.dart';
import 'package:bapp/screens/tabs/updates_tab.dart';
import 'package:bapp/stores/updates_store.dart';
import 'package:bapp/widgets/app/bapp_navigator_widget.dart';
import 'package:bapp/widgets/location_switch.dart';
import 'package:bapp/widgets/app/menu.dart';
import 'package:bapp/widgets/size_provider.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  final int? tab;

  const CustomerHome({Key? key, this.tab}) : super(key: key);
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _selectedPage = 0;
  late final tabs = [
    DiscoverTab(),
    BookingsTab(),
    FavoritesTab(),
    UpdatesTab(
      keepAlive: () => mounted,
    ),
  ];

  @override
  void initState() {
    _selectedPage = widget.tab ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _getPageTitle(
          _selectedPage,
        ),
        centerTitle: false,
      ),
      endDrawer: Menu(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: IndexedStack(
          index: _selectedPage,
          children: tabs,
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
              icon: e.name == "Updates"
                  ? PendingUpdatesIcon(
                      child: Icon(e.icon),
                    )
                  : Icon(e.icon),
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
          return LocationSwitch();
        }
      case 1:
        {
          return Text(
            "Your Bookings",
            style: Theme.of(context).textTheme.headline1,
          );
        }
      case 2:
        {
          return Text(
            "Your Favorites",
            style: Theme.of(context).textTheme.headline1,
          );
        }
      case 3:
        {
          return Text(
            "Updates & Notifications",
            style: Theme.of(context).textTheme.headline1,
          );
        }
      default:
        {
          return SizedBox();
        }
    }
  }
}

class PendingUpdatesIcon extends StatefulWidget {
  final Widget? child;

  const PendingUpdatesIcon({Key? key, this.child}) : super(key: key);
  @override
  _PendingUpdatesIconState createState() => _PendingUpdatesIconState();
}

class _PendingUpdatesIconState extends State<PendingUpdatesIcon> {
  Size? _childSize;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child is Widget)
          OnChildSizedWidget(
            child: widget.child as Widget,
            onChildSize: (s) {
              if (mounted) {
                setState(() {
                  _childSize = s;
                });
              }
            },
          ),
        if (_childSize != null)
          Builder(
            builder: (_) {
              final totalUpdates = 2;
              return totalUpdates > 0
                  ? SizedBox.fromSize(
                      size: _childSize,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: _childSize?.width ?? 0 / 2,
                          height: _childSize?.width ?? 0 / 2,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.redAccent),
                          alignment: Alignment.center,
                          child: Text(
                            "${totalUpdates < 10 ? totalUpdates : 9}",
                            style: Theme.of(context).textTheme.caption?.apply(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox();
            },
          )
      ],
    );
  }
}
