import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/helpers/helper.dart';
import 'package:bapp/main.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/stores/themestore.dart';
import 'package:event_bus/event_bus.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Menu"),
          actions: [
            IconButton(
              icon: Icon(FeatherIcons.xCircle),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
        body: Consumer<CloudStore>(
          builder: (_, cloudStore, __) {
            return Observer(
              builder: (_) {
                final items = Helper.filterMenuItems(
                    cloudStore.bappUser.userType.value,
                    cloudStore.bappUser.alterEgo.value,
                    cloudStore.status);
                return ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    ..._getMenuItems(context, items),
                    Consumer<ThemeStore>(
                      builder: (_, themeStore, __) {
                        return Observer(
                          builder: (_) {
                            return ListTile(
                              title: Text("Dark mode"),
                              trailing: Switch(
                                value: themeStore.brightness == Brightness.dark,
                                onChanged: (b) {
                                  if (b) {
                                    themeStore.brightness = Brightness.dark;
                                  } else {
                                    themeStore.brightness = Brightness.light;
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _getMenuItems(BuildContext context, List<List<MenuItem>> items) {
    var ws = <Widget>[];
    items.forEach(
      (element) {
        element.forEach(
          (e) {
            ws.add(
              ListTile(
                title: Text(
                  e.name,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                trailing: Icon(e.icon),
                onTap: () {
                  _menuItemSelected(e.kind, context);
                },
              ),
            );
          },
        );
        ws.add(Divider());
      },
    );
    if (ws.isNotEmpty) ws.removeLast();
    return ws;
  }

  void _menuItemSelected(MenuItemKind kind, BuildContext context) {
    switch (kind) {
      case MenuItemKind.yourProfile:
        {
          Navigator.of(context)
              .popAndPushNamed(RouteManager.createProfileScreen);
          break;
        }
      case MenuItemKind.settings:
        {
          Navigator.of(context).popAndPushNamed(RouteManager.settingsScreen);
          break;
        }
      case MenuItemKind.rateTheApp:
        {
          Navigator.of(context).popAndPushNamed(RouteManager.rateMyAppScreen);
          break;
        }
      case MenuItemKind.helpUsImprove:
        {
          Navigator.of(context)
              .popAndPushNamed(RouteManager.helpUsImproveScreen);
          break;
        }
      case MenuItemKind.referABusiness:
        {
          Navigator.of(context)
              .popAndPushNamed(RouteManager.selectBusinessCategoryScreen);
          break;
        }
      case MenuItemKind.logOut:
        {
          () async {
            await Provider.of<CloudStore>(context, listen: false).signOut();
            Provider.of<EventBus>(context, listen: false)
                .fire(AppEvents.reboot);
          }();
          break;
        }
      case MenuItemKind.logIn:
        {
          Navigator.of(context).popAndPushNamed(RouteManager.loginScreen);
          break;
        }
      case MenuItemKind.switchTosShopping:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToBusiness:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToSales:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToManager:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
      case MenuItemKind.switchToSudoUser:
        {
          Provider.of<CloudStore>(context, listen: false)
              .switchUserType(context);
          break;
        }
    }
  }
}
