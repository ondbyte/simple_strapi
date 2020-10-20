import 'package:bapp/config/config.dart';
import 'package:bapp/config/config_data_types.dart';
import 'package:bapp/config/constants.dart';
import 'package:bapp/route_manager.dart';
import 'package:bapp/stores/auth_store.dart';
import 'package:bapp/stores/cloud_store.dart';
import 'package:bapp/widgets/bapp_bar.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
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
          leading: SizedBox(),
          flexibleSpace: BappBar(
            leading: "Menu",
            trailing: IconButton(
              icon: Icon(FeatherIcons.xCircle),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            ..._getMenuItems(context)
          ],
        ),
      ),
    );
  }

  List<Widget> _getMenuItems(BuildContext context) {
    var ws = <Widget>[];
    kFilteredMenuItems.forEach(
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
            await Provider.of<AuthStore>(context, listen: false).signOut();
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/", (route) => false);
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
